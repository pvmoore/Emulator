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
}
void inc() {
    cpu.reset();

}
void dec() {
    cpu.reset();

}
void ld() {
    cpu.reset();

}
void add() {
    cpu.reset();

}
void adc() {
    cpu.reset();

}
void sub() {
    cpu.reset();

}
void sbc() {
    cpu.reset();

}
void and() {
    cpu.reset();

}
void xor() {
    cpu.reset();

}
void or() {
    cpu.reset();

}
void cp() {
    cpu.reset();

}

setup();

inc();
dec();
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