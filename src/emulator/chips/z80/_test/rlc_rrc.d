module emulator.chips.z80._test.rlc_rrc;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {
static if(true) {

enum {
    RLC_A = [0xcb, 0x07],
    RLC_B = [0xcb, 0x00],
    RLC_C = [0xcb, 0x01],
    RLC_D = [0xcb, 0x02],
    RLC_E = [0xcb, 0x03],
    RLC_H = [0xcb, 0x04],
    RLC_L = [0xcb, 0x05],
    RLC_HL = [0xcb, 0x06],

    RRC_A = [0xcb, 0x0f],
    RRC_B = [0xcb, 0x08],
    RRC_C = [0xcb, 0x09],
    RRC_D = [0xcb, 0x0a],
    RRC_E = [0xcb, 0x0b],
    RRC_H = [0xcb, 0x0c],
    RRC_L = [0xcb, 0x0d],
    RRC_HL = [0xcb, 0x0e],
}
void rlc() {
    cpu.reset();

    //---------------------------------- rlc a
    state.A = 0xff;
    state.flagC(false);
    test("
        rlc a
    ", RLC_A);

    assert(state.A == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    state.A = 0x00;
    state.flagC(false);
    test("
        rlc a
    ", RLC_A);

    assert(state.A == 0x00);
    assertFlagsSet(PV, Z);
    assertFlagsClear(S, C);

    //--------------------------------- rlc b
    state.B = 0xff;
    state.flagC(false);
    test("
        rlc b
    ", RLC_B);

    assert(state.B == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rlc c
    state.C = 0xff;
    state.flagC(false);
    test("
        rlc c
    ", RLC_C);

    assert(state.C == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rlc d
    state.D = 0xff;
    state.flagC(false);
    test("
        rlc d
    ", RLC_D);

    assert(state.D == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rlc e
    state.E = 0xff;
    state.flagC(false);
    test("
        rlc e
    ", RLC_E);

    assert(state.E == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rlc h
    state.H = 0xff;
    state.flagC(false);
    test("
        rlc h
    ", RLC_H);

    assert(state.H == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rlc l
    state.L = 0xff;
    state.flagC(false);
    test("
        rlc l
    ", RLC_L);

    assert(state.L == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rlc (hl)
    state.HL = 0x0000;
    writeBytes(0x0000, [0xff]);
    state.flagC(false);
    test("
        rlc (hl)
    ", RLC_HL);

    assert(bus.read(0x0000) == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rlc (ix+d)
    state.IX = 0x0000;
    writeBytes(0x0001, [0xff]);
    state.flagC(false);
    test("
        rlc (ix+$01)
    ", [0xdd, 0xcb, 0x01, 0x06]);

    assert(bus.read(0x0001) == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rlc (iy+d)
    state.IY = 0x0000;
    writeBytes(0x0001, [0xff]);
    state.flagC(false);
    test("
        rlc (iy+$01)
    ", [0xfd, 0xcb, 0x01, 0x06]);

    assert(bus.read(0x0001) == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);
}
void rrc() {
    cpu.reset();

    //---------------------------------- rrc a
    state.A = 0xff;
    state.flagC(false);
    test("
        rrc a
    ", RRC_A);

    assert(state.A == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    state.A = 0x00;
    state.flagC(false);
    test("
        rrc a
    ", RRC_A);

    assert(state.A == 0x00);
    assertFlagsSet(PV, Z);
    assertFlagsClear(S, C);

    //--------------------------------- rrc b
    state.B = 0xff;
    state.flagC(false);
    test("
        rrc b
    ", RRC_B);

    assert(state.B == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rrc c
    state.C = 0xff;
    state.flagC(false);
    test("
        rrc c
    ", RRC_C);

    assert(state.C == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rrc d
    state.D = 0xff;
    state.flagC(false);
    test("
        rrc d
    ", RRC_D);

    assert(state.D == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rrc e
    state.E = 0xff;
    state.flagC(false);
    test("
        rrc e
    ", RRC_E);

    assert(state.E == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rrc h
    state.H = 0xff;
    state.flagC(false);
    test("
        rrc h
    ", RRC_H);

    assert(state.H == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rrc l
    state.L = 0xff;
    state.flagC(false);
    test("
        rrc l
    ", RRC_L);

    assert(state.L == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rrc (hl)
    state.HL = 0x0000;
    writeBytes(0x0000, [0xff]);
    state.flagC(false);
    test("
        rrc (hl)
    ", RRC_HL);

    assert(bus.read(0x0000) == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rrc (ix+d)
    state.IX = 0x0000;
    writeBytes(0x0001, [0xff]);
    state.flagC(false);
    test("
        rrc (ix+$01)
    ", [0xdd, 0xcb, 0x01, 0x0e]);

    assert(bus.read(0x0001) == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);

    //--------------------------------- rrc (iy+d)
    state.IY = 0x0000;
    writeBytes(0x0001, [0xff]);
    state.flagC(false);
    test("
        rrc (iy+$01)
    ", [0xfd, 0xcb, 0x01, 0x0e]);

    assert(bus.read(0x0001) == 0xff);
    assertFlagsSet(C, PV, S);
    assertFlagsClear(Z);
}

writefln("rlc rrc tests");

setup();

rlc();
rrc();

} // static if
} // unittest