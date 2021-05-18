module emulator.chips.z80._test.sll_srl;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

enum {
    SLL_A  = [0xcb, 0x37],
    SLL_B  = [0xcb, 0x30],
    SLL_C  = [0xcb, 0x31],
    SLL_D  = [0xcb, 0x32],
    SLL_E  = [0xcb, 0x33],
    SLL_H  = [0xcb, 0x34],
    SLL_L  = [0xcb, 0x35],
    SLL_HL = [0xcb, 0x36],

    SRL_A  = [0xcb, 0x3f],
    SRL_B  = [0xcb, 0x38],
    SRL_C  = [0xcb, 0x39],
    SRL_D  = [0xcb, 0x3a],
    SRL_E  = [0xcb, 0x3b],
    SRL_H  = [0xcb, 0x3c],
    SRL_L  = [0xcb, 0x3d],
    SRL_HL = [0xcb, 0x3e],
}
void sll() {
    cpu.reset();

    // Undocumented instruction
}
void srl() {
    cpu.reset();
    state.F = 0;

    //------------------------------- srl a
    state.A = 0b1111_0000;
    test("
        srl a
    ", SRL_A);

    assert(state.A == 0b0111_1000);
    assertFlagsSet();
    assertFlagsClear(H, N, C, S, Z);

    state.A = 0b0000_0000;
    test("
        srl a
    ", SRL_A);

    assert(state.A == 0b0000_0000);
    assertFlagsSet(Z);
    assertFlagsClear(H, N, C, S);

    //------------------------------- srl b
    state.B = 0b1111_0000;
    test("
        srl b
    ", SRL_B);

    assert(state.B == 0b0111_1000);
    assertFlagsSet();
    assertFlagsClear(H, N, C, S, Z);

    //------------------------------- srl c
    state.C = 0b1111_0000;
    test("
        srl c
    ", SRL_C);

    assert(state.C == 0b0111_1000);
    assertFlagsSet();
    assertFlagsClear(H, N, C, S, Z);

    //------------------------------- srl d
    state.D = 0b1111_0000;
    test("
        srl d
    ", SRL_D);

    assert(state.D == 0b0111_1000);
    assertFlagsSet();
    assertFlagsClear(H, N, C, S, Z);

    //------------------------------- srl e
    state.E = 0b1111_0000;
    test("
        srl e
    ", SRL_E);

    assert(state.E == 0b0111_1000);
    assertFlagsSet();
    assertFlagsClear(H, N, C, S, Z);

    //------------------------------- srl h
    state.H = 0b1111_0000;
    test("
        srl h
    ", SRL_H);

    assert(state.H == 0b0111_1000);
    assertFlagsSet();
    assertFlagsClear(H, N, C, S, Z);

    //------------------------------- srl l
    state.L = 0b1111_0000;
    test("
        srl l
    ", SRL_L);

    assert(state.L == 0b0111_1000);
    assertFlagsSet();
    assertFlagsClear(H, N, C, S, Z);

    //------------------------------- srl (hl)
    writeBytes(0x0000, [0b1111_0000]);
    state.HL = 0x0000;
    test("
        srl (hl)
    ", SRL_HL);

    assert(bus.read(0x0000) == 0b0111_1000);
    assertFlagsSet();
    assertFlagsClear(H, N, C, S, Z);
}

setup();

sll();
srl();

} // unittest