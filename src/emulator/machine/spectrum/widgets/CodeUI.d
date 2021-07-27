module emulator.machine.spectrum.widgets.CodeUI;

import emulator.machine.spectrum.all;
import vulkan.all;

final class CodeUI {
private:
    enum WIDTH = 620, HEIGHT = 435;
    Spectrum spectrum;
public:
    this(Spectrum spectrum) {
        this.spectrum = spectrum;
    }
    void render(Frame frame) {

        igSetNextWindowPos(ImVec2(1390,30), ImGuiCond_Once, ImVec2(1.0, 0.0));
        igSetNextWindowSize(ImVec2(WIDTH, HEIGHT), ImGuiCond_Once);

        auto windowFlags = ImGuiWindowFlags_None
            | ImGuiWindowFlags_NoSavedSettings
            //| ImGuiWindowFlags_NoTitleBar
            //| ImGuiWindowFlags_NoCollapse
            //| ImGuiWindowFlags_NoResize
            //| ImGuiWindowFlags_NoMove;
            ;

        if(igBegin("Code", null, windowFlags)) {

            // bool igBeginChildStr(const(char)* str_id, const ImVec2 size, bool border, ImGuiWindowFlags flags);

            igBeginChildStr("##scrollingChildWindow",
                ImVec2(0, 0),
                true,
                ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoNav);


            auto numLines = 100;

            __gshared string[] lines;

            if(lines.length==0) {
                foreach(i; 0..numLines) {
                    lines ~= "[%s] I am a line of text".format(i);
                }
            }

            float lineHeight = igGetTextLineHeightWithSpacing();

            ImGuiListClipper clipper;
            ImGuiListClipper_Begin(&clipper, numLines, lineHeight);
            ImGuiListClipper_Step(&clipper);

            for (int line = clipper.DisplayStart; line < clipper.DisplayEnd; line++) {
                igText(toStringz(lines[line]));
                igSameLine(0, 5);

                igTextColored(ImVec4(1.0f, 0.0f, 1.0f, 1.0f), "Pink");
            }

            ImGuiListClipper_End(&clipper);

            igEndChild();

        }
        igEnd();
    }
}