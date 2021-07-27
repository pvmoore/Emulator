module emulator.machine.spectrum.widgets.PortsUI;

import vulkan.gui;
import emulator.machine.spectrum.all;

final class PortsUI {
private:
    enum WIDTH = 720, HEIGHT = 435;
    @Borrowed Spectrum spectrum;
    @Borrowed VulkanContext context;
    @Borrowed Z80Ports ports;
    MemoryEditor portsEditor;
    bool open = true;
public:
    this(VulkanContext context, Spectrum spectrum) {
        this.context = context;
        this.spectrum = spectrum;
        this.ports = spectrum.getPorts();

        this.portsEditor = new MemoryEditor()
            .withFont(context.vk.getImguiFont(1));

        portsEditor.ReadFn = (ptr, offset) {
            ubyte value;
            ports.read(offset.as!uint, value);
            return value;
        };
        portsEditor.WriteFn = (ptr, offset, value) {
            ports.write(offset.as!uint, value.as!ubyte);
        };
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
            //| ImGuiWindowFlags_NoMove;
            ;

        if(igBegin("Ports", &open, windowFlags)) {

            portsEditor.DrawContents(null, 256, 0);

        }
        igEnd();
    }
}