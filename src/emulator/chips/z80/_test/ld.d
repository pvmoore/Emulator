module emulator.chips.z80._test.ld;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

enum {
    LD_A_R = [0xed, 0x5f],
    LD_R_A = [0xed, 0x4f],
    LD_A_I = [0xed, 0x57],
    LD_I_A = [0xed, 0x47],

    LD_BC_NN = [0xed, 0x4b],
    LD_DE_NN = [0xed, 0x5b],
    LD_HL_NN = [0xed, 0x6b],
    LD_SP_NN = [0xed, 0x7b],

    LD_NN_BC = [0xed, 0x43],
    LD_NN_DE = [0xed, 0x53],
    LD_NN_HL = [0xed, 0x63],
    LD_NN_SP = [0xed, 0x73],
}

void ld_imm() {
    cpu.reset();
    test("
        ld bc, $1122
        ld de, $3344
        ld hl, $5566
        ld ix, $99aa
        ld iy, $bbcc
        ld sp, $7788

", [0x01, 0x22, 0x11,
    0x11, 0x44, 0x33,
    0x21, 0x66, 0x55,
    0xdd, 0x21, 0xaa, 0x99,
    0xfd, 0x21, 0xcc, 0xbb,
    0x31, 0x88, 0x77]);

    assertFlagsClear(allFlags());
    assert(state.BC == 0x1122);
    assert(state.DE == 0x3344);
    assert(state.HL == 0x5566);
    assert(state.IX == 0x99aa);
    assert(state.IY == 0xbbcc);
    assert(state.SP == 0x7788);
    //-----------------------------------------
    test("
        ld b, $01
        ld c, $02
        ld d, $03
        ld e, $04
        ld h, $05
        ld l, $06
        ld a, $07

", [0x06, 0x01,
     0x0e, 0x02,
     0x16, 0x03,
     0x1e, 0x04,
     0x26, 0x05,
     0x2e, 0x06,
     0x3e, 0x07
     ]);

    assertFlagsClear(allFlags());
    assert(state.B == 0x01);
    assert(state.C == 0x02);
    assert(state.D == 0x03);
    assert(state.E == 0x04);
    assert(state.H == 0x05);
    assert(state.L == 0x06);
    assert(state.A == 0x07);
}
void ld_rrr() {
    cpu.reset();

    test("
        ld a, $07
        ld a, a
        ld b, a
        ld c, a
        ld d, a
        ld e, a
        ld h, a
        ld l, a

", [0x3e, 0x07, 0x7f, 0x47, 0x4f, 0x57, 0x5f, 0x67, 0x6f]);

    assertFlagsClear(allFlags());
    assert(state.A == 7);
    assert(state.B == 7);
    assert(state.C == 7);
    assert(state.D == 7);
    assert(state.E == 7);
    assert(state.H == 7);
    assert(state.L == 7);
    //---------------------------------------
    test("
        ld b, $09
        ld a, b
        ld b, b
        ld c, b
        ld d, b
        ld e, b
        ld h, b
        ld l, b

", [0x06, 0x09, 0x78, 0x40, 0x48, 0x50, 0x58, 0x60, 0x68]);

    assertFlagsClear(allFlags());
    assert(state.A == 9);
    assert(state.B == 9);
    assert(state.C == 9);
    assert(state.D == 9);
    assert(state.E == 9);
    assert(state.H == 9);
    assert(state.L == 9);
    //---------------------------------------
    test("
        ld c, $11
        ld a, c
        ld b, c
        ld c, c
        ld d, c
        ld e, c
        ld h, c
        ld l, c

", [0x0e, 0x11, 0x79, 0x41, 0x49, 0x51, 0x59, 0x61, 0x69]);

    assertFlagsClear(allFlags());
    assert(state.A == 17);
    assert(state.B == 17);
    assert(state.C == 17);
    assert(state.D == 17);
    assert(state.E == 17);
    assert(state.H == 17);
    assert(state.L == 17);
    //---------------------------------------
    test("
        ld d, $13
        ld a, d
        ld b, d
        ld c, d
        ld d, d
        ld e, d
        ld h, d
        ld l, d

", [0x16, 0x13, 0x7a, 0x42, 0x4a, 0x52, 0x5a, 0x62, 0x6a]);

    assertFlagsClear(allFlags());
    assert(state.A == 19);
    assert(state.B == 19);
    assert(state.C == 19);
    assert(state.D == 19);
    assert(state.E == 19);
    assert(state.H == 19);
    assert(state.L == 19);
    //---------------------------------------
    test("
        ld e, $15
        ld a, e
        ld b, e
        ld c, e
        ld d, e
        ld e, e
        ld h, e
        ld l, e

", [0x1e, 0x15,  0x7b, 0x43, 0x4b, 0x53, 0x5b, 0x63, 0x6b]);

    assertFlagsClear(allFlags());
    assert(state.A == 21);
    assert(state.B == 21);
    assert(state.C == 21);
    assert(state.D == 21);
    assert(state.E == 21);
    assert(state.H == 21);
    assert(state.L == 21);
    //---------------------------------------
    test("
        ld h, $17
        ld a, h
        ld b, h
        ld c, h
        ld d, h
        ld e, h
        ld h, h
        ld l, h

", [0x26, 0x17,  0x7c, 0x44, 0x4c, 0x54, 0x5c, 0x64, 0x6c]);

    assertFlagsClear(allFlags());
    assert(state.A == 23);
    assert(state.B == 23);
    assert(state.C == 23);
    assert(state.D == 23);
    assert(state.E == 23);
    assert(state.H == 23);
    assert(state.L == 23);
    //---------------------------------------
    test("
        ld l, $19
        ld a, l
        ld b, l
        ld c, l
        ld d, l
        ld e, l
        ld h, l
        ld l, l

", [0x2e, 0x19,  0x7d, 0x45, 0x4d, 0x55, 0x5d, 0x65, 0x6d]);

    assertFlagsClear(allFlags());
    assert(state.A == 25);
    assert(state.B == 25);
    assert(state.C == 25);
    assert(state.D == 25);
    assert(state.E == 25);
    assert(state.H == 25);
    assert(state.L == 25);
}
void ld_indirect() {
    cpu.reset();

    test("
        ld a, $15
        ld bc, $8000
        ld de, $9000
        ld (bc), a
        ld (de), a

", [0x3e, 0x15,
     0x01, 0x00, 0x80,
     0x11, 0x00, 0x90,
     0x02,
     0x12]);

    assertFlagsClear(allFlags());
    assert(state.A == 0x15);
    assert(state.BC == 0x8000);
    assert(state.DE == 0x9000);
    assert(bus.read(0x8000) == 0x15);
    assert(bus.read(0x9000) == 0x15);

    test("
        ld a, $15
        ld hl, $1234
        ld ($6000), a
        ld ($7000), hl

", [0x3e, 0x15,
     0x21, 0x34, 0x12,
     0x32, 0x00, 0x60,
     0x22, 0x00, 0x70]);

    assertFlagsClear(allFlags());
    assert(state.A == 0x15);
    assert(state.HL == 0x1234);
    assert(bus.read(0x6000) == 0x15);
    assert(bus.readWord(0x7000) == 0x1234);
    //-------------------------------------------

    writeBytes(0x6000, [1,2,3,4,5]);
    test("
        ld bc, $6000
        ld a, (bc)

", [0x01, 0x00, 0x60,
     0x0a]);

    assertFlagsClear(allFlags());
    assert(state.A == 1);

    test("
        ld de, $6001
        ld a, (de)

", [0x11, 0x01, 0x60,
     0x1a]);

    assertFlagsClear(allFlags());
    assert(state.A == 2);

    test("
        ld hl, ($6002)
        ld a, ($6004)

", [0x2a, 0x02, 0x60,
     0x3a, 0x04, 0x60]);

    assertFlagsClear(allFlags());
    assert(state.HL == 0x0403);
    assert(state.A == 5);

    test("
        ld hl, $6000
        ld (hl), $23

        ld a, (hl)
        ld b, (hl)
        ld c, (hl)
        ld d, (hl)
        ld e, (hl)

", [0x21, 0x00, 0x60,
     0x36, 0x23,
     0x7e, 0x46, 0x4e, 0x56, 0x5e]);

    assertFlagsClear(allFlags());
    assert(state.HL == 0x6000);
    assert(bus.read(0x6000) == 0x23);
    assert(state.A == 0x23);
    assert(state.B == 0x23);
    assert(state.C == 0x23);
    assert(state.D == 0x23);
    assert(state.E == 0x23);

    writeBytes(0x6000, [0x23]);

    test("
        ld hl, $6000
        ld h, (hl)

", [0x21, 0x00, 0x60,
     0x66]);

    assertFlagsClear(allFlags());
    assert(state.H == 0x23);

    test("
        ld hl, $6000
        ld l, (hl)

", [0x21, 0x00, 0x60,
     0x6e]);

    assertFlagsClear(allFlags());
    assert(state.L == 0x23);

    state.HL = 0x6000;
    state.A = 1;
    state.B = 2;
    state.C = 3;
    state.D = 4;
    state.E = 5;
    test("
        ld (hl), a
        inc hl
        ld (hl), b
        inc hl
        ld (hl), c
        inc hl
        ld (hl), d
        inc hl
        ld (hl), e
        inc hl
        ld (hl), h
        inc hl
        ld (hl), l

", [0x77, 0x23,
     0x70, 0x23,
     0x71, 0x23,
     0x72, 0x23,
     0x73, 0x23,
     0x74, 0x23,
     0x75]);

    assertFlagsClear(allFlags());
    assert(bus.read(0x6000) == 1);
    assert(bus.read(0x6001) == 2);
    assert(bus.read(0x6002) == 3);
    assert(bus.read(0x6003) == 4);
    assert(bus.read(0x6004) == 5);
    assert(bus.read(0x6005) == 0x60);
    assert(bus.read(0x6006) == 6);

    //--------------------------------- ld (ix+d), n

    // This one is awkward because it has 2 fixups
    writeBytes(0x0000, [0]);
    state.IX = 0x0000;
    test("
        ld (ix+$01), $11
    ", [0xdd, 0x36, 0x01, 0x11]);

    //--------------------------------- ld b, (ix+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IX = 0x0000;
    test("
        ld b, (ix+$01)
    ", [0xdd, 0x46, 0x01]);

    assert(state.B == 0x07);

    //--------------------------------- ld c, (ix+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IX = 0x0000;
    test("
        ld c, (ix+$01)
    ", [0xdd, 0x4e, 0x01]);

    assert(state.C == 0x07);

    //--------------------------------- ld d, (ix+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IX = 0x0000;
    test("
        ld d, (ix+$01)
    ", [0xdd, 0x56, 0x01]);

    assert(state.D == 0x07);

    //--------------------------------- ld e, (ix+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IX = 0x0000;
    test("
        ld e, (ix+$01)
    ", [0xdd, 0x5e, 0x01]);

    assert(state.E == 0x07);

    //--------------------------------- ld h, (ix+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IX = 0x0000;
    test("
        ld h, (ix+$01)
    ", [0xdd, 0x66, 0x01]);

    assert(state.H == 0x07);

    //--------------------------------- ld l, (ix+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IX = 0x0000;
    test("
        ld l, (ix+$01)
    ", [0xdd, 0x6e, 0x01]);

    assert(state.L == 0x07);

    //--------------------------------- ld a, (ix+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IX = 0x0000;
    test("
        ld a, (ix+$01)
    ", [0xdd, 0x7e, 0x01]);

    assert(state.A == 0x07);

    //--------------------------------- ld (ix+d), a
    state.A = 0x11;
    state.IX = 0x0000;
    test("
        ld (ix+$02), a
    ", [0xdd, 0x77, 0x02]);

    assert(bus.read(0x0002) == 0x11);
    //--------------------------------- ld (ix+d), b
    state.B = 0x12;
    state.IX = 0x0000;
    test("
        ld (ix+$02), b
    ", [0xdd, 0x70, 0x02]);

    assert(bus.read(0x0002) == 0x12);
    //--------------------------------- ld (ix+d), c
    state.C = 0x13;
    state.IX = 0x0000;
    test("
        ld (ix+$02), c
    ", [0xdd, 0x71, 0x02]);

    assert(bus.read(0x0002) == 0x13);
    //--------------------------------- ld (ix+d), d
    state.D = 0x14;
    state.IX = 0x0000;
    test("
        ld (ix+$02), d
    ", [0xdd, 0x72, 0x02]);

    assert(bus.read(0x0002) == 0x14);
    //--------------------------------- ld (ix+d), e
    state.E = 0x15;
    state.IX = 0x0000;
    test("
        ld (ix+$02), e
    ", [0xdd, 0x73, 0x02]);

    assert(bus.read(0x0002) == 0x15);
    //--------------------------------- ld (ix+d), h
    state.H = 0x16;
    state.IX = 0x0000;
    test("
        ld (ix+$02), h
    ", [0xdd, 0x74, 0x02]);

    assert(bus.read(0x0002) == 0x16);
    //--------------------------------- ld (ix+d), l
    state.L = 0x17;
    state.IX = 0x0000;
    test("
        ld (ix+$02), l
    ", [0xdd, 0x75, 0x02]);

    assert(bus.read(0x0002) == 0x17);
    //--------------------------------- ld a, (ix+d)
    writeBytes(0x0000, [0, 0, 0, 0x33]);
    state.IX = 0x0000;
    test("
        ld a, (ix+$03)
    ", [0xdd, 0x7e, 0x03]);

    assert(bus.read(0x0003) == 0x33);



    //--------------------------------- ld (iy+d), n

    // This one is awkward because it has 2 fixups
    writeBytes(0x0000, [0]);
    state.IY = 0x0000;
    test("
        ld (iy+$01), $11
    ", [0xfd, 0x36, 0x01, 0x11]);

    //--------------------------------- ld b, (iy+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IY = 0x0000;
    test("
        ld b, (iy+$01)
    ", [0xfd, 0x46, 0x01]);

    assert(state.B == 0x07);

    //--------------------------------- ld c, (iy+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IY = 0x0000;
    test("
        ld c, (iy+$01)
    ", [0xfd, 0x4e, 0x01]);

    assert(state.C == 0x07);

    //--------------------------------- ld d, (iy+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IY = 0x0000;
    test("
        ld d, (iy+$01)
    ", [0xfd, 0x56, 0x01]);

    assert(state.D == 0x07);

    //--------------------------------- ld e, (iy+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IY = 0x0000;
    test("
        ld e, (iy+$01)
    ", [0xfd, 0x5e, 0x01]);

    assert(state.E == 0x07);

    //--------------------------------- ld h, (iy+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IY = 0x0000;
    test("
        ld h, (iy+$01)
    ", [0xfd, 0x66, 0x01]);

    assert(state.H == 0x07);

    //--------------------------------- ld l, (iy+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IY = 0x0000;
    test("
        ld l, (iy+$01)
    ", [0xfd, 0x6e, 0x01]);

    assert(state.L == 0x07);

    //--------------------------------- ld a, (iy+d)
    writeBytes(0x0000, [0x00, 0x07]);
    state.IY = 0x0000;
    test("
        ld a, (iy+$01)
    ", [0xfd, 0x7e, 0x01]);

    assert(state.A == 0x07);

    //--------------------------------- ld (iy+d), a
    state.A = 0x11;
    state.IY = 0x0000;
    test("
        ld (iy+$02), a
    ", [0xfd, 0x77, 0x02]);

    assert(bus.read(0x0002) == 0x11);
    //--------------------------------- ld (iy+d), b
    state.B = 0x12;
    state.IY = 0x0000;
    test("
        ld (iy+$02), b
    ", [0xfd, 0x70, 0x02]);

    assert(bus.read(0x0002) == 0x12);
    //--------------------------------- ld (iy+d), c
    state.C = 0x13;
    state.IY = 0x0000;
    test("
        ld (iy+$02), c
    ", [0xfd, 0x71, 0x02]);

    assert(bus.read(0x0002) == 0x13);
    //--------------------------------- ld (iy+d), d
    state.D = 0x14;
    state.IY = 0x0000;
    test("
        ld (iy+$02), d
    ", [0xfd, 0x72, 0x02]);

    assert(bus.read(0x0002) == 0x14);
    //--------------------------------- ld (iy+d), e
    state.E = 0x15;
    state.IY = 0x0000;
    test("
        ld (iy+$02), e
    ", [0xfd, 0x73, 0x02]);

    assert(bus.read(0x0002) == 0x15);
    //--------------------------------- ld (iy+d), h
    state.H = 0x16;
    state.IY = 0x0000;
    test("
        ld (iy+$02), h
    ", [0xfd, 0x74, 0x02]);

    assert(bus.read(0x0002) == 0x16);
    //--------------------------------- ld (iy+d), l
    state.L = 0x17;
    state.IY = 0x0000;
    test("
        ld (iy+$02), l
    ", [0xfd, 0x75, 0x02]);

    assert(bus.read(0x0002) == 0x17);
    //--------------------------------- ld a, (iy+d)
    writeBytes(0x0000, [0, 0, 0, 0x33]);
    state.IY = 0x0000;
    test("
        ld a, (iy+$03)
    ", [0xfd, 0x7e, 0x03]);

    assert(bus.read(0x0003) == 0x33);
}
void ld_r() {
    cpu.reset();

    state.IFF2 = true;
    state.R = 0;
    test("
        ld a, r
    ", LD_A_R);

    assert(state.A == 0);
    assertFlagsSet(Z, PV);
    assertFlagsClear(N, H, S);

    state.IFF2 = false;
    state.R = 0x80;
    test("
        ld a, r
    ", LD_A_R);

    assert(state.A == 0x80);
    assertFlagsSet(S);
    assertFlagsClear(N, H, PV, Z);

    //----------------------------------

    state.F = 0;
    state.A = 0x10;
    test("
        ld r, a
    ", LD_R_A);

    assert(state.R == 0x10);
    assertFlagsClear(allFlags());
}
void ld_i() {
    cpu.reset();

    state.IFF2 = true;
    state.I = 0;
    test("
        ld a, i
    ", LD_A_I);

    assert(state.A == 0);
    assertFlagsSet(Z, PV);
    assertFlagsClear(N, H, S);

    state.IFF2 = false;
    state.I = 0x80;
    test("
        ld a, i
    ", LD_A_I);

    assert(state.A == 0x80);
    assertFlagsSet(S);
    assertFlagsClear(N, H, PV, Z);

    //----------------------------------

    state.F = 0;
    state.A = 0x10;
    test("
        ld i, a
    ", LD_I_A);

    assert(state.I == 0x10);
    assertFlagsClear(allFlags());
}
void ld_rr_nn_ED() {
    cpu.reset();

    writeBytes(0x0123, [0x01, 0x02]);
    test("
        ld bc, ($0123)
    ", LD_BC_NN ~ [0x23, 0x01]);

    assert(state.BC == 0x0201);
    assertFlagsClear(allFlags());

    test("
        ld de, ($0123)
    ", LD_DE_NN ~ [0x23, 0x01]);

    assert(state.DE == 0x0201);
    assertFlagsClear(allFlags());

    // This one chooses the shorter [0x2a, 0x23, 0x01]
    //test("
    //    ld hl, ($0123)
    //", LD_HL_NN ~ [0x23, 0x01]);

    //assert(state.HL == 0x0201);
    //assertFlagsClear(allFlags());

    test("
        ld sp, ($0123)
    ", LD_SP_NN ~ [0x23, 0x01]);

    assert(state.SP == 0x0201);
    assertFlagsClear(allFlags());
}
void ld_nn_rr_ED() {
    cpu.reset();

    state.BC = 0x1111;
    state.DE = 0x2222;
    state.HL = 0x3333;
    state.SP = 0x4444;
    state.IX = 0x5555;
    test("
        ld ($0123), bc
    ", LD_NN_BC ~ [0x23, 0x01]);

    assert(bus.readWord(0x0123) == 0x1111);
    assertFlagsClear(allFlags());

    test("
        ld ($0123), de
    ", LD_NN_DE ~ [0x23, 0x01]);

    assert(bus.readWord(0x0123) == 0x2222);
    assertFlagsClear(allFlags());

    // this chooses the shorter [0x22, 0x23, 0x01]
    // test("
    //     ld ($0123), hl
    // ", LD_NN_HL ~ [0x23, 0x01]);

    // assert(bus.readWord(0x0123) == 0x3333);
    // assertFlagsClear(allFlags());

    test("
        ld ($0123), sp
    ", LD_NN_SP ~ [0x23, 0x01]);

    assert(bus.readWord(0x0123) == 0x4444);
    assertFlagsClear(allFlags());
}
void ld_nn_rr() {
    cpu.reset();
    state.F = 0;

    state.HL = 0x3333;
    state.IX = 0x4444;
    test("
        ld ($0123), hl
        ld ($0125), ix
    ", [0x22]       ~ [0x23, 0x01] ~
       [0xdd, 0x22] ~ [0x25, 0x01]);

    assert(bus.readWord(0x0123) == 0x3333);
    assert(bus.readWord(0x0125) == 0x4444);
    assertFlagsClear(allFlags());
}
void ld_rr_nn() {
    cpu.reset();

    writeBytes(0x0123, [0x01, 0x02, 0x03, 0x04]);
    test("
       ld hl, ($0123)
       ld ix, ($0125)
    ", [0x2a]       ~ [0x23, 0x01] ~
       [0xdd, 0x2a] ~ [0x25, 0x01]);

    assert(state.HL == 0x0201);
    assert(state.IX == 0x0403);
    assertFlagsClear(allFlags());
}
void ld_rr_rr() {
    cpu.reset();
    state.F = 0;

    state.HL = 0x1234;
    test("
        ld sp, hl
    ", [0xf9]);

    assert(state.SP == 0x1234);

    state.IX = 0x1234;
    test("
        ld sp, ix
    ", [0xdd, 0xf9]);

    assert(state.SP == 0x1234);
}

setup();

ld_imm();
ld_rrr();
ld_indirect();
ld_r();
ld_i();
ld_rr_nn_ED();
ld_nn_rr_ED();
ld_nn_rr();
ld_rr_nn();
ld_rr_rr();

} //unittest