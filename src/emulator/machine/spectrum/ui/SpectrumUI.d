module emulator.machine.spectrum.ui.SpectrumUI;

import emulator.all;
import emulator.machine.spectrum.all;
import vulkan.all;

final class SpectrumUI : VulkanApplication {
    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    FPS fps;
    Camera2D camera;
    VkClearValue bgColour;

    Spectrum spectrum;
    CodeUI codeUI;
    MemoryUI memoryUI;
    RegsUI regsUI;
    ScreenUI screenUI;
    FileDialog fileDialog;

    this(Spectrum spectrum) {
        this.spectrum = spectrum;

        enum NAME = "Spectrum Emulator";
        WindowProperties wprops = {
            width:          1400,
            height:         900,
            fullscreen:     false,
            vsync:          false,
            title:          NAME,
            icon:           "/pvmoore/_assets/icons/3dshapes.png",
            showWindow:     false,
            frameBuffers:   3
        };
        VulkanProperties vprops = {
            appName: NAME,
            imgui: {
                enabled: true,
                configFlags:
                    ImGuiConfigFlags_NoMouseCursorChange |
                    ImGuiConfigFlags_DockingEnable |
                    ImGuiConfigFlags_ViewportsEnable,
                fontPaths: [
                    "/pvmoore/_assets/fonts/Roboto-Regular.ttf",
                    "/pvmoore/_assets/fonts/RobotoCondensed-Regular.ttf"
                ],
                fontSizes: [
                    22,
                    22]
            }
        };

		this.vk = new Vulkan(this, wprops, vprops);
        vk.initialise();
        this.log("screen = %s", vk.windowSize);

        import std : fromStringz, format;
        import core.cpuid: processor;
        string gpuName = cast(string)vk.properties.deviceName.ptr.fromStringz;
        vk.setWindowTitle(NAME ~ " :: %s, %s".format(gpuName, processor()));

        vk.showWindow();
    }
    override void destroy() {
	    if(!vk) return;
	    if(device) {
	        vkDeviceWaitIdle(device);

            if(context) context.dumpMemory();

            if(fps) fps.destroy();
            if(screenUI) screenUI.destroy();

            if(renderPass) device.destroyRenderPass(renderPass);
            if(context) context.destroy();
	    }
		vk.destroy();
    }
    override void run() {
        vk.mainLoop();
    }
    override VkRenderPass getRenderPass(VkDevice device) {
        createRenderPass(device);
        return renderPass;
    }
    override void deviceReady(VkDevice device, PerFrameResource[] frameResources) {
        this.device = device;
        initScene();
    }
    void update(Frame frame) {
        fps.beforeRenderPass(frame, vk.getFPS);
        screenUI.update(frame);
    }
    override void render(Frame frame) {
        auto res = frame.resource;
	    auto b = res.adhocCB;
	    b.beginOneTimeSubmit();

        update(frame);

        // begin the render pass
        b.beginRenderPass(
            renderPass,
            res.frameBuffer,
            toVkRect2D(0,0, vk.windowSize.toVkExtent2D),
            [ bgColour ],
            VK_SUBPASS_CONTENTS_INLINE
        );

        renderImguiWindows(frame);
        fps.insideRenderPass(frame);

        b.endRenderPass();
        b.end();

        /// Submit our render buffer
        vk.getGraphicsQueue().submit(
            [b],
            [res.imageAvailable],
            [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT],
            [res.renderFinished],  // signal semaphores
            res.fence              // fence
        );
    }
private:
    void initScene() {
        this.camera = Camera2D.forVulkan(vk.windowSize);

        auto mem = new MemoryAllocator(vk);

        auto maxLocal =
            mem.builder(0)
                .withAll(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
                .withoutAll(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT)
                .maxHeapSize();

        this.log("Max local memory = %s MBs", maxLocal / 1.MB);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("Spectrum_Local", 256.MB))
          //.withMemory(MemID.SHARED, mem.allocStdShared("Spectrum_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("Spectrum_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, 32.MB);

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        this.fps = new FPS(context, "dejavusansmono-bold").size(22);

        this.bgColour = clearColour(0.0f,0,0,1);

        this.codeUI = new CodeUI(spectrum);
        this.memoryUI = new MemoryUI(context, spectrum);
        this.regsUI = new RegsUI(context, spectrum);
        this.screenUI = new ScreenUI(context, spectrum);
        this.fileDialog = new FileDialog(context);

        initImguiStyle();
    }
    void createRenderPass(VkDevice device) {
        this.log("Creating render pass");
        auto colorAttachment    = attachmentDescription(vk.swapchain.colorFormat);
        auto colorAttachmentRef = attachmentReference(0);

        auto subpass = subpassDescription((info) {
            info.colorAttachmentCount = 1;
            info.pColorAttachments    = &colorAttachmentRef;
        });

        auto dependency = subpassDependency();

        renderPass = .createRenderPass(
            device,
            [colorAttachment],
            [subpass],
            subpassDependency2()//[dependency]
        );
    }
    void initImguiStyle() {
        auto viewport = igGetMainViewport();
        auto style = igGetStyle();

        auto windowPos = viewport.Pos;
        auto windowSize = viewport.Size;
        auto workSize = viewport.WorkSize;

        style.ScrollbarSize = 24;
        style.ScrollbarRounding = 5;
        style.GrabMinSize = 20;
        //style.FramePadding = ImVec2(10,10);
        //style.ItemSpacing = ImVec2(5,0);
        style.WindowTitleAlign = ImVec2(0.0, 0.5);

        //style.Colors[ImGuiCol_ScrollbarGrab] = ImVec4(1,1,0,1);
    }
    void renderImguiWindows(Frame frame) {
        vk.imguiRenderStart(frame);

        igSetNextWindowPos(ImVec2(0,0), ImGuiCond_Always, ImVec2(0.0, 0.0));
        igSetNextWindowSize(ImVec2(-1, -1), ImGuiCond_Always);

        auto flags = ImGuiWindowFlags_NoTitleBar
            | ImGuiWindowFlags_NoSavedSettings
            | ImGuiWindowFlags_NoDocking
            | ImGuiWindowFlags_NoMove
            | ImGuiWindowFlags_NoResize
            | ImGuiWindowFlags_NoBackground
            | ImGuiWindowFlags_MenuBar;

        //igPushStyleColorVec4(ImGuiCol_WindowBg, ImVec4(0.4, 0.2, 0.4, 0.2));

        if(igBegin("Menu", null, flags)) {

            codeUI.render(frame);
            memoryUI.render(frame);
            regsUI.render(frame);
            screenUI.render(frame);

            renderMenu(frame);
        }
        igEnd();

        //igPopStyleColor(1);

        vk.imguiRenderEnd(frame);
    }
    void renderMenu(Frame frame) {
        if(igBeginMenuBar()) {

            if(igBeginMenu("File", true)) {
                if(igMenuItem("Exit", "Ctrl+X"))  {

                }
                igEndMenu();
            }

            if(igBeginMenu("Machine", true)) {
                if(igMenuItem("Reset")) {
                    spectrum.reset();
                }
                igSeparator();
                // if(igMenuItem("Load ROM")) {
                //     string filename = fileDialog.open(".", "*.tap\0*.tzx");
                //     if(filename) {
                //         // load ROM
                //     }
                // }
                if(igMenuItem("Load Tape")) {
                    string filename = fileDialog.open(".", "*.tap\0*.tzx");
                    if(filename) {
                        spectrum.loadTape(filename);
                    }
                }
                if(igMenuItem("Load Snapshot")) {
                    string filename = fileDialog.open(".", "*.sna\0*.z80");
                    if(filename) {
                        spectrum.loadSnapshot(filename);
                    }
                }
                if(igMenuItem("Load Asm")) {
                    string filename = fileDialog.open(".", "*.asm");
                    if(filename) {
                        loadAsm(filename);
                    }
                }
                igSeparator();
                if(igMenuItem("Save Snapshot")) {
                    string filename = fileDialog.save(".");
                    if(filename) {
                        spectrum.saveSnapshot(filename);
                    }
                }

                igEndMenu();
            }

            if(igBeginMenu("Help", true)) {
                if(igMenuItem("About", "Alt+A")) {

                }
                igEndMenu();
            }

            igEndMenuBar();
        }
    }
    void loadAsm(string filename) {
        import std.file : read;

        this.log("Loading asm file: %s", filename);
        auto text = cast(string)read(filename);
        auto assembler = createZ80Assembler();
        auto lines = assembler.encode(text);
        log("lines = %s %s", lines, lines.length);

        auto startAddr = lines.first().address;
        auto endAddr = lines.last().address;
        auto data = lines.extractCode();

        this.log("[%04x] -> [%04x] len = %s", startAddr, endAddr, data.length);

        // Update CodeUI
        codeUI.addLines(lines);
        codeUI.scrollToAddress(startAddr);

        // Write the code to memory
        spectrum.writeToMemory(startAddr.as!ushort, data);
        spectrum.getCpu().state.PC = startAddr.as!ushort;
    }
}