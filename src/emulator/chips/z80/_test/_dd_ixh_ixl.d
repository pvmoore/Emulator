module emulator.chips.z80._test._dd_ixh_ixl;


import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

enum {
    INC_IXH = [0xdd, 0x24],     // inc h
    DEC_IXH = [0xdd, 0x25],     // dec h
    LD_IXH_N = [0xdd, 0x26],    // ld h, n
    INC_IXL = [0xdd, 0x2c],     // inc l
    DEC_IXL = [0xdd, 0x2d],     // dec l
    LD_IXL_N = [0xdd, 0x2e],    // ld l, n

    LD_B_IXH = [0xdd, 0x44],    // ld b,h
    LD_B_IXL = [0xdd, 0x45],    // ld b,l

    LD_C_IXH = [0xdd, 0x4c],    // ld c,h
    LD_C_IXL = [0xdd, 0x4d],    // ld c,l

    LD_D_IXH = [0xdd, 0x54],    // ld d,h
    LD_D_IXL = [0xdd, 0x55],    // ld d,l

    LD_E_IXH = [0xdd, 0x5c],    // ld e,h
    LD_E_IXL = [0xdd, 0x5d],    // ld e,l

    LD_IXH_B = [0xdd, 0x60],    // ld h,b
    LD_IXH_C = [0xdd, 0x61],    // ld h,c
    LD_IXH_D = [0xdd, 0x62],    // ld h,d
    LD_IXH_E = [0xdd, 0x63],    // ld h,e
    LD_IXH_IXH = [0xdd, 0x64],  // ld h,h
    LD_IXH_IXL = [0xdd, 0x65],  // ld h,l
    LD_IXH_A = [0xdd, 0x67],    // ld h,a

    LD_IXL_B = [0xdd, 0x68],    // ld l,b
    LD_IXL_C = [0xdd, 0x69],    // ld l,c
    LD_IXL_D = [0xdd, 0x6a],    // ld l,d
    LD_IXL_E = [0xdd, 0x6b],    // ld l,e
    LD_IXL_IXH = [0xdd, 0x6c],  // ld l,h
    LD_IXL_IXL = [0xdd, 0x6d],  // ld l,l
    LD_IXL_A = [0xdd, 0x6f],    // ld l,a

    LD_A_IXH = [0xdd, 0x7c],    // ld a,h
    LD_A_IXL = [0xdd, 0x7d],    // ld a,l

    ADD_A_IXH = [0xdd, 0x84],   // add a,h
    ADD_A_IXL = [0xdd, 0x85],   // add a,l
    ADC_A_IXH = [0xdd, 0x8c],   // adc a,h
    ADC_A_IXL = [0xdd, 0x8d],   // adc a,l

    SUB_A_IXH = [0xdd, 0x94],   // sub a,h
    SUB_A_IXL = [0xdd, 0x95],   // sub a,l
    SBC_A_IXH = [0xdd, 0x9c],   // sbc a,h
    SBC_A_IXL = [0xdd, 0x9d],   // sbc a,l

    AND_A_IXH = [0xdd, 0xa4],   // and a,h
    AND_A_IXL = [0xdd, 0xa5],   // and a,l
    XOR_A_IXH = [0xdd, 0xac],   // xor a,h
    XOR_A_IXL = [0xdd, 0xad],   // xor a,l

    OR_A_IXH = [0xdd, 0xb4],    // or a,h
    OR_A_IXL = [0xdd, 0xb5],    // or a,l
    CP_A_IXH = [0xdd, 0xbc],    // cp a,h
    CP_A_IXL = [0xdd, 0xbd],    // cp a,l


    INC_IYH = [0xfd, 0x24],     // inc h
    DEC_IYH = [0xfd, 0x25],     // dec h
    LD_IYH_N = [0xfd, 0x26],    // ld h, n
    INC_IYL = [0xfd, 0x2c],     // inc l
    DEC_IYL = [0xfd, 0x2d],     // dec l
    LD_IYL_N = [0xfd, 0x2e],    // ld l, n

