module emulator.machine.spectrum.ui.CodeUI;

import emulator.machine.spectrum.all;
import vulkan.all;

alias LinesW = emulator.assembler.Lines.Lines;

final class CodeUI {
private:
    enum WIDTH = 720, HEIGHT = 435;
    enum REG_COLOUR = ImVec4(0, 0.8, 1, 1);
    enum INSTR_COLOUR = ImVec4(0.8, 0.8, 0.8, 1);
    enum NUM_COLOUR = ImVec4(1, 1, 1, 1);

    @Borrowed Spectrum spectrum;
    @Borrowed Z80 cpu;
    @Borrowed State state;

    Disassembler disasm;
    Set!string regs;
    char[5] selectAddress = "0\0\0\0\0";
    char[5] watchAddress = "0\0\0\0\0";
    char[5] watchLength = "0\0\0\0\0";

    LinesW lines;
    uint _scrollToLine = uint.max;
    WatchRange[] watchList;
    int maxRunInstructions = 0;
    int currentCodeLine = -1;

    uint[uint] address2Line;
    uint[uint] line2address;
    Set!uint breakpointAddresses;
public:
    this(Spectrum spectrum) {
        this.spectrum = spectrum;
        this.cpu = spectrum.getCpu();
        this.state = cpu.state;
        this.disasm = createZ80Disassembler();
        this.regs = new Set!string;
        this.breakpointAddresses = new Set!uint;
        this.regs.add([
            "a", "b", "c", "d", "e", "f", "h", "l", "i", "r",
            "af", "bc", "de", "hl", "ix", "iy",
            "ixh", "ixl", "iyh", "iyl"
        ]);

        // Assume ROM is in memory
        codeModified(0, 0x4000);
    }
    /**
     * Either:
     *  1 - ROM loaded
     *  2 - Tape loaded
     *  3 - Snapshot loaded
     *  4 - Memory edited
     */
    void codeModified(uint fromAddr, uint length) {
        vkassert(fromAddr <= 0xffff);

        if(fromAddr + length > 0x10000) length = 0x10000 - fromAddr;
        ubyte[] code = spectrum.readFromMemory(fromAddr.as!ushort, length.as!ushort);

        auto newLines = disasm.decode(code, fromAddr);
        log("Decompiled %s lines", newLines.length);

        addLines(newLines);

        addBreakpoints();

        if(fromAddr == 0x0000) {
            spectrum.getROM().applyMetadata(lines);
        }
    }
    /**
     * Assembly file loaded
     */
    void addLines(LinesW newLines) {
        auto fromAddr = newLines[0].address;
        mergeLines(newLines);
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

            if (igBeginTabBar("MyTabBar", ImGuiTabItemFlags_None)) {

                //auto flags = selectTab == 0 ? ImGuiTabItemFlags_SetSelected : ImGuiTabItemFlags_None;

                if (igBeginTabItem("Instructions", null, ImGuiTabItemFlags_None)) {
                    renderCode();
                    igEndTabItem();
                }

                //flags = selectTab == 1 ? ImGuiTabItemFlags_SetSelected : ImGuiTabItemFlags_None;
                if (igBeginTabItem("Breakpoints", null, ImGuiTabItemFlags_None)) {
                    renderBreakpointList();
                    igEndTabItem();
                }

                if (igBeginTabItem("WatchList", null, ImGuiTabItemFlags_None)) {
                    renderWatchList();
                    igEndTabItem();
                }


                igEndTabBar();
            }
        }

        igEnd();
    }
