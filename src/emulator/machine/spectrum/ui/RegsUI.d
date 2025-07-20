module emulator.machine.spectrum.ui.RegsUI;

import emulator.machine.spectrum.all;
import vulkan.all;

final class RegsUI {
private:
    enum WIDTH = 620, HEIGHT = 430;
    enum REG_COLOUR = ImVec4(0, 0.8, 1, 1);
    @Borrowed VulkanContext context;
    @Borrowed Spectrum spectrum;
    @Borrowed Z80 cpu;
    @Borrowed State state;
public:
    this(VulkanContext context, Spectrum spectrum) {
        this.context = context;
        this.spectrum = spectrum;
        this.cpu = spectrum.getCpu();
        this.state = cpu.state;
    }
    void render(Frame frame) {

        igSetNextWindowPos(igGetMainViewport().WorkPos + ImVec2(1390,890), ImGuiCond_Once, ImVec2(1.0, 1.0));
        igSetNextWindowSize(ImVec2(WIDTH, HEIGHT), ImGuiCond_Once);

        auto windowFlags = ImGuiWindowFlags_None
            | ImGuiWindowFlags_NoSavedSettings
            | ImGuiWindowFlags_NoScrollWithMouse
            | ImGuiWindowFlags_NoScrollbar
            //| ImGuiWindowFlags_NoTitleBar
            //| ImGuiWindowFlags_NoCollapse
            //| ImGuiWindowFlags_NoBackground
            //| ImGuiWindowFlags_NoResize
            //| ImGuiWindowFlags_NoMove;
            ;

        if(igBegin("CPU State", null, windowFlags)) {

            regsTable();

        }
        igEnd();
    }
private:
    void regsTable() {

        igPushFont(context.vk.getImguiFont(1), 0);

        reg8Table();

        igSameLine(0, 5);
        reg16Table();

        igSameLine(0, 5);
        flagsTable();

        igSameLine(0, 5);
        specialRegTable();

        igPopFont();
    }
    void reg8Table() {
        const flags = ImGuiTableFlags_None
            | ImGuiTableFlags_Borders
            | ImGuiTableFlags_RowBg;

        const numCols = 4;
        const outerSize = ImVec2(180,0);
        const innerWidth = 0f;

        if(igBeginTable("regs8Table", numCols, flags, outerSize, innerWidth)) {

            // Headers
            igTableSetupColumn("Reg", ImGuiTableColumnFlags_WidthFixed, 26, 0);
            igTableSetupColumn("",  ImGuiTableColumnFlags_None, 0, 0);
            igTableSetupColumn("+",  ImGuiTableColumnFlags_None, 0, 0);
            igTableSetupColumn("+/-",  ImGuiTableColumnFlags_None, 0, 0);
            igTableHeadersRow();

            displayRegRow("A", state.A, 8);
            displayRegRow("F", state.F, 8);
            displayRegRow("B", state.B, 8);
            displayRegRow("C", state.C, 8);
            displayRegRow("D", state.D, 8);
            displayRegRow("E", state.E, 8);
            displayRegRow("H", state.H, 8);
            displayRegRow("L", state.L, 8);

            displayEmptyRow4();

            displayRegRow("IXH", state.IXH, 8);
            displayRegRow("IXL", state.IXL, 8);
            displayRegRow("IYH", state.IYH, 8);
            displayRegRow("IYL", state.IYL, 8);

            igEndTable();
        }
    }
    void reg16Table() {
        const flags = ImGuiTableFlags_None
            | ImGuiTableFlags_Borders
            | ImGuiTableFlags_RowBg;

        const numCols = 4;
        const outerSize = ImVec2(240,0);
        const innerWidth = 0f;

        if(igBeginTable("regs16Table", numCols, flags, outerSize, innerWidth)) {
            // Headers
            igTableSetupColumn("Reg", ImGuiTableColumnFlags_WidthFixed, 26, 0);
            igTableSetupColumn("",  ImGuiTableColumnFlags_None, 0, 0);
            igTableSetupColumn("+",  ImGuiTableColumnFlags_None, 0, 0);
            igTableSetupColumn("+/-",  ImGuiTableColumnFlags_None, 0, 0);
            igTableHeadersRow();

            displayRegRow("AF", state.AF, 16);
            displayRegRow("BC", state.BC, 16);
            displayRegRow("DE", state.DE, 16);
            displayRegRow("HL", state.HL, 16);
            displayRegRow("IX", state.IX, 16);
            displayRegRow("IY", state.IY, 16);
            displayEmptyRow4();
            displayRegRow("SP", state.SP, 16);

            displayRegRow("PC", state.PC, 16, true);

            displayEmptyRow4();
            displayRegRow("AF'", state.AF1, 16);
            displayRegRow("BC'", state.BC1, 16);
            displayRegRow("DE'", state.DE1, 16);
            displayRegRow("HL'", state.HL1, 16);

            igEndTable();
        }
    }
    void flagsTable() {
        const flags = ImGuiTableFlags_None
            | ImGuiTableFlags_Borders
            | ImGuiTableFlags_RowBg;

        const numCols = 2;
        const outerSize = ImVec2(70,0);
        const innerWidth = 0f;

        if(igBeginTable("flagsTable", numCols, flags, outerSize, innerWidth)) {

            // Headers
            igTableSetupColumn("Flag", ImGuiTableColumnFlags_WidthFixed, 30, 0);
            igTableSetupColumn("",  ImGuiTableColumnFlags_None, 0, 0);
            igTableHeadersRow();

            displayRegRowFmt("%b", "C", state.flagC());
            displayRegRowFmt("%b", "N", state.flagN());
            displayRegRowFmt("%b", "P/V", state.flagPV());
            displayRegRowFmt("%b", "H", state.flagH());
            displayRegRowFmt("%b", "Z", state.flagZ());
            displayRegRowFmt("%b", "S", state.flagS());

            igEndTable();
        }
    }
    void specialRegTable() {
        const flags = ImGuiTableFlags_None
            | ImGuiTableFlags_Borders
            | ImGuiTableFlags_RowBg;

        const numCols = 2;
        const outerSize = ImVec2(100,0);
        const innerWidth = 0f;

        if(igBeginTable("specialRegTable", numCols, flags, outerSize, innerWidth)) {

            // Headers
            igTableSetupColumn("Reg", ImGuiTableColumnFlags_WidthFixed, 32, 0);
            igTableSetupColumn("",  ImGuiTableColumnFlags_None, 0, 0);
            igTableHeadersRow();

            displayRegRowFmt("%s", "IFF1", state.IFF1);
            displayRegRowFmt("%s", "IFF2", state.IFF2);
            displayRegRowFmt("%s", "IM", state.IM);

            displayRegRowFmt("%02x", "I", state.I);
            displayRegRowFmt("%02x", "R", state.R);

            igEndTable();
        }
    }
    void displayRegRow(string name, uint value, int bits, bool editable = false) {
        string xfmt = bits==8 ? "%02X" : "%04X";
        igTableNextRow(ImGuiTableRowFlags_None, 10);
        igTableSetColumnIndex(0);
        igTextColored(REG_COLOUR, toStringz(name));
        igTableSetColumnIndex(1);
        igText(toStringz(xfmt.format(value)));
        igTableSetColumnIndex(2);
        igText(toStringz("%s".format(value)));
        igTableSetColumnIndex(3);
        igText(toStringz("%s".format((value<<24).as!int>>24)));

        if(editable) {
            // igInputText("",
            //     buf.ptr,
            //     buf.length,
            //     ImGuiInputTextFlags_None,
            //     null,
            //     null);
        } else {

        }
    }
    void displayRegRowFmt(string fmt, string name, uint value) {
        igTableNextRow(ImGuiTableRowFlags_None, 10);
        igTableSetColumnIndex(0);
        igTextColored(REG_COLOUR, toStringz(name));
        igTableSetColumnIndex(1);
        igText(toStringz(fmt.format(value)));
    }
    void displayEmptyRow4() {
        igTableNextRow(ImGuiTableRowFlags_None, 10);
        igTableSetColumnIndex(0);
        igTableSetColumnIndex(1);
        igTableSetColumnIndex(2);
        igTableSetColumnIndex(3);
    }
}