    LD_B_IYH = [0xfd, 0x44],    // ld b,h
    LD_B_IYL = [0xfd, 0x45],    // ld b,l

    LD_C_IYH = [0xfd, 0x4c],    // ld c,h
    LD_C_IYL = [0xfd, 0x4d],    // ld c,l

    LD_D_IYH = [0xfd, 0x54],    // ld d,h
    LD_D_IYL = [0xfd, 0x55],    // ld d,l

    LD_E_IYH = [0xfd, 0x5c],    // ld e,h
    LD_E_IYL = [0xfd, 0x5d],    // ld e,l

    LD_IYH_B = [0xfd, 0x60],    // ld h,b
    LD_IYH_C = [0xfd, 0x61],    // ld h,c
    LD_IYH_D = [0xfd, 0x62],    // ld h,d
    LD_IYH_E = [0xfd, 0x63],    // ld h,e
    LD_IYH_IYH = [0xfd, 0x64],  // ld h,h
    LD_IYH_IYL = [0xfd, 0x65],  // ld h,l
    LD_IYH_A = [0xfd, 0x67],    // ld h,a

    LD_IYL_B = [0xfd, 0x68],    // ld l,b
    LD_IYL_C = [0xfd, 0x69],    // ld l,c
    LD_IYL_D = [0xfd, 0x6a],    // ld l,d
    LD_IYL_E = [0xfd, 0x6b],    // ld l,e
    LD_IYL_IYH = [0xfd, 0x6c],  // ld l,h
    LD_IYL_IYL = [0xfd, 0x6d],  // ld l,l
    LD_IYL_A = [0xfd, 0x6f],    // ld l,a

    LD_A_IYH = [0xfd, 0x7c],    // ld a,h
    LD_A_IYL = [0xfd, 0x7d],    // ld a,l

    ADD_A_IYH = [0xfd, 0x84],   // add a,h
    ADD_A_IYL = [0xfd, 0x85],   // add a,l
    ADC_A_IYH = [0xfd, 0x8c],   // adc a,h
    ADC_A_IYL = [0xfd, 0x8d],   // adc a,l

    SUB_A_IYH = [0xfd, 0x94],   // sub a,h
    SUB_A_IYL = [0xfd, 0x95],   // sub a,l
    SBC_A_IYH = [0xfd, 0x9c],   // sbc a,h
    SBC_A_IYL = [0xfd, 0x9d],   // sbc a,l

    AND_A_IYH = [0xfd, 0xa4],   // and a,h
    AND_A_IYL = [0xfd, 0xa5],   // and a,l
    XOR_A_IYH = [0xfd, 0xac],   // xor a,h
    XOR_A_IYL = [0xfd, 0xad],   // xor a,l