private:
    void scrollToLine(uint line) {
        this._scrollToLine = line;
    }
    void mergeLines(LinesW newLines) {
        if(lines is null) {
            lines = newLines;
        } else {
            log("before merge lines is %04x to %04x", lines.first().address, lines.last().address);
            lines.merge(newLines);
            log("lines is now %04x to %04x", lines.first().address, lines.last().address);
        }

        // Update address2Line/line2address
        address2Line.clear();
        line2address.clear();
        foreach(i, ref l; lines.lines) {
            address2Line[l.address] = i.as!uint;
            line2address[i.as!uint] = l.address;
        }
    }
    void addBreakpointAtAddress(uint addr) {
        breakpointAddresses.add(addr);
    }
    void removeBreakpointAtAddress(uint addr) {
        breakpointAddresses.remove(addr);
    }
    void renderBreakpointList() {
        auto numLines = breakpointAddresses.length().as!uint;
        if(numLines==0) return;

        float lineHeight = igGetTextLineHeightWithSpacing();

        ImGuiListClipper clipper;
        ImGuiListClipper_Begin(&clipper, numLines, lineHeight);
        ImGuiListClipper_Step(&clipper);

        auto array = breakpointAddresses.values();

        for (int bpLine = clipper.DisplayStart; bpLine < clipper.DisplayEnd; bpLine++) {
            auto addr = array[bpLine];
            auto line = address2Line[addr];

            igText("[%04x]".format(addr).toStringz());
            igSameLine(0,5);
            if(igButton("Go", ImVec2(0,0))) {
                scrollToLine(line);
                // TODO - select code tab
            }
            igSameLine(0,10);
            if(igButton("Remove", ImVec2(0,0))) {
                removeBreakpointAtAddress(addr);
            }
        }

        ImGuiListClipper_End(&clipper);
    }
    void renderWatchList() {

        enum childFlags = ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoNav;

        igBeginChildStr("##scrollingChildWindow",
            ImVec2(0, HEIGHT-106),
            true,
            childFlags);

        auto numLines = watchList.length.as!int;
        if(numLines > 0) {

            float lineHeight = igGetTextLineHeightWithSpacing();
            int toRemove = -1;

            ImGuiListClipper clipper;
            ImGuiListClipper_Begin(&clipper, numLines, lineHeight);
            ImGuiListClipper_Step(&clipper);

            for (int line = clipper.DisplayStart; line < clipper.DisplayEnd; line++) {

                igPushIDInt(line);
                if(igButton("Remove", ImVec2(0,0))) {
                    toRemove = line;
                }
                igPopID();
                igSameLine(0, 10);
                igText("%04x".format(watchList[line].start).toStringz());
                igSameLine(0,5);
                igText("%04x".format(watchList[line].start + watchList[line].numBytes-1).toStringz());
                igSameLine(0,10);
                igText("(%s bytes)".format(watchList[line].numBytes).toStringz());
            }

            ImGuiListClipper_End(&clipper);

            if(toRemove!=-1) {
                fireRemoveWatch(watchList[toRemove]);
                watchList.removeAt(toRemove);
            }
        }

        igEndChild();

        igPushStyleVar(ImGuiStyleVar_FrameRounding, 4.0);
        igPushItemWidth(60);
        if(igInputText("Start", watchAddress.ptr, watchAddress.length.as!int,
                        ImGuiInputTextFlags_CharsHexadecimal,
                        null, null))
        {

        }

        igSameLine(0,10);
        if(igInputText("End", watchLength.ptr, watchLength.length.as!int,
                        ImGuiInputTextFlags_CharsHexadecimal,
                        null, null))
        {

        }
        igPopItemWidth();

        igSameLine(0,10);
        if(igButton("Add", ImVec2(0,0))) {
            auto start = fromStringz(watchAddress.ptr).to!uint(16);
            auto end = fromStringz(watchLength.ptr).to!uint(16);
            if(start <= 0xffff && end >= start && end <=0xffff) {
                watchList ~= WatchRange(start, end+1-start);
            }
            fireAddWatch(watchList[$-1]);
        }

        igPopStyleVar(1);
    }
    void renderCode() {
        enum size = ImVec2(0, HEIGHT-106);
        enum border = true;
        enum childFlags = ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoNav;

        igBeginChildStr("##scrollingChildWindow",
            size,
            border,
            childFlags);

        renderCodeTable();
        igEndChild();

        renderCodeButtons();
    }
    void renderCodeTable() {
        const flags = ImGuiTableFlags_None
            | ImGuiTableFlags_Borders
            | ImGuiTableFlags_RowBg;

        const numCols = 4;
        const outerSize = ImVec2(0,0);
        const innerWidth = 0f;

        if(igBeginTableEx("codeTable", 2, numCols, flags, outerSize, innerWidth)) {

            igTableSetupColumn("Address", ImGuiTableColumnFlags_WidthFixed, 170.0f, 0);
            igTableSetupColumn("Bytes", ImGuiTableColumnFlags_WidthFixed, 150.0f, 0);
            igTableSetupColumn("Instructions", ImGuiTableColumnFlags_WidthFixed, 150, 0);
            igTableSetupColumn("Comments", ImGuiTableColumnFlags_WidthStretch, 0, 0);

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
                if(currentLine) {
                    if(line != currentCodeLine) {
                        currentCodeLine = line;
                        fireCodeLineChange(&lines[line]);
                    }
                }

                renderRow(line, currentLine);
            }

            ImGuiListClipper_End(&clipper);

            igEndTable();
        }
    }
    void renderRow(int line, bool highlightRow) {

        igTableNextRow(ImGuiTableRowFlags_None, 10);

        auto addr = line2address[line];

        if(highlightRow) {
            igTableSetBgColor(ImGuiTableBgTarget_RowBg0, 0x6000ff00, -1);

        } else if(breakpointAddresses.contains(addr)) {
            igTableSetBgColor(ImGuiTableBgTarget_RowBg1, 0x600000ff, -1);
        }

        renderAddressAndLabel(line);
        renderBytes(line);
        renderInstructions(line);
        renderComment(line);
    }
    void renderAddressAndLabel(int line) {
        igTableSetColumnIndex(0);

        // Address
        auto address = lines[line].address;
        auto addrStr = "%04X".format(address);
        igTextColored(ImVec4(0.8, 0.8, 0.8, 1), toStringz(addrStr));

        // Label
        if(lines[line].labels) {
            string label = lines[line].labels.length == 1
                ? lines[line].labels[0] ~ ":"
                : lines[line].labels.join(": ");

            igSameLine(0,8);
            igTextColored(ImVec4(0.8, 0.8, 0.8, 1), toStringz(label));
        }

        // Click to set/unset a breakpoint
        if(igIsItemHovered(ImGuiHoveredFlags_None) && igIsMouseClicked(0, false)) {
            log("select line %s", line);
            if(breakpointAddresses.contains(address)) {
                removeBreakpointAtAddress(address);
            } else {
                addBreakpointAtAddress(address);
            }
        }
    }
    void renderBytes(int line) {
        igTableSetColumnIndex(1);
        auto bytes = lines[line].code.map!(it=>"%02X".format(it)).join(" ");
        igTextColored(ImVec4(0.6, 0.6, 0.6, 1), toStringz(bytes));
    }
    void renderInstructions(int line) {
        igTableSetColumnIndex(2);
        string[] tokens = lines[line].tokens;
        string prev = "";
        igBeginGroup();
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
        igEndGroup();
        if(igIsItemHovered(ImGuiHoveredFlags_None) && igIsMouseClicked(0, false)) {
            fireInstructionClicked(&lines[line]);
        }
    }
    void renderComment(int line) {
        igTableSetColumnIndex(3);
        auto address = lines[line].address;

        if(lines[line].comments) {
            string comment = lines[line].comments.length == 1
                ? lines[line].comments[0]
                : lines[line].comments.join(", ");

            igTextColored(ImVec4(0.6, 0.6, 0.6, 1), toStringz(comment));
        }
    }
    void renderCodeButtons() {

        igPushStyleVar(ImGuiStyleVar_FrameRounding, 4.0);

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

        igSameLine(0, 5);
        if(igButton("To PC", ImVec2(0,0))) {
            scrollToAddress(state.PC);
        }

        igSameLine(0,20);
        igSeparatorEx(ImGuiSeparatorFlags_Vertical);

        igSameLine(0,20);
        igPushStyleColorVec4(ImGuiCol_Button, ImVec4(0.4, 0.7, 0.4, 0.75));

        //igPushButtonRepeat(true);
        if(igButton("Step", ImVec2(0,0))) {
            fireExecuteStateChange(ExecuteState.EXECUTING);
            spectrum.execute(null, 1, null, () {
                scrollToAddress(state.PC);
                fireExecuteStateChange(ExecuteState.PAUSED);
            });
        }
        //igPopButtonRepeat();

        igSameLine(0,5);
        if(igButton("Step Over", ImVec2(0,0))) {

            // If the current instruction is a call:
            //  - Place a breakpoint after the call
            //  - Remove breakpoint after execution (unless it was already there)
            //  - Fix issue with breakpointLines

            // auto currentLine = lines.getLineAtAddress(state.PC);
            // if(currentLine.tokens.length > 0 && currentLine.tokens[0] == "call") {
            //     addBreakpointAtAddress(currentLine.address + currentLine.code.length.as!int);
            // }

            // todo uncomment

            // fireExecuteStateChange(ExecuteState.EXECUTING);
            // spectrum.execute(null, 1, null, () {
            //     scrollToAddress(state.PC);
            //     fireExecuteStateChange(ExecuteState.PAUSED);
            // });


        }

        igPopStyleColor(1);


        igSameLine(0,40);
        igSetNextItemWidth(75);
        igPushIDInt(3);
        igDragInt("", &maxRunInstructions, 0.2, 1, 100, "%d", ImGuiSliderFlags_Logarithmic);
        igPopID();

        igPushStyleColorVec4(ImGuiCol_Button, ImVec4(0.7, 0.4, 0.4, 0.75));
        igSameLine(0,5);
        if(igButton("Run", ImVec2(0,0))) {

            fireExecuteStateChange(ExecuteState.EXECUTING);
            spectrum.execute(breakpointAddresses, maxRunInstructions, () {
                scrollToAddress(state.PC);
            }, () {
                fireExecuteStateChange(ExecuteState.PAUSED);
            });
        }

        igSameLine(0,5);
        if(igButton("Run Fast", ImVec2(0,0))) {

            fireExecuteStateChange(ExecuteState.EXECUTING);
            spectrum.execute(breakpointAddresses, maxRunInstructions, null, () {
                scrollToAddress(state.PC);
                fireExecuteStateChange(ExecuteState.PAUSED);
            });
        }
        igPopStyleColor(1);

        igPopStyleVar(1);
    }
    void addLabel(uint addr, string label) {
        if(auto line = lines.getLineAtAddress(addr)) {
            line.labels ~= label;
        }
    }
    void addComment(uint addr, string comment) {
        if(auto line = lines.getLineAtAddress(addr)) {
            line.comments ~= comment;
        }
    }
    void addBreakpoints() {
        addBreakpointAtAddress(0x12a9);
    }
}