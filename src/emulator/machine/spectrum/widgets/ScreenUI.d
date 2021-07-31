module emulator.machine.spectrum.widgets.ScreenUI;

import emulator.machine.spectrum.all;
import vulkan.all;

/**
 *  Display Spectrum screen
 *      Pixel data:
 *          - 32x24 bytes
 *          - 256x192 pixels
 *
 *      Attribute data:
 *          - 32x24 bytes
 *
 * | 4000 | 57ff | Screen Pixel Memory     | 6144 (0x1800) bytes
 * | 5800 | 5aff | Screen attribute Memory | 768 (0x300) bytes
 */
final class ScreenUI {
private:
    enum WIDTH  = 532;  // 256*2 = 512 + 20 = 532
    enum HEIGHT = 404;  // 192*2 = 384 + 20 = 404
    Spectrum spectrum;
    Memory memory;
public:
    this(Spectrum spectrum) {
        this.spectrum = spectrum;
        this.memory = spectrum.getMemory();
    }
    void render(Frame frame) {
        igSetNextWindowPos(ImVec2(10,35), ImGuiCond_Once, ImVec2(0.0, 0.0));
        igSetNextWindowSize(ImVec2(WIDTH, HEIGHT), ImGuiCond_Once);

        auto windowFlags = ImGuiWindowFlags_None
            | ImGuiWindowFlags_NoSavedSettings
            //| ImGuiWindowFlags_NoTitleBar
            //| ImGuiWindowFlags_NoCollapse
            //| ImGuiWindowFlags_NoResize
            //| ImGuiWindowFlags_NoBackground
            //| ImGuiWindowFlags_NoMove;
            ;

        if(igBegin("Screen", null, windowFlags)) {


        }
        igEnd();
    }
}
