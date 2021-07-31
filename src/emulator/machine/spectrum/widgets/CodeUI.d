module emulator.machine.spectrum.widgets.CodeUI;

import emulator.machine.spectrum.all;
import vulkan.all;

final class CodeUI {
private:
    enum WIDTH = 720, HEIGHT = 435;
    enum REG_COLOUR = ImVec4(1,1,1,1);
    enum INSTR_COLOUR = ImVec4(0.8, 0.8, 0.8, 1);
    enum NUM_COLOUR = ImVec4(0.7, 1, 0.7, 1);

    @Borrowed Spectrum spectrum;
    @Borrowed Z80 cpu;
    @Borrowed State state;

    Disassembler disasm;
    Line[] lines;
    Set!string regs;
    char[5] selectAddress = "0\0\0\0\0";
    uint _scrollToLine = uint.max;
public:
    this(Spectrum spectrum) {
        this.spectrum = spectrum;
        this.cpu = spectrum.getCpu();
        this.state = cpu.state;
        this.disasm = createZ80Disassembler();
        this.regs = new Set!string;
        this.regs.add([
            "a", "b", "c", "d", "e", "f", "h", "l", "i", "r",
            "bc", "de", "hl", "ix", "iy",
            "ixh", "ixl", "iyh", "iyl"
        ]);
        refresh(0, 0x4000);
    }
    /**
     * Either:
     *  1 - ROM loaded
     *  2 - Tape loaded
     *  3 - Memory edited
     */
    void refresh(uint fromAddr, uint length) {
        vkassert(fromAddr <= 0xffff);
        if(fromAddr + length > 0x10000) length = 0x10000 - fromAddr;
        ubyte[] code = spectrum.readFromMemory(fromAddr.as!ushort, length.as!ushort);

        this.lines = disasm.decode(code, fromAddr);
        log("Decompiled %s lines", lines.length);

        scrollToAddress(fromAddr);

    }
    void scrollToAddress(uint addr) {
        // Calculate line for this address - a bit inefficient but not called often
        int line = lines.length.as!int - 1;
        foreach(i; 0..lines.length) {
            if(addr <= lines[i].address) {
                line = i.as!uint;
                break;
            }
        }
        line = maxOf(line-6, 0);
        scrollToLine(line);
    }
    void scrollToLine(uint line) {
        this._scrollToLine = line;
    }
    void render(Frame frame) {

        igSetNextWindowPos(ImVec2(1390,10), ImGuiCond_Once, ImVec2(1.0, 0.0));
        igSetNextWindowSize(ImVec2(WIDTH, HEIGHT), ImGuiCond_Once);

        auto windowFlags = ImGuiWindowFlags_None
            | ImGuiWindowFlags_NoSavedSettings
            //| ImGuiWindowFlags_NoTitleBar
            //| ImGuiWindowFlags_NoCollapse
            //| ImGuiWindowFlags_NoResize
            //| ImGuiWindowFlags_NoBackground
            //| ImGuiWindowFlags_NoMove;
            ;

        if(igBegin("Code", null, windowFlags)) {

            enum size = ImVec2(0, HEIGHT-78);
            enum border = true;
            enum childFlags = ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoNav;

            igBeginChildStr("##scrollingChildWindow",
                size,
                border,
                childFlags);

            renderTable();

            igEndChild();

            renderButtons();
        }

        igEnd();
    }
private:
    void renderButtons() {
        if(igButton("Step", ImVec2(0,0))) {
            cpu.execute();
            scrollToAddress(state.PC);
        }

        igSameLine(0,20);
        if(igButton("Run", ImVec2(0,0))) {
            // TODO
        }

        igSameLine(0,20);
        igPushItemWidth(60);
        if(igInputText("", selectAddress.ptr, selectAddress.length.as!int,
                        ImGuiInputTextFlags_CharsHexadecimal | ImGuiInputTextFlags_EnterReturnsTrue,
                        null, null))
        {
            scrollToAddress(fromStringz(selectAddress.ptr).to!uint(16));
        }
        igPopItemWidth();

        igSameLine(0, 1);
        if(igButton("To Addr", ImVec2(0,0))) {
            scrollToAddress(fromStringz(selectAddress.ptr).to!uint(16));
        }
    }
    void renderTable() {
        const flags = ImGuiTableFlags_None
            | ImGuiTableFlags_Borders
            | ImGuiTableFlags_RowBg;

        const numCols = 3;
        const outerSize = ImVec2(0,0);
        const innerWidth = 0f;

        if(igBeginTableEx("codeTable", 2, numCols, flags, outerSize, innerWidth)) {

            igTableSetupColumn("Address", ImGuiTableColumnFlags_WidthFixed, 60.0f, 0);
            igTableSetupColumn("Bytes", ImGuiTableColumnFlags_WidthFixed, 150.0f, 0);
            igTableSetupColumn("Instructions", ImGuiTableColumnFlags_WidthStretch, 0, 0);

            auto numLines = lines.length.as!uint;
            float lineHeight = igGetTextLineHeightWithSpacing();

            ImGuiListClipper clipper;
            ImGuiListClipper_Begin(&clipper, numLines, lineHeight);
            ImGuiListClipper_Step(&clipper);

            // scroll to line
            if(_scrollToLine != uint.max) {
                igSetScrollYFloat(_scrollToLine*lineHeight);
                _scrollToLine = uint.max;
            }

            for (int line = clipper.DisplayStart; line < clipper.DisplayEnd; line++) {

                auto currentLine = state.PC == lines[line].address;

                // if(currentLine) {
                //     igPushStyleColorVec4(ImGuiCol_TableRowBg, ImVec4(1,1, 0.5, 1));
                //     igPushStyleColorVec4(ImGuiCol_TableRowBgAlt, ImVec4(1,1, 0.5, 1));
                // }

                renderRow(line, currentLine);

                // if(currentLine) {
                //     igPopStyleColor(2);
                // }
            }

            ImGuiListClipper_End(&clipper);

            igEndTable();
        }
    }
    void renderRow(int line, bool highlightRow) {
        auto addr = "%04X".format(lines[line].address);
        auto bytes = lines[line].code.map!(it=>"%02X".format(it)).join(" ");

        igTableNextRow(ImGuiTableRowFlags_None, 10);

        if(highlightRow) {
    //     ImGuiTableBgTarget_None = 0,
    //     ImGuiTableBgTarget_RowBg0 = 1,
    //     ImGuiTableBgTarget_RowBg1 = 2,
    //     ImGuiTableBgTarget_CellBg = 3,
            igTableSetBgColor(ImGuiTableBgTarget_RowBg0, 0x6000ff00, -1);
        }

        igTableSetColumnIndex(0);
        igTextColored(ImVec4(0.8, 0.8, 0.8, 1), toStringz(addr));

        igTableSetColumnIndex(1);
        igTextColored(ImVec4(0.6, 0.6, 0.6, 1), toStringz(bytes));

        igTableSetColumnIndex(2);
        renderInstructions(lines[line].tokens);
    }
    void renderInstructions(string[] tokens) {
        string prev = "";
        foreach(i, t; tokens) {
            if(i>0) {
                auto space = 7;
                if(t.isOneOf(",", ")")) {
                    space = 0;
                } else {
                    if(prev.isOneOf("(")) space = 0;
                }
                igSameLine(0, space);
            }

            auto col = INSTR_COLOUR;

            if(t[0]=='$' || isDigit(t[0])) {
                col = NUM_COLOUR;
            } else if(regs.contains(t) && !prev.isOneOf("call", "ret", "jp", "jr")) {
                col = REG_COLOUR;
                t = From!"std.string".toUpper(t);
            }

            igTextColored(col, toStringz(t));

            prev = t;
        }
    }
}