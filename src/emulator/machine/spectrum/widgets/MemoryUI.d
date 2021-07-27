module emulator.machine.spectrum.widgets.MemoryUI;

import emulator.machine.spectrum.all;
import vulkan.all;

/**
 *
 *
 *
 */
final class MemoryUI  {
private:
    enum WIDTH = 720, HEIGHT = 435;
    @Borrowed Spectrum spectrum;
    @Borrowed VulkanContext context;
    @Borrowed Memory memory;
    MemoryEditor ramEditor;
    bool open = true;
public:

    this(VulkanContext context, Spectrum spectrum) {
        this.context = context;
        this.spectrum = spectrum;
        this.memory = spectrum.getMemory();

        import std;
        foreach(i; 0..65536) {
            spectrum.getMemory().write(i, (uniform01()*255.0).as!ubyte);
        }

        this.ramEditor = new MemoryEditor()
            .withFont(context.vk.getImguiFont(1));

        ramEditor.ReadFn = (ptr, offset) {
            ubyte value;
            memory.read(offset.as!uint, value);
            return value;
        };
        ramEditor.WriteFn = (ptr, offset, value) {
            memory.write(offset.as!uint, value.as!ubyte);
        };
        ramEditor.PreviewDataType = ImGuiDataType_U16;
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

        if(igBegin("RAM", &open, windowFlags)) {

            ramEditor.DrawContents(null, 65536, 0);


        }
        igEnd();
    }
}