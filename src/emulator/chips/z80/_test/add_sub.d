module emulator.chips.z80._test.add_sub;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {
static if(true) {

enum {
    ADD_N = 0xc6,
    ADD_A = 0x87,
    ADD_B = 0x80,
    ADD_C = 0x81,
    ADD_D = 0x82,
    ADD_E = 0x83,
    ADD_H = 0x84,
    ADD_L = 0x85,
    ADD_HL = 0x86,
    ADD_HL_BC = 0x09,
    ADD_HL_DE = 0x19,
    ADD_HL_HL = 0x29,
    ADD_HL_SP = 0x39,

    SUB_N = 0xd6,
    SUB_A = 0x97,
    SUB_B = 0x90,
    SUB_C = 0x91,
    SUB_D = 0x92,
    SUB_E = 0x93,
    SUB_H = 0x94,
    SUB_L = 0x95,
    SUB_HL = 0x96,
}
enum {
    ADD_IX_BC = [0xdd, 0x09],
    ADD_IX_DE = [0xdd, 0x19],
    ADD_IX_IX = [0xdd, 0x29],
    ADD_IX_SP = [0xdd, 0x39],

    ADD_IY_BC = [0xfd, 0x09],
    ADD_IY_DE = [0xfd, 0x19],
    ADD_IY_IY = [0xfd, 0x29],
    ADD_IY_SP = [0xfd, 0x39],

    ADD_IX = [0xdd, 0x86],
    ADD_IY = [0xfd, 0x86],

    SUB_IX = [0xdd, 0x96],
    SUB_IY = [0xfd, 0x96],
}

void add_n() {
    cpu.reset();

    state.A = 0x01;
    test("
        add a, $0f
    ", [ADD_N, 0x0f]);

    assert(state.A == 0x10);
    assertFlagsSet(H);
    assertFlagsClear(N, Z, S, PV, C);

    state.A = 0x01;
    test("
        add a, $7f
    ", [ADD_N, 0x7f]);

    assert(state.A == 0x80);
    assertFlagsSet(PV, H, S);
    assertFlagsClear(N, Z, C);

    state.A = 0x81;
    test("
        add a, $7f
    ", [ADD_N, 0x7f]);

    assert(state.A == 0x00);
    assertFlagsSet(Z, H, C);
    assertFlagsClear(N, PV);
}
void add_r() {
    cpu.reset();

    //--------------------- add a,a
    state.A = 0x01;
    test("
        add a,a
    ", [ADD_A]);

    assert(state.A == 0x02);

    //--------------------- add a,b
    state.A = 0x01;
    state.B = 0x0f;
    test("
        add a,b
    ", [ADD_B]);

    assert(state.A == 0x10);
    assertFlagsSet(H);
    assertFlagsClear(N, Z, S, PV, C);

    state.A = 0x01;
    state.B = 0x7f;
    test("
        add a,b
    ", [ADD_B]);

    assert(state.A == 0x80);
    assertFlagsSet(PV, H, S);
    assertFlagsClear(N, Z, C);

    state.A = 0x81;
    state.B = 0x7f;
    test("
        add a,b
    ", [ADD_B]);

    assert(state.A == 0x00);
    assertFlagsSet(Z, H, C);
    assertFlagsClear(N, PV);

    //--------------------- add a,c
    state.A = 0x01;
    state.C = 0x7f;
    test("
        add a,c
    ", [ADD_C]);

    assert(state.A == 0x80);

    //--------------------- add a,d
    state.A = 0x01;
    state.D = 0x7f;
    test("
        add a,d
    ", [ADD_D]);

    assert(state.A == 0x80);

    //--------------------- add a,e
    state.A = 0x01;
    state.E = 0x7f;
    test("
        add a,e
    ", [ADD_E]);

    assert(state.A == 0x80);

    //--------------------- add a,h
    state.A = 0x01;
    state.H = 0x7f;
    test("
        add a,h
    ", [ADD_H]);

    assert(state.A == 0x80);

    //--------------------- add a,l
    state.A = 0x01;
    state.L = 0x7f;
    test("
        add a,l
    ", [ADD_L]);

    assert(state.A == 0x80);

    //--------------------- add a, (hl)
    state.A = 0x01;
    state.HL = 0x0000;
    writeBytes(0x0000, [0x7f]);
    test("
        add a, (hl)
    ", [ADD_HL]);

    assert(state.A == 0x80);

    //--------------------- add a, (ix+d)
    state.A = 0x01;
    state.IX = 0x0000;
    writeBytes(0x0001, [0x7f]);
    test("
        add a, (ix + $01)
    ", ADD_IX ~ [0x01]);

    assert(state.A == 0x80);

    //--------------------- add a, (iy+d)
    state.A = 0x01;
    state.IY = 0x0000;
    writeBytes(0x0001, [0x7f]);
    test("
        add a, (iy + $01)
    ", ADD_IY ~ [0x01]);

    assert(state.A == 0x80);
}
void sub_n() {
    cpu.reset();

    state.A = 0x00;
    test("
        sub a, $01
    ", [SUB_N, 0x01]);

    assert(state.A == 0xff);
    assertFlagsSet(N, H, S, C);
    assertFlagsClear(PV, Z);

    state.A = 0x00;
    test("
        sub a, $80
    ", [SUB_N, 0x80]);

    assert(state.A == 0x80);
    assertFlagsSet(N, C, S, PV);
    assertFlagsClear(H, Z);
}
void sub_r() {
    cpu.reset();

    //--------------------- sub a,a
    state.A = 0x01;
    test("
        sub a, a
    ", [SUB_A]);

    assert(state.A == 0x00);

    //--------------------- sub a,b
    state.A = 0x00;
    state.B = 0x01;
    test("
        sub a, b
    ", [SUB_B]);

    assert(state.A == 0xff);
    assertFlagsSet(N, H, S, C);
    assertFlagsClear(PV, Z);

    state.A = 0x00;
    state.B = 0x80;
    test("
        sub a, b
    ", [SUB_B]);

    assert(state.A == 0x80);
    assertFlagsSet(N, C, S, PV);
    assertFlagsClear(H, Z);

    //--------------------- sub a, c
    state.A = 0x00;
    state.C = 0x01;
    test("
        sub a, c
    ", [SUB_C]);

    assert(state.A == 0xff);

    //--------------------- sub a, d
    state.A = 0x00;
    state.D = 0x01;
    test("
        sub a, d
    ", [SUB_D]);

    assert(state.A == 0xff);

    //--------------------- sub a, e
    state.A = 0x00;
    state.E = 0x01;
    test("
        sub a, e
    ", [SUB_E]);

    assert(state.A == 0xff);

    //--------------------- sub a, h
    state.A = 0x00;
    state.H = 0x01;
    test("
        sub a, h
    ", [SUB_H]);

    assert(state.A == 0xff);

    //--------------------- sub a, l
    state.A = 0x00;
    state.L = 0x01;
    test("
        sub a, l
    ", [SUB_L]);

    assert(state.A == 0xff);

    //--------------------- sub a, (hl)
    state.A = 0x00;
    state.HL = 0x0000;
    writeBytes(0x0000, [0x01]);
    test("
        sub a, (hl)
    ", [SUB_HL]);

    assert(state.A == 0xff);

    //--------------------- sub a, (ix+d)
    state.A = 0x00;
    state.IX = 0x0000;
    writeBytes(0x0001, [0x01]);
    test("
        sub a, (ix+$01)
    ", SUB_IX ~ [0x01]);

    assert(state.A == 0xff);

    //--------------------- sub a, (iy+d)
    state.A = 0x00;
    state.IY = 0x0000;
    writeBytes(0x0001, [0x01]);
    test("
        sub a, (iy+$01)
    ", SUB_IY ~ [0x01]);

    assert(state.A == 0xff);
}
void add_HL_rr() {
    cpu.reset();

    //--------------------------- add hl, bc
    state.HL = 0x0102;
    state.BC = 0x1010;
    test("
        add hl, bc
    ", [ADD_HL_BC]);

    assert(state.HL == 0x1112);
    assertFlagsSet();
    assertFlagsClear(N, H);

    //--------------------------- add hl, de
    state.HL = 0x0102;
    state.DE = 0x1010;
    test("
        add hl, de
    ", [ADD_HL_DE]);

    assert(state.HL == 0x1112);
    assertFlagsSet();
    assertFlagsClear(N, H);

    //--------------------------- add hl, hl
    state.HL = 0x0102;
    state.BC = 0x1010;
    test("
        add hl, hl
    ", [ADD_HL_HL]);

    assert(state.HL == 0x0204);
    assertFlagsSet();
    assertFlagsClear(N, H);

    //--------------------------- add hl, sp
    state.HL = 0x0102;
    state.SP = 0x1010;
    test("
        add hl, sp
    ", [ADD_HL_SP]);

    assert(state.HL == 0x1112);
    assertFlagsSet();
    assertFlagsClear(N, H);

    //--------------------------- add ix, bc
    state.HL = 0x0000;
    state.IX = 0x0102;
    state.BC = 0x1010;
    test("
        add ix, bc
    ", ADD_IX_BC);

    assert(state.IX == 0x1112);
    assertFlagsSet();
    assertFlagsClear(N, H);

    //--------------------------- add ix, de
    state.HL = 0x0000;
    state.IX = 0x0102;
    state.DE = 0x1010;
    test("
        add ix, de
    ", ADD_IX_DE);

    assert(state.IX == 0x1112);
    assertFlagsSet();
    assertFlagsClear(N, H);

    //--------------------------- add ix, ix
    state.HL = 0x0000;
    state.IX = 0x0102;
    state.BC = 0x1010;
    test("
        add ix, ix
    ", ADD_IX_IX);

    assert(state.IX == 0x0204);
    assertFlagsSet();
    assertFlagsClear(N, H);

    //--------------------------- add ix, sp
    state.HL = 0x0000;
    state.IX = 0x0102;
    state.SP = 0x1010;
    test("
        add ix, sp
    ", ADD_IX_SP);

    assert(state.IX == 0x1112);
    assertFlagsSet();
    assertFlagsClear(N, H);

    //--------------------------- add iy, bc
    state.IY = 0x0102;
    state.BC = 0x1010;
    test("
        add iy, bc
    ", ADD_IY_BC);

    assert(state.IY == 0x1112);
    assertFlagsSet();
    assertFlagsClear(N, H);

    //--------------------------- add iy, de
    state.IY = 0x0102;
    state.DE = 0x1010;
    test("
        add iy, de
    ", ADD_IY_DE);

    assert(state.IY == 0x1112);
    assertFlagsSet();
    assertFlagsClear(N, H);

    //--------------------------- add iy, iy
    state.IY = 0x0102;
    test("
        add iy, iy
    ", ADD_IY_IY);

    assert(state.IY == 0x0204);
    assertFlagsSet();
    assertFlagsClear(N, H);

    //--------------------------- add iy, sp
    state.IY = 0x0102;
    state.SP = 0x1010;
    test("
        add iy, sp
    ", ADD_IY_SP);

    assert(state.IY == 0x1112);
    assertFlagsSet();
    assertFlagsClear(N, H);
}

writefln("add sub tests");

setup();

add_n();
add_r();
sub_n();
sub_r();
add_HL_rr();

} // static if
} // unittest