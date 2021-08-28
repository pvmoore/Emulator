module emulator.machine.spectrum.ROM48K;

import emulator.all;

final class ROM48K {
public:
    ubyte[] getCode() {
        return cast(ubyte[])From!"std.file".read(ROM);
    }
    void applyMetadata(Lines lines) {
        foreach(m; META) {
            if(auto line = lines.getLineAtAddress(m.address)) {

                line.labels ~= m.label;

                if(m.comment) {
                    line.comments ~= m.comment;
                }
            }
        }
    }
private:
    enum ROM = "resources/roms/48k.rom";

    static struct Meta {
        uint address;
        string label;
        string comment;

        this(uint address, string label, string comment) {
            this.address = address;
            this.label = label;
            this.comment = comment;
        }
        this(uint address, string label) {
            this.address = address;
            this.label = label;
        }
    }

    /**
     * Labels from:
     *      https://skoolkid.github.io/rom/maps/all.html
     */
    const Meta[] META = [
        // https://skoolkid.github.io/rom/asm/0000.html
        Meta(0x0000, "START"),

        // https://skoolkid.github.io/rom/asm/0008.html
        Meta(0x0008, "ERROR_1", "rst $08 - Error handling"),

        // https://skoolkid.github.io/rom/asm/0010.html
        Meta(0x0010, "PRINT_A_1", "rst $10 - In: A = char to print. (Jump to $15F2)"),

        // https://skoolkid.github.io/rom/asm/0018.html
        Meta(0x0018, "GET_CHAR", "rst $18 - Collect char. Out: A = char"),
        Meta(0x001c, "TEST_CHAR"),

        // https://skoolkid.github.io/rom/asm/0020.html
        Meta(0x0020, "NEXT_CHAR", "rst $20 - Collect next char. Out: A = next char"),

        // https://skoolkid.github.io/rom/asm/0028.html
        Meta(0x0028, "FP_CALC", "rst $28 - Calculator. (Jump to $335B)"),

        // https://skoolkid.github.io/rom/asm/0030.html
        Meta(0x0030, "BC_SPACES", "rst $30 - Make spaces. In:BC = count, Out: DE = first byte addr, HL = last byte addr"),

        // https://skoolkid.github.io/rom/asm/0038.html
        Meta(0x0038, "MASK_INT", "rst $38 - Maskable interrupt. Update clock and scan keyboard"),
        Meta(0x0048, "KEY_INT"),

        // https://skoolkid.github.io/rom/asm/0074.html
        Meta(0x0074, "CH_ADD_1", "CH-ADD+1 subroutine"),
        Meta(0x0077, "TEMP_PTR1"),
        Meta(0x0074, "TEMP_PTR2"),

        // https://skoolkid.github.io/rom/asm/007D.html
        Meta(0x007d, "SKIP_OVER", "Skip-over subroutine"),
        Meta(0x0090, "SKIPS"),

        // https://skoolkid.github.io/rom/asm/0095.html
        Meta(0x0095, "TOKENS", "Token table"),

        // https://skoolkid.github.io/rom/asm/0205.html
        Meta(0x0205, "KEYTABLE_A", "Key tables"),
        Meta(0x022c, "KEYTABLE_B"),
        Meta(0x0246, "KEYTABLE_C"),
        Meta(0x0260, "KEYTABLE_D"),
        Meta(0x026a, "KEYTABLE_E"),
        Meta(0x0284, "KEYTABLE_F"),

        // https://skoolkid.github.io/rom/asm/028E.html
        Meta(0x028e, "KEY_SCAN", "Keyboard scann subroutine"),
        Meta(0x0296, "KEY_LINE"),
        Meta(0x029f, "KEY_3KEYS"),
        Meta(0x02a1, "KEY_BITS"),
        Meta(0x02ab, "KEY_DONE"),

        // https://skoolkid.github.io/rom/asm/02BF.html
        Meta(0x02bf, "KEYBOARD", "Called by maskable interrupt routine"),
        Meta(0x02c6, "K_ST_LOOP"),
        Meta(0x02d1, "K_CH_SET"),
        Meta(0x02f1, "K_NEW"),
        Meta(0x0308, "K_END"),
        Meta(0x0310, "K_REPEAT"),

        // https://skoolkid.github.io/rom/asm/031E.html
        Meta(0x031e, "K_TEST", "K-Test subroutine"),
        Meta(0x032c, "K_MAIN"),

        // https://skoolkid.github.io/rom/asm/0333.html
        Meta(0x0333, "K_DECODE", "Keyboard decoding subroutine"),
        Meta(0x0341, "K_E_LET"),
        Meta(0x034a, "K_LOOK_UP"),
        Meta(0x034f, "K_KLC_LET"),
        Meta(0x0364, "K_TOKENS"),
        Meta(0x0367, "K_DIGIT"),
        Meta(0x0382, "K_8_9"),
        Meta(0x0389, "K_GRA_DGT"),
        Meta(0x039d, "K_KLC_DGT"),
        Meta(0x03b2, "K_AT_CHAR"),

        // https://skoolkid.github.io/rom/asm/03B5.html
        Meta(0x03b5, "BEEPER", "Beeper subroutine"),
        Meta(0x03d6, "BE_H_L_LP"),
        Meta(0x03f2, "BE_AGAIN"),
        Meta(0x03f6, "BE_END"),

        // https://skoolkid.github.io/rom/asm/03F8.html
        Meta(0x03f8, "BEEP", "Beep command routine"),
        Meta(0x0425, "BE_i_OK"),
        Meta(0x0427, "BE_OCTAVE"),
        Meta(0x046c, "REPORT_B"),

        // https://skoolkid.github.io/rom/asm/046E.html
        Meta(0x046e, "SEMITONES", "The semi-tone table"),

        // https://skoolkid.github.io/rom/asm/04AA.html
        Meta(0x04aa, "PROGNAME", "Program name subroutine (ZX81)"),

        // https://skoolkid.github.io/rom/asm/04C2.html
        Meta(0x04c2, "SA_BYTES", "SA_BYTES save subroutine. In: A = block type, DE = block length, IX = Start address"),
        Meta(0x04d0, "SA_FLAG"),
        Meta(0x04d8, "SA_LEADER"),
        Meta(0x04ea, "SA_SYNC_1"),
        Meta(0x04f2, "SA_SYNC_2"),
        Meta(0x04fe, "SA_LOOP"),
        Meta(0x0505, "SA_LOOP_P"),
        Meta(0x0507, "SA_START"),
        Meta(0x050e, "SA_PARITY"),
        Meta(0x0511, "SA_BIT_2"),
        Meta(0x0514, "SA_BIT_1"),
        Meta(0x051a, "SA_SET"),
        Meta(0x051c, "SA_OUT"),
        Meta(0x0525, "SA_8_BITS"),
        Meta(0x053c, "SA_DELAY"),

        // https://skoolkid.github.io/rom/asm/053F.html
        Meta(0x053f, "SA_LD_RET", "Save/Load subroutine"),
        Meta(0x0554, "SA_LD_END"),

        // https://skoolkid.github.io/rom/asm/0556.html
        Meta(0x0556, "LD_BYTES", "Load header/block"),
        Meta(0x056b, "LD_BREAK"),
        Meta(0x056c, "LD_START"),
        Meta(0x0574, "LD_WAIT"),
        Meta(0x0580, "LD_LEADER"),
        Meta(0x058f, "LD_SYNC"),
        Meta(0x05a9, "LD_LOOP"),
        Meta(0x05b3, "LD_FLAG"),
        Meta(0x05bd, "LD_VERIFY"),
        Meta(0x05c2, "LD_NEXT"),
        Meta(0x05c4, "LD_DEC"),
        Meta(0x05c8, "LD_MARKER"),
        Meta(0x05ca, "LD_8_BITS"),

        // https://skoolkid.github.io/rom/asm/05E3.html
        Meta(0x05e3, "LD_EDGE_2", "Load/verify"),
        Meta(0x05e7, "LD_EDGE_1"),
        Meta(0x05e9, "LD_DELAY"),
        Meta(0x05ed, "LD_SAMPLE"),

        // https://skoolkid.github.io/rom/asm/0605.html
        Meta(0x0605, "SAVE_ETC", "Save/Load/Verify/Merge subroutines"),
        Meta(0x0621, "SA_SPACE"),
        Meta(0x0629, "SA_BLANK"),
        Meta(0x0644, "SA_NULL"),
        Meta(0x064b, "SA_NAME"),
        Meta(0x0652, "SA_DATA"),
        Meta(0x0672, "SA_V_OLD"),
        Meta(0x0685, "SA_V_NEW"),
        Meta(0x068f, "SA_V_TYPE"),
        Meta(0x0692, "SA_DATA_1"),
        Meta(0x06a0, "SA_SCR"),
        Meta(0x06c3, "SA_CODE"),
        Meta(0x06e1, "SA_CODE_1"),
        Meta(0x06f0, "SA_CODE_2"),
        Meta(0x06f5, "SA_CODE_3"),
        Meta(0x06f9, "SA_CODE_4"),
        Meta(0x0710, "SA_TYPE_3"),
        Meta(0x0716, "SA_LINE"),
        Meta(0x0723, "SA_LINE_1"),
        Meta(0x07ea, "SA_TYPE_0"),
        Meta(0x075a, "SA_ALL"),
        Meta(0x0767, "SA_LOOK_H"),
        Meta(0x078a, "LD_TYPE"),
        Meta(0x07a6, "LD_NAME"),
        Meta(0x07ad, "LD_CH_PR"),

        // https://skoolkid.github.io/rom/asm/07CB.html
        Meta(0x07cb, "VR_CONTROL", "Verify control routine"),
        Meta(0x07e9, "VR_CONT_1"),
        Meta(0x07f4, "VR_CONT_2"),
        Meta(0x0800, "VR_CONT_3"),

        // https://skoolkid.github.io/rom/asm/0802.html
        Meta(0x0802, "LD_BLOCK", "Load data block. In: A = $ff, C = 1=load/0=verify, DE = Block length, IX = Start address"),
        Meta(0x0806, "REPORT_R"),

        // https://skoolkid.github.io/rom/asm/0808.html
        Meta(0x0808, "LD_CONTROL", "Load control routine"),
        Meta(0x0819, "LD_CONT_1"),
        Meta(0x0825, "LD_CONT_2"),
        Meta(0x082e, "LD_DATA"),
        Meta(0x084c, "LD_DATA_1"),
        Meta(0x0873, "LD_PROG"),
        Meta(0x08ad, "LD_PROG_1"),

        // https://skoolkid.github.io/rom/asm/08B6.html
        Meta(0x08b6, "ME_CONTROL", "Merge control routine"),
        Meta(0x08d2, "ME_NEW_LP"),
        Meta(0x08d7, "ME_OLD_LP"),
        Meta(0x08df, "ME_OLD_L1"),
        Meta(0x08eb, "ME_NEW_L2"),
        Meta(0x08f0, "ME_VAR_LP"),
        Meta(0x08f9, "ME_OLD_VP"),
        Meta(0x0901, "ME_OLD_V1"),
        Meta(0x0909, "ME_OLD_V2"),
        Meta(0x0912, "ME_OLD_V3"),
        Meta(0x091e, "ME_OLD_V4"),
        Meta(0x0921, "ME_VAR_L1"),
        Meta(0x0923, "ME_VAR_L2"),

        // https://skoolkid.github.io/rom/asm/092C.html
        Meta(0x092c, "ME_ENTER", "Merge line or variable routine"),
        Meta(0x093e, "ME_ENT_1"),
        Meta(0x0955, "ME_ENT_2"),
        Meta(0x0958, "ME_ENT_3"),

        // https://skoolkid.github.io/rom/asm/0970.html
        Meta(0x0970, "SA_CONTRL", "Save control routine"),
        Meta(0x0991, "SA_1_SEC"),

        // https://skoolkid.github.io/rom/asm/09A1.html
        Meta(0x09a1, "CASSETTE", "Cassette messages"),
        Meta(0x09c1, "BLOCK_HDR"),

        // https://skoolkid.github.io/rom/asm/09F4.html
        Meta(0x09f4, "PRINT_OUT", "Print out routines"),

        // https://skoolkid.github.io/rom/asm/0A11.html
        Meta(0x0a11, "CTRL_CHARS", "Control character table"),

        // https://skoolkid.github.io/rom/asm/0A23.html
        Meta(0x0a23, "PO_BACK_1", "Cursor left subroutinme"),
        Meta(0x0a38, "PO_BACK_2"),
        Meta(0x0a3a, "PO_BACK_3"),

        // https://skoolkid.github.io/rom/asm/0A3D.html
        Meta(0x0a3d, "PO_RIGHT", "Cursor right subroutine"),

        // https://skoolkid.github.io/rom/asm/0A4F.html
        Meta(0x0a4f, "PO_ENTER", "Carriage return subroutine"),

        // https://skoolkid.github.io/rom/asm/0A5F.html
        Meta(0x0a5f, "PO_COMMA", "Print comma subroutine"),

        // https://skoolkid.github.io/rom/asm/0A69.html
        Meta(0x0a69, "PO_QUEST", "Print question mark subroutine"),

        // https://skoolkid.github.io/rom/asm/0A6D.html
        Meta(0x0a6d, "PO_TV_2", "Ctrl chars with operands routine"),
        Meta(0x0a75, "PO_2_OPER"),
        Meta(0x0a7a, "PO_1_OPER"),
        Meta(0x0a7d, "PO_TV_1"),
        Meta(0x0a80, "PO_CHANGE"),
        Meta(0x0a87, "PO_CONT"),
        Meta(0x0aac, "PO_AT_ERR"),
        Meta(0x0abf, "PO_AT_SET"),
        Meta(0x0ac2, "PO_TAB"),
        Meta(0x0ac3, "PO_FILL"),
        Meta(0x0ad0, "PO_SPACE"),

        // https://skoolkid.github.io/rom/asm/0AD9.html
        Meta(0x0ad9, "PO_ABLE", "Printable char codes"),

        // https://skoolkid.github.io/rom/asm/0ADC.html
        Meta(0x0adc, "PO_STORE"),
        Meta(0x0af0, "PO_ST_E"),
        Meta(0x0afc, "PO_ST_PR"),

        // https://skoolkid.github.io/rom/asm/0B03.html
        Meta(0x0b03, "PO_FETCH", "Position fetch subroutine"),
        Meta(0x0b1d, "PO_F_PR"),

        // https://skoolkid.github.io/rom/asm/0B24.html
        Meta(0x0b24, "PO_ANY", "Print any chars subroutine"),
        Meta(0x0b38, "PO_GR_1"),
        Meta(0x0b3e, "PO_GR_2"),
        Meta(0x0b4c, "PO_GR_3"),
        Meta(0x0b52, "PO_T_UDG"),
        Meta(0x0b5f, "PO_T"),
        Meta(0x0b65, "PO_CHAR"),
        Meta(0x0b6a, "PO_CHAR_2"),
        Meta(0x0b76, "PO_CHAR_3"),
        Meta(0x0b7f, "PR_ALL"),
        Meta(0x0b93, "PR_ALL_1"),
        Meta(0x0ba4, "PR_ALL_2"),
        Meta(0x0bb6, "PR_ALL_3"),
        Meta(0x0bb7, "PR_ALL_4"),
        Meta(0x0bc1, "PR_ALL_5"),
        Meta(0x0bd3, "PR_ALL_6"),

        // https://skoolkid.github.io/rom/asm/0BDB.html
        Meta(0x0bdb, "PO_ATTR", "Set attribute subroutine"),
        Meta(0x0bfa, "PO_ATTR_1"),
        Meta(0x0c08, "PO_ATTR_2"),

        // https://skoolkid.github.io/rom/asm/0C0A.html
        Meta(0x0c0a, "PO_MSG", "Message printing subroutine"),
        Meta(0x0c10, "PO_TOKENS"),
        Meta(0x0c14, "PO_TABLE"),
        Meta(0x0c22, "PO_EACH"),
        Meta(0x0c35, "PO_TR_SP"),

        // https://skoolkid.github.io/rom/asm/0C3B.html
        Meta(0x0c3b, "PO_SAVE", "PO-SAVE subroutine"),

        // https://skoolkid.github.io/rom/asm/0C41.html
        Meta(0x0c41, "PO_SEARCH", "Table search subroutine"),
        Meta(0x0c44, "PO_STEP"),

        // https://skoolkid.github.io/rom/asm/0C55.html
        Meta(0x0c55, "PO_SCR", "Test for scroll subroutine"),
        Meta(0x0c86, "REPORT_5"),
        Meta(0x0c88, "PO_SCR_2"),
        Meta(0x0cd2, "PO_SCR_3"),
        Meta(0x0cf0, "PO_SCR_3A"),
        Meta(0x0cf8, "SCROLL"),
        Meta(0x0d00, "REPORT_D"),
        Meta(0x0d02, "PO_SCR_4"),
        Meta(0x0d1c, "PO_SCR_4A"),
        Meta(0x0d2d, "PO_SCR_4B"),

        // https://skoolkid.github.io/rom/asm/0D4D.html
        Meta(0x0d4d, "TEMPS", "Temporary colour items subroutine"),
        Meta(0x0d5b, "TEMPS_1"),
        Meta(0x0d65, "TEMPS_2"),

        // https://skoolkid.github.io/rom/asm/0D6B.html
        Meta(0x0d6b, "CLS"),
        Meta(0x0d6e, "CLS_LOWER"),
        Meta(0x0d87, "CLS_1"),
        Meta(0x0d89, "CLS_2"),
        Meta(0x0d8e, "CLS_3"),
        Meta(0x0d94, "CL_CHAN"),
        Meta(0x0da0, "CL_CHAN_A"),

        // https://skoolkid.github.io/rom/asm/0DAF.html
        Meta(0x0daf, "CL_ALL"),

        // https://skoolkid.github.io/rom/asm/0DD9.html
        Meta(0x0dd9, "CL_SET", "CL-SET subroutine"),
        Meta(0x0dee, "CL_SET_1"),
        Meta(0x0df4, "CL_SET_2"),

        // https://skoolkid.github.io/rom/asm/0DFE.html
        Meta(0x0dfe, "CL_SC_ALL", "Scrolling subroutine"),
        Meta(0x0e00, "CL_SCROLL"),
        Meta(0x0e05, "CL_SCR_1"),
        Meta(0x0e0d, "CL_SCR_2"),
        Meta(0x0e19, "CL_SCR_3"),

        // https://skoolkid.github.io/rom/asm/0E44.html
        Meta(0x0e44, "CL_LINE", "Clear lines subroutine"),
        Meta(0x0e4a, "CL_LINE_1"),
        Meta(0x0e4d, "CL_LINE_2"),
        Meta(0x0e80, "CL_LINE_3"),

        // https://skoolkid.github.io/rom/asm/0E88.html
        Meta(0x0e88, "CL_ATTR", "CL-ATTR subroutine"),

        // https://skoolkid.github.io/rom/asm/0E9B.html
        Meta(0x0e9b, "CL_ADDR", "AL-ADDR subroutine"),

        // https://skoolkid.github.io/rom/asm/0EAC.html
        Meta(0x0eac, "COPY", "Copy command routine"),
        Meta(0x0eb2, "COPY_1"),
        Meta(0x0ec9, "COPY_2"),

        // https://skoolkid.github.io/rom/asm/0ECD.html
        Meta(0x0ecd, "COPY_BUFF", "Copy buff subroutine"),
        Meta(0x0ed3, "COPY_3"),
        Meta(0x0eda, "COPY_END"),

        // https://skoolkid.github.io/rom/asm/0EDF.html
        Meta(0x0edf, "CLEAR_PRB"),
        Meta(0x0ee7, "PRB_BYTES"),

        // https://skoolkid.github.io/rom/asm/0EF4.html
        Meta(0x0ef4, "COPY_LINE", "Copy line subroutine"),
        Meta(0x0efd, "COPY_L_1"),
        Meta(0x0f0c, "COPY_L_2"),
        Meta(0x0f14, "COPY_L_3"),
        Meta(0x0f18, "COPY_L_4"),
        Meta(0x0f1e, "COPY_L_5"),

        // https://skoolkid.github.io/rom/asm/0F2C.html
        Meta(0x0f2c, "EDITOR", "Editor routines"),
        Meta(0x0f30, "ED_AGAIN"),
        Meta(0x0f38, "ED_LOOP"),
        Meta(0x0f6c, "ED_CONTR"),
        Meta(0x0f81, "ADD_CHAR"),
        Meta(0x0f8b, "ADD_CH_1"),
        Meta(0x0f92, "ED_KEYS"),

        // https://skoolkid.github.io/rom/asm/0FA0.html
        Meta(0x0fa0, "EDITKEYS", "Editing keys table"),

        // https://skoolkid.github.io/rom/asm/0FA9.html
        Meta(0x0fa9, "ED_EDIT", "Edit key subroutine"),

        // https://skoolkid.github.io/rom/asm/0FF3.html
        Meta(0x0ff3, "ED_DOWN", "Cursor down editing subroutine"),
        Meta(0x1001, "ED_STOP"),

        // https://skoolkid.github.io/rom/asm/1007.html
        Meta(0x1007, "ED_LEFT", "Cursor left editing subroutine"),

        // https://skoolkid.github.io/rom/asm/100C.html
        Meta(0x100c, "ED_RIGHT", "Cursor right editing subroutine"),
        Meta(0x1011, "ED_CUR"),

        // https://skoolkid.github.io/rom/asm/1015.html
        Meta(0x1015, "ED_DELETE", "Delete editing subroutine"),

        // https://skoolkid.github.io/rom/asm/101E.html
        Meta(0x101e, "ED_IGNORE", "ED-IGNORE subroutine"),

        // https://skoolkid.github.io/rom/asm/1024.html
        Meta(0x1024, "ED_ENTER", "Edter editing subroutine"),
        Meta(0x1026, "ED_END"),

        // https://skoolkid.github.io/rom/asm/1031.html
        Meta(0x1031, "ED_EDGE", "ED-EDGE subroutine"),
        Meta(0x103e, "ED_EDGE_1"),
        Meta(0x1051, "ED_EDGE_3"),

        // https://skoolkid.github.io/rom/asm/1059.html
        Meta(0x1059, "ED_UP", "Cursor up editing routine"),
        Meta(0x106e, "ED_LIST"),

        // https://skoolkid.github.io/rom/asm/1076.html
        Meta(0x1076, "ED_SYMBOL", "ED-SYMBOL subroutine"),
        Meta(0x107c, "ED_GRAPH"),

        // https://skoolkid.github.io/rom/asm/107F.html
        Meta(0x107f, "ED_ERROR", "ED-ERROR subroutine"),

        // https://skoolkid.github.io/rom/asm/1097.html
        Meta(0x1097, "CLEAR_SP", "CLEAR-SP subroutine"),

        // https://skoolkid.github.io/rom/asm/10A8.html
        Meta(0x10a8, "KEY_INPUT", "Keyboard input subroutine"),
        Meta(0x10db, "KEY_M_CL"),
        Meta(0x10e6, "KEY_MODE"),
        Meta(0x10f4, "KEY_FLAG"),
        Meta(0x10fa, "KEY_CONTR"),
        Meta(0x1105, "KEY_DATA"),
        Meta(0x110d, "KEY_NEXT"),
        Meta(0x1113, "KEY_CHAN"),
        Meta(0x111b, "KEY_DONE_2"),

        // https://skoolkid.github.io/rom/asm/111D.html
        Meta(0x111d, "ED_COPY", "Lower screen copying sub"),
        Meta(0x1150, "ED_BLANK"),
        Meta(0x115e, "ED_SPACES"),
        Meta(0x1167, "ED_FULL"),
        Meta(0x117c, "ED_C_DONE"),
        Meta(0x117e, "ED_C_END"),

        // https://skoolkid.github.io/rom/asm/1190.html
        Meta(0x1190, "SET_HL", "Set-HL and Set-DE subroutines"),
        Meta(0x1195, "SET_DE"),

        // https://skoolkid.github.io/rom/asm/11A7.html
        Meta(0x11a7, "REMOVE_FP", "Remove hidden FP in BASIC sub"),

        // https://skoolkid.github.io/rom/asm/11B7.html
        Meta(0x11b7, "NEW"),
        Meta(0x11cb, "START_NEW"),
        Meta(0x11dc, "RAM_FILL"),
        Meta(0x11e2, "RAM_READ"),
        Meta(0x11ef, "RAM_DONE"),
        Meta(0x1219, "RAM_SET"),

        // https://skoolkid.github.io/rom/asm/12A2.html
        Meta(0x12a2, "MAIN_EXEC", "Main execution loop"),
        Meta(0x12a9, "MAIN_1"),
        Meta(0x12ac, "MAIN_2"),
        Meta(0x12cf, "MAIN_3"),
        Meta(0x1303, "MAIN_4"),
        Meta(0x1313, "MAIN_G"),
        Meta(0x133c, "MAIN_5"),
        Meta(0x1373, "MAIN_6"),
        Meta(0x1376, "MAIN_7"),
        Meta(0x1384, "MAIN_8"),
        Meta(0x1386, "MAIN_9"),

        // https://skoolkid.github.io/rom/asm/1391.html
        Meta(0x1391, "REPORTS", "Report messages"),
        Meta(0x1537, "COMMA_SPC"),

        // https://skoolkid.github.io/rom/asm/1539.html
        Meta(0x1539, "COPYRIGHT", "Copyright message"),

        // https://skoolkid.github.io/rom/asm/1555.html
        Meta(0x1555, "REPORT_G", "No room for line"),

        // https://skoolkid.github.io/rom/asm/155D.html
        Meta(0x155d, "MAIN_ADD", "Add BASIC line to program"),
        Meta(0x157d, "MAIN_ADD1"),
        Meta(0x15ab, "MAIN_ADD2"),

        // https://skoolkid.github.io/rom/asm/15AF.html
        Meta(0x15af, "CHANINFO", "Initial channel information"),

        // https://skoolkid.github.io/rom/asm/15C4.html
        Meta(0x15c4, "REPORT_J", "Invalid I/O device"),

        // https://skoolkid.github.io/rom/asm/15C6.html
        Meta(0x15c6, "STRMDATA", "Initla stream data"),

        // https://skoolkid.github.io/rom/asm/15D4.html
        Meta(0x15d4, "WAIT_KEY", "Wait-key subroutine"),
        Meta(0x15de, "WAIT_KEY1"),

        // https://skoolkid.github.io/rom/asm/15E6.html
        Meta(0x15e6, "INPUT_AD", "Input-AD subroutine"),

        // https://skoolkid.github.io/rom/asm/15EF.html
        Meta(0x15ef, "OUT_CODE", "A = char to print (0 to 9 for digits, 11 to 22 for letters A-R)"),
        Meta(0x15f2, "PRINT_A_2", "A = the char to print"),
        Meta(0x15f7, "CALL_SUB"),

        // https://skoolkid.github.io/rom/asm/1601.html
        Meta(0x1601, "CHAN_OPEN", "IN: A = stream number"),
        Meta(0x160e, "REPORT_O"),
        Meta(0x1610, "CHAN_OP_1"),

        // https://skoolkid.github.io/rom/asm/1615.html
        Meta(0x1615, "CHAN_FLAG", "IN: HL = base addr of channel"),
        Meta(0x162c, "CALL_JUMP"),

        // https://skoolkid.github.io/rom/asm/162D.html
        Meta(0x162d, "CHANCODE", "Channel code lookup table"),

        // https://skoolkid.github.io/rom/asm/1634.html
        Meta(0x1634, "CHAN_K", "Channel K flag subroutine"),

        // https://skoolkid.github.io/rom/asm/1642.html
        Meta(0x1642, "CHAN_S", "Channel S flag subroutine"),
        Meta(0x1646, "CHAN_S_1"),

        // https://skoolkid.github.io/rom/asm/164D.html
        Meta(0x164d, "CHAN_P", "Channel P flag subroutine"),

        // https://skoolkid.github.io/rom/asm/1652.html
        Meta(0x1652, "ONE_SPACE", "Make room subroutine. IN: HL = address, OUT: DE = " ~
            "addr of last byte of new space, HL = address of byte before the start of the new space"),
        Meta(0x1655, "MAKE_ROOM"),

        // https://skoolkid.github.io/rom/asm/1664.html
        Meta(0x1664, "POINTERS", "Pointers subroutine"),
        Meta(0x166b, "PTR_NEXT"),
        Meta(0x167f, "PTR_DONE"),

        // https://skoolkid.github.io/rom/asm/168F.html
        Meta(0x168f, "LINE_ZERO", "Collect a line number"),
        Meta(0x1691, "LINE_NO_A"),
        Meta(0x1695, "LINE_NO"),

        // https://skoolkid.github.io/rom/asm/169E.html
        Meta(0x169e, "RESERVE", "Reserve space"),

        // https://skoolkid.github.io/rom/asm/16B0.html
        Meta(0x16b0, "SET_MIN", "Resets the editing area"),
        Meta(0x16bf, "SET_WORK"),
        Meta(0x16c5, "SET_STK"),

        // https://skoolkid.github.io/rom/asm/16D4.html
        Meta(0x16d4, "REC_EDIT", "Reclaim the edit line - NOT USED"),

        // https://skoolkid.github.io/rom/asm/16DB.html
        Meta(0x16db, "INDEXER_1", "Look through a table"),
        Meta(0x16dc, "INDEXER"),

        // https://skoolkid.github.io/rom/asm/16E5.html
        Meta(0x16e5, "CLOSE", "CLOSE# subroutine"),
        Meta(0x16fc, "CLOSE_1"),

        // https://skoolkid.github.io/rom/asm/1701.html
        Meta(0x1701, "CLOSE_2", "Close-2"),

        // https://skoolkid.github.io/rom/asm/1716.html
        Meta(0x1716, "CLOSESTRM", "Close stream lookup table"),

        // https://skoolkid.github.io/rom/asm/171C.html
        Meta(0x171c, "CLOSE_STR", "Close stream subroutine"),

        // https://skoolkid.github.io/rom/asm/171E.html
        Meta(0x171e, "STR_DATA", "Stream data subroutine"),
        Meta(0x1725, "REPORT_O_2"),
        Meta(0x1727, "STR_DATA1"),

        // https://skoolkid.github.io/rom/asm/1736.html
        Meta(0x1736, "OPEN", "OPEN# subroutine"),
        Meta(0x1756, "OPEN_1"),

        // https://skoolkid.github.io/rom/asm/175D.html
        Meta(0x175d, "OPEN_2"),
        Meta(0x1765, "REPORT_F"),
        Meta(0x1767, "OPEN_3"),

        // https://skoolkid.github.io/rom/asm/177A.html
        Meta(0x177a, "OPENSTRM", "Open stream lookup table"),

        // https://skoolkid.github.io/rom/asm/1781.html
        Meta(0x1781, "OPEN_K", "Open K subroutine"),

        // https://skoolkid.github.io/rom/asm/1785.html
        Meta(0x1785, "OPEN_S", "Open S subroutine"),

        // https://skoolkid.github.io/rom/asm/1789.html
        Meta(0x1789, "OPEN_P", "Open P subroutine"),
        Meta(0x178b, "OPEN_END"),

        // https://skoolkid.github.io/rom/asm/1793.html
        Meta(0x1793, "CAT_ETC", "CAT, ERASE, FORMAT, MOVE commands - invalid stream"),

        // https://skoolkid.github.io/rom/asm/1795.html
        Meta(0x1795, "AUTO_LIST", "LIST routines"),
        Meta(0x17ce, "AUTO_L_1"),
        Meta(0x17e1, "AUTO_L_2"),
        Meta(0x17e4, "AUTO_L_3"),
        Meta(0x17ed, "AUTO_L_4"),

        // https://skoolkid.github.io/rom/asm/17F5.html
        Meta(0x17f5, "LLIST", "LLIST entry point"),

        // https://skoolkid.github.io/rom/asm/17F9.html
        Meta(0x17f9, "LIST", "LIST entry point"),
        Meta(0x17fb, "LIST_1"),
        Meta(0x1814, "LIST_2"),
        Meta(0x181a, "LIST_3"),
        Meta(0x181f, "LIST_4"),
        Meta(0x1822, "LIST_5"),
        Meta(0x1833, "LIST_ALL"),
        Meta(0x1835, "LIST_ALL_1"),

        // https://skoolkid.github.io/rom/asm/1855.html
        Meta(0x1855, "OUT_LINE", "Print a whole BASIC line"),
        Meta(0x1865, "OUT_LINE1"),
        Meta(0x187d, "OUT_LINE2"),
        Meta(0x1881, "OUT_LINE3"),
        Meta(0x1894, "OUT_LINE4"),
        Meta(0x18a1, "OUT_LINE5"),
        Meta(0x18b4, "OUT_LINE6"),

        // https://skoolkid.github.io/rom/asm/18B6.html
        Meta(0x18b6, "NUMBER", "Number subroutine"),

        // https://skoolkid.github.io/rom/asm/18C1.html
        Meta(0x18c1, "OUT_FLASH", "Print a flashing char. IN: A = char"),

        // https://skoolkid.github.io/rom/asm/18E1.html
        Meta(0x18e1, "OUT_CURS", "Print the cursor"),
        Meta(0x18f3, "OUT_C_1"),
        Meta(0x1909, "OUT_C_2"),

        // https://skoolkid.github.io/rom/asm/190F.html
        Meta(0x190f, "LN_FETCH", "Line fetch subroutine"),
        Meta(0x191c, "LN_STORE"),

        // https://skoolkid.github.io/rom/asm/1925.html
        Meta(0x1925, "OUT_SP_2", "Printing chars in a BASIC line subroutine"),
        Meta(0x192a, "OUT_SP_NO"),
        Meta(0x192b, "OUT_SP_1"),
        Meta(0x1937, "OUT_CHAR"),
        Meta(0x195a, "OUT_CH_1"),
        Meta(0x1968, "OUT_CH_2"),
        Meta(0x196c, "OUT_CH_3"),

        // https://skoolkid.github.io/rom/asm/196E.html
        Meta(0x196e, "LINE_ADDR", "Return line address for line in HL"),
        Meta(0x1974, "LINE_AD_1"),

        // https://skoolkid.github.io/rom/asm/1980.html
        Meta(0x1980, "CP_LINES", "Compare line numbers"),

        // https://skoolkid.github.io/rom/asm/198B.html
        Meta(0x198b, "EACH_STMT", "Find statement"),
        Meta(0x1990, "EACH_S_1"),
        Meta(0x1998, "EACH_S_2"),
        Meta(0x199a, "EACH_S_3"),
        Meta(0x19a5, "EACH_S_4"),
        Meta(0x19b1, "EACH_S_5"),

        // https://skoolkid.github.io/rom/asm/19B8.html
        Meta(0x19b8, "NEXT_ONE", "Find next line/variable"),
        Meta(0x19c7, "NEXT_O_1"),
        Meta(0x19ce, "NEXT_O_2"),
        Meta(0x19d5, "NEXT_O_3"),
        Meta(0x19d6, "NEXT_O_4"),
        Meta(0x19db, "NEXT_O_5"),

        // https://skoolkid.github.io/rom/asm/19DD.html
        Meta(0x19dd, "DIFFER", "Find the distance between two addresses"),

        // https://skoolkid.github.io/rom/asm/19E5.html
        Meta(0x19e5, "RECLAIM_1", "Reclaim space"),
        Meta(0x19e8, "RECLAIM_2"),

        // https://skoolkid.github.io/rom/asm/19FB.html
        Meta(0x19fb, "E_LINE_NO", "Reads line number"),
        Meta(0x1a15, "E_L_1"),

        // https://skoolkid.github.io/rom/asm/1A1B.html
        Meta(0x1a1b, "OUT_NUM_1", "Report and line number printing subroutime"),
        Meta(0x1a28, "OUT_NUM_2"),
        Meta(0x1a30, "OUT_NUM_3"),
        Meta(0x1a42, "OUT_NUM_4"),

        // https://skoolkid.github.io/rom/asm/1A48.html
        Meta(0x1a48, "SYNTAX", "Command offset table"),
        Meta(0x1a7a, "P_LET", "Command parameter table"),
        Meta(0x1a7d, "P_GO_TO"),
        Meta(0x1a81, "P_IF"),
        Meta(0x1a86, "P_GO_SUB"),
        Meta(0x1a8a, "P_STOP"),
        Meta(0x1a8d, "P_RETURN"),
        Meta(0x1a90, "P_FOR"),
        Meta(0x1a98, "P_NEXT"),
        Meta(0x1a9c, "P_PRINT"),
        Meta(0x1a9f, "P_INPUT"),
        Meta(0x1aa2, "P_DIM"),
        Meta(0x1aa5, "P_REM"),
        Meta(0x1aa8, "P_NEW"),
        Meta(0x1aab, "P_RUN"),
        Meta(0x1aae, "P_LIST"),
        Meta(0x1ab1, "P_POKE"),
        Meta(0x1ab5, "P_RANDOM"),
        Meta(0x1ab8, "P_CONT"),
        Meta(0x1abb, "P_CLEAR"),
        Meta(0x1abe, "P_CLS"),
        Meta(0x1ac1, "P_PLOT"),
        Meta(0x1ac5, "P_PAUSE"),
        Meta(0x1ac9, "P_READ"),
        Meta(0x1acc, "P_DATA"),
        Meta(0x1acf, "P_RESTORE"),
        Meta(0x1ad2, "P_DRAW"),
        Meta(0x1ad6, "P_COPY"),
        Meta(0x1ad9, "P_LPRINT"),
        Meta(0x1adc, "P_LLIST"),
        Meta(0x1adf, "P_SAVE"),
        Meta(0x1ae0, "P_LOAD"),
        Meta(0x1ae1, "P_VERIFY"),
        Meta(0x1ae2, "P_MERGE"),
        Meta(0x1ae3, "P_BEEP"),
        Meta(0x1ae7, "P_CIRCLE"),
        Meta(0x1aeb, "P_INK"),
        Meta(0x1aec, "P_PAPER"),
        Meta(0x1aed, "P_FLASH"),
        Meta(0x1aee, "P_BRIGHT"),
        Meta(0x1aef, "P_INVERSE"),
        Meta(0x1af0, "P_OVER"),
        Meta(0x1af1, "P_OUT"),
        Meta(0x1af5, "P_BORDER"),
        Meta(0x1af9, "P_DEF_FN"),
        Meta(0x1afc, "P_OPEN"),
        Meta(0x1b02, "P_CLOSE"),
        Meta(0x1b06, "P_FORMAT"),
        Meta(0x1b0a, "P_MOVE"),
        Meta(0x1b10, "P_ERASE"),
        Meta(0x1b14, "P_CAT"),

        // https://skoolkid.github.io/rom/asm/1B17.html
        Meta(0x1b17, "LINE_SCAN", "Main BASIC parser"),

        // https://skoolkid.github.io/rom/asm/1B28.html
        Meta(0x1b28, "STMT_LOOP", "Parse statement"),
        Meta(0x1b29, "STMT_L_1"),
        Meta(0x1b52, "SCAN_LOOP"),
        Meta(0x1b55, "GET_PARAM"),

        // https://skoolkid.github.io/rom/asm/1B6F.html
        Meta(0x1b6f, "SEPARATOR", "Separator subroutine"),

        // https://skoolkid.github.io/rom/asm/1B76.html
        Meta(0x1b76, "STMT_RET", "Stmt return subroutine"),
        Meta(0x1b7d, "STMT_R_1"),

        // https://skoolkid.github.io/rom/asm/1B8A.html
        Meta(0x1b8a, "LINE_RUN", "Run a line"),

        // https://skoolkid.github.io/rom/asm/1B9E.html
        Meta(0x1b9e, "LINE_NEW", "Find a line"),

        // https://skoolkid.github.io/rom/asm/1BB2.html
        Meta(0x1bb2, "REM", "REM command routine"),

        // https://skoolkid.github.io/rom/asm/1BB3.html
        Meta(0x1bb3, "LINE_END", "Line-end routine"),

        // https://skoolkid.github.io/rom/asm/1BBF.html
        Meta(0x1bbf, "LINE_USE", "Line-use routine"),

        // https://skoolkid.github.io/rom/asm/1BD1.html
        Meta(0x1bd1, "NEXT_LINE", "Next-line routine"),
        Meta(0x1bec, "REPORT_N"),

        // https://skoolkid.github.io/rom/asm/1BEE.html
        Meta(0x1bee, "CHECK_END", "Check-end subroutine"),

        // https://skoolkid.github.io/rom/asm/1BF4.html
        Meta(0x1bf4, "STMT_NEXT", "Stmt-next routine"),

        // https://skoolkid.github.io/rom/asm/1C01.html
        Meta(0x1c01, "CMDCLASS", "The command class table"),

        // https://skoolkid.github.io/rom/asm/1C0D.html
        Meta(0x1c0d, "CLASS_03", "Command classes 00,03 and 05"),
        Meta(0x1c10, "CLASS_00"),
        Meta(0x1c11, "CLASS_05"),

        // https://skoolkid.github.io/rom/asm/1C1F.html
        Meta(0x1c1f, "CLASS_01", "Command class 01"),

        // https://skoolkid.github.io/rom/asm/1C22.html
        Meta(0x1c22, "VAR_A_1", "Variable in assignment subroutine"),
        Meta(0x1c2e, "REPORT_2"),
        Meta(0x1c30, "VAR_A_2"),
        Meta(0x1c46, "VAR_A_3"),

        // https://skoolkid.github.io/rom/asm/1C4E.html
        Meta(0x1c4e, "CLASS_02", "Command class 02"),

        // https://skoolkid.github.io/rom/asm/1C56.html
        Meta(0x1c56, "VAL_FET_1", "Fetch a value subroutine"),
        Meta(0x1c59, "VAL_FET_2"),

        // https://skoolkid.github.io/rom/asm/1C6C.html
        Meta(0x1c6c, "CLASS_04", "Command class 04"),

        // https://skoolkid.github.io/rom/asm/1C79.html
        Meta(0x1c79, "NEXT_2NUM", "Expect numeric/string expression"),
        Meta(0x1c7a, "CLASS_08"),
        Meta(0x1c82, "CLASS_06"),
        Meta(0x1c8a, "REPORT_C"),
        Meta(0x1c8c, "CLASS_0A"),

        // https://skoolkid.github.io/rom/asm/1C96.html
        Meta(0x1c96, "CLASS_07", "Set permanent colours subroutine"),

        // https://skoolkid.github.io/rom/asm/1CBE.html
        Meta(0x1cbe, "CLASS_09", "Command class 09"),
        Meta(0x1cd6, "CL_09_1"),

        // https://skoolkid.github.io/rom/asm/1CDB.html
        Meta(0x1cdb, "CLASS_0B", "Command class 0B"),

        // https://skoolkid.github.io/rom/asm/1CDE.html
        Meta(0x1cde, "FETCH_NUM", "Fetch a number subroutine"),
        Meta(0x1ce6, "USE_ZERO"),

        // https://skoolkid.github.io/rom/asm/1CEE.html
        Meta(0x1cee, "STOP", "STOP command routine"),

        // https://skoolkid.github.io/rom/asm/1CF0.html
        Meta(0x1cf0, "IF_CMD", "IF command routine"),
        Meta(0x1d00, "IF_1"),

        // https://skoolkid.github.io/rom/asm/1D03.html
        Meta(0x1d03, "FOR", "FOR command routine"),
        Meta(0x1d10, "F_USE_1"),
        Meta(0x1d16, "F_REORDER"),
        Meta(0x1d34, "F_L_S"),
        Meta(0x1d64, "F_LOOP"),
        Meta(0x1d7c, "F_FOUND"),
        Meta(0x1d84, "REPORT_I"),

        // https://skoolkid.github.io/rom/asm/1D86.html
        Meta(0x1d86, "LOOK_PROG", "Find DATA, DEFFN or NEXT"),
        Meta(0x1d8b, "LOOK_P_1"),
        Meta(0x1da3, "LOOK_P_2"),

        // https://skoolkid.github.io/rom/asm/1DAB.html
        Meta(0x1dab, "NEXT", "NEXT command routine"),
        Meta(0x1dd8, "REPORT_1"),

        // https://skoolkid.github.io/rom/asm/1DDA.html
        Meta(0x1dda, "NEXT_LOOP", "NEXT-loop subroutine"),
        Meta(0x1de2, "NEXT_1"),
        Meta(0x1de9, "NEXT_2"),

        // https://skoolkid.github.io/rom/asm/1DEC.html
        Meta(0x1dec, "READ_3", "READ command routine"),
        Meta(0x1ded, "READ"),
        Meta(0x1e0a, "READ_1"),
        Meta(0x1e1e, "READ_2"),

        // https://skoolkid.github.io/rom/asm/1E27.html
        Meta(0x1e27, "DATA", "DATA command routine"),
        Meta(0x1e2c, "DATA_1"),
        Meta(0x1e37, "DATA_2"),

        // https://skoolkid.github.io/rom/asm/1E39.html
        Meta(0x1e39, "PASS_BY", "Pass-by subroutine"),

        // https://skoolkid.github.io/rom/asm/1E42.html
        Meta(0x1e42, "RESTORE", "RESTORE command routine"),
        Meta(0x1e45, "REST_RUN"),

        // https://skoolkid.github.io/rom/asm/1E4F.html
        Meta(0x1e4f, "RANDOMIZE", "RANDOMIZE command routine"),
        Meta(0x1e5a, "RAND_1"),

        // https://skoolkid.github.io/rom/asm/1E5F.html

        Meta(0x1e5f, "CONTINUE", "CONTINUE command routine"),

        // https://skoolkid.github.io/rom/asm/1E67.html
        Meta(0x1e67, "GO_TO", "GO_TO command routine"),
        Meta(0x1e73, "GO_TO_2"),

        // https://skoolkid.github.io/rom/asm/1E7A.html
        Meta(0x1e7a, "OUT_CMD", "OUT command routine"),

        // https://skoolkid.github.io/rom/asm/1E80.html
        Meta(0x1e80, "POKE", "POKE command routine"),

        // https://skoolkid.github.io/rom/asm/1E85.html
        Meta(0x1e85, "TWO_PARAM", "Two-param subroutine"),
        Meta(0x1e8e, "TWO_P_1"),

        // https://skoolkid.github.io/rom/asm/1E94.html
        Meta(0x1e94, "FIND_INT1", "Find integers subroutine"),
        Meta(0x1e99, "FIND_INT2"),
        Meta(0x1e9c, "FIND_I_1"),
        Meta(0x1e9f, "REPORT_B_2"),

        // https://skoolkid.github.io/rom/asm/1EA1.html
        Meta(0x1ea1, "RUN", "RUN command routine"),

        // https://skoolkid.github.io/rom/asm/1EAC.html
        Meta(0x1eac, "CLEAR", "CLEAR command routine"),
        Meta(0x1eaf, "CLEAR_RUN"),
        Meta(0x1eb7, "CLEAR_1"),
        Meta(0x1eda, "REPORT_M"),
        Meta(0x1edc, "CLEAR_2"),

        // https://skoolkid.github.io/rom/asm/1EED.html
        Meta(0x1eed, "GO_SUB", "GO_SUB command routine"),

        // https://skoolkid.github.io/rom/asm/1F05.html
        Meta(0x1f05, "TEST_ROOM", "Test room subroutine"),
        Meta(0x1f15, "REPORT_4"),

        // https://skoolkid.github.io/rom/asm/1F1A.html
        Meta(0x1f1a, "FREE_MEM", "Free memory subroutine"),

        // https://skoolkid.github.io/rom/asm/1F23.html
        Meta(0x1f23, "RETURN", "RETURN command routine"),
        Meta(0x1f36, "REPORT_7"),

        // https://skoolkid.github.io/rom/asm/1F3A.html
        Meta(0x1f3a, "PAUSE", "PAUSE command routine"),
        Meta(0x1f3d, "PAUSE_1"),
        Meta(0x1f49, "PAUSE_2"),
        Meta(0x1f4f, "PAUSE_END"),

        // https://skoolkid.github.io/rom/asm/1F54.html
        Meta(0x1f54, "BREAK_KEY", "Nreak-key subroutine"),

        // https://skoolkid.github.io/rom/asm/1F60.html
        Meta(0x1f60, "DEF_FN", "DEF_FN command routine"),
        Meta(0x1f6a, "DEF_FN_1"),
        Meta(0x1f7d, "DEF_FN_2"),
        Meta(0x1f86, "DEF_FN_3"),
        Meta(0x1f89, "DEF_FN_4"),
        Meta(0x1f94, "DEF_FN_5"),
        Meta(0x1fa6, "DEF_FN_6"),
        Meta(0x1fbd, "DEF_FN_7"),

        // https://skoolkid.github.io/rom/asm/1FC3.html
        Meta(0x1fc3, "UNSTACK_Z", "Unstack-z subroutine"),

        // https://skoolkid.github.io/rom/asm/1FC9.html
        Meta(0x1fc9, "LPRINT", "LPRINT command routine"),
        Meta(0x1fcd, "PRINT"),
        Meta(0x1fcf, "PRINT_1"),

        // https://skoolkid.github.io/rom/asm/1FDF.html
        Meta(0x1fdf, "PRINT_2", "Print controlling subroutine"),
        Meta(0x1fe5, "PRINT_3"),
        Meta(0x1ff2, "PRINT_4"),

        // https://skoolkid.github.io/rom/asm/1FF5.html
        Meta(0x1ff5, "PRINT_CR", "Print a carriage return subroutine"),

        // https://skoolkid.github.io/rom/asm/1FFC.html
        Meta(0x1ffc, "PR_ITEM_1", "Print items subroutine"),
        Meta(0x200e, "PR_ITEM_2"),
        Meta(0x201e, "PR_AT_TAB"),
        Meta(0x2024, "PR_ITEM_3"),
        Meta(0x203c, "PR_STRING"),

        // https://skoolkid.github.io/rom/asm/2045.html
        Meta(0x2045, "PR_END_Z", "End of printing subroutine"),
        Meta(0x2048, "PR_ST_END"),

        // https://skoolkid.github.io/rom/asm/204E.html
        Meta(0x204e, "PR_POSN_1", "Print position subroutine"),
        Meta(0x2061, "PR_POSN_2"),
        Meta(0x2067, "PR_POSN_3"),
        Meta(0x206e, "PR_POSN_4"),

        // https://skoolkid.github.io/rom/asm/2070.html
        Meta(0x2070, "STR_ALTER", "Alter stream subroutine"),

        // https://skoolkid.github.io/rom/asm/2089.html
        Meta(0x2089, "INPUT", "INPUT command routine"),
        Meta(0x2096, "INPUT_1"),
        Meta(0x20ad, "INPUT_2"),
        Meta(0x20c1, "IN_ITEM_1"),
        Meta(0x20d8, "IN_ITEM_2"),
        Meta(0x20ed, "IN_ITEM_3"),
        Meta(0x20fa, "IN_PROMPT"),
        Meta(0x211a, "IN_PR_1"),
        Meta(0x211c, "IN_PR_2"),
        Meta(0x2129, "IN_PR_3"),
        Meta(0x213a, "IN_VAR_1"),
        Meta(0x2148, "IN_VAR_2"),
        Meta(0x215e, "IN_VAR_3"),
        Meta(0x2161, "IN_VAR_4"),
        Meta(0x2174, "IN_VAR_5"),
        Meta(0x219b, "IN_VAR_6"),
        Meta(0x21af, "IN_NEXT_1"),
        Meta(0x21b2, "IN_NEXT_2"),

        // https://skoolkid.github.io/rom/asm/21B9.html
        Meta(0x21b9, "IN_ASSIGN", "In-assign subroutine"),
        Meta(0x21d0, "IN_STOP"),

        // https://skoolkid.github.io/rom/asm/21D6.html
        Meta(0x21d6, "IN_CHAN_K", "In chan K subroutine"),

        // https://skoolkid.github.io/rom/asm/21E1.html
        Meta(0x21e1, "CO_TEMP_1", "Colour item routines"),
        Meta(0x21e2, "CO_TEMP_2"),
        Meta(0x21f2, "CO_TEMP_3"),
        Meta(0x21fc, "CO_TEMP_4"),
        Meta(0x2211, "CO_TEMP_5"),
        Meta(0x2228, "CO_TEMP_6"),
        Meta(0x2234, "CO_TEMP_7"),
        Meta(0x223e, "CO_TEMP_8"),
        Meta(0x2244, "REPORT_K"),
        Meta(0x2246, "CO_TEMP_9"),
        Meta(0x2257, "CO_TEMP_A"),
        Meta(0x2258, "CO_TEMP_B"),
        Meta(0x226c, "CO_CHANGE"),
        Meta(0x2273, "CO_TEMP_C"),
        Meta(0x227d, "CO_TEMP_D"),
        Meta(0x2287, "CO_TEMP_E"),

        // https://skoolkid.github.io/rom/asm/2294.html
        Meta(0x2294, "BORDER", "BORDER command routine"),
        Meta(0x22a6, "BORDER_1"),

        // https://skoolkid.github.io/rom/asm/22AA.html
        Meta(0x22aa, "PIXEL_ADD", "Pixel address subroutine"),

        // https://skoolkid.github.io/rom/asm/22CB.html
        Meta(0x22cb, "POINT_SUB", "Point subroutine"),
        Meta(0x22d4, "POINT_LP"),

        // https://skoolkid.github.io/rom/asm/22DC.html
        Meta(0x22dc, "PLOT", "PLOT command routine"),
        Meta(0x22e5, "PLOT_SUB"),
        Meta(0x22f0, "PLOT_LOOP"),
        Meta(0x22fd, "PL_TST_IN"),
        Meta(0x2303, "PLOT_END"),

        // https://skoolkid.github.io/rom/asm/2307.html
        Meta(0x2307, "STK_TO_BC", "Stk-to-bc subroutine"),

        // https://skoolkid.github.io/rom/asm/2314.html
        Meta(0x2314, "STK_TO_A", "Tok-to-a subroutine"),

        // https://skoolkid.github.io/rom/asm/2320.html
        Meta(0x2320, "CIRCLE", "CIRCLE command routine"),
        Meta(0x233b, "C_R_GRE_1"),
        Meta(0x235a, "C_ARC_GE1"),

        // https://skoolkid.github.io/rom/asm/2382.html
        Meta(0x2382, "DRAW", "DRAW command routine"),
        Meta(0x238d, "DR_3_PRMS"),
        Meta(0x23a3, "DR_SIN_NZ"),
        Meta(0x23c1, "DR_PRMS"),
        Meta(0x2420, "DRW_STEPS"),
        Meta(0x2425, "ARC_LOOP"),
        Meta(0x2439, "ARC_START"),
        Meta(0x245f, "ARC_END"),
        Meta(0x2477, "LINE_DRAW"),

        // https://skoolkid.github.io/rom/asm/247D.html
        Meta(0x247d, "CD_PRMS1", "Initial parameters subroutine"),
        Meta(0x2495, "USE_252"),
        Meta(0x2497, "DRAW_SAVE"),

        // https://skoolkid.github.io/rom/asm/24B7.html
        Meta(0x24b7, "DRAW_LINE", "Line drawing subroutine"),
        Meta(0x24c4, "DL_X_GE_Y"),
        Meta(0x24cb, "DL_LARGER"),
        Meta(0x24ce, "D_L_LOOP"),
        Meta(0x24d4, "D_L_DIAG"),
        Meta(0x24db, "D_L_HR_VT"),
        Meta(0x24df, "D_L_STEP"),
        Meta(0x24ec, "D_L_PLOT"),
        Meta(0x24f7, "D_L_RANGE"),
        Meta(0x24f9, "REPORT_B_3"),

        // https://skoolkid.github.io/rom/asm/24FB.html
        Meta(0x24fb, "SCANNING", "Scanning subroutine"),
        Meta(0x24ff, "S_LOOP_1"),

        // https://skoolkid.github.io/rom/asm/250F.html
        Meta(0x250f, "S_QUOTE_S", "Scanning quote subroutine"),

        // https://skoolkid.github.io/rom/asm/2522.html
        Meta(0x2522, "S_2_COORD", "Scanning 2 coordinates subroutine"),
        Meta(0x252d, "S_RPORT_C"),

        // https://skoolkid.github.io/rom/asm/2530.html
        Meta(0x2530, "SYNTAX_Z", "Syntax-z subroutine"),

        // https://skoolkid.github.io/rom/asm/2535.html
        Meta(0x2535, "S_SCRN_S", "Scanning SCREEN$ subroutine"),
        Meta(0x254f, "S_SCRN_LP"),
        Meta(0x255a, "S_SC_MTCH"),
        Meta(0x255d, "S_SC_ROWS"),
        Meta(0x2573, "S_SCR_NXT"),
        Meta(0x257d, "S_SCR_STO"),

        // https://skoolkid.github.io/rom/asm/2580.html
        Meta(0x2580, "S_ATTR_S", "Scanning attributes subroutine"),

        // https://skoolkid.github.io/rom/asm/2596.html
        Meta(0x2596, "SCANFUNC", "Scanning function table"),

        // https://skoolkid.github.io/rom/asm/25AF.html
        Meta(0x25af, "S_U_PLUS", "Scanning unary plus routine"),

        // https://skoolkid.github.io/rom/asm/25B3.html
        Meta(0x25b3, "S_QUOTE", "Scanning quote routine"),
        Meta(0x25be, "S_Q_AGAIN"),
        Meta(0x25cb, "S_Q_COPY"),
        Meta(0x25d9, "S_Q_PRMS"),
        Meta(0x25db, "S_STRING"),

        // https://skoolkid.github.io/rom/asm/25E8.html
        Meta(0x25e8, "S_BRACKET", "Scanning bracket routine"),

        // https://skoolkid.github.io/rom/asm/25F5.html
        Meta(0x25f5, "S_FN", "Scanning FN routine"),

        // https://skoolkid.github.io/rom/asm/25F8.html
        Meta(0x25f8, "S_RND", "Scanning RND routine"),
        Meta(0x2625, "S_RND_END"),

        // https://skoolkid.github.io/rom/asm/2627.html
        Meta(0x2627, "S_PI", "Scanning PI routine"),
        Meta(0x2630, "S_PI_END"),

        // https://skoolkid.github.io/rom/asm/2634.html
        Meta(0x2634, "S_INKEY", "Scanning INKEY$ routine"),
        Meta(0x2660, "S_IK_STK"),
        Meta(0x2665, "S_INK_EN"),

        //https://skoolkid.github.io/rom/asm/2668.html
        Meta(0x2668, "S_SCREEN", "Scanning SCREEN$ routine"),

        // https://skoolkid.github.io/rom/asm/2672.html
        Meta(0x2672, "S_ATTR", "Scanning ATTR routine"),

        // https://skoolkid.github.io/rom/asm/267B.html
        Meta(0x267b, "S_POINT", "Scanning POINT routine"),

        // https://skoolkid.github.io/rom/asm/2684.html
        Meta(0x2684, "S_ALPHNUM", "Scanning alpha-numeric routine"),

        // https://skoolkid.github.io/rom/asm/268D.html
        Meta(0x268d, "S_DECIMAL", "Scanning decimal routine"),
        Meta(0x26b5, "S_STK_DEC"),
        Meta(0x26b6, "S_SD_SKIP"),
        Meta(0x26c3, "S_NUMERIC"),

        // https://skoolkid.github.io/rom/asm/26C9.html
        Meta(0x26c9, "S_LETTER", "Scanning variable routine"),
        Meta(0x26dd, "S_CONT_1"),
        Meta(0x26df, "S_NEGATE"),
        Meta(0x2707, "S_NO_TO_S"),
        Meta(0x270d, "S_PUSH_PO"),
        Meta(0x2712, "S_CONT_2"),
        Meta(0x2713, "S_CONT_3"),
        Meta(0x2723, "S_OPERTR"),
        Meta(0x2734, "S_LOOP"),
        Meta(0x274c, "S_STK_LST"),
        Meta(0x275b, "S_SYNTEST"),
        Meta(0x2761, "S_RPORT_C_2"),
        Meta(0x2764, "S_RUNTEST"),
        Meta(0x2770, "S_LOOPEND"),
        Meta(0x2773, "S_TIGHTER"),
        Meta(0x2788, "S_NOT_AND"),
        Meta(0x2790, "S_NEXT"),

        // https://skoolkid.github.io/rom/asm/2795.html
        Meta(0x2795, "OPERATORS", "Table or operators"),

        // https://skoolkid.github.io/rom/asm/27B0.html
        Meta(0x27b0, "PRIORITIES", "Table of priorities"),

        // https://skoolkid.github.io/rom/asm/27BD.html
        Meta(0x27bd, "S_FN_SBRN", "Scanning FUNCTION routine"),
        Meta(0x27d0, "SF_BRKT_1"),
        Meta(0x27d9, "SF_ARGMTS"),
        Meta(0x27e4, "SF_BRKT_2"),
        Meta(0x27e6, "SF_BRKT_C"),
        Meta(0x27e9, "SF_FLAG_6"),
        Meta(0x27f4, "SF_SYN_EN"),
        Meta(0x27f7, "SF_RUN"),
        Meta(0x2802, "SF_ARGMT1"),
        Meta(0x2808, "SF_FND_DF"),
        Meta(0x2814, "SF_CP_DEF"),
        Meta(0x2825, "SF_NOT_FD"),
        Meta(0x2831, "SF_VALUES"),
        Meta(0x2843, "SF_ARG_LP"),
        Meta(0x2852, "SF_ARG_VL"),
        Meta(0x2885, "SF_R_BR_2"),
        Meta(0x288b, "REPORT_Q"),
        Meta(0x288d, "SF_VALUE"),

        // https://skoolkid.github.io/rom/asm/28AB.html
        Meta(0x28ab, "FN_SKPOVR", "Function skipover subroutine"),

        // https://skoolkid.github.io/rom/asm/28B2.html
        Meta(0x28b2, "LOOK_VARS", "Look-vars subroutine"),
        Meta(0x28d4, "V_CHAR"),
        Meta(0x28de, "V_STR_VAR"),
        Meta(0x28e3, "V_TEST_FN"),
        Meta(0x28ef, "V_RUN_SYN"),
        Meta(0x28fd, "V_RUN"),
        Meta(0x2900, "V_EACH"),
        Meta(0x2912, "V_MATCHES"),
        Meta(0x2913, "V_SPACES"),
        Meta(0x2929, "V_GET_PTR"),
        Meta(0x292a, "V_NEXT"),
        Meta(0x2932, "V_80_BYTE"),
        Meta(0x2934, "V_SYNTAX"),
        Meta(0x293e, "V_FOUND_1"),
        Meta(0x293f, "V_FOUND_2"),
        Meta(0x2943, "V_PASS"),
        Meta(0x294b, "V_END"),

        // https://skoolkid.github.io/rom/asm/2951.html
        Meta(0x2951, "STK_F_ARG", "Stack function argument subroutine"),
        Meta(0x295a, "SFA_LOOP"),
        Meta(0x296b, "SFA_CP_VR"),
        Meta(0x2981, "SFA_MATCH"),
        Meta(0x2991, "SFA_END"),

        // https://skoolkid.github.io/rom/asm/2996.html
        Meta(0x2996, "STK_VAR", "Stk-var subroutine"),
        Meta(0x29a1, "SV_SIMPLE"),
        Meta(0x29ae, "SV_ARRAYS"),
        Meta(0x29c0, "SV_PTR"),
        Meta(0x29c3, "SV_COMMA"),
        Meta(0x29d8, "SV_CLOSE"),
        Meta(0x29e0, "SV_CH_ADD"),
        Meta(0x29e7, "SV_COUNT"),
        Meta(0x29ea, "SV_LOOP"),
        Meta(0x29fb, "SV_MULT"),
        Meta(0x2a12, "SV_RPT_C"),
        Meta(0x2a20, "REPORT_3"),
        Meta(0x2a22, "SV_NUMBER"),
        Meta(0x2a2c, "SV_ELEM"),
        Meta(0x2a45, "SV_SLICE"),
        Meta(0x2a48, "SV_DIM"),
        Meta(0x2a49, "SV_SLICE2"),

        // https://skoolkid.github.io/rom/asm/2A52.html
        Meta(0x2a52, "SLICING", "Slicing subroutine"),
        Meta(0x2a7a, "SL_RPT_C"),
        Meta(0x2a81, "SL_SECOND"),
        Meta(0x2a94, "SL_DEFINE"),
        Meta(0x2aa8, "SL_OVER"),
        Meta(0x2aad, "SL_STORE"),

        // https://skoolkid.github.io/rom/asm/2AB1.html
        Meta(0x2ab1, "STK_ST_0", "Stk-storee subroutine"),
        Meta(0x2ab2, "STK_STO"),
        Meta(0x2ab6, "STK_STORE"),

        // https://skoolkid.github.io/rom/asm/2ACC.html
        Meta(0x2acc, "INT_EXP1", "Int-exp subroutine"),
        Meta(0x2acd, "INT_EXP2"),
        Meta(0x2ae8, "I_CARRY"),
        Meta(0x2aeb, "I_RESTORE"),

        // https://skoolkid.github.io/rom/asm/2AEE.html
        Meta(0x2aee, "DE_DE_1", "DX,(DE+1) subroutine"),

        // https://skoolkid.github.io/rom/asm/2AF4.html
        Meta(0x2af4, "GET_HLxDE", "GET HL*DE subroutine"),

        // https://skoolkid.github.io/rom/asm/2AFF.html
        Meta(0x2aff, "LET", "LET command routine"),
        Meta(0x2b0b, "L_EACH_CH"),
        Meta(0x2b0c, "L_NO_SP"),
        Meta(0x2b1f, "L_TEST_CH"),
        Meta(0x2b29, "L_SPACES"),
        Meta(0x2b3e, "L_CHAR"),
        Meta(0x2b4f, "L_SINGLE"),
        Meta(0x2b59, "L_NUMERIC"),
        Meta(0x2b66, "L_EXISTS"),
        Meta(0x2b72, "L_DELETE"),
        Meta(0x2b9b, "L_LENGTH"),
        Meta(0x2ba3, "L_IN_W_S"),
        Meta(0x2ba6, "L_ENTER"),
        Meta(0x2baf, "L_ADD"),
        Meta(0x2bc0, "L_NEW"),
        Meta(0x2bc6, "L_STRING"),
        Meta(0x2bea, "L_FIRST"),

        // https://skoolkid.github.io/rom/asm/2BF1.html
        Meta(0x2bf1, "STK_FETCH", "Stk-fetch subroutine"),

        // https://skoolkid.github.io/rom/asm/2C02.html
        Meta(0x2c02, "DIM", "DIM command routine"),
        Meta(0x2c05, "D_RPORT_C"),
        Meta(0x2c15, "D_RUN"),
        Meta(0x2c1f, "D_LETTER"),
        Meta(0x2c2d, "D_SIZE"),
        Meta(0x2c2e, "D_NO_LOOP"),
        Meta(0x2c7c, "DIM_CLEAR"),
        Meta(0x2c7f, "DIM_SIZES"),

        // https://skoolkid.github.io/rom/asm/2C88.html
        Meta(0x2c88, "ALPHANUM", "Alphanum subroutine"),

        // https://skoolkid.github.io/rom/asm/2C8D.html
        Meta(0x2c8d, "ALPHA", "Alpha subroutine"),

        // https://skoolkid.github.io/rom/asm/2C9B.html
        Meta(0x2c9b, "DEC_TO_FP", "Decimal to float subroutine"),
        Meta(0x2ca2, "BIN_DIGIT"),
        Meta(0x2cb3, "BIN_END"),
        Meta(0x2cb8, "NOT_BIN"),
        Meta(0x2ccb, "DECIMAL"),
        Meta(0x2ccf, "DEC_RPT_CT"),
        Meta(0x2cd5, "DEC_STO_1"),
        Meta(0x2cda, "NXT_DGT_1"),
        Meta(0x2ceb, "E_FORMAT"),
        Meta(0x2cf2, "SIGN_FLAG"),
        Meta(0x2cfe, "SIGN_DONE"),
        Meta(0x2cff, "ST_E_PART"),
        Meta(0x2d18, "E_FP_JUMP"),

        // https://skoolkid.github.io/rom/asm/2D1B.html
        Meta(0x2d1b, "NUMERIC", "Numeric subroutine"),

        // https://skoolkid.github.io/rom/asm/2D22.html
        Meta(0x2d22, "STK_DIGIT", "Stk-digit subroutine"),

        // https://skoolkid.github.io/rom/asm/2D28.html
        Meta(0x2d28, "STACK_A", "Stack-a subroutine"),

        // https://skoolkid.github.io/rom/asm/2D2B.html
        Meta(0x2d2b, "STACK_BC", "Stack-bc subroutine"),

        // https://skoolkid.github.io/rom/asm/2D3B.html
        Meta(0x2d3b, "INT_TO_FP", "Integer to float subroutine"),
        Meta(0x2d40, "NXT_DGT_2"),

        // https://skoolkid.github.io/rom/asm/2D4F.html
        Meta(0x2d4f, "e_to_fp", "E-format to float subroutine"),
        Meta(0x2d55, "E_SAVE"),
        Meta(0x2d60, "E_LOOP"),
        Meta(0x2d6d, "E_DIVSN"),
        Meta(0x2d6e, "E_FETCH"),
        Meta(0x2d71, "E_TST_END"),
        Meta(0x2d7b, "E_END"),

        // https://skoolkid.github.io/rom/asm/2D7F.html
        Meta(0x2d7f, "INT_FETCH", "Int-fetch subroutine"),

        // https://skoolkid.github.io/rom/asm/2D8C.html
        Meta(0x2d8c, "P_INT_STO", "Positive integer store"),

        // https://skoolkid.github.io/rom/asm/2D8E.html
        Meta(0x2d8e, "INT_STORE", "Int store subroutine"),

        // https://skoolkid.github.io/rom/asm/2DA2.html
        Meta(0x2da2, "FP_TO_BC", "float to BC subroutine"),
        Meta(0x2dad, "FP_DELETE"),

        // https://skoolkid.github.io/rom/asm/2DC1.html
        Meta(0x2dc1, "LOG_2_A", "LOG(2^A) subroutine"),

        // https://skoolkid.github.io/rom/asm/2DD5.html
        Meta(0x2dd5, "FP_TO_A", "float to A subroutine"),
        Meta(0x2de1, "FP_A_END"),

        // https://skoolkid.github.io/rom/asm/2DE3.html
        Meta(0x2de3, "PRINT_FP", "Print float subroutine"),
        Meta(0x2df2, "PF_NEGTVE"),
        Meta(0x2df8, "PF_NPSTVE"),
        Meta(0x2e01, "PF_LOOP"),
        Meta(0x2e1e, "PF_SAVE"),
        Meta(0x2e24, "PF_SMALL"),
        Meta(0x2e56, "PF_LARGE"),
        Meta(0x2e6f, "PF_MEDIUM"),
        Meta(0x2e7b, "PF_BITS"),
        Meta(0x2e8a, "PF_BYTES"),
        Meta(0x2ea1, "PF_DIGITS"),
        Meta(0x2ea9, "PF_INSERT"),
        Meta(0x2eb3, "PF_TEST_2"),
        Meta(0x2eb8, "PF_ALL_9"),
        Meta(0x2ecb, "PF_MORE"),
        Meta(0x2ecf, "PF_FRACTN"),
        Meta(0x2edf, "PF_FRN_LP"),
        Meta(0x2eec, "PF_FR_DGT"),
        Meta(0x2eef, "PF_FR_EXX"),
        Meta(0x2f0c, "PF_ROUND"),
        Meta(0x2f18, "PF_RND_LP"),

        Meta(0x2f25, "PF_R_BACK"),
        Meta(0x2f2d, "PF_COUNT"),
        Meta(0x2f46, "PF_NOT_E"),
        Meta(0x2f4a, "PF_E_SBRN"),
        Meta(0x2f52, "PF_OUT_LP"),
        Meta(0x2f59, "PF_OUT_DT"),
        Meta(0x2f5e, "PF_DC_OUT"),
        Meta(0x2f64, "PF_DEC_0S"),
        Meta(0x2f6c, "PF_E_FRMT"),
        Meta(0x2f83, "PF_E_POS"),
        Meta(0x2f85, "PF_E_SIGN"),

        // https://skoolkid.github.io/rom/asm/2F8B.html
        Meta(0x2f8b, "CA_10A_C", "CA=10*A+c subroutine"),

        // https://skoolkid.github.io/rom/asm/2F9B.html
        Meta(0x2f9b, "PREP_ADD", "Prepare to add subroutine"),
        Meta(0x2faf, "NEG_BYTE"),

        // https://skoolkid.github.io/rom/asm/2FBA.html
        Meta(0x2fba, "FETCH_TWO", "Fetch two numbers subroutine"),

        // https://skoolkid.github.io/rom/asm/2FDD.html
        Meta(0x2fdd, "SHIFT_FP", "Shift append subroutine"),
        Meta(0x2fe5, "ONE_SHIFT"),
        Meta(0x2ff9, "ADDEND_0"),
        Meta(0x2ffb, "ZEROS_4_5"),

        // https://skoolkid.github.io/rom/asm/3004.html
        Meta(0x3004, "ADD_BACK", "Add-back subroutine"),
        Meta(0x300d, "ALL_ADDED"),

        // https://skoolkid.github.io/rom/asm/300F.html

        Meta(0x300f, "subtract", "The subtraction operation"),

        // https://skoolkid.github.io/rom/asm/3014.html

        Meta(0x3014, "addition", "The addition operation"),
        Meta(0x303c, "ADDN_OFLW"),
        Meta(0x303e, "FULL_ADDN"),
        Meta(0x3055, "SHIFT_LEN"),
        Meta(0x307c, "TEST_NEG"),
        Meta(0x309f, "ADD_REP_6"),
        Meta(0x30a3, "END_COMPL"),
        Meta(0x30a5, "GO_NC_MLT"),

        // https://skoolkid.github.io/rom/asm/30A9.html
        Meta(0x30a9, "HL_HLxDE", "HL = HL*DE subroutine"),
        Meta(0x30b1, "HL_LOOP"),
        Meta(0x30bc, "HL_AGAIN"),
        Meta(0x30be, "HL_END"),

        // https://skoolkid.github.io/rom/asm/30C0.html
        Meta(0x30c0, "PREP_M_D", "Prepare to multiply or divide"),

        // https://skoolkid.github.io/rom/asm/30CA.html
        Meta(0x30ca, "multiply", "Multiplication operation"),
        Meta(0x30ea, "MULT_RSLT"),
        Meta(0x30ef, "MULT_OFLW"),
        Meta(0x30f0, "MULT_LONG"),
        Meta(0x3114, "MLT_LOOP"),
        Meta(0x311b, "NO_ADD"),
        Meta(0x3125, "STRT_MLT"),
        Meta(0x313b, "MAKE_EXPT"),
        Meta(0x313d, "DIVN_EXPT"),
        Meta(0x3146, "OFLW1_CLR"),
        Meta(0x3151, "OFLW2_CLS"),
        Meta(0x3155, "TEST_NORM"),
        Meta(0x3159, "NEAR_ZERO"),
        Meta(0x315d, "ZERO_RSLT"),
        Meta(0x315e, "SKIP_ZERO"),
        Meta(0x316c, "NORMALISE"),
        Meta(0x316e, "SHIFT_ONE"),
        Meta(0x3186, "NORML_NOW"),
        Meta(0x3195, "OFLOW_CLR"),
        Meta(0x31ad, "REPORT_6"),

        // https://skoolkid.github.io/rom/asm/31AF.html
        Meta(0x31af, "division"),
        Meta(0x31d2, "DIV_LOOP"),
        Meta(0x31db, "DIV_34TH"),
        Meta(0x31e2, "DIV_START"),
        Meta(0x31f2, "SUBN_ONLY"),
        Meta(0x31f9, "NO_RSTORE"),
        Meta(0x31fa, "COUNT_ONE"),

        // https://skoolkid.github.io/rom/asm/3214.html
        Meta(0x3214, "truncate", "Integer truncation towards zero subroutine"),
        Meta(0x3221, "T_GR_ZERO"),
        Meta(0x3233, "T_FIRST"),
        Meta(0x323f, "T_SMALL"),
        Meta(0x3252, "T_NUMERIC"),
        Meta(0x325e, "T_TEST"),
        Meta(0x3261, "T_SHIFT"),
        Meta(0x3267, "T_STORE"),
        Meta(0x326c, "T_EXPNENT"),
        Meta(0x326d, "X_LARGE"),
        Meta(0x3272, "NIL_BYTES"),
        Meta(0x327e, "BYTE_ZERO"),
        Meta(0x3283, "BITS_ZERO"),
        Meta(0x328a, "LESS_MASK"),
        Meta(0x3290, "IX_END"),

        // https://skoolkid.github.io/rom/asm/3293.html
        Meta(0x3293, "RE_ST_TWO", "Re-stack two subroutine"),
        Meta(0x3296, "RESTK_SUB"),

        // https://skoolkid.github.io/rom/asm/3297.html
        Meta(0x3297, "re_stack", "Re-stack subroutine"),
        Meta(0x32b1, "RS_NRMLSE"),
        Meta(0x32b2, "RSTK_LOOP"),
        Meta(0x32bd, "RS_STORE"),

        // https://skoolkid.github.io/rom/asm/32C5.html
        Meta(0x32c5, "CONSTANTS", "Table of constants"),
        Meta(0x32c8, "stk_one"),
        Meta(0x32cc, "stk_half"),
        Meta(0x32ce, "stk_pi_2"),
        Meta(0x32d3, "stk_ten"),

        // https://skoolkid.github.io/rom/asm/32D7.html
        Meta(0x32d7, "CALCADDR", "Table of addresses"),

        // https://skoolkid.github.io/rom/asm/335B.html
        Meta(0x335b, "CALCULATE", "Calculate subroutine"),
        Meta(0x335e, "GEN_END_1"),
        Meta(0x3362, "GEN_END_2"),
        Meta(0x3365, "RE_ENTRY"),
        Meta(0x336c, "SCAN_ENT"),
        Meta(0x3380, "FIRST_3D"),
        Meta(0x338c, "DOUBLE_A"),
        Meta(0x338e, "END_TABLE"),
        Meta(0x33a1, "delete"),

        // https://skoolkid.github.io/rom/asm/33A2.html
        Meta(0x33a2, "fp_calc_2", "Single operation subroutine"),

        // https://skoolkid.github.io/rom/asm/33A9.html
        Meta(0x33a9, "TEST_5_SP", "Test 5 spaces subroutine"),

        // https://skoolkid.github.io/rom/asm/33B4.html
        Meta(0x33b4, "STACK_NUM", "Stack number subroutine"),

        // https://skoolkid.github.io/rom/asm/33C0.html
        Meta(0x33c0, "duplicate", "Mova a float number subroutine"),

        // https://skoolkid.github.io/rom/asm/33C6.html
        Meta(0x33c6, "stk_data", "Stack literals subroutine"),
        Meta(0x33c8, "STK_CONST"),
        Meta(0x33de, "FORM_EXP"),
        Meta(0x33f1, "STK_ZEROS"),

        // https://skoolkid.github.io/rom/asm/33F7.html
        Meta(0x33f7, "SKIP_CONS", "Skip constants subroutine"),
        Meta(0x33f8, "SKIP_NEXT"),

        // https://skoolkid.github.io/rom/asm/3406.html
        Meta(0x3406, "LOC_MEM", "Memory location subroutine"),

        // https://skoolkid.github.io/rom/asm/340F.html
        Meta(0x340f, "get_mem", "Get from memory area subroutine"),

        // https://skoolkid.github.io/rom/asm/341B.html
        Meta(0x341b, "stk_con", "Stack A constant subroutine"),

        // https://skoolkid.github.io/rom/asm/342D.html
        Meta(0x342d, "st_mem", "Store in memory area subroutine"),

        // https://skoolkid.github.io/rom/asm/343C.html
        Meta(0x343c, "exchange", "Exchange subroutine"),
        Meta(0x343e, "SWAP_BYTE"),

        // https://skoolkid.github.io/rom/asm/3449.html
        Meta(0x3449, "series", "Series generator subroutine"),
        Meta(0x3453, "G_LOOP"),

        // https://skoolkid.github.io/rom/asm/346A.html
        Meta(0x346a, "abs", "Absolute magnitude function"),

        // https://skoolkid.github.io/rom/asm/346E.html
        Meta(0x346e, "negate", "Unary minus operation"),
        Meta(0x3474, "NEG_TEST"),
        Meta(0x3483, "INT_CASE"),

        // https://skoolkid.github.io/rom/asm/3492.html
        Meta(0x3492, "sgn", "Signum function"),

        // https://skoolkid.github.io/rom/asm/34A5.html
        Meta(0x34a5, "f_in", "IN function"),

        // https://skoolkid.github.io/rom/asm/34AC.html
        Meta(0x34ac, "peek", "PEEK function"),
        Meta(0x34b0, "IN_PK_STK"),

        // https://skoolkid.github.io/rom/asm/34B3.html
        Meta(0x34b3, "usr_no", "USR function"),

        // https://skoolkid.github.io/rom/asm/34BC.html
        Meta(0x34bc, "usr", "USR STRING function"),
        Meta(0x34d3, "USR_RANGE"),
        Meta(0x34e4, "USR_STACK"),
        Meta(0x34e7, "REPORT_A"),

        // https://skoolkid.github.io/rom/asm/34E9.html
        Meta(0x34e9, "TEST_ZERO", "Test-zero subroutine"),

        // https://skoolkid.github.io/rom/asm/34F9.html
        Meta(0x34f9, "greater_0", "Greater than zero operation"),

        // https://skoolkid.github.io/rom/asm/3501.html
        Meta(0x3501, "f_not", "NOT function"),

        // https://skoolkid.github.io/rom/asm/3506.html
        Meta(0x3506, "less_0", "Less than zero operation"),
        Meta(0x3507, "SIGN_TO_C"),

        // https://skoolkid.github.io/rom/asm/350B.html
        Meta(0x350b, "FP_0_1", "Zero or one subroutine"),

        // https://skoolkid.github.io/rom/asm/351B.html
        Meta(0x351b, "no_or_no", "OR operation"),

        // https://skoolkid.github.io/rom/asm/3524.html
        Meta(0x3524, "no_and_no", "Number AND number operation"),

        // https://skoolkid.github.io/rom/asm/352D.html
        Meta(0x352d, "str_no", "String and number operation"),

        // https://skoolkid.github.io/rom/asm/353B.html
        Meta(0x353b, "compare", "Comparison operations"),
        Meta(0x3543, "EX_OR_NOT"),
        Meta(0x354e, "NU_OR_STR"),
        Meta(0x3559, "STRINGS"),
        Meta(0x3564, "BYTE_COMP"),
        Meta(0x356b, "SECND_LOW"),
        Meta(0x3572, "BOTH_NULL"),
        Meta(0x3575, "SEC_PLUS"),
        Meta(0x3585, "FRST_LESS"),
        Meta(0x3588, "STR_TEST"),
        Meta(0x358c, "END_TESTS"),

        // https://skoolkid.github.io/rom/asm/359C.html
        Meta(0x359c, "strs_add", "String concatenation operation"),
        Meta(0x35b7, "OTHER_STR"),

        // https://skoolkid.github.io/rom/asm/35BF.html
        Meta(0x35bf, "STK_PNTRS", "Stk-pntrs subroutine"),

        // https://skoolkid.github.io/rom/asm/35C9.html
        Meta(0x35c9, "chrs", "CHR$ function"),
        Meta(0x35dc, "REPORT_B_4"),

        // https://skoolkid.github.io/rom/asm/35DE.html
        Meta(0x35de, "val", "VAL and VAL$ functions"),
        Meta(0x360c, "V_RPORT_C"),

        // https://skoolkid.github.io/rom/asm/361F.html
        Meta(0x361f, "str", "STR$ function"),

        // https://skoolkid.github.io/rom/asm/3645.html
        Meta(0x3645, "read_in", "READ-IN subroutine"),
        Meta(0x365f, "R_I_STORE"),

        // https://skoolkid.github.io/rom/asm/3669.html
        Meta(0x3669, "code", "CODE function"),
        Meta(0x3671, "STK_CODE"),

        // https://skoolkid.github.io/rom/asm/3674.html
        Meta(0x3674, "len", "LEN function"),

        // https://skoolkid.github.io/rom/asm/367A.html
        Meta(0x367a,  "dec_jr_nz", "Decrease the counter subroutine"),

        // https://skoolkid.github.io/rom/asm/3686.html
        Meta(0x3686, "jump", "JUMP subroutine"),
        Meta(0x3687, "JUMP_2"),

        // https://skoolkid.github.io/rom/asm/368F.html
        Meta(0x368f, "jump_true", "JUMP on true subroutine"),

        // https://skoolkid.github.io/rom/asm/369B.html
        Meta(0x369b, "end_calc", "End-calc subroutine"),

        // https://skoolkid.github.io/rom/asm/36A0.html
        Meta(0x36a0, "n_mod_m", "Modulus subroutine"),

        // https://skoolkid.github.io/rom/asm/36AF.html
        Meta(0x36af, "int", "INT function"),
        Meta(0x36b7, "X_NEG"),
        Meta(0x36c2, "EXIT"),

        // https://skoolkid.github.io/rom/asm/36C4.html
        Meta(0x36c4, "exp"),
        Meta(0x3703, "REPORT_6_2"),
        Meta(0x3705, "N_NEGTV"),
        Meta(0x370c, "RESULT_OK"),
        Meta(0x370e, "RSLT_ZERO"),

        // https://skoolkid.github.io/rom/asm/3713.html
        Meta(0x3713, "ln", "Natural logarithm function"),
        Meta(0x371c, "VALID"),
        Meta(0x373d, "GRE_8"),

        // https://skoolkid.github.io/rom/asm/3783.html
        Meta(0x3783, "get_argt", "Reduce argument subroutine"),
        Meta(0x37a1, "ZPLUS"),
        Meta(0x37a8, "YNEG"),

        // https://skoolkid.github.io/rom/asm/37AA.html
        Meta(0x37aa, "cos", "COSINE function"),

        // https://skoolkid.github.io/rom/asm/37B5.html
        Meta(0x37b5, "sin", "SINE function"),
        Meta(0x37b7, "C_ENT"),

        // https://skoolkid.github.io/rom/asm/37DA.html
        Meta(0x37da, "tab", "TAB function"),

        // https://skoolkid.github.io/rom/asm/37E2.html
        Meta(0x37e2, "atn", "ARCTAN routine"),
        Meta(0x37f8, "SMALL"),
        Meta(0x37fa, "CASES"),

        // https://skoolkid.github.io/rom/asm/3833.html
        Meta(0x3833, "asn", "ARCSIN function"),

        // https://skoolkid.github.io/rom/asm/3843.html
        Meta(0x3843, "acs", "ARCCOS function"),

        // https://skoolkid.github.io/rom/asm/384A.html
        Meta(0x384a, "sqr", "SQRT function"),

        // https://skoolkid.github.io/rom/asm/3851.html
        Meta(0x3851, "to_power", "Exponentiation operation"),
        Meta(0x385d, "XIS0"),
        Meta(0x386a, "ONE"),
        Meta(0x386c, "LAST"),

        // https://skoolkid.github.io/rom/asm/3D00.html
        Meta(0x3d00, "CHARSET", "Character set"),

        // https://skoolkid.github.io/rom/asm/5C00.html
        Meta(0x5c00, "KSTATE", "KSTATE - Keyboard"),

        // https://skoolkid.github.io/rom/asm/5C08.html
        Meta(0x5c08, "LAST_K", "Last key pressed"),

        // https://skoolkid.github.io/rom/asm/5C09.html
        Meta(0x5c09, "REPDEL", "Keyboard repeat delay"),

        // https://skoolkid.github.io/rom/asm/5C0A.html
        Meta(0x5c0a, "REPPER", "Keyboard repeat rate"),

        // https://skoolkid.github.io/rom/asm/5C0B.html
        Meta(0x5c0b, "DEFADD", "Address of args of user defined variables"),

        // https://skoolkid.github.io/rom/asm/5C0D.html
        Meta(0x5c0d, "K_DATA", "Second byte of colour controls entered from keyboard"),

        // https://skoolkid.github.io/rom/asm/5C0E.html
        Meta(0x5c0e, "TVDATA", "Colour, AT abd TAB controls going to TV"),

        // https://skoolkid.github.io/rom/asm/5C10.html
        Meta(0x5c10, "STRMS", "Addresses of channels attached to streams"),

        // https://skoolkid.github.io/rom/asm/5C36.html
        Meta(0x5c36, "CHARS", "256 less than address of character set"),

        // https://skoolkid.github.io/rom/asm/5C38.html
        Meta(0x5c38, "RASP", "Length of warning buzz"),

        // https://skoolkid.github.io/rom/asm/5C39.html
        Meta(0x5c39, "PIP", "Length of keyboard click"),

        // https://skoolkid.github.io/rom/asm/5C3A.html
        Meta(0x5c3a, "ERR_NR", "Error report code - 1"),

        // https://skoolkid.github.io/rom/asm/5C3B.html
        Meta(0x5c3b, "FLAGS", "BASIC flags"),

        // https://skoolkid.github.io/rom/asm/5C3C.html
        Meta(0x5c3c, "TV_FLAG", "TV flags"),

        // https://skoolkid.github.io/rom/asm/5C3D.html
        Meta(0x5c3d, "ERR_SP", "Address of item on machine stack to use as error return"),

        // https://skoolkid.github.io/rom/asm/5C3F.html
        Meta(0x5c3f, "LIST_SP", "Return address from auto listing"),

        // https://skoolkid.github.io/rom/asm/5C41.html
        Meta(0x5c41, "MODE", "K, L, C, E or G cursor"),

        // https://skoolkid.github.io/rom/asm/5C42.html
        Meta(0x5c42, "NEWPPC", "Line to be jumped to"),

        // https://skoolkid.github.io/rom/asm/5C44.html
        Meta(0x5c44, "NSPPC", "Statement number in line to be jumped to"),

        // https://skoolkid.github.io/rom/asm/5C45.html
        Meta(0x5c45, "PPC", "Line number of statement being executed"),

        // https://skoolkid.github.io/rom/asm/5C47.html
        Meta(0x5c47, "SUBPPC", "Statement number within line being executed"),

        // https://skoolkid.github.io/rom/asm/5C48.html
        Meta(0x5c48, "Border colour"),

        // https://skoolkid.github.io/rom/asm/5C49.html
        Meta(0x5c49, "E_PPC", "Number of current line"),

        // https://skoolkid.github.io/rom/asm/5C4B.html
        Meta(0x5c4b, "VARS", "Address of variables"),

        // https://skoolkid.github.io/rom/asm/5C4D.html
        Meta(0x5c4d, "DEST", "Address of variable in assignment"),

        // https://skoolkid.github.io/rom/asm/5C4F.html
        Meta(0x5c4f, "CHANS", "Address of channel data"),

        // https://skoolkid.github.io/rom/asm/5C51.html
        Meta(0x5c51, "CURCHL", "Address of information used for input and output"),

        // https://skoolkid.github.io/rom/asm/5C53.html
        Meta(0x5c53, "PROG", "Address of BASIC program"),

        // https://skoolkid.github.io/rom/asm/5C55.html
        Meta(0x5c55, "NXTLIN", "Address of next line of program"),

        // https://skoolkid.github.io/rom/asm/5C57.html
        Meta(0x5c57, "DATADD", "Address of terminator of last DATA item"),

        // https://skoolkid.github.io/rom/asm/5C59.html
        Meta(0x5c59, "E_LINE", "Address of command being typed in"),

        // https://skoolkid.github.io/rom/asm/5C5B.html
        Meta(0x5c5b, "K_CUR", "Address of cursor"),

        // https://skoolkid.github.io/rom/asm/5C5D.html
        Meta(0x5c5d, "CH_ADD", "Address of next character to be interpreted"),

        // https://skoolkid.github.io/rom/asm/5C5F.html
        Meta(0x5c5f, "X_PTR", "Address of the character after the '?' marker"),

        // https://skoolkid.github.io/rom/asm/5C61.html
        Meta(0x5c61, "WORKSP", "Address of temporary work space"),

        // https://skoolkid.github.io/rom/asm/5C63.html
        Meta(0x5c63, "STKBOT", "Address of bottom of calculator stack"),

        // https://skoolkid.github.io/rom/asm/5C65.html
        Meta(0x5c65, "STKEND", "Address of start of spare space"),

        // https://skoolkid.github.io/rom/asm/5C67.html
        Meta(0x5c67, "BREG", "Calculator's B register"),

        // https://skoolkid.github.io/rom/asm/5C68.html
        Meta(0x5c68, "MEM", "Address of area used for calculator's memory"),

        // https://skoolkid.github.io/rom/asm/5C6A.html
        Meta(0x5c6a, "FLAGS2", "More flags"),

        // https://skoolkid.github.io/rom/asm/5C6B.html
        Meta(0x5c6b, "DF_SZ", "Number of lines in the lower part of the screen"),

        // https://skoolkid.github.io/rom/asm/5C6C.html
        Meta(0x5c6c, "S_TOP", "Number of the top program line in auto listing"),

        // https://skoolkid.github.io/rom/asm/5C6E.html
        Meta(0x5c6e, "OLDPPC", "Line number to which CONTINUE jumps"),

        // https://skoolkid.github.io/rom/asm/5C70.html
        Meta(0x5c70, "OSPCC", "Number within line of statement to which CONTINUE jumps"),

        // https://skoolkid.github.io/rom/asm/5C71.html
        Meta(0x5c71, "FLAGX", "Various flags"),

        // https://skoolkid.github.io/rom/asm/5C72.html
        Meta(0x5c72, "STRLEN", "Length of string type destination assignment"),

        // https://skoolkid.github.io/rom/asm/5C74.html
        Meta(0x5c74, "T_ADDR", "Address of next item in parameter table"),

        // https://skoolkid.github.io/rom/asm/5C76.html
        Meta(0x5c76, "SEED", "The seed for RND"),

        // https://skoolkid.github.io/rom/asm/5C78.html
        Meta(0x5c78, "FRAMES", "Frame counter"),

        // https://skoolkid.github.io/rom/asm/5C7B.html
        Meta(0x5c7b, "UDG", "Address of first user defined graphic"),

        // https://skoolkid.github.io/rom/asm/5C7D.html
        Meta(0x5c7d, "COORDS", "Coordinates of last point plotted"),

        // https://skoolkid.github.io/rom/asm/5C7F.html
        Meta(0x5c7f, "P_POSN", "Column number of printer position"),

        // https://skoolkid.github.io/rom/asm/5C80.html
        Meta(0x5c80, "PR_CC", "Address of next position for LPRINT to print at"),

        // https://skoolkid.github.io/rom/asm/5C82.html
        Meta(0x5c82, "ECHO_E", "Column and line number of end of input buffer"),

        // https://skoolkid.github.io/rom/asm/5C84.html
        Meta(0x5c84, "DF_CC", "Address in display file of PRINT position"),

        // https://skoolkid.github.io/rom/asm/5C86.html
        Meta(0x5c86, "DF_CCL", "Like DF-CC for lower part of screen"),

        // https://skoolkid.github.io/rom/asm/5C88.html
        Meta(0x5c88, "S_POSN", "Column and line number for PRINT position"),

        // https://skoolkid.github.io/rom/asm/5C8A.html
        Meta(0x5c8a, "S_POSNL", "Like S_POSN for lower part of screen"),

        // https://skoolkid.github.io/rom/asm/5C8C.html
        Meta(0x5c8c, "SCR_CT", "Scroll counter"),

        // https://skoolkid.github.io/rom/asm/5C8D.html
        Meta(0x5c8d, "ATTR_P", "Permanent current colours"),

        // https://skoolkid.github.io/rom/asm/5C8E.html
        Meta(0x5c8e, "MASK_P", "Used for transparent colours"),

        // https://skoolkid.github.io/rom/asm/5C8F.html
        Meta(0x5c8f, "ATTR_T", "Temporary current colours"),

        // https://skoolkid.github.io/rom/asm/5C90.html
        Meta(0x5c90, "MASK_T", "Temporary transparent colours"),

        // https://skoolkid.github.io/rom/asm/5C91.html
        Meta(0x5c91, "P_FLAG", "More flags"),

        // https://skoolkid.github.io/rom/asm/5C92.html
        Meta(0x5c92, "MEMBOT", "Calculators's memory area"),

        // https://skoolkid.github.io/rom/asm/5CB0.html
        Meta(0x5cb0, "NMIADD", "Non-maskable interrupt address"),

        // https://skoolkid.github.io/rom/asm/5CB2.html
        Meta(0x5cb2, "RAMTOP", "Address of last byte of BASIC system area"),

        // https://skoolkid.github.io/rom/asm/5CB4.html
        Meta(0x5cb4, "P_RAMT", "Address of last byte of physical RAM"),

        // https://skoolkid.github.io/rom/asm/5CB6.html
        Meta(0x5cb6, "CHINFO", "Channel information")
    ];
}
