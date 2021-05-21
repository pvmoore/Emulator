module emulator.chips.z80._test.misc;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

enum {
    DI = 0xf3,
    EI = 0xfb,
}
enum {
    NEG = [0xed, 0x44],
    RETI = [0xed, 0x4d],
    RETN = [0xed, 0x45],
    RLD = [0xed, 0x6f],
    RRD = [0xed, 0x67],
    IM_0 = [0xed, 0x46],
    IM_1 = [0xed, 0x56],
    IM_2 = [0xed, 0x5e],
}

void nop() {
    cpu.reset();
    test("
        nop
    ", [0x00]);

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

    //-------------------------------------------

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

    //-------------------------------------------

    state.HL = 0x1234;
    state.SP = 0x0000;
    writeBytes(0x0000, [0x45, 0x23]);
    test("
        ex (sp), hl
    ", [0xe3]);

    assert(state.HL == 0x2345);
    assert(cpu.readWord(0x0000) == 0x1234);

    state.IX = 0x1234;
    state.SP = 0x0000;
    writeBytes(0x0000, [0x45, 0x23]);
    test("
        ex (sp), ix
    ", [0xdd, 0xe3]);

    assert(state.IX == 0x2345);
    assert(cpu.readWord(0x0000) == 0x1234);

    state.IY = 0x1234;
    state.SP = 0x0000;
    writeBytes(0x0000, [0x45, 0x23]);
    test("
        ex (sp), iy
    ", [0xfd, 0xe3]);

    assert(state.IY == 0x2345);
    assert(cpu.readWord(0x0000) == 0x1234);
}
void di_ei() {
    cpu.reset();

    state.IFF1 = true;
    state.IFF2 = true;

    test("
        di
    ", [DI]);

    assert(state.IFF1 == false);
    assert(state.IFF2 == false);

    //---------------------------------

    state.IFF1 = false;
    state.IFF2 = false;

    test("
        ei
    ", [EI]);

    assert(state.IFF1 == true);
    assert(state.IFF2 == true);
}
void neg() {
    cpu.reset();

    state.A = 0xff;
    test("
        neg
    ", NEG);

    assert(state.A == 0x01);

    assertFlagsSet(N, C, H);
    assertFlagsClear(S, Z, PV);

    //-------------------------------

    state.A = 0x00;
    test("
        neg
    ", NEG);

    assert(state.A == 0x00);

    assertFlagsSet(N, Z);
    assertFlagsClear(C, S, H, PV);

    //------------------------------

    state.A = 0x80;
    test("
        neg
    ", NEG);

    assert(state.A == 0x80);

    assertFlagsSet(N, C, PV, S);
    assertFlagsClear(Z, H);
}
void reti() {
    cpu.reset();

    state.IFF1 = false;
    state.IFF2 = true;
    state.F = 0;
    test("
        reti
    ", RETI);

    assert(state.IFF1 == true);
    assertFlagsClear(allFlags());
}
void retn() {
    cpu.reset();

    state.IFF1 = false;
    state.IFF2 = true;
    state.F = 0;
    test("
        retn
    ", RETN);

    assert(state.IFF1 == true);
    assertFlagsClear(allFlags());
}
void rld() {
    cpu.reset();

    state.A = 0x34;
    state.HL = 0x0000;
    writeBytes(0x0000, [0x12]);
    test("
        rld
    ", RLD);

    assert(state.A == 0x31);
    assert(bus.read(0x0000) == 0x24);

    assertFlagsSet();
    assertFlagsClear(S, Z, H, PV, N);

    //-----------------------------------

    state.A = 0x00;
    state.HL = 0x0000;
    writeBytes(0x0000, [0x00]);
    test("
        rld
    ", RLD);

    assertFlagsSet(Z, PV);
    assertFlagsClear(S, H);

    //-----------------------------------

    state.A = 0xf0;
    state.HL = 0x0000;
    writeBytes(0x0000, [0x0f]);
    test("
        rld
    ", RLD);

    assert(state.A == 0xf0);
    assertFlagsSet(S, PV);
    assertFlagsClear(Z, H);
}
void rrd() {
    cpu.reset();

    state.A = 0x34;
    state.HL = 0x0000;
    writeBytes(0x0000, [0x12]);
    test("
        rrd
    ", RRD);

    assert(state.A == 0x32);
    assert(bus.read(0x0000) == 0x41);

    assertFlagsSet();
    assertFlagsClear(S, Z, H, N, PV);

    //-------------------------------------

    state.A = 0xf4;
    state.HL = 0x0000;
    writeBytes(0x0000, [0x13]);
    test("
        rrd
    ", RRD);

    assert(state.A == 0xf3);
    assertFlagsSet(S, PV);
    assertFlagsClear(Z, H, N);

    //-------------------------------------

    state.A = 0x00;
    state.HL = 0x0000;
    writeBytes(0x0000, [0x00]);
    test("
        rrd
    ", RRD);

    assert(state.A == 0x00);
    assertFlagsSet(Z, PV);
    assertFlagsClear(S, H, N);
}
void im() {
    cpu.reset();

    state.F = 0;
    test("
        im 0
    ", IM_0);

    assert(state.IM == 0);
    assertFlagsClear(allFlags());

    test("
        im 1
    ", IM_1);

    assert(state.IM == 1);

    test("
        im 2
    ", IM_2);

    assert(state.IM == 2);
}

setup();

nop();
cpl();
ccf();
daa();
scf_ccf();
ex_exx();
di_ei();
neg();
reti();
retn();
rld();
rrd();
im();

} // unittest
