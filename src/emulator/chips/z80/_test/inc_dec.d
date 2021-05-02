module emulator.chips.z80._test.inc_dec;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

void inc() {
    cpu.reset();

    writeBytes(0x0000, [0]);
    state.BC = 0; state.DE = 0; state.HL = 0; state.SP = 0;
    state.A = 0;

    test("
        inc (hl)
        ;inc (ix+$01)
        ;inc (iy+$01
        ;inc ix
        ;inc iy

        inc bc
        inc de
        inc hl
        inc sp

        inc a
        inc b
        inc c
        inc d
        inc e
        inc h
        inc l
", [0x034,
    0x03, 0x13, 0x23, 0x33,
    0x3c, 0x04, 0x0c, 0x14, 0x1c, 0x24, 0x2c]);

    assert(state.BC == 0x0102);
    assert(state.DE == 0x0102);
    assert(state.HL == 0x0102);
    assert(state.SP == 0x0001);
    assert(state.A == 1);
    assert(bus.read(0x0000) == 1);

    // ---------------------------

    // inc word regs does not affect the flags
    state.F = 0;
    state.BC = 0xfffe;
    state.DE = 0xffff;

    test("
        inc bc
        inc de
        inc hl
        inc sp
", [0x03, 0x13, 0x23, 0x33]);

    assertFlagsClear(allFlags());

    // ---------------------------

    state.A = 0xfe;
    test("inc a", [0x3c]);

    assertFlagsSet(S);
    assertFlagsClear(N, Z, H, PV, C);

    // ---------------------------

    state.A = 0x7f;
    state.flagC(true);
    test("inc a", [0x3c]);

    assertFlagsSet(S, PV, C, H);
    assertFlagsClear(N, Z);

    // ---------------------------

    state.A = 0xf;
    test("inc a", [0x3c]);

    assertFlagsSet(H);
    assertFlagsClear(S, N, Z, PV);
}
void dec() {
    cpu.reset();

    writeBytes(0x0000, [0]);
    state.BC = 0; state.DE = 0; state.HL = 0; state.SP = 0;
    state.A = 0;

    test("
        dec (hl)
        ;dec (ix+$01)
        ;dec (iy+$01
        ;dec ix
        ;dec iy

        dec bc
        dec de
        dec hl
        dec sp

        dec a
        dec b
        dec c
        dec d
        dec e
        dec h
        dec l
", [0x35,
    0x0b, 0x1b,0x2b, 0x3b,
    0x3d, 0x05, 0x0d, 0x15, 0x1d, 0x25, 0x2d]);

    assert(state.BC == 0xfefe);
    assert(state.DE == 0xfefe);
    assert(state.HL == 0xfefe);
    assert(state.SP == 0xffff);
    assert(state.A == 0xff);
    assert(bus.read(0x0000) == 0xff);

    // ---------------------------
    state.F = 0;

    // dec word regs does not affect the flags
    test("
        dec bc
        dec de
        dec hl
        dec sp
", [0x0b, 0x1b, 0x2b, 0x3b]);

    assertFlagsClear(allFlags());

    // ---------------------------

    state.A = 0x01;
    test("dec a", [0x3d]);

    assertFlagsSet(Z, N);           // zero
    assertFlagsClear(S, H, PV, C);

    // ---------------------------

    state.A = 0x00;
    test("dec a", [0x3d]);

    assertFlagsSet(S, N, H);           // zero
    assertFlagsClear(PV, C);

    // ---------------------------

    state.A = 0x80;
    test("dec a", [0x3d]);

    assertFlagsSet(PV, N, H);           // zero
    assertFlagsClear(S, C, Z);

    // ---------------------------
}

setup();
inc();
dec();


} //unittest