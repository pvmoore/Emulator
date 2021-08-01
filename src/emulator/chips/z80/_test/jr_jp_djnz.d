module emulator.chips.z80._test.jr_jp_djnz;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

enum INC_A = 0x3c;

void jr() {
    cpu.reset();

    //----------------------------- jr n

    state.A = 0x00;
    test("
        jr $01  ; pc = 0x1000
        inc a   ; pc = 0x1002
        inc a   ; pc = 0x1003
    ", [0x18, 0x01,
        INC_A, INC_A]);

    assertFlagsClear(allFlags());
    assert(state.A == 0x01, "%s".format(state.A));

    test("
        nop     ; pc = 0x1000
        nop     ; pc = 0x1001
        jr $fc  ; pc = 0x1002 (fc = -4)
                ; pc = 0x1004
    ", [0x00, 0x00, 0x18, 0xfc]);

    assertFlagsClear(allFlags());
    assert(state.PC == 0x1000);

    //----------------------------- jr z, n

    state.A = 0x00;
    state.flagZ(true);

    test("
        jr z, $01   ; 0x1000
        inc a       ; 0x1002
        inc a       ; 0x1003
    ", [0x28, 0x01,
        INC_A, INC_A]);

    assert(state.A == 0x01);

    state.A = 0x00;
    state.flagZ(false);

    test("
        jr z, $01   ; 0x1000
        inc a       ; 0x1002
        inc a       ; 0x1003
    ", [0x28, 0x01,
        INC_A, INC_A]);

    assert(state.A == 0x02);

    //----------------------------- jr nz, n

    state.A = 0x00;
    state.flagZ(true);

    test("
        jr nz, $01
        inc a
        inc a
    ", [0x20, 0x01,
        INC_A, INC_A]);

    assert(state.A == 0x02);

    state.A = 0x00;
    state.flagZ(false);

    test("
        jr nz, $01  ; pc = 0x1000 (branch taken)
        inc a       ; pc = 0x1002 (skipped)
        inc a       ; pc = 0x1003
    ", [0x20, 0x01,
        INC_A, INC_A]);

    assert(state.A == 0x01);

    //----------------------------- jr c, n

    state.A = 0x00;
    state.flagC(true);

    test("
        jr c, $01  ; pc = 0x1000 (branch taken)
        inc a      ; pc = 0x1002 (skipped)
        inc a      ; pc = 0x1003
    ", [0x38, 0x01,
        INC_A, INC_A]);

    assert(state.A == 0x01);

    state.A = 0x00;
    state.flagC(false);

    test("
        jr c, $01 ; pc = 0x1000 (branch not taken)
        inc a
        inc a
    ", [0x38, 0x01,
        INC_A, INC_A]);

    assert(state.A == 0x02);

    //----------------------------- jr nc, n

    state.A = 0x00;
    state.flagC(true);

    test("
        jr nc, $03
        inc a
        inc a
    ", [0x30, 0x03,
        INC_A, INC_A]);

    assert(state.A == 0x02);

    state.A = 0x00;
    state.flagC(false);

    test("
        jr nc, $01  ; pc = 0x1000 (branch taken)
        inc a       ; pc = 0x1002 (skipped)
        inc a       ; pc = 0x1003
    ", [0x30, 0x01,
        INC_A, INC_A]);

    assert(state.A == 0x01);
}
void jp() {
    cpu.reset();

    //----------------------------- jp nn

    state.A = 0x00;
    test("
        jp $1004    ; pc = 0x1000
        inc a       ; pc = 0x1003
        inc a       ; pc = 0x1004
        nop         ; pc = 0x1005
    ", [0xc3, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assertFlagsClear(allFlags());
    assert(state.A == 0x01);

    //----------------------------- jp z, nn

    state.A = 0x00;
    state.flagZ(true);
    test("
        jp z, $1004 ; pc = 0x1000
        inc a       ; pc = 0x1003
        inc a       ; pc = 0x1004
        nop         ; pc = 0x0005
    ", [0xca, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x01);

    state.A = 0x00;
    state.flagZ(false);
    test("
        jp z, $1004 ; pc = 0x1000
        inc a       ; pc = 0x1003
        inc a       ; pc = 0x1004
        nop         ; pc = 0x1005
    ", [0xca, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x02);

    //----------------------------- jp nz, nn

    state.A = 0x00;
    state.flagZ(true);
    test("
        jp nz, $1004 ; pc = 0x1000
        inc a        ; pc = 0x1003
        inc a        ; pc = 0x1004
        nop          ; pc = 0x1005
    ", [0xc2, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x02);

    state.A = 0x00;
    state.flagZ(false);
    test("
        jp nz, $1004 ; pc = 0x1000
        inc a        ; pc = 0x1003
        inc a        ; pc = 0x1004
        nop          ; pc = 0x1005
    ", [0xc2, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x01);

    //----------------------------- jp c, nn

    state.A = 0x00;
    state.flagC(true);
    test("
        jp c, $1004 ; pc = 0x1000
        inc a       ; pc = 0x1003
        inc a       ; pc = 0x1004
        nop         ; pc = 0x1005
    ", [0xda, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x01);

    state.A = 0x00;
    state.flagC(false);
    test("
        jp c, $1004 ; pc = 0x1000
        inc a       ; pc = 0x1003
        inc a       ; pc = 0x1004
        nop         ; pc = 0x1004
    ", [0xda, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x02);

    //----------------------------- jp nc, nn

    state.A = 0x00;
    state.flagC(true);
    test("
        jp nc, $1004 ; pc = 0x1000
        inc a        ; pc = 0x1003
        inc a        ; pc = 0x1004
        nop          ; pc = 0x1005
    ", [0xd2, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x02);

    state.A = 0x00;
    state.flagC(false);
    test("
        jp nc, $1004 ; pc = 0x1000
        inc a        ; pc = 0x1003
        inc a        ; pc = 0x1004
        nop          ; pc = 0x1005
    ", [0xd2, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x01);

    //----------------------------- jp pe, nn

    state.A = 0x00;
    state.flagPV(true);
    test("
        jp pe, $1004 ; pc = 0x1000
        inc a        ; pc = 0x1003
        inc a        ; pc = 0x1004
        nop          ; pc = 0x1005
    ", [0xea, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x01);

    state.A = 0x00;
    state.flagPV(false);
    test("
        jp pe, $1004 ; pc = 0x1000
        inc a        ; pc = 0x1003
        inc a        ; pc = 0x1004
        nop          ; pc = 0x1005
    ", [0xea, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x02);

    //----------------------------- jp po, nn

    state.A = 0x00;
    state.flagPV(true);
    test("
        jp po, $1004 ; pc = 0x1000
        inc a        ; pc = 0x1003
        inc a        ; pc = 0x1004
        nop          ; pc = 0x1005
    ", [0xe2, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x02);

    state.A = 0x00;
    state.flagPV(false);
    test("
        jp po, $1004 ; pc = 0x1000
        inc a        ; pc = 0x1003
        inc a        ; pc = 0x1004
        nop          ; pc = 0x1005
    ", [0xe2, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x01);

    //----------------------------- jp m, nn    ; minus

    state.A = 0x00;
    state.flagS(true);
    test("
        jp m, $1004 ; pc = 0x1000
        inc a       ; pc = 0x1003
        inc a       ; pc = 0x1004
        nop         ; pc = 0x1005
    ", [0xfa, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x01);

    state.A = 0x00;
    state.flagS(false);
    test("
        jp m, $1004 ; pc = 0x1000
        inc a       ; pc = 0x1003
        inc a       ; pc = 0x1004
        nop         ; pc = 0x1005
    ", [0xfa, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x02);

    //----------------------------- jp p, nn    ; positive

    state.A = 0x00;
    state.flagS(true);
    test("
        jp p, $1004 ; pc = 0x1000
        inc a       ; pc = 0x1003
        inc a       ; pc = 0x1004
        nop         ; pc = 0x1005
    ", [0xf2, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x02);

    state.A = 0x00;
    state.flagS(false);
    test("
        jp p, $1004 ; pc = 0x1000
        inc a       ; pc = 0x1003
        inc a       ; pc = 0x1004
        nop         ; pc = 0x1005
    ", [0xf2, 0x04, 0x10,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x01);

    //----------------------------- jp (hl)

    state.A = 0x00;
    state.HL = 0x0000;
    writeBytes(0x0000, [0x02, 0x10]);
    test("
        jp (hl)     ; pc = 0x1000
        inc a       ; pc = 0x1001
        inc a       ; pc = 0x1002
        nop         ; pc = 0x1003
        nop         ; pc = 0x1004
    ", [0xe9,
        0x3c,
        0x3c,
        0x00,
        0x00]);

    assert(state.A == 0x01);

    //----------------------------- jp (ix)

    state.A = 0x00;
    state.IX = 0x0000;
    writeBytes(0x0000, [0x03, 0x10]);
    test("
        jp (ix)     ; pc = 0x1000
        inc a       ; pc = 0x1002
        inc a       ; pc = 0x1003
        nop         ; pc = 0x1004
        nop         ; pc = 0x1005
    ", [0xdd, 0xe9,
        0x3c,
        0x3c,
        0x00,
        0x00]);

    assert(state.A == 0x01);

    //----------------------------- jp (iy)

    state.A = 0x00;
    state.IY = 0x0000;
    writeBytes(0x0000, [0x03, 0x10]);
    test("
        jp (iy)     ; pc = 0x1000
        inc a       ; pc = 0x1002
        inc a       ; pc = 0x1003
        nop         ; pc = 0x1004
        nop         ; pc = 0x1005
    ", [0xfd, 0xe9,
        0x3c,
        0x3c,
        0x00,
        0x00]);

    assert(state.A == 0x01, "%s".format(state.A));
}
void djnz() {
    cpu.reset();

    state.A = 0x00;
    state.B = 0x01;

    test("
        djnz $03    ; pc = 0x1000 (branch not taken)
        inc a       ; pc = 0x1002
        inc a       ; pc = 0x1003
        nop         ; pc = 0x1004
    ", [0x10, 0x03,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x02);
    assert(state.B == 0x00);

    state.A = 0x00;
    state.B = 0x02;

    test("
        djnz $01    ; pc = 0x1000 (branch taken)
        inc a       ; pc = 0x1002
        inc a       ; pc = 0x1003
        nop         ; pc = 0x1004
    ", [0x10, 0x01,
        INC_A,
        INC_A,
        0x00]);

    assert(state.A == 0x01);
    assert(state.B == 0x01);
}

setup();

jr();
jp();
djnz();

} // unittest