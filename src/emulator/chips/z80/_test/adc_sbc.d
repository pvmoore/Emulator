module emulator.chips.z80._test.adc_sbc;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

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

void adc() {
    cpu.reset();

    //------------------------------------------ adc a, n

    state.A = 0b0000_1111;  // 15
    state.flagC(true);
    test("
        adc a, $0f
    ", [ADC_N, 0x0f]);

    assert(state.A == 0b0001_1111); // 15 + 15 + 1 = 31
    assertFlagsSet(H);
    assertFlagsClear(C, N, PV, S, Z);

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
    assertFlagsSet(C, PV, Z);
    assertFlagsClear(N, S);

    //------------------------------------------ adc a, a

    state.A = 0b0000_1111;  // 15
    state.flagC(true);
    test("
        adc a, a
    ", [ADC_A]);

    assert(state.A == 0b0001_1111); // 15 + 15 + 1 = 31
    assertFlagsSet(H);
    assertFlagsClear(C, N, PV, S, Z);

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
    assertFlagsSet(H, N);
    assertFlagsClear(C, PV, S, Z);

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
        sbc a, $80
    ", [SBC_N, 0x80]);

    assert(state.A == 0x00); // 0x80 - 0x80 = 0x00
    assertFlagsSet(N, Z);
    assertFlagsClear(C, S, PV);
}

setup();

adc();
sbc();

} // unittest