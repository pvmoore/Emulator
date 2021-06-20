module emulator.machine.spectrum.widgets.SpectrumUI;

import emulator.all;
import emulator.machine.spectrum.all;
import vulkan.all;
import vulkan.gui;

final class SpectrumUI : VulkanApplication {
    Vulkan vk;
	VkDevice device;
    VulkanContext context;
    VkRenderPass renderPass;

    FPS fps;
    GUI gui;
    Camera2D camera;
    VkClearValue bgColour;

    Spectrum spectrum;
    CodeUI codeUI;
    MemoryUI memoryUI;
    PortsUI portsUI;
    RegsUI regsUI;
    ScreenUI screenUI;

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
            appName: NAME
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

            if(gui) gui.destroy();

            if(fps) fps.destroy();
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
        gui.beforeRenderPass(frame);
        fps.beforeRenderPass(frame, vk.getFPS);
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
            VSubpassContents.INLINE
            //VSubpassContents.SECONDARY_COMMAND_BUFFERS
        );

        gui.insideRenderPass(frame);
        fps.insideRenderPass(frame);

        b.endRenderPass();
        b.end();

        /// Submit our render buffer
        vk.getGraphicsQueue().submit(
            [b],
            [res.imageAvailable],
            [VPipelineStage.COLOR_ATTACHMENT_OUTPUT],
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
                .withAll(VMemoryProperty.DEVICE_LOCAL)
                .withoutAll(VMemoryProperty.HOST_VISIBLE)
                .maxHeapSize();

        this.log("Max local memory = %s MBs", maxLocal / 1.MB);

        this.context = new VulkanContext(vk)
            .withMemory(MemID.LOCAL, mem.allocStdDeviceLocal("Spectrum_Local", 256.MB))
          //.withMemory(MemID.SHARED, mem.allocStdShared("Spectrum_Shared", 128.MB))
            .withMemory(MemID.STAGING, mem.allocStdStagingUpload("Spectrum_Staging", 32.MB));

        context.withBuffer(MemID.LOCAL, BufID.VERTEX, VBufferUsage.VERTEX | VBufferUsage.TRANSFER_DST, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.INDEX, VBufferUsage.INDEX | VBufferUsage.TRANSFER_DST, 32.MB)
               .withBuffer(MemID.LOCAL, BufID.UNIFORM, VBufferUsage.UNIFORM | VBufferUsage.TRANSFER_DST, 1.MB)
               .withBuffer(MemID.STAGING, BufID.STAGING, VBufferUsage.TRANSFER_SRC, 32.MB);

        context.withFonts("resources/fonts/")
               .withImages("resources/images/")
               .withRenderPass(renderPass);

        this.log("shared mem available = %s", context.hasMemory(MemID.SHARED));

        this.log("%s", context);

        this.fps = new FPS(context, "dejavusansmono-bold").size(22);

        this.bgColour = clearColour(0.0f,0,0,1);

        this.gui = new GUI(context);
        gui.camera(camera);

        this.codeUI = new CodeUI(spectrum);
        this.memoryUI = new MemoryUI(spectrum);
        this.portsUI = new PortsUI(spectrum);
        this.regsUI = new RegsUI(spectrum);
        this.screenUI = new ScreenUI(spectrum);

        gui.getStage()
           .add(codeUI)
           .add(memoryUI)
           .add(regsUI)
           .add(portsUI)
           .add(screenUI);
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
}