    OR_A_IYH = [0xfd, 0xb4],    // or a,h
    OR_A_IYL = [0xfd, 0xb5],    // or a,l
    CP_A_IYH = [0xfd, 0xbc],    // cp a,h
    CP_A_IYL = [0xfd, 0xbd],    // cp a,l
}
void inc() {
    cpu.reset();

    state.IXH = 0x00;
    state.IXL = 0x00;
    state.IYH = 0x00;
    state.IYL = 0x00;
    test("
        inc ixh
        inc ixl
        inc iyh
        inc iyl
    ", INC_IXH ~ INC_IXL ~ INC_IYH ~ INC_IYL);

    assert(state.IXH == 0x01);
    assert(state.IXL == 0x01);
    assert(state.IX == 0x0101);
    assert(state.IYH == 0x01);
    assert(state.IYL == 0x01);
    assert(state.IY == 0x0101);
}
void dec() {
    cpu.reset();

    state.IXH = 0x00;
    state.IXL = 0x00;
    state.IYH = 0x00;
    state.IYL = 0x00;
    test("
        dec ixh
        dec ixl
        dec iyh
        dec iyl
    ", DEC_IXH ~ DEC_IXL ~ DEC_IYH ~ DEC_IYL);

    assert(state.IXH == 0xff);
    assert(state.IXL == 0xff);
    assert(state.IX == 0xffff);
    assert(state.IYH == 0xff);
    assert(state.IYL == 0xff);
    assert(state.IY == 0xffff);
}
void ld_n() {
    cpu.reset();

    test("
        ld ixh, $01
        ld ixl, $02
        ld iyh, $03
        ld iyl, $04
    ", LD_IXH_N ~ [0x01] ~
       LD_IXL_N ~ [0x02] ~
       LD_IYH_N ~ [0x03] ~
       LD_IYL_N ~ [0x04]);

    assert(state.IXH == 0x01);
    assert(state.IXL == 0x02);
    assert(state.IYH == 0x03);
    assert(state.IYL == 0x04);
}
void ld() {
    cpu.reset();

    state.IXH = 0x01;
    test("
        ld a, ixh
        ld b, ixh
        ld c, ixh
        ld d, ixh
        ld e, ixh
        ld ixh, ixh
        ld ixl, ixh
    ", LD_A_IXH ~ LD_B_IXH ~ LD_C_IXH ~ LD_D_IXH ~ LD_E_IXH ~ LD_IXH_IXH ~ LD_IXL_IXH);

    assert(state.A == 0x01);
    assert(state.B == 0x01);
    assert(state.C == 0x01);
    assert(state.D == 0x01);
    assert(state.E == 0x01);
    assert(state.IXH == 0x01);
    assert(state.IXL == 0x01);

    state.IYH = 0x02;
    test("
        ld a, iyh
        ld b, iyh
        ld c, iyh
        ld d, iyh
        ld e, iyh
        ld iyh, iyh
        ld iyl, iyh
    ", LD_A_IYH ~ LD_B_IYH ~ LD_C_IYH ~ LD_D_IYH ~ LD_E_IYH ~ LD_IYH_IYH ~ LD_IYL_IYH);

    assert(state.A == 0x02);
    assert(state.B == 0x02);
    assert(state.C == 0x02);
    assert(state.D == 0x02);
    assert(state.E == 0x02);
    assert(state.IYH == 0x02);
    assert(state.IYL == 0x02);

    state.IXL = 0x03;
    test("
        ld a, ixl
        ld b, ixl
        ld c, ixl
        ld d, ixl
        ld e, ixl
        ld ixh, ixl
        ld ixl, ixl
    ", LD_A_IXL ~ LD_B_IXL ~ LD_C_IXL ~ LD_D_IXL ~ LD_E_IXL ~ LD_IXH_IXL ~ LD_IXL_IXL);

    assert(state.A == 0x03);
    assert(state.B == 0x03);
    assert(state.C == 0x03);
    assert(state.D == 0x03);
    assert(state.E == 0x03);
    assert(state.IXH == 0x03);
    assert(state.IXL == 0x03);

    state.IYL = 0x04;
    test("
        ld a, iyl
        ld b, iyl
        ld c, iyl
        ld d, iyl
        ld e, iyl
        ld iyh, iyl
        ld iyl, iyl
    ", LD_A_IYL ~ LD_B_IYL ~ LD_C_IYL ~ LD_D_IYL ~ LD_E_IYL ~ LD_IYH_IYL ~ LD_IYL_IYL);

    assert(state.A == 0x04);
    assert(state.B == 0x04);
    assert(state.C == 0x04);
    assert(state.D == 0x04);
    assert(state.E == 0x04);
    assert(state.IYH == 0x04);
    assert(state.IYL == 0x04);


    state.A = 0x01; test("\tld ixh, a", LD_IXH_A); assert(state.IXH == 0x01);
    state.B = 0x02; test("\tld ixh, b", LD_IXH_B); assert(state.IXH == 0x02);
    state.C = 0x03; test("\tld ixh, c", LD_IXH_C); assert(state.IXH == 0x03);
    state.D = 0x04; test("\tld ixh, d", LD_IXH_D); assert(state.IXH == 0x04);
    state.E = 0x05; test("\tld ixh, e", LD_IXH_E); assert(state.IXH == 0x05);
    state.IXH = 0x06; test("\tld ixh, ixh", LD_IXH_IXH); assert(state.IXH == 0x06);
    state.IXL = 0x07; test("\tld ixh, ixl", LD_IXH_IXL); assert(state.IXH == 0x07);

    state.A = 0x01; test("\tld iyh, a", LD_IYH_A); assert(state.IYH == 0x01);
    state.B = 0x02; test("\tld iyh, b", LD_IYH_B); assert(state.IYH == 0x02);
    state.C = 0x03; test("\tld iyh, c", LD_IYH_C); assert(state.IYH == 0x03);
    state.D = 0x04; test("\tld iyh, d", LD_IYH_D); assert(state.IYH == 0x04);
    state.E = 0x05; test("\tld iyh, e", LD_IYH_E); assert(state.IYH == 0x05);
    state.IYH = 0x06; test("\tld iyh, iyh", LD_IYH_IYH); assert(state.IYH == 0x06);
    state.IYL = 0x07; test("\tld iyh, iyl", LD_IYH_IYL); assert(state.IYH == 0x07);


    state.A = 0x01; test("\tld ixl, a", LD_IXL_A); assert(state.IXL == 0x01);
    state.B = 0x02; test("\tld ixl, b", LD_IXL_B); assert(state.IXL == 0x02);
    state.C = 0x03; test("\tld ixl, c", LD_IXL_C); assert(state.IXL == 0x03);
    state.D = 0x04; test("\tld ixl, d", LD_IXL_D); assert(state.IXL == 0x04);
    state.E = 0x05; test("\tld ixl, e", LD_IXL_E); assert(state.IXL == 0x05);
    state.IXH = 0x06; test("\tld ixl, ixh", LD_IXL_IXH); assert(state.IXL == 0x06);
    state.IXL = 0x07; test("\tld ixl, ixl", LD_IXL_IXL); assert(state.IXL == 0x07);

    state.A = 0x01; test("\tld iyl, a", LD_IYL_A); assert(state.IYL == 0x01);
    state.B = 0x02; test("\tld iyl, b", LD_IYL_B); assert(state.IYL == 0x02);
    state.C = 0x03; test("\tld iyl, c", LD_IYL_C); assert(state.IYL == 0x03);
    state.D = 0x04; test("\tld iyl, d", LD_IYL_D); assert(state.IYL == 0x04);
    state.E = 0x05; test("\tld iyl, e", LD_IYL_E); assert(state.IYL == 0x05);
    state.IYH = 0x06; test("\tld iyl, iyh", LD_IYL_IYH); assert(state.IYL == 0x06);
    state.IYL = 0x07; test("\tld iyl, iyl", LD_IYL_IYL); assert(state.IYL == 0x07);
}
void add() {
    cpu.reset();

    state.IXH = 0x01;
    state.IXL = 0x02;
    state.IYH = 0x03;
    state.IYL = 0x04;

    state.A = 0x10; test("\tadd a, ixh", ADD_A_IXH); assert(state.A == 0x11);
    state.A = 0x10; test("\tadd a, ixl", ADD_A_IXL); assert(state.A == 0x12);
    state.A = 0x10; test("\tadd a, iyh", ADD_A_IYH); assert(state.A == 0x13);
    state.A = 0x10; test("\tadd a, iyl", ADD_A_IYL); assert(state.A == 0x14);
}
void adc() {
    cpu.reset();

    state.IXH = 0x01;
    state.IXL = 0x02;
    state.IYH = 0x03;
    state.IYL = 0x04;

    state.flagC(true); state.A = 0x10; test("\tadc a, ixh", ADC_A_IXH); assert(state.A == 0x12);
    state.flagC(true); state.A = 0x10; test("\tadc a, ixl", ADC_A_IXL); assert(state.A == 0x13);
    state.flagC(true); state.A = 0x10; test("\tadc a, iyh", ADC_A_IYH); assert(state.A == 0x14);
    state.flagC(true); state.A = 0x10; test("\tadc a, iyl", ADC_A_IYL); assert(state.A == 0x15);
}
void sub() {
    cpu.reset();

    state.IXH = 0x01;
    state.IXL = 0x02;
    state.IYH = 0x03;
    state.IYL = 0x04;

    state.A = 0x10; test("\tsub a, ixh", SUB_A_IXH); assert(state.A == 0x0f);
    state.A = 0x10; test("\tsub a, ixl", SUB_A_IXL); assert(state.A == 0x0e);
    state.A = 0x10; test("\tsub a, iyh", SUB_A_IYH); assert(state.A == 0x0d);
    state.A = 0x10; test("\tsub a, iyl", SUB_A_IYL); assert(state.A == 0x0c);
}
void sbc() {
    cpu.reset();

    state.IXH = 0x01;
    state.IXL = 0x02;
    state.IYH = 0x03;
    state.IYL = 0x04;

    state.flagC(true); state.A = 0x10; test("\tsbc a, ixh", SBC_A_IXH); assert(state.A == 0x0e);
    state.flagC(true); state.A = 0x10; test("\tsbc a, ixl", SBC_A_IXL); assert(state.A == 0x0d);
    state.flagC(true); state.A = 0x10; test("\tsbc a, iyh", SBC_A_IYH); assert(state.A == 0x0c);
    state.flagC(true); state.A = 0x10; test("\tsbc a, iyl", SBC_A_IYL); assert(state.A == 0x0b);
}
void and() {
    cpu.reset();

    state.IXH = 0x11;
    state.IXL = 0x12;
    state.IYH = 0x13;
    state.IYL = 0x14;

    state.A = 0x10; test("\tand a, ixh", AND_A_IXH); assert(state.A == 0x10);
    state.A = 0x10; test("\tand a, ixl", AND_A_IXL); assert(state.A == 0x10);
    state.A = 0x10; test("\tand a, iyh", AND_A_IYH); assert(state.A == 0x10);
    state.A = 0x10; test("\tand a, iyl", AND_A_IYL); assert(state.A == 0x10);

}
void xor() {
    cpu.reset();

    state.IXH = 0x11;
    state.IXL = 0x12;
    state.IYH = 0x13;
    state.IYL = 0x14;

    state.A = 0x10; test("\txor a, ixh", XOR_A_IXH); assert(state.A == 0x01);
    state.A = 0x10; test("\txor a, ixl", XOR_A_IXL); assert(state.A == 0x02);
    state.A = 0x10; test("\txor a, iyh", XOR_A_IYH); assert(state.A == 0x03);
    state.A = 0x10; test("\txor a, iyl", XOR_A_IYL); assert(state.A == 0x04);
}
void or() {
    cpu.reset();

    state.IXH = 0x11;
    state.IXL = 0x12;
    state.IYH = 0x13;
    state.IYL = 0x14;

    state.A = 0x10; test("\tor a, ixh", OR_A_IXH); assert(state.A == 0x11);
    state.A = 0x10; test("\tor a, ixl", OR_A_IXL); assert(state.A == 0x12);
    state.A = 0x10; test("\tor a, iyh", OR_A_IYH); assert(state.A == 0x13);
    state.A = 0x10; test("\tor a, iyl", OR_A_IYL); assert(state.A == 0x14);
}
void cp() {
    cpu.reset();

    state.IXH = 0x11;
    state.IXL = 0x12;
    state.IYH = 0x13;
    state.IYL = 0x14;

    state.A = 0x10; test("\tcp a, ixh", CP_A_IXH); assert(state.A == 0x10);
    state.A = 0x10; test("\tcp a, ixl", CP_A_IXL); assert(state.A == 0x10);
    state.A = 0x10; test("\tcp a, iyh", CP_A_IYH); assert(state.A == 0x10);
    state.A = 0x10; test("\tcp a, iyl", CP_A_IYL); assert(state.A == 0x10);
}

setup();

inc();
dec();
ld_n();
ld();
add();
adc();
sub();
sbc();
and();
xor();
or();
cp();

} //unit test