module emulator.chips.z80._test.ld;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

void ld_imm() {
    cpu.reset();
    test("
        ld bc, $1122
        ld de, $3344
        ld hl, $5566
        ld sp, $7788

", [0x01, 0x22, 0x11,
     0x11, 0x44, 0x33,
     0x21, 0x66, 0x55,
     0x31, 0x88, 0x77]);

    assertFlagsClear(allFlags());
    assert(state.BC == 0x1122);
    assert(state.DE == 0x3344);
    assert(state.HL == 0x5566);
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
void ld_r() {
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
}

setup();

ld_imm();
ld_r();
ld_indirect();

} //unittest