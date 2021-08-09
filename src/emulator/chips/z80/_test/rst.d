module emulator.chips.z80._test.rst;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {
static if(true) {

enum {
    RST_00 = 0xc7,
    RST_08 = 0xcf,
    RST_10 = 0xd7,
    RST_18 = 0xdf,
    RST_20 = 0xe7,
    RST_28 = 0xef,
    RST_30 = 0xf7,
    RST_38 = 0xff
}

void rst() {
    cpu.reset();

    state.A = 0x00;
    state.SP = 0x2002;
    test("
        rst 00  ; 0x1000
    ", [RST_00]);

    assert(state.PC == 0x0000);
    assert(state.SP == 0x2000);
    assert(bus.read(0x2001) == 0x10);
    assert(bus.read(0x2000) == 0x01);

    //------------------------------------

    state.A = 0x00;
    state.SP = 0x2002;
    test("
        rst 38  ; 0x1000
    ", [RST_38]);

    assert(state.PC == 0x0038);
    assert(state.SP == 0x2000);
    assert(bus.read(0x2001) == 0x10);
    assert(bus.read(0x2000) == 0x01);
}

writefln("rst tests");

setup();

rst();

} // static if
} // unittest