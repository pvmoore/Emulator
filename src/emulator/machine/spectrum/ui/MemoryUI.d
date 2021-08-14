module emulator.machine.spectrum.ui.MemoryUI;

import emulator.machine.spectrum.all;
import vulkan.all;

/**
 *
 *
 *
 */
final class MemoryUI  {
private:
    enum WIDTH = 745, HEIGHT = 430;
    @Borrowed Spectrum spectrum;
    @Borrowed VulkanContext context;
    @Borrowed Memory memory;
    @Borrowed Z80 cpu;
    @Borrowed Z80Ports ports;
    @Borrowed Z80Pins pins;
    MemoryEditor ramEditor;
    MemoryEditor portsEditor;
public:

    this(VulkanContext context, Spectrum spectrum) {
        this.context = context;
        this.spectrum = spectrum;
        this.cpu = spectrum.getCpu();
        this.memory = spectrum.getMemory();
        this.ports = spectrum.getPorts();
        this.pins = cpu.pins;

        this.ramEditor = new MemoryEditor()
            .withFont(context.vk.getImguiFont(1));
        this.portsEditor = new MemoryEditor()
            .withFont(context.vk.getImguiFont(1));

        ramEditor.ReadFn = (ptr, offset) {
            ubyte value;
            memory.read(offset.as!uint, value);
            return value;
        };
        portsEditor.ReadFn = (ptr, offset) {
            ubyte value;
            ports.read(offset.as!uint, value);
            return value;
        };

        ramEditor.WriteFn = (ptr, offset, value) {
            memory.write(offset.as!uint, value.as!ubyte);
        };
        portsEditor.WriteFn = (ptr, offset, value) {
            ports.write(offset.as!uint, value.as!ubyte);
        };

        ramEditor.PreviewDataType = ImGuiDataType_U8;
        portsEditor.PreviewDataType = ImGuiDataType_U8;
    }
    void render(Frame frame) {

        igSetNextWindowPos(ImVec2(10,890), ImGuiCond_Once, ImVec2(0.0, 1.0));
        igSetNextWindowSize(ImVec2(WIDTH, HEIGHT), ImGuiCond_Once);

        auto windowFlags = ImGuiWindowFlags_None
            | ImGuiWindowFlags_NoSavedSettings
            //| ImGuiWindowFlags_NoTitleBar
            //| ImGuiWindowFlags_NoCollapse
            //| ImGuiWindowFlags_NoResize
            //| ImGuiWindowFlags_NoBackground
            //| ImGuiWindowFlags_NoMove;
            ;

        if(igBegin("IO", null, windowFlags)) {

            auto options = ImGuiTabItemFlags_None
               // | ImGuiTabBarFlags_Reorderable
                ;

            if (igBeginTabBar("MyTabBar", options)) {

                auto flags = ImGuiTabItemFlags_None;
                    //ImGuiTabItemFlags_UnsavedDocument;
                    //| ImGuiTabItemFlags_SetSelected;

                if (igBeginTabItem("RAM", null, flags))
                {
                    ramEditor.DrawContents(null, 65536, 0);
                    igEndTabItem();
                }
                if (igBeginTabItem("Ports", null, ImGuiTabItemFlags_None)) {
                    pins.setIOReq(true);
                    portsEditor.DrawContents(null, 256, 0);
                    pins.setIOReq(false);
                    igEndTabItem();
                }

                igEndTabBar();
            }

        }
        igEnd();
    }
}