module emulator.chips.z80._test.sla_sra;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {
static if(true) {

enum {
    SLA_A = [0xcb, 0x27],
    SLA_B = [0xcb, 0x20],
    SLA_C = [0xcb, 0x21],
    SLA_D = [0xcb, 0x22],
    SLA_E = [0xcb, 0x23],
    SLA_H = [0xcb, 0x24],
    SLA_L = [0xcb, 0x25],
    SLA_HL = [0xcb, 0x26],

    SRA_A = [0xcb, 0x2f],
    SRA_B = [0xcb, 0x28],
    SRA_C = [0xcb, 0x29],
    SRA_D = [0xcb, 0x2a],
    SRA_E = [0xcb, 0x2b],
    SRA_H = [0xcb, 0x2c],
    SRA_L = [0xcb, 0x2d],
    SRA_HL = [0xcb, 0x2e],
}
void sla() {
    cpu.reset();
    state.F = 0;

    //------------------------------- sla a
    state.A = 0b1111_0000;
    test("
        sla a
    ", SLA_A);

    assert(state.A == 0b1110_0000);
    assertFlagsSet(C, S);
    assertFlagsClear(Z, PV, H, N);

    state.A = 0x00;
    test("
        sla a
    ", SLA_A);

    assert(state.A == 0x00);
    assertFlagsSet(Z, PV);
    assertFlagsClear(C, S, H, N);

    //------------------------------- sla b
    state.B = 0b1111_0000;
    test("
        sla b
    ", SLA_B);

    assert(state.B == 0b1110_0000);
    assertFlagsSet(C, S);
    assertFlagsClear(Z, PV, H, N);

    //------------------------------- sla c
    state.C = 0b1111_0000;
    test("
        sla c
    ", SLA_C);

    assert(state.C == 0b1110_0000);
    assertFlagsSet(C, S);
    assertFlagsClear(Z, PV, H, N);

    //------------------------------- sla d
    state.D = 0b1111_0000;
    test("
        sla d
    ", SLA_D);

    assert(state.D == 0b1110_0000);
    assertFlagsSet(C, S);
    assertFlagsClear(Z, PV, H, N);

    //------------------------------- sla e
    state.E = 0b1111_0000;
    test("
        sla e
    ", SLA_E);

    assert(state.E == 0b1110_0000);
    assertFlagsSet(C, S);
    assertFlagsClear(Z, PV, H, N);

    //------------------------------- sla h
    state.H = 0b1111_0000;
    test("
        sla h
    ", SLA_H);

    assert(state.H == 0b1110_0000);
    assertFlagsSet(C, S);
    assertFlagsClear(Z, PV, H, N);

    //------------------------------- sla l
    state.L = 0b1111_0000;
    test("
        sla l
    ", SLA_L);

    assert(state.L == 0b1110_0000);
    assertFlagsSet(C, S);
    assertFlagsClear(Z, PV, H, N);

    //------------------------------- sla (hl)
    state.HL = 0x0000;
    writeBytes((0x0000), [0b1111_0000]);
    test("
        sla (hl)
    ", SLA_HL);

    assert(bus.read(0x0000) == 0b1110_0000);
    assertFlagsSet(C, S);
    assertFlagsClear(Z, PV, H, N);

    //------------------------------- sla (ix+d)
    state.IX = 0x0000;
    writeBytes((0x0001), [0b1111_0000]);
    test("
        sla (ix+$01)
    ", [0xdd, 0xcb, 0x01, 0x26]);

    assert(bus.read(0x0001) == 0b1110_0000);
    assertFlagsSet(C, S);
    assertFlagsClear(Z, PV, H, N);

    //------------------------------- sla (iy+d)
    state.IY = 0x0000;
    writeBytes((0x0001), [0b1111_0000]);
    test("
        sla (iy+$01)
    ", [0xfd, 0xcb, 0x01, 0x26]);

    assert(bus.read(0x0001) == 0b1110_0000);
    assertFlagsSet(C, S);
    assertFlagsClear(Z, PV, H, N);
}
void sra() {
    cpu.reset();
    state.F = 0;

    //------------------------------- sra a
    state.flagC(false);
    state.A = 0b1000_1111;
    test("
        sra a
    ", SRA_A);

    assert(state.A == 0b1100_0111);
    assertFlagsSet(C, S);
    assertFlagsClear(H, N, Z);

    state.flagC(false);
    state.A = 0;
    test("
        sra a
    ", SRA_A);

    assert(state.A == 0x00);
    assertFlagsSet(Z);
    assertFlagsClear(H, N, C, S);

    //------------------------------- sra b
    state.flagC(false);
    state.B = 0b1000_1111;
    test("
        sra b
    ", SRA_B);

    assert(state.B == 0b1100_0111);
    assertFlagsSet(C, S);
    assertFlagsClear(H, N, Z);

    //------------------------------- sra c
    state.flagC(false);
    state.C = 0b1000_1111;
    test("
        sra c
    ", SRA_C);

    assert(state.C == 0b1100_0111);
    assertFlagsSet(C, S);
    assertFlagsClear(H, N, Z);

    //------------------------------- sra d
    state.flagC(false);
    state.D = 0b1000_1111;
    test("
        sra d
    ", SRA_D);

    assert(state.D == 0b1100_0111);
    assertFlagsSet(C, S);
    assertFlagsClear(H, N, Z);

    //------------------------------- sra e
    state.flagC(false);
    state.E = 0b1000_1111;
    test("
        sra e
    ", SRA_E);

    assert(state.E == 0b1100_0111);
    assertFlagsSet(C, S);
    assertFlagsClear(H, N, Z);

    //------------------------------- sra h
    state.flagC(false);
    state.H = 0b1000_1111;
    test("
        sra h
    ", SRA_H);

    assert(state.H == 0b1100_0111);
    assertFlagsSet(C, S);
    assertFlagsClear(H, N, Z);

    //------------------------------- sra l
    state.flagC(false);
    state.L = 0b1000_1111;
    test("
        sra l
    ", SRA_L);

    assert(state.L == 0b1100_0111);
    assertFlagsSet(C, S);
    assertFlagsClear(H, N, Z);

    //------------------------------- sra (hl)
    state.flagC(false);
    state.HL = 0x0000;
    writeBytes(0x0000, [0b1000_1111]);
    test("
        sra (hl)
    ", SRA_HL);

    assert(bus.read(0x0000) == 0b1100_0111);
    assertFlagsSet(C, S);
    assertFlagsClear(H, N, Z);

    //------------------------------- sra (ix+d)
    state.flagC(false);
    state.IX = 0x0000;
    writeBytes(0x0001, [0b1000_1111]);
    test("
        sra (ix+$01)
    ", [0xdd, 0xcb, 0x01, 0x2e]);

    assert(bus.read(0x0001) == 0b1100_0111);
    assertFlagsSet(C, S);
    assertFlagsClear(H, N, Z);

    //------------------------------- sra (iy+d)
    state.flagC(false);
    state.IY = 0x0000;
    writeBytes(0x0001, [0b1000_1111]);
    test("
        sra (iy+$01)
    ", [0xfd, 0xcb, 0x01, 0x2e]);

    assert(bus.read(0x0001) == 0b1100_0111);
    assertFlagsSet(C, S);
    assertFlagsClear(H, N, Z);
}

writefln("sla sra tests");

setup();

sla();
sra();

} // static if
} // unitest