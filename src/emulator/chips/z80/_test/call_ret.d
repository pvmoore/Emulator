module emulator.chips.z80._test.call_ret;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

enum {
    INC_A   = 0x3c,
    CALL_Z  = 0xcc, CALL_NZ = 0xc4,
    CALL_C  = 0xdc, CALL_NC = 0xd4,
    CALL_PE = 0xec, CALL_PO = 0xe4,
    CALL_M  = 0xfc, CALL_P  = 0xf4, CALL_NN = 0xcd,
    RET_Z   = 0xc8, RET_NZ  = 0xc0, RET = 0xc9,
    RET_C   = 0xd8, RET_NC  = 0xd0,
    RET_PE  = 0xe8, RET_PO  = 0xe0,
    RET_M   = 0xf8, RET_P   = 0xf0
}

void call() {
    cpu.reset();

    state.A  = 0x00;
    state.SP = 0x2000;
    test("
        call $1003  ; 0x1000 ---┐
        nop         ; 0x1003 ←--┙

    ", [CALL_NN, 0x03, 0x10, 0x00]);

    // Flags are not affected
    assertFlagsClear(allFlags());

    //----------------------------- call nn

    state.A  = 0x00;
    state.SP = 0x2000;
    test("
        call $1004  ; 0x1000 ---┐
        inc a       ; 0x1003    |
        inc a       ; 0x1004 ←--┙

    ", [CALL_NN, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2000-2);

    //----------------------------- call z, nn
    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagZ(true);
    test("
        call z, $1004   ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙
        ; nop           ; 0x1005

    ", [CALL_Z, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2000-2);
    assert(state.PC == 0x1006);

    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagZ(false);
    test("
        call z, $1004   ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙

    ", [CALL_Z, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1005);

    //----------------------------- call nz, nn
    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagZ(true);
    test("
        call nz, $1004  ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙
        ; nop           ; 0x1005

    ", [CALL_NZ, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1005);

    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagZ(false);
    test("
        call nz, $1004  ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙

    ", [CALL_NZ, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2000-2);
    assert(state.PC == 0x1006);

    //----------------------------- call c, nn
    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagC(true);
    test("
        call c, $1004   ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙
        ; nop           ; 0x1005

    ", [CALL_C, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2000-2);
    assert(state.PC == 0x1006);

    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagC(false);
    test("
        call c, $1004   ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙

    ", [CALL_C, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1005);

    //----------------------------- call nc, nn
    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagC(true);
    test("
        call nc, $1004  ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙
        ; nop           ; 0x1005

    ", [CALL_NC, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1005);

    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagC(false);
    test("
        call nc, $1004  ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙

    ", [CALL_NC, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2000-2);
    assert(state.PC == 0x1006);

    //----------------------------- call pe, nn
    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagPV(true);
    test("
        call pe, $1004  ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙
        ; nop           ; 0x1005

    ", [CALL_PE, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2000-2);
    assert(state.PC == 0x1006);

    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagPV(false);
    test("
        call pe, $1004  ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙

    ", [CALL_PE, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1005);

    //----------------------------- call po, nn
    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagPV(true);
    test("
        call po, $1004  ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙
        ; nop           ; 0x1005

    ", [CALL_PO, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1005);

    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagPV(false);
    test("
        call po, $1004  ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙

    ", [CALL_PO, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2000-2);
    assert(state.PC == 0x1006);

    //----------------------------- call m, nn
    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagS(true);
    test("
        call m, $1004   ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙
        ; nop           ; 0x1005

    ", [CALL_M, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2000-2);
    assert(state.PC == 0x1006);

    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagS(false);
    test("
        call m, $1004   ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙

    ", [CALL_M, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1005);

    //----------------------------- call p, nn
    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagS(true);
    test("
        call p, $1004   ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙
        ; nop           ; 0x1005

    ", [CALL_P, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1005);

    state.A  = 0x00;
    state.SP = 0x2000;
    state.flagS(false);
    test("
        call p, $1004   ; 0x1000 ---┐
        inc a           ; 0x1003    |
        inc a           ; 0x1004 ←--┙

    ", [CALL_P, 0x04, 0x10, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2000-2);
    assert(state.PC == 0x1006);
}
void ret() {
    cpu.reset();

    //----------------------------- ret
    state.A = 0x00;
    state.SP = 0x2000;
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret     ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2002);
    assert(state.PC == 0x1004);

    //----------------------------- ret z
    state.A = 0x00;
    state.SP = 0x2000;
    state.flagZ(true);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret z   ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_Z, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2002);
    assert(state.PC == 0x1004);

    state.A = 0x00;
    state.SP = 0x2000;
    state.flagZ(false);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret z   ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_Z, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1003);

    //----------------------------- ret nz
    state.A = 0x00;
    state.SP = 0x2000;
    state.flagZ(true);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret nz  ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_NZ, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1003);

    state.A = 0x00;
    state.SP = 0x2000;
    state.flagZ(false);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret nz  ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_NZ, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2002);
    assert(state.PC == 0x1004);

    //----------------------------- ret c
    state.A = 0x00;
    state.SP = 0x2000;
    state.flagC(true);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret c   ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_C, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2002);
    assert(state.PC == 0x1004);

    state.A = 0x00;
    state.SP = 0x2000;
    state.flagC(false);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret c   ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_C, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1003);

    //----------------------------- ret nc
    state.A = 0x00;
    state.SP = 0x2000;
    state.flagC(true);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret nc  ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_NC, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1003);

    state.A = 0x00;
    state.SP = 0x2000;
    state.flagC(false);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret nc  ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_NC, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2002);
    assert(state.PC == 0x1004);

    //----------------------------- ret pe
    state.A = 0x00;
    state.SP = 0x2000;
    state.flagPV(true);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret pe  ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_PE, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2002);
    assert(state.PC == 0x1004);

    state.A = 0x00;
    state.SP = 0x2000;
    state.flagPV(false);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret pe  ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_PE, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1003);

    //----------------------------- ret po
    state.A = 0x00;
    state.SP = 0x2000;
    state.flagPV(true);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret po  ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_PO, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1003);

    state.A = 0x00;
    state.SP = 0x2000;
    state.flagPV(false);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret po  ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_PO, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2002);
    assert(state.PC == 0x1004);

    //----------------------------- ret m
    state.A = 0x00;
    state.SP = 0x2000;
    state.flagS(true);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret m   ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_M, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2002);
    assert(state.PC == 0x1004);

    state.A = 0x00;
    state.SP = 0x2000;
    state.flagS(false);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret m   ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_M, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1003);

    //----------------------------- ret p
    state.A = 0x00;
    state.SP = 0x2000;
    state.flagS(true);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret p   ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_P, INC_A, INC_A]);

    assert(state.A == 0x02);
    assert(state.SP == 0x2000);
    assert(state.PC == 0x1003);

    state.A = 0x00;
    state.SP = 0x2000;
    state.flagS(false);
    writeBytes(0x2000, [0x02, 0x10]);
    writeBytes(0x1000, [0,0,0,0,0,0,0,0,0,0]);
    test("
        ret p   ; 0x1000
        inc a   ; 0x1001
        inc a   ; 0x1002
        ; nop   ; 0x1003
    ", [RET_P, INC_A, INC_A]);

    assert(state.A == 0x01);
    assert(state.SP == 0x2002);
    assert(state.PC == 0x1004);
}

setup();

call();
ret();

} // unittest
