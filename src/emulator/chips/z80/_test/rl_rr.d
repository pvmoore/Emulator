module emulator.chips.z80._test.rl_rr;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

enum {
    RL_A = [0xcb, 0x17],
    RL_B = [0xcb, 0x10],
    RL_C = [0xcb, 0x11],
    RL_D = [0xcb, 0x12],
    RL_E = [0xcb, 0x13],
    RL_H = [0xcb, 0x14],
    RL_L = [0xcb, 0x15],
    RL_HL = [0xcb, 0x16],

    RR_A = [0xcb, 0x1f],
    RR_B = [0xcb, 0x18],
    RR_C = [0xcb, 0x19],
    RR_D = [0xcb, 0x1a],
    RR_E = [0xcb, 0x1b],
    RR_H = [0xcb, 0x1c],
    RR_L = [0xcb, 0x1d],
    RR_HL = [0xcb, 0x1e],
}
void rl() {
    cpu.reset();

    //---------------------------- rl a
    state.flagC(true);
    state.A = 0xff;
    test("
        rl a
    ", RL_A);

    assert(state.A == 0xff);
    assertFlagsSet(C, S, PV);
    assertFlagsClear(H, N, Z);

    state.flagC(true);
    state.A = 0x00;
    test("
        rl a
    ", RL_A);

    assert(state.A == 0x01);
    assertFlagsSet();
    assertFlagsClear(H, N, Z, PV, S, C);

    //---------------------------- rl b
    state.flagC(true);
    state.B = 0b1111_0000;
    test("
        rl b
    ", RL_B);

    assert(state.B == 0b1110_0001);
    assertFlagsSet(C, S, PV);
    assertFlagsClear(H, N, Z);

    //---------------------------- rl c
    state.flagC(true);
    state.C = 0b1111_0000;
    test("
        rl c
    ", RL_C);

    assert(state.C == 0b1110_0001);
    assertFlagsSet(C, S, PV);
    assertFlagsClear(H, N, Z);

    //---------------------------- rl d
    state.flagC(true);
    state.D = 0b1111_0000;
    test("
        rl d
    ", RL_D);

    assert(state.D == 0b1110_0001);
    assertFlagsSet(C, S, PV);
    assertFlagsClear(H, N, Z);

    //---------------------------- rl e
    state.flagC(true);
    state.E = 0b1111_0000;
    test("
        rl e
    ", RL_E);

    assert(state.E == 0b1110_0001);
    assertFlagsSet(C, S, PV);
    assertFlagsClear(H, N, Z);

    //---------------------------- rl h
    state.flagC(true);
    state.H = 0b1111_0000;
    test("
        rl h
    ", RL_H);

    assert(state.H == 0b1110_0001);
    assertFlagsSet(C, S, PV);
    assertFlagsClear(H, N, Z);

    //---------------------------- rl l
    state.flagC(true);
    state.L = 0b1111_0000;
    test("
        rl l
    ", RL_L);

    assert(state.L == 0b1110_0001);
    assertFlagsSet(C, S, PV);
    assertFlagsClear(H, N, Z);

    //---------------------------- rl (hl)
    state.flagC(true);
    writeBytes(0x0000, [0b1111_0000]);
    state.HL = 0x0000;
    test("
        rl (hl)
    ", RL_HL);

    assert(bus.read(0x0000) == 0b1110_0001);
    assertFlagsSet(C, S, PV);
    assertFlagsClear(H, N, Z);
}
void rr() {
    cpu.reset();

}

setup();

rl();
rr();

} // unittest