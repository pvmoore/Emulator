module emulator.chips.z80._test.bit;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

void bit() {
    cpu.reset();

    foreach(BIT; 0..8) {
        auto i     = 0x40 + BIT*8;
        auto regs  = "bcdehla";
        auto bytes = cast(ubyte[])[i+0, i+1, i+2, i+3, i+4, i+5, i+7];

        foreach(j; 0..7) {
            auto r = regs[j];
            auto n = bytes[j];

            state.A = 0xff;
            state.B = 0xff;
            state.C = 0xff;
            state.D = 0xff;
            state.E = 0xff;
            state.H = 0xff;
            state.L = 0xff;
            test("\tbit %s, %s".format(BIT, r), [0xcb, n]);

            assertFlagsSet(H);
            assertFlagsClear(N, Z);

            state.A = 0x00;
            state.B = 0x00;
            state.C = 0x00;
            state.D = 0x00;
            state.E = 0x00;
            state.H = 0x00;
            state.L = 0x00;
            test("\tbit %s, %s".format(BIT, r), [0xcb, n]);

            assertFlagsSet(H, Z);
            assertFlagsClear(N);
        }

        writeBytes(0x0000, [0xff, 0x00]);

        state.HL = 0x0000;
        test("\tbit %s, (hl)".format(BIT), [0xcb, (i+6).as!ubyte]);

        assertFlagsSet(H);
        assertFlagsClear(N, Z);

        state.HL = 0x0001;
        test("\tbit %s, (hl)".format(BIT), [0xcb, (i+6).as!ubyte]);

        assertFlagsSet(H, Z);
        assertFlagsClear(N);
    }
}

setup();

bit();

} // unittest