module emulator.chips.z80._test.adc_sbc;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {
static if(true) {

enum {
    ADC_N  = 0xce,
    ADC_A  = 0x8f,
    ADC_B  = 0x88,
    ADC_C  = 0x89,
    ADC_D  = 0x8a,
    ADC_E  = 0x8b,
    ADC_H  = 0x8c,
    ADC_L  = 0x8d,
    ADC_HL = 0x8e,

    SBC_N  = 0xde,
    SBC_A  = 0x9f,
    SBC_B  = 0x98,
    SBC_C  = 0x99,
    SBC_D  = 0x9a,
    SBC_E  = 0x9b,
    SBC_H  = 0x9c,
    SBC_L  = 0x9d,
    SBC_HL = 0x9e,
}
enum {
    ADC_HL_BC = [0xed, 0x4a],
    ADC_HL_DE = [0xed, 0x5a],
    ADC_HL_HL = [0xed, 0x6a],
    ADC_HL_SP = [0xed, 0x7a],

    SBC_HL_BC = [0xed, 0x42],
    SBC_HL_DE = [0xed, 0x52],
    SBC_HL_HL = [0xed, 0x62],
    SBC_HL_SP = [0xed, 0x72],

    ADC_IX = [0xdd, 0x8e],
    ADC_IY = [0xfd, 0x8e],
    SBC_IX = [0xdd, 0x9e],
    SBC_IY = [0xfd, 0x9e],
}

void adc() {
    cpu.reset();

    //------------------------------------------ adc a, n

    state.A = 0b0000_1111;  // 15
    state.flagC(true);
    test("
        adc a, $0f
    ", [ADC_N, 0x0f]);

    assert(state.A == 0b0001_1111); // 15 + 15 + 1 = 31
    assertFlagsSet();
    assertFlagsClear(C, N, H, PV, S, Z);

    state.A = 0b0000_1111;  // 15
    state.flagC(false);
    test("
        adc a, $0f
    ", [ADC_N, 0x0f]);

    assert(state.A == 0b0001_1110);    // 15 + 15 = 30
    assertFlagsSet(H);
    assertFlagsClear(C, N, PV, S, Z);

    // test overflow

    state.A = 0x80;  // 128
    state.flagC(false);
    test("
        adc a, $80
    ", [ADC_N, 0x80]);

    assert(state.A == 0x00); // 0x80 + 0x80 = 0x00
    assertFlagsSet(C, Z, PV);
    assertFlagsClear(N, S);

    //------------------------------------------ adc a, a

    state.A = 0b0000_1111;  // 15
    state.flagC(true);
    test("
        adc a, a
    ", [ADC_A]);

    assert(state.A == 0b0001_1111); // 15 + 15 + 1 = 31
    assertFlagsSet();
    assertFlagsClear(C, N, H, PV, S, Z);

    state.A = 0b0000_1111;  // 15
    state.flagC(false);
    test("
        adc a, a
    ", [ADC_A]);

    assert(state.A == 0b0001_1110);    // 15 + 15 = 30
    assertFlagsSet(H);
    assertFlagsClear(C, N, PV, S, Z);

    // test overflow

    state.A = 0x80;  // 128
    state.flagC(false);
    test("
        adc a, a
    ", [ADC_A]);

    assert(state.A == 0x00); // 0x80 + 0x80 = 0x00
    assertFlagsSet(C, PV, Z);
    assertFlagsClear(N, S);

    //-------------------------------------- adc a, b
    state.A = 0x02;
    state.B = 0x01;
    state.flagC(true);
    test("
        adc a, b
    ", [ADC_B]);

    assert(state.A == 0x03 + 1);
    assertFlagsSet();
    assertFlagsClear(C, H, N, PV, S, Z);

    //-------------------------------------- adc a, c
    state.A = 0x02;
    state.C = 0x01;
    state.flagC(true);
    test("
        adc a, c
    ", [ADC_C]);

    assert(state.A == 0x03 + 1);
    assertFlagsSet();
    assertFlagsClear(C, H, N, PV, S, Z);

    //-------------------------------------- adc a, d
    state.A = 0x02;
    state.D = 0x01;
    state.flagC(true);
    test("
        adc a, d
    ", [ADC_D]);

    assert(state.A == 0x03 + 1);
    assertFlagsSet();
    assertFlagsClear(C, H, N, PV, S, Z);

    //-------------------------------------- adc a, e
    state.A = 0x02;
    state.E = 0x01;
    state.flagC(true);
    test("
        adc a, e
    ", [ADC_E]);

    assert(state.A == 0x03 + 1);
    assertFlagsSet();
    assertFlagsClear(C, H, N, PV, S, Z);

    //-------------------------------------- adc a, h
    state.A = 0x02;
    state.H = 0x01;
    state.flagC(true);
    test("
        adc a, h
    ", [ADC_H]);

    assert(state.A == 0x03 + 1);
    assertFlagsSet();
    assertFlagsClear(C, H, N, PV, S, Z);

    //-------------------------------------- adc a, l
    state.A = 0x02;
    state.L = 0x01;
    state.flagC(true);
    test("
        adc a, l
    ", [ADC_L]);

    assert(state.A == 0x03 + 1);
    assertFlagsSet();
    assertFlagsClear(C, H, N, PV, S, Z);

    //-------------------------------------- adc a, (hl)
    state.A = 0x02;
    state.HL = 0x0000;
    writeBytes(0x0000, [0x07]);
    state.flagC(true);
    test("
        adc a, (hl)
    ", [ADC_HL]);

    assert(state.A == 0x09 + 1);
    assertFlagsSet();
    assertFlagsClear(C, H, N, PV, S, Z);

    //------------------------- adc a, (ix+d)
    state.A = 0x02;
    state.IX = 0x0000;
    writeBytes(0x0001, [0x07]);
    state.flagC(true);
    test("
        adc a, (ix + $01)
    ", ADC_IX ~ [0x01]);

    assert(state.A == 0x09 + 1);
    assertFlagsSet();
    assertFlagsClear(C, H, N, PV, S, Z);

    //------------------------- adc a, (iy+d)
    state.A = 0x02;
    state.IY = 0x0000;
    writeBytes(0x0001, [0x07]);
    state.flagC(true);
    test("
        adc a, (iy + $01)
    ", ADC_IY ~ [0x01]);

    assert(state.A == 0x09 + 1);
    assertFlagsSet();
    assertFlagsClear(C, H, N, PV, S, Z);
}
void sbc() {
    cpu.reset();

    //------------------------------------------ sbc a, n

    state.A = 0b0001_1111;  // 31
    state.flagC(true);
    test("
        sbc a, $0f          ; 15
    ", [SBC_N, 0x0f]);

    assert(state.A == 0b0000_1111); // 31 - 15 - 1 = 0x0f
    assertFlagsSet(N);
    assertFlagsClear(C, H, PV, S, Z);

    state.A = 0b0001_1111;  // 31
    state.flagC(false);
    test("
        sbc a, $0f
    ", [SBC_N, 0x0f]);

    assert(state.A == 0b0001_0000);    // 31 - 15 = 0x10
    assertFlagsSet(N);
    assertFlagsClear(H, C, PV, S, Z);

    // // test overflow

    state.A = 0x80;  // 128
    state.flagC(false);
    test("
        sbc a, $01
    ", [SBC_N, 0x01]);

    assert(state.A == 0x7f);
    assertFlagsSet(N, PV);
    assertFlagsClear(Z, C, S);

    state.A = 0xc2;
    state.flagC(false);
    test("
        sbc a, $e9
    ", [SBC_N, 0xe9]);

    assert(state.A == 0xd9);
    assertFlagsSet(N, S, C);
    assertFlagsClear(Z, PV);

    //------------------------------------------ sbc a, a
    state.A = 0b0000_1111;  // 0f
    state.flagC(true);
    test("
        sbc a, a
    ", [SBC_A]);

    assert(state.A == 0xff); // 0f - 0f - 01 = ff
    assertFlagsSet(N, C, S);
    assertFlagsClear(Z, PV, H);

    state.A = 0b1000_0000;  // 80
    state.flagC(false);
    test("
        sbc a, a
    ", [SBC_A]);

    assert(state.A == 0x00); // 0f - 0f - 00 = 00
    assertFlagsSet(N, Z);
    assertFlagsClear(C, S, H, PV);

    //------------------------------------------ sbc a, b
    state.A = 0x0f;
    state.B = 0x0f;
    state.flagC(true);
    test("
        sbc a, b
    ", [SBC_B]);

    assert(state.A == 0xff);
    assertFlagsSet(N, C, S);
    assertFlagsClear(Z, PV, H);

    state.A = 0x80;
    state.B = 0x80;
    state.flagC(false);
    test("
        sbc a, b
    ", [SBC_B]);

    assert(state.A == 0x00);
    assertFlagsSet(N, Z);
    assertFlagsClear(C, S, H, PV);

    //------------------------------------------ sbc a, c
    state.A = 0x0f;
    state.C = 0x0f;
    state.flagC(true);
    test("
        sbc a, c
    ", [SBC_C]);

    assert(state.A == 0xff);
    assertFlagsSet(N, C, S);
    assertFlagsClear(Z, PV, H);

    //------------------------------------------ sbc a, d
    state.A = 0x0f;
    state.D = 0x0f;
    state.flagC(true);
    test("
        sbc a, d
    ", [SBC_D]);

    assert(state.A == 0xff);
    assertFlagsSet(N, C, S);
    assertFlagsClear(Z, PV, H);

    //------------------------------------------ sbc a, e
    state.A = 0x0f;
    state.E = 0x0f;
    state.flagC(true);
    test("
        sbc a, e
    ", [SBC_E]);

    assert(state.A == 0xff);
    assertFlagsSet(N, C, S);
    assertFlagsClear(Z, PV, H);

    //------------------------------------------ sbc a, h
    state.A = 0x0f;
    state.H = 0x0f;
    state.flagC(true);
    test("
        sbc a, h
    ", [SBC_H]);

    assert(state.A == 0xff);
    assertFlagsSet(N, C, S);
    assertFlagsClear(Z, PV, H);

    //------------------------------------------ sbc a, l
    state.A = 0x0f;
    state.L = 0x0f;
    state.flagC(true);
    test("
        sbc a, l
    ", [SBC_L]);

    assert(state.A == 0xff);
    assertFlagsSet(N, C, S);
    assertFlagsClear(Z, PV, H);

    //------------------------------------------ sbc a, (hl)
    state.A = 0x0f;
    state.HL = 0x0000;
    writeBytes(0x0000, [0x0f]);
    state.flagC(true);
    test("
        sbc a, (hl)
    ", [SBC_HL]);

    assert(state.A == 0xff);
    assertFlagsSet(N, C, S);
    assertFlagsClear(Z, PV, H);

    //------------------------------------------ sbc a, (ix+d)
    state.A = 0x0f;
    state.IX = 0x0000;
    writeBytes(0x0001, [0x0f]);
    state.flagC(true);
    test("
        sbc a, (ix+$01)
    ", SBC_IX ~ [0x01]);

    assert(state.A == 0xff);
    assertFlagsSet(N, C, S);
    assertFlagsClear(Z, PV, H);

    //------------------------------------------ sbc a, (iy+d)
    state.A = 0x0f;
    state.IY = 0x0000;
    writeBytes(0x0001, [0x0f]);
    state.flagC(true);
    test("
        sbc a, (iy+$01)
    ", SBC_IY ~ [0x01]);

    assert(state.A == 0xff);
    assertFlagsSet(N, C, S);
    assertFlagsClear(Z, PV, H);
}
void adc_rr() {
    cpu.reset();

    state.flagC(true);
    state.HL = 0x1234;
    state.BC = 0x5678;
    test("
        adc hl, bc
    ", ADC_HL_BC);

    assert(state.HL == 0x68ad);

    assertFlagsSet();
    assertFlagsClear(N, S, Z, C, H, PV);

    //--------------------------------------

    state.flagC(false);
    state.HL = 0x1234;
    state.BC = 0x5678;
    test("
        adc hl, bc
    ", ADC_HL_BC);

    assert(state.HL == 0x68ac);

    assertFlagsSet();
    assertFlagsClear(N, S, Z, C, H, PV);

    //--------------------------------------

    state.flagC(false);
    state.HL = 0x8000;
    state.BC = 0x8000;
    test("
        adc hl, bc
    ", ADC_HL_BC);

    assert(state.HL == 0x0000);

    assertFlagsSet(Z, C, PV);
    assertFlagsClear(N, S, H);

    //--------------------------------------

    state.flagC(false);
    state.HL = 0x1234;
    state.DE = 0x5678;
    test("
        adc hl, de
    ", ADC_HL_DE);

    assert(state.HL == 0x68ac);

    //--------------------------------------

    state.flagC(false);
    state.HL = 0x1234;
    test("
        adc hl, hl
    ", ADC_HL_HL);

    assert(state.HL == 0x2468);

    //--------------------------------------

    state.flagC(false);
    state.HL = 0x1234;
    state.SP = 0x5678;
    test("
        adc hl, sp
    ", ADC_HL_SP);

    assert(state.HL == 0x68ac);
}
void sbc_rr() {
    cpu.reset();

    state.flagC(true);
    state.HL = 0x5678;
    state.BC = 0x1234;
    test("
        sbc hl, bc
    ", SBC_HL_BC);

    assert(state.HL == 0x4443);

    assertFlagsSet(N);
    assertFlagsClear(S, Z, C, H, PV);

    //--------------------------------------

    state.flagC(false);
    state.HL = 0x0000;
    state.BC = 0x0000;
    test("
        sbc hl, bc
    ", SBC_HL_BC);

    assert(state.HL == 0x0000);

    assertFlagsSet(N, Z);
    assertFlagsClear(S, C, H, PV);

    //--------------------------------------

    state.flagC(true);
    state.HL = 0x5678;
    state.BC = 0x5678;
    test("
        sbc hl, bc
    ", SBC_HL_BC);

    assert(state.HL == 0xffff);

    assertFlagsSet(N, S, C, H);
    assertFlagsClear(Z, PV);

    //--------------------------------------

    state.flagC(true);
    state.HL = 0x5678;
    state.DE = 0x1234;
    test("
        sbc hl, de
    ", SBC_HL_DE);

    assert(state.HL == 0x4443);

    assertFlagsSet(N);
    assertFlagsClear(S, Z, C, H, PV);

    //--------------------------------------

    state.flagC(false);
    state.HL = 0x5678;
    test("
        sbc hl, hl
    ", SBC_HL_HL);

    assert(state.HL == 0x0000);

    assertFlagsSet(N, Z);
    assertFlagsClear(S, C, H, PV);

    //--------------------------------------

    state.flagC(true);
    state.HL = 0x5678;
    state.SP = 0x1234;
    test("
        sbc hl, sp
    ", SBC_HL_SP);

    assert(state.HL == 0x4443);

    assertFlagsSet(N);
    assertFlagsClear(S, Z, C, H, PV);
}

writefln("adc sbc tests");

setup();

adc();
sbc();
adc_rr();
sbc_rr();

} // static if
} // unittest
