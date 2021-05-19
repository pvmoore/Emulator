module emulator.chips.z80._test.res;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

void res() {
    cpu.reset();

    foreach(BIT; 0..8) {
        auto i      = 0x80 + BIT*8;
        auto regStr = "bcdehla";
        auto bytes  = cast(ubyte[])[i+0, i+1, i+2, i+3, i+4, i+5, i+7];
        auto regs   = [Reg.B, Reg.C, Reg.D, Reg.E, Reg.H, Reg.L, Reg.A];
        ubyte expected = (0xff & ~(1<<BIT)).as!ubyte;

        foreach(j; 0..7) {
            auto r = regStr[j];
            auto n = bytes[j];
            auto reg = regs[j];

            state.setReg8(reg, 0xff);
            test("\tres %s, %s".format(BIT, r), [0xcb, n]);

            assert(state.getReg8(reg) == expected);
            assertFlagsClear(allFlags());

            state.setReg8(reg, 0x00);
            test("\tres %s, %s".format(BIT, r), [0xcb, n]);

            assert(state.getReg8(reg) == 0x00);
            assertFlagsClear(allFlags());
        }

        writeBytes(0x0000, [0xff, 0x00]);

        state.HL = 0x0000;
        test("\tres %s, (hl)".format(BIT), [0xcb, (i+6).as!ubyte]);

        assert(bus.read(0x0000) == expected);
        assertFlagsClear(allFlags());

        state.HL = 0x0001;
        test("\tres %s, (hl)".format(BIT), [0xcb, (i+6).as!ubyte]);

        assert(bus.read(0x0001) == 0x00);
        assertFlagsClear(allFlags());


        state.IX = 0x0000;
        test("\tres %s, (ix+$00)".format(BIT), [0xdd, 0xcb, (i+6).as!ubyte, 0x00]);

        assert(bus.read(0x0000) == expected);
        assertFlagsClear(allFlags());

        state.IX = 0x0001;
        test("\tres %s, (ix+$00)".format(BIT), [0xdd, 0xcb, (i+6).as!ubyte, 0x00]);

        assert(bus.read(0x0001) == 0x00);
        assertFlagsClear(allFlags());


        state.IY = 0x0000;
        test("\tres %s, (iy+$00)".format(BIT), [0xfd, 0xcb, (i+6).as!ubyte, 0x00]);

        assert(bus.read(0x0000) == expected);
        assertFlagsClear(allFlags());

        state.IY = 0x0001;
        test("\tres %s, (iy+$00)".format(BIT), [0xfd, 0xcb, (i+6).as!ubyte, 0x00]);

        assert(bus.read(0x0001) == 0x00);
        assertFlagsClear(allFlags());

    }
}

setup();

res();

} // unittest