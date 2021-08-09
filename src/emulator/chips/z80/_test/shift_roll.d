module emulator.chips.z80._test.shift_roll;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {
static if(true) {

void rla() {
    cpu.reset();

    state.A = 0b1100_0000;
    state.flagC(true);

    test("
        rla
    ", [0x17]);

    assert(state.A == 0b1000_0001);
    assertFlagsSet(C);
    assertFlagsClear(H, N);

    //-----------------------

    state.A = 0b0000_0000;
    state.flagC(false);

    test("
        rla
    ", [0x17]);

    assert(state.A == 0b0000_0000);
    assertFlagsSet();
    assertFlagsClear(C, H, N);
}
void rra() {
    cpu.reset();

    state.A = 0b1100_0011;
    state.flagC(true);

    test("
        rra
    ", [0x1f]);

    assert(state.A == 0b1110_0001);
    assertFlagsSet(C);
    assertFlagsClear(H, N);

    //----------------------------

    state.A = 0b1100_0010;
    state.flagC(false);

    test("
        rra
    ", [0x1f]);

    assert(state.A == 0b0110_0001);
    assertFlagsSet();
    assertFlagsClear(C, H, N);

}
void rlca() {
    cpu.reset();

    state.A = 0b1111_0000;

    test("
        rlca
    ", [0x07]);

    assert(state.A == 0b1110_0001);
    assertFlagsSet(C);
    assertFlagsClear(H, N);

    //----------------------------

    state.A = 0b0111_0000;

    test("
        rlca
    ", [0x07]);

    assert(state.A == 0b1110_0000);
    assertFlagsSet();
    assertFlagsClear(C, H, N);

}
void rrca() {
    cpu.reset();

    state.A = 0b1000_0111;

    test("
        rrca
    ", [0x0f]);

    assert(state.A == 0b1100_0011);
    assertFlagsSet(C);
    assertFlagsClear(H, N);

    //----------------------

    state.A = 0b1000_0110;

    test("
        rrca
    ", [0x0f]);

    assert(state.A == 0b0100_0011);
    assertFlagsSet();
    assertFlagsClear(C, H, N);

}

writefln("shift roll tests");

setup();

rla();
rra();
rlca();
rrca();

} // static if
} // unittest