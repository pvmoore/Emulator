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
void scf_ccf() {
    cpu.reset();

    test("
        scf
    ", [0x37]);

    assertFlagsSet(C);
    assertFlagsClear(H, N);

    state.flagC(true);

    test("
        ccf
    ", [0x3f]);

    assertFlagsSet(H);
    assertFlagsClear(C, N);
}
void ex_exx() {
    cpu.reset();

    state.AF = 0x10;
    state.AF1 = 0x20;
    state.DE = 0x30;
    state.HL = 0x40;

    test("
        ex af, af1
        ex de, hl

    ", [0x08, 0xeb]);

    assertFlagsClear(allFlags());
    assert(state.AF == 0x20);
    assert(state.AF1 == 0x10);
    assert(state.DE == 0x40);
    assert(state.HL == 0x30);

    state.BC = 0x01; state.BC1 = 0x10;
    state.DE = 0x02; state.DE1 = 0x20;
    state.HL = 0x03; state.HL1 = 0x30;

    test("
        exx
    ", [0xd9]);

    assertFlagsClear(allFlags());
    assert(state.BC == 0x10); assert(state.BC1 == 0x01);
    assert(state.DE == 0x20); assert(state.DE1 == 0x02);
    assert(state.HL == 0x30); assert(state.HL1 == 0x03);
}


setup();

nop();
cpl();
ccf();
daa();
scf_ccf();
ex_exx();

} // unittest
