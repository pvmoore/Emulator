module emulator.chips.z80._test.misc;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

void nop() {
    cpu.reset();
    test("
        nop
    ", [0x00]);

    prevState.PC = state.PC;
    assert(prevState == state);
    assertFlagsClear(allFlags());
}
void cpl() {
    cpu.reset();

    state.A = 0b1010_1010;

    test("
        cpl
    ", [0x2f]);

    assert(state.A == 0b0101_0101);
    assertFlagsSet(H, N);
}
void ccf() {
    cpu.reset();

    state.F = 0xff & cast(ubyte)(~H.as!uint);

    test("
        ccf
    ", [0x3f]);

    assertFlagsSet(S, Z, H, PV);
    assertFlagsClear(C, N);

    //-------------------

    state.F = 0x00;

    test("
        ccf
    ", [0x3f]);

    assertFlagsSet(C);
    assertFlagsClear(S, Z, H, PV, N);
}
void daa() {
    cpu.reset();

    test("
        add a, $01
        daa
    ", [0xc6, 0x01, 0x27]);

    test(null, [" add a, $01\n daa"], [], [], {});

}
void scf() {
    cpu.reset();
}


setup();

nop();
cpl();
ccf();
daa();
scf();

} // unittest
