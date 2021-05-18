module emulator.chips.z80._test.in_out;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

enum {
    IN_A_N  = 0xdb,     // in a, (n)
    OUT_N_A = 0xd3,     // out (n), a
}
enum {
    IN_A_C = [0xed, 0x78],
    IN_B_C = [0xed, 0x40],
    IN_C_C = [0xed, 0x48],
    IN_D_C = [0xed, 0x50],
    IN_E_C = [0xed, 0x58],
    IN_H_C = [0xed, 0x60],
    IN_L_C = [0xed, 0x68],

    OUT_C_A = [0xed, 0x79],
    OUT_C_B = [0xed, 0x41],
    OUT_C_C = [0xed, 0x49],
    OUT_C_D = [0xed, 0x51],
    OUT_C_E = [0xed, 0x59],
    OUT_C_H = [0xed, 0x61],
    OUT_C_L = [0xed, 0x69],
}

void in_a() {
    cpu.reset();

    writePort(3, 77);

    test("
        in a, ($03)
    ", [IN_A_N, 0x03]);

    assert(state.A == 77);
    assert(pins.isIOReq() == false);
}
void out_a() {
    cpu.reset();

    writePort(3, 0);

    state.A = 77;
    test("
        out ($03), a
    ", [OUT_N_A, 0x03]);

    assert(readPort(3) == 77);
}
void in_c() {
    cpu.reset();

    writePort(4, 66);

    state.C = 4;
    test("
        in a, (c)
    ", IN_A_C);

    assert(state.A == 66);
    assertFlagsSet(PV);
    assertFlagsClear(N, Z, S, H);

    writePort(4, 0x83);

    state.C = 4;
    test("
        in a, (c)
    ", IN_A_C);

    assert(state.A == 0x83);
    assertFlagsSet(S);
    assertFlagsClear(N, Z, PV, H);

    writePort(4, 0x00);

    state.C = 4;
    test("
        in a, (c)
    ", IN_A_C);

    assert(state.A == 0x00);
    assertFlagsSet(Z, PV);
    assertFlagsClear(N, S, H);

    writePort(4, 0x10);

    state.C = 4;
    test("
        in b, (c)
    ", IN_B_C);

    assert(state.B == 0x10);

    writePort(4, 0x10);

    state.C = 4;
    test("
        in c, (c)
    ", IN_C_C);

    assert(state.C == 0x10);

    writePort(4, 0x10);

    state.C = 4;
    test("
        in d, (c)
    ", IN_D_C);

    assert(state.D == 0x10);

    writePort(4, 0x10);

    state.C = 4;
    test("
        in e, (c)
    ", IN_E_C);

    assert(state.E == 0x10);

    writePort(4, 0x10);

    state.C = 4;
    test("
        in h, (c)
    ", IN_H_C);

    assert(state.H == 0x10);

    writePort(4, 0x10);

    state.C = 4;
    test("
        in l, (c)
    ", IN_L_C);

    assert(state.L == 0x10);
}
void out_c() {
    cpu.reset();

    state.A = 0x12;
    state.C = 8;
    test("
        out (c), a
    ", OUT_C_A);

    assert(readPort(8) == 0x12);
    assertFlagsClear(allFlags());

    state.B = 0x13;
    state.C = 8;
    test("
        out (c), b
    ", OUT_C_B);

    assert(readPort(8) == 0x13);
    assertFlagsClear(allFlags());

    state.C = 8;
    test("
        out (c), c
    ", OUT_C_C);

    assert(readPort(8) == 8);
    assertFlagsClear(allFlags());

    state.D = 0x14;
    state.C = 8;
    test("
        out (c), d
    ", OUT_C_D);

    assert(readPort(8) == 0x14);
    assertFlagsClear(allFlags());

    state.E = 0x15;
    state.C = 8;
    test("
        out (c), e
    ", OUT_C_E);

    assert(readPort(8) == 0x15);
    assertFlagsClear(allFlags());

    state.H = 0x16;
    state.C = 8;
    test("
        out (c), h
    ", OUT_C_H);

    assert(readPort(8) == 0x16);
    assertFlagsClear(allFlags());

    state.L = 0x17;
    state.C = 8;
    test("
        out (c), l
    ", OUT_C_L);

    assert(readPort(8) == 0x17);
    assertFlagsClear(allFlags());
}
setup();

in_a();
out_a();
in_c();
out_c();

} // unittest
