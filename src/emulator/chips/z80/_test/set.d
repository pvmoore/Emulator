module emulator.chips.z80._test.set;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {
static if(true) {

enum {
    SET     = [0x00],               // fixme
    SET_IX  = [0xdd, 0xbc, 0x00],
    SET_IY  = [0xdd, 0xbc, 0x00],   // also these are wrong due to the displacement
}

void setBasic() {
    cpu.reset();

    //---------------------------------------- HL
    writeBytes(0x0000, [0x00]);
    state.HL = 0x0000;

    test("
        set 1, (hl)
    ", [0xcb, 0xce]);

    assert(bus.read(0x0000) == 0x02);
    assertFlagsClear(allFlags());
    //---------------------------------------- IX
    cpu.reset();

    writeBytes(0x0000, [0x00, 0x00]);
    state.IX = 0x0000;

    test("
        set 1, (ix + $01)
    ", [0xdd, 0xcb, 0x01, 0xce]);

    assert(bus.read(0x0001) == 0x02);
    assertFlagsClear(allFlags());
    //---------------------------------------- IY
    cpu.reset();

    writeBytes(0x0000, [0x00, 0x00, 0x00]);
    state.IY = 0x0000;

    test("
        set 1, (iy + $02)
    ", [0xfd, 0xcb, 0x02, 0xce]);

    assert(bus.read(0x0002) == 0x02);
    assertFlagsClear(allFlags());
}
void set() {
    cpu.reset();

    foreach(BIT; 0..8) {
        auto i      = 0xc0 + BIT*8;
        auto regStr = "bcdehla";
        auto bytes  = cast(ubyte[])[i+0, i+1, i+2, i+3, i+4, i+5, i+7];
        auto regs   = [Reg.B, Reg.C, Reg.D, Reg.E, Reg.H, Reg.L, Reg.A];
        ubyte expected = (1<<BIT).as!ubyte;

        foreach(j; 0..7) {
            auto r = regStr[j];
            auto n = bytes[j];
            auto reg = regs[j];

            state.setReg8(reg, 0xff);
            test("\tset %s, %s".format(BIT, r), [0xcb, n]);

            assert(state.getReg8(reg) == 0xff);
            assertFlagsClear(allFlags());

            state.setReg8(reg, 0x00);
            test("\tset %s, %s".format(BIT, r), [0xcb, n]);

            assert(state.getReg8(reg) == expected);
            assertFlagsClear(allFlags());
        }

        writeBytes(0x0000, [0xff, 0x00]);

        state.HL = 0x0000;
        test("\tset %s, (hl)".format(BIT), [0xcb, (i+6).as!ubyte]);

        assert(bus.read(0x0000) == 0xff);
        assertFlagsClear(allFlags());

        state.HL = 0x0001;
        test("\tset %s, (hl)".format(BIT), [0xcb, (i+6).as!ubyte]);

        assert(bus.read(0x0001) == expected);
        assertFlagsClear(allFlags());


        state.IX = 0x0000;
        test("\tset %s, (ix+$00)".format(BIT), [0xdd, 0xcb, 0x00, (i+6).as!ubyte]);

        assert(bus.read(0x0000) == 0xff);
        assertFlagsClear(allFlags());

        state.IX = 0x0001;
        test("\tset %s, (ix+$00)".format(BIT), [0xdd, 0xcb, 0x00, (i+6).as!ubyte]);

        assert(bus.read(0x0001) == expected);
        assertFlagsClear(allFlags());


        state.IY = 0x0000;
        test("\tset %s, (iy+$00)".format(BIT), [0xfd, 0xcb, 0x00, (i+6).as!ubyte]);

        assert(bus.read(0x0000) == 0xff);
        assertFlagsClear(allFlags());

        state.IY = 0x0001;
        test("\tset %s, (iy+$00)".format(BIT), [0xfd, 0xcb, 0x00, (i+6).as!ubyte]);

        assert(bus.read(0x0001) == expected);
        assertFlagsClear(allFlags());

    }
}

writefln("set tests");

setup();

setBasic();
set();

} // static if
} // unittest