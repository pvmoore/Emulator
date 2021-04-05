module emulator.chips._6502.tests;

import std.stdio;
import emulator.chips._6502.all;
import emulator.component.Memory;

unittest {

__gshared CPU6502 cpu;
__gshared Memory mem;
__gshared Bus bus;

void writeBytes(uint addr, ubyte[] bytes) {
    foreach(i; 0..cast(uint)bytes.length) {
        bus.write(addr + i, bytes[i]);
    }
}
void setup() {
    mem = new Memory(65536);
    bus = new Bus().add(mem);
    cpu = new CPU6502();
    assert(cpu);
    assert(mem);
    assert(bus);
    cpu.addBus(bus);

    //                  0000  0001  0002  0003  0004  0005  0006  0007
    writeBytes(0x0000, [0x01, 0x02, 0x03, 0x04, 0x00, 0x03, 0x00, 0x04]); // ZP reads

    writeBytes(0x0080, [0x00, 0x00, 0x00, 0x00, 0x00, 0x00]); // ZP writes
    writeBytes(0x0300, [0x05, 0x06, 0x07, 0x08]);
    writeBytes(0x0400, [0x00, 0x00, 0x00, 0x00]); // non ZP writes
}
void test(ubyte[] p, int count, bool function(CPU6502.State state) checker, bool dumpState = false) {
    cpu.reset();
    cpu.load(0x0200, p);
    cpu.setPC(0x0200);

    foreach(i; 0..count) {
        cpu.execute(dumpState);
    }
    assert(checker(cpu.getState()));
}

void adc() {
    test([LDA_IMM, 0x10, ADC_IMM, 0x10], 2, s=>s.A==0x20); // imm
    test([LDA_IMM, 0x10, ADC_ZP, 0x07], 2, s=>s.A==0x14); // zp
    test([LDA_IMM, 0x10, LDX_IMM, 0x01, ADC_ZP_X, 0x06], 3, s=>s.A==0x14); // zp x
    test([LDA_IMM, 0x10, ADC_ABS, 0x00, 0x03], 2, s=>s.A==0x15); // abs
    test([LDX_IMM, 0x01, LDA_IMM, 0x10, ADC_ABS_X, 0x00, 0x03], 3, s=>s.A==0x16); // abs x
    test([LDY_IMM, 0x01, LDA_IMM, 0x10, ADC_ABS_Y, 0x00, 0x03], 3, s=>s.A==0x16); // abs y
    test([LDX_IMM, 0x01, LDA_IMM, 0x10, ADC_IND_X, 0x03], 3, s=>s.A==0x15); // ind x
    test([LDY_IMM, 0x01, LDA_IMM, 0x10, ADC_IND_Y, 0x04], 3, s=>s.A==0x16); // ind y
}
void and() {
    // 0x04 == 0b0000_0100
    // 0x05 == 0b0000_0101
    test([LDA_IMM, 0b1010_1010, AND_IMM, 0b0101_1111], 2, s=>s.A==0b00001010); // imm
    test([LDA_IMM, 0b1111_1100, AND_ZP, 0x07], 2, s=>s.A==0b0000_0100); // zp
    test([LDA_IMM, 0b1111_1100, LDX_IMM, 0x01, AND_ZP_X, 0x06], 3, s=>s.A==0b0000_0100); // zp x
    test([LDA_IMM, 0b1111_1111, AND_ABS, 0x00, 0x03], 2, s=>s.A==0b0000_0101); // abs
    test([LDX_IMM, 0x01, LDA_IMM, 0b1111_1111, AND_ABS_X, 0x00, 0x03], 3, s=>s.A==0b0000_0110); // abs x
    test([LDY_IMM, 0x01, LDA_IMM, 0b1111_1111, AND_ABS_Y, 0x00, 0x03], 3, s=>s.A==0b0000_0110); // abs y
    test([LDX_IMM, 0x01, LDA_IMM, 0b1111_1111, AND_IND_X, 0x03], 3, s=>s.A==0b0000_0101); // ind x
    test([LDY_IMM, 0x01, LDA_IMM, 0b1111_1111, AND_IND_Y, 0x04], 3, s=>s.A==0b0000_0110); // ind y
}
void asl() {
    test([LDA_IMM, 0b0000_0001, ASL_ACC], 2, s=>s.A==0b0000_0010 && s.flags.C==false); // accumulator
    test([LDA_IMM, 0b1000_0001, ASL_ACC], 2, s=>s.A==0b0000_0010 && s.flags.C==true); // accumulator
    test([LDA_IMM, 0b0100_0000, STA_ZP, 0x80, ASL_ZP, 0x80], 3,
        s=>bus.read(0x80) == 0b1000_0000 && s.flags.C==false); // zp
    test([LDA_IMM, 0b1100_0000, STA_ZP, 0x80, ASL_ZP, 0x80], 3,
        s=>bus.read(0x80) == 0b1000_0000 && s.flags.C==true); // zp
    test([LDA_IMM, 0b0100_0000, STA_ZP, 0x81, LDX_IMM, 0x01, ASL_ZP_X, 0x80], 4,
        s=>bus.read(0x81)==0b1000_0000 && s.flags.C==false); // zp x
    test([LDA_IMM, 0b1100_0000, STA_ZP, 0x81, LDX_IMM, 0x01, ASL_ZP_X, 0x80], 4,
        s=>bus.read(0x81)==0b1000_0000 && s.flags.C==true); // zp x
    test([LDA_IMM, 0b0111_0001, STA_ABS, 0x00, 0x04, ASL_ABS, 0x00, 0x04], 3,
        s=>bus.read(0x0400)==0b1110_0010 && s.flags.C==false); // abs
    test([LDA_IMM, 0b1111_0001, STA_ABS, 0x00, 0x04, ASL_ABS, 0x00, 0x04], 3,
        s=>bus.read(0x0400)==0b1110_0010 && s.flags.C==true); // abs
    test([LDA_IMM, 0b1111_0001, STA_ABS, 0x01, 0x04, LDX_IMM, 0x01, ASL_ABS_X, 0x00, 0x04], 4,
        s=>bus.read(0x0401)==0b1110_0010); // abs x
}
void bcc() {
    test([LDA_IMM, 0x01, CLC, BCC, 0x02, LDA_IMM, 0x02, NOP, NOP], 5, s=>s.A==0x01);
    //                         ⮩------------------------⮭
    test([LDA_IMM, 0x01, SEC, BCC, 0x02, LDA_IMM, 0x02, NOP], 5, s=>s.A==0x02);
    //                         ⮩------------⮭
}
void bcs() {
    test([LDA_IMM, 0x01, SEC, BCS, 0x02, LDA_IMM, 0x02, NOP, NOP], 5, s=>s.A==0x01);
    //                         ⮩------------------------⮭
    test([LDA_IMM, 0x01, CLC, BCS, 0x02, LDA_IMM, 0x02, NOP], 5, s=>s.A==0x02);
    //                         ⮩------------⮭
}
void beq() {
    test([AND_IMM, 0x00, BEQ, 0x02, LDA_IMM, 0x02, NOP, NOP], 4, s=>s.A==0x00);
    //                     ⮩-----------------------⮭
    test([LDA_IMM, 0x01, AND_IMM, 0xff, BEQ, 0x02, LDA_IMM, 0x02, NOP, NOP], 5, s=>s.A==0x02);
    //                                    ⮩----------⮭
}
void bit() {
    bus.write(0x0080, 0xff);
    test([LDA_IMM, 0xff, BIT_ZP, 0x80], 2,
        s=>s.flags.Z==false && s.flags.V==true && s.flags.N==true);

    bus.write(0x0080, 0b0000_1111);
    test([LDA_IMM, 0xff, BIT_ZP, 0x80], 2,
        s=>s.flags.Z==false && s.flags.V==false && s.flags.N==false);

    bus.write(0x0080, 0b0000_0000);
    test([LDA_IMM, 0xff, BIT_ZP, 0x80], 2,
        s=>s.flags.Z==true && s.flags.V==false && s.flags.N==false);
}
void bmi() {
    test([LDA_IMM, 0x00, LDX_IMM, 0xff, BMI, 0x02, LDA_IMM, 0x02, NOP, NOP], 5, s=>s.A==0x00);
    //                                   ⮩-----------------------⮭
    test([LDA_IMM, 0x00, LDX_IMM, 0x1f, BMI, 0x02, LDA_IMM, 0x02, NOP, NOP], 5, s=>s.A==0x02);
    //                                   ⮩-----------⮭
}
void bne() {
    test([LDA_IMM, 0x00, LDX_IMM, 0x1f, BNE, 0x02, LDA_IMM, 0x02, NOP, NOP], 5, s=>s.A==0x00);
    //                                   ⮩-----------------------⮭
    test([LDA_IMM, 0x00, LDX_IMM, 0x00, BNE, 0x02, LDA_IMM, 0x02, NOP, NOP], 5, s=>s.A==0x02);
    //                                   ⮩-----------⮭
}
void bpl() {
    test([LDA_IMM, 0x00, LDX_IMM, 0x1f, BPL, 0x02, LDA_IMM, 0x02, NOP, NOP], 5, s=>s.A==0x00);
    //                                   ⮩-----------------------⮭
    test([LDA_IMM, 0x00, LDX_IMM, 0xff, BPL, 0x02, LDA_IMM, 0x02, NOP, NOP], 5, s=>s.A==0x02);
    //                                   ⮩-----------⮭
}
void brk() {
    // push PC+1, flags
    // set I

    // PC = 0x0200
    // SP = 0xfd
    test([BRK], 1, s=>s.flags.I==true &&
        bus.read(0x01fd) == 0x02 &&     // hi
        bus.read(0x01fc) == 0x02 &&     // lo
        bus.read(0x01fb) == 0x30);      // flags (--UB----)
}
void bvc() {
    test([LDY_IMM, 0x00, LDA_IMM, 0x80, ADC_IMM, 0x7f, BVC, 0x02, LDY_IMM, 0x02, NOP, NOP], 6, s=>s.Y==0x00);
    //                                  ⮩---------------------------------------⮭
    test([LDY_IMM, 0x00, LDA_IMM, 0x80, ADC_IMM, 0x80, BVC, 0x02, LDY_IMM, 0x02, NOP, NOP], 6, s=>s.Y==0x02);
    //                                  ⮩--------------------------⮭
}
void bvs() {
    test([LDY_IMM, 0x00, LDA_IMM, 0x80, ADC_IMM, 0x80, BVS, 0x02, LDY_IMM, 0x02, NOP, NOP], 6, s=>s.Y==0x00);
    //                                   ⮩---------------------------------------⮭
    test([LDY_IMM, 0x00, LDA_IMM, 0x80, ADC_IMM, 0x10, BVS, 0x02, LDY_IMM, 0x02, NOP, NOP], 6, s=>s.Y==0x02);
    //                                   ⮩--------------------------⮭
}
void clc() {
    test([CLC], 1, s=>s.flags.C==false);
    test([SEC, CLC], 2, s=>s.flags.C==false);
}
void cld() {
    test([CLD], 1, s=>s.flags.D==false);
    test([CLD, SEC, CLD], 3, s=>s.flags.D==false);
}
void cli() {
    test([CLI], 1, s=>s.flags.I==false);
    test([CLI, SEI, CLI], 3, s=>s.flags.I==false);
}
void clv() {
    test([CLV], 1, s=>s.flags.V==false);
    test([LDA_IMM, 0x80, ADC_IMM, 0x80], 2, s=>s.flags.V==true);
    test([LDA_IMM, 0x80, ADC_IMM, 0x10, CLV], 3, s=>s.flags.V==false);
}
void cmp() {
    // imm
    test([LDA_IMM, 0x80, CMP_IMM, 0x80], 2, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    test([LDA_IMM, 0x80, CMP_IMM, 0x7f], 2, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    test([LDA_IMM, 0x80, CMP_IMM, 0x81], 2, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    // zp
    bus.write(0x0080, 0x80);
    test([LDA_IMM, 0x80, CMP_ZP, 0x80], 2, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0080, 0x7f);
    test([LDA_IMM, 0x80, CMP_ZP, 0x80], 2, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0080, 0x81);
    test([LDA_IMM, 0x80, CMP_ZP, 0x80], 2, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    // zp x
    bus.write(0x0081, 0x80);
    test([LDX_IMM, 0x01, LDA_IMM, 0x80, CMP_ZP_X, 0x80], 3, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0081, 0x7f);
    test([LDX_IMM, 0x01, LDA_IMM, 0x80, CMP_ZP_X, 0x80], 3, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0081, 0x81);
    test([LDX_IMM, 0x01, LDA_IMM, 0x80, CMP_ZP_X, 0x80], 3, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    // abs
    bus.write(0x0400, 0x80);
    test([LDA_IMM, 0x80, CMP_ABS, 0x00, 0x04], 2, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0400, 0x7f);
    test([LDA_IMM, 0x80, CMP_ABS, 0x00, 0x04], 2, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0400, 0x81);
    test([LDA_IMM, 0x80, CMP_ABS, 0x00, 0x04], 2, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    // abs x
    bus.write(0x0401, 0x80);
    test([LDX_IMM, 0x01, LDA_IMM, 0x80, CMP_ABS_X, 0x00, 0x04], 3, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0401, 0x7f);
    test([LDX_IMM, 0x01, LDA_IMM, 0x80, CMP_ABS_X, 0x00, 0x04], 3, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0401, 0x81);
    test([LDX_IMM, 0x01, LDA_IMM, 0x80, CMP_ABS_X, 0x00, 0x04], 3, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    // abs y
    bus.write(0x0401, 0x80);
    test([LDY_IMM, 0x01, LDA_IMM, 0x80, CMP_ABS_Y, 0x00, 0x04], 3, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0401, 0x7f);
    test([LDY_IMM, 0x01, LDA_IMM, 0x80, CMP_ABS_Y, 0x00, 0x04], 3, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0401, 0x81);
    test([LDY_IMM, 0x01, LDA_IMM, 0x80, CMP_ABS_Y, 0x00, 0x04], 3, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    // ind x
    bus.write(0x0081, 0x00);
    bus.write(0x0082, 0x04);
    bus.write(0x0400, 0x80);
    test([LDX_IMM, 0x01, LDA_IMM, 0x80, CMP_IND_X, 0x80], 3, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0081, 0x00);
    bus.write(0x0082, 0x04);
    bus.write(0x0400, 0x7f);
    test([LDX_IMM, 0x01, LDA_IMM, 0x80, CMP_IND_X, 0x80], 3, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0081, 0x00);
    bus.write(0x0082, 0x04);
    bus.write(0x0400, 0x81);
    test([LDX_IMM, 0x01, LDA_IMM, 0x80, CMP_IND_X, 0x80], 3, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    // ind y
    bus.write(0x0080, 0x00);
    bus.write(0x0081, 0x04);
    bus.write(0x0401, 0x80);
    test([LDY_IMM, 0x01, LDA_IMM, 0x80, CMP_IND_Y, 0x80], 3, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0080, 0x00);
    bus.write(0x0081, 0x04);
    bus.write(0x0401, 0x7f);
    test([LDY_IMM, 0x01, LDA_IMM, 0x80, CMP_IND_Y, 0x80], 3, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0080, 0x00);
    bus.write(0x0081, 0x04);
    bus.write(0x0401, 0x81);
    test([LDY_IMM, 0x01, LDA_IMM, 0x80, CMP_IND_Y, 0x80], 3, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
}
void cpx() {
    // imm
    test([LDX_IMM, 0x80, CPX_IMM, 0x80], 2, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    test([LDX_IMM, 0x80, CPX_IMM, 0x7f], 2, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    test([LDX_IMM, 0x80, CPX_IMM, 0x81], 2, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    // zp
    bus.write(0x0080, 0x80);
    test([LDX_IMM, 0x80, CPX_ZP, 0x80], 2, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0080, 0x7f);
    test([LDX_IMM, 0x80, CPX_ZP, 0x80], 2, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0080, 0x81);
    test([LDX_IMM, 0x80, CPX_ZP, 0x80], 2, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    // abs
    bus.write(0x0400, 0x80);
    test([LDX_IMM, 0x80, CPX_ABS, 0x00, 0x04], 2, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0400, 0x7f);
    test([LDX_IMM, 0x80, CPX_ABS, 0x00, 0x04], 2, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0400, 0x81);
    test([LDX_IMM, 0x80, CPX_ABS, 0x00, 0x04], 2, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
}
void cpy() {
    // imm
    test([LDY_IMM, 0x80, CPY_IMM, 0x80], 2, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    test([LDY_IMM, 0x80, CPY_IMM, 0x7f], 2, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    test([LDY_IMM, 0x80, CPY_IMM, 0x81], 2, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    // zp
    bus.write(0x0080, 0x80);
    test([LDY_IMM, 0x80, CPY_ZP, 0x80], 2, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0080, 0x7f);
    test([LDY_IMM, 0x80, CPY_ZP, 0x80], 2, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0080, 0x81);
    test([LDY_IMM, 0x80, CPY_ZP, 0x80], 2, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    // abs
    bus.write(0x0400, 0x80);
    test([LDY_IMM, 0x80, CPY_ABS, 0x00, 0x04], 2, s=>s.flags.C==true && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0400, 0x7f);
    test([LDY_IMM, 0x80, CPY_ABS, 0x00, 0x04], 2, s=>s.flags.C==true && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0400, 0x81);
    test([LDY_IMM, 0x80, CPY_ABS, 0x00, 0x04], 2, s=>s.flags.C==false && s.flags.Z==false && s.flags.N==true);
}
void dec() {
    // zp
    bus.write(0x0080, 0x2);
    test([DEC_ZP, 0x80], 1, s=>bus.read(0x0080) == 0x01 && s.flags.Z==false && s.flags.N==false);
    test([DEC_ZP, 0x80], 1, s=>bus.read(0x0080) == 0x00 && s.flags.Z==true && s.flags.N==false);
    test([DEC_ZP, 0x80], 1, s=>bus.read(0x0080) == 0xff && s.flags.Z==false && s.flags.N==true);
    // zp x
    bus.write(0x0081, 0x2);
    test([LDX_IMM, 0x01, DEC_ZP_X, 0x80], 2, s=>bus.read(0x0081) == 0x01 && s.flags.Z==false && s.flags.N==false);
    test([LDX_IMM, 0x01, DEC_ZP_X, 0x80], 2, s=>bus.read(0x0081) == 0x00 && s.flags.Z==true && s.flags.N==false);
    test([LDX_IMM, 0x01, DEC_ZP_X, 0x80], 2, s=>bus.read(0x0081) == 0xff && s.flags.Z==false && s.flags.N==true);
    // abs
    bus.write(0x0400, 0x2);
    test([DEC_ABS, 0x00, 0x04], 1, s=>bus.read(0x0400) == 0x01 && s.flags.Z==false && s.flags.N==false);
    test([DEC_ABS, 0x00, 0x04], 1, s=>bus.read(0x0400) == 0x00 && s.flags.Z==true && s.flags.N==false);
    test([DEC_ABS, 0x00, 0x04], 1, s=>bus.read(0x0400) == 0xff && s.flags.Z==false && s.flags.N==true);
    // abs x
    bus.write(0x0401, 0x2);
    test([LDX_IMM, 0x01, DEC_ABS_X, 0x00, 0x04], 2, s=>bus.read(0x0401) == 0x01 && s.flags.Z==false && s.flags.N==false);
    test([LDX_IMM, 0x01, DEC_ABS_X, 0x00, 0x04], 2, s=>bus.read(0x0401) == 0x00 && s.flags.Z==true && s.flags.N==false);
    test([LDX_IMM, 0x01, DEC_ABS_X, 0x00, 0x04], 2, s=>bus.read(0x0401) == 0xff && s.flags.Z==false && s.flags.N==true);
}
void dex() {
    test([LDX_IMM, 0x02, DEX], 2, s=>s.X==0x01 && s.flags.Z==false && s.flags.N==false);
    test([LDX_IMM, 0x01, DEX], 2, s=>s.X==0x00 && s.flags.Z==true && s.flags.N==false);
    test([LDX_IMM, 0x00, DEX], 2, s=>s.X==0xff && s.flags.Z==false && s.flags.N==true);
}
void dey() {
    test([LDY_IMM, 0x02, DEY], 2, s=>s.Y==0x01 && s.flags.Z==false && s.flags.N==false);
    test([LDY_IMM, 0x01, DEY], 2, s=>s.Y==0x00 && s.flags.Z==true && s.flags.N==false);
    test([LDY_IMM, 0x00, DEY], 2, s=>s.Y==0xff && s.flags.Z==false && s.flags.N==true);
}
void eor() {
    // imm
    test([LDA_IMM, 0b1111_0000, EOR_IMM, 0b1010_1010], 2, s=>s.A==0b0101_1010 && s.flags.Z==false && s.flags.N==false);
    test([LDA_IMM, 0b1111_0000, EOR_IMM, 0b1111_0000], 2, s=>s.A==0b0000_0000 && s.flags.Z==true && s.flags.N==false);
    test([LDA_IMM, 0b0111_0000, EOR_IMM, 0b1111_0000], 2, s=>s.A==0b1000_0000 && s.flags.Z==false && s.flags.N==true);
    // zp
    bus.write(0x0080, 0b1010_1010);
    test([LDA_IMM, 0b1111_0000, EOR_ZP, 0x80], 2, s=>s.A==0b0101_1010 && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0080, 0b1111_0000);
    test([LDA_IMM, 0b1111_0000, EOR_ZP, 0x80], 2, s=>s.A==0b0000_0000 && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0080, 0b1111_0000);
    test([LDA_IMM, 0b0111_0000, EOR_ZP, 0x80], 2, s=>s.A==0b1000_0000 && s.flags.Z==false && s.flags.N==true);
    // zp x
    bus.write(0x0081, 0b1010_1010);
    test([LDX_IMM, 0x01, LDA_IMM, 0b1111_0000, EOR_ZP_X, 0x80], 3, s=>s.A==0b0101_1010 && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0081, 0b1111_0000);
    test([LDX_IMM, 0x01, LDA_IMM, 0b1111_0000, EOR_ZP_X, 0x80], 3, s=>s.A==0b0000_0000 && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0081, 0b1111_0000);
    test([LDX_IMM, 0x01, LDA_IMM, 0b0111_0000, EOR_ZP_X, 0x80], 3, s=>s.A==0b1000_0000 && s.flags.Z==false && s.flags.N==true);
    // abs
    bus.write(0x0400, 0b1010_1010);
    test([LDA_IMM, 0b1111_0000, EOR_ABS, 0x00, 0x04], 2, s=>s.A==0b0101_1010 && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0400, 0b1111_0000);
    test([LDA_IMM, 0b1111_0000, EOR_ABS, 0x00, 0x04], 2, s=>s.A==0b0000_0000 && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0400, 0b1111_0000);
    test([LDA_IMM, 0b0111_0000, EOR_ABS, 0x00, 0x04], 2, s=>s.A==0b1000_0000 && s.flags.Z==false && s.flags.N==true);
    // abs x
    bus.write(0x0401, 0b1010_1010);
    test([LDX_IMM, 0x01, LDA_IMM, 0b1111_0000, EOR_ABS_X, 0x00, 0x04], 3, s=>s.A==0b0101_1010 && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0401, 0b1111_0000);
    test([LDX_IMM, 0x01, LDA_IMM, 0b1111_0000, EOR_ABS_X, 0x00, 0x04], 3, s=>s.A==0b0000_0000 && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0401, 0b1111_0000);
    test([LDX_IMM, 0x01, LDA_IMM, 0b0111_0000, EOR_ABS_X, 0x00, 0x04], 3, s=>s.A==0b1000_0000 && s.flags.Z==false && s.flags.N==true);
    // abs y
    bus.write(0x0401, 0b1010_1010);
    test([LDY_IMM, 0x01, LDA_IMM, 0b1111_0000, EOR_ABS_Y, 0x00, 0x04], 3, s=>s.A==0b0101_1010 && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0401, 0b1111_0000);
    test([LDY_IMM, 0x01, LDA_IMM, 0b1111_0000, EOR_ABS_Y, 0x00, 0x04], 3, s=>s.A==0b0000_0000 && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0401, 0b1111_0000);
    test([LDY_IMM, 0x01, LDA_IMM, 0b0111_0000, EOR_ABS_Y, 0x00, 0x04], 3, s=>s.A==0b1000_0000 && s.flags.Z==false && s.flags.N==true);
    // ind x
    bus.write(0x0081, 0x00);
    bus.write(0x0082, 0x04);
    bus.write(0x0400, 0b1010_1010);
    test([LDX_IMM, 0x01, LDA_IMM, 0b1111_0000, EOR_IND_X, 0x80], 3, s=>s.A==0b0101_1010 && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0081, 0x00);
    bus.write(0x0082, 0x04);
    bus.write(0x0400, 0b1111_0000);
    test([LDX_IMM, 0x01, LDA_IMM, 0b1111_0000, EOR_IND_X, 0x80], 3, s=>s.A==0b0000_0000 && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0081, 0x00);
    bus.write(0x0082, 0x04);
    bus.write(0x0400, 0b1111_0000);
    test([LDX_IMM, 0x01, LDA_IMM, 0b0111_0000, EOR_IND_X, 0x80], 3, s=>s.A==0b1000_0000 && s.flags.Z==false && s.flags.N==true);
    // ind y
    bus.write(0x0080, 0x00);
    bus.write(0x0081, 0x04);
    bus.write(0x0401, 0b1010_1010);
    test([LDY_IMM, 0x01, LDA_IMM, 0b1111_0000, EOR_IND_Y, 0x80], 3, s=>s.A==0b0101_1010 && s.flags.Z==false && s.flags.N==false);
    bus.write(0x0080, 0x00);
    bus.write(0x0081, 0x04);
    bus.write(0x0401, 0b1111_0000);
    test([LDY_IMM, 0x01, LDA_IMM, 0b1111_0000, EOR_IND_Y, 0x80], 3, s=>s.A==0b0000_0000 && s.flags.Z==true && s.flags.N==false);
    bus.write(0x0080, 0x00);
    bus.write(0x0081, 0x04);
    bus.write(0x0401, 0b1111_0000);
    test([LDY_IMM, 0x01, LDA_IMM, 0b0111_0000, EOR_IND_Y, 0x80], 3, s=>s.A==0b1000_0000 && s.flags.Z==false && s.flags.N==true);
}
void inc() {
    // zp
    bus.write(0x0080, 0xfe);
    test([INC_ZP, 0x80], 1, s=>bus.read(0x0080) == 0xff && s.flags.Z==false && s.flags.N==true);
    test([INC_ZP, 0x80], 1, s=>bus.read(0x0080) == 0x00 && s.flags.Z==true && s.flags.N==false);
    test([INC_ZP, 0x80], 1, s=>bus.read(0x0080) == 0x01 && s.flags.Z==false && s.flags.N==false);
    // zp x
    bus.write(0x0081, 0xfe);
    test([LDX_IMM, 0x01, INC_ZP_X, 0x80], 2, s=>bus.read(0x0081) == 0xff && s.flags.Z==false && s.flags.N==true);
    test([LDX_IMM, 0x01, INC_ZP_X, 0x80], 2, s=>bus.read(0x0081) == 0x00 && s.flags.Z==true && s.flags.N==false);
    test([LDX_IMM, 0x01, INC_ZP_X, 0x80], 2, s=>bus.read(0x0081) == 0x01 && s.flags.Z==false && s.flags.N==false);
    // // abs
    bus.write(0x0400, 0xfe);
    test([INC_ABS, 0x00, 0x04], 1, s=>bus.read(0x0400) == 0xff && s.flags.Z==false && s.flags.N==true);
    test([INC_ABS, 0x00, 0x04], 1, s=>bus.read(0x0400) == 0x00 && s.flags.Z==true && s.flags.N==false);
    test([INC_ABS, 0x00, 0x04], 1, s=>bus.read(0x0400) == 0x01 && s.flags.Z==false && s.flags.N==false);
    // // abs x
    bus.write(0x0401, 0xfe);
    test([LDX_IMM, 0x01, INC_ABS_X, 0x00, 0x04], 2, s=>bus.read(0x0401) == 0xff && s.flags.Z==false && s.flags.N==true);
    test([LDX_IMM, 0x01, INC_ABS_X, 0x00, 0x04], 2, s=>bus.read(0x0401) == 0x00 && s.flags.Z==true && s.flags.N==false);
    test([LDX_IMM, 0x01, INC_ABS_X, 0x00, 0x04], 2, s=>bus.read(0x0401) == 0x01 && s.flags.Z==false && s.flags.N==false);
}
void inx() {
    test([LDX_IMM, 0xfe, INX], 2, s=>s.X==0xff && s.flags.Z==false && s.flags.N==true);
    test([LDX_IMM, 0xff, INX], 2, s=>s.X==0x00 && s.flags.Z==true && s.flags.N==false);
    test([LDX_IMM, 0x00, INX], 2, s=>s.X==0x01 && s.flags.Z==false && s.flags.N==false);
}
void iny() {
    test([LDY_IMM, 0xfe, INY], 2, s=>s.Y==0xff && s.flags.Z==false && s.flags.N==true);
    test([LDY_IMM, 0xff, INY], 2, s=>s.Y==0x00 && s.flags.Z==true && s.flags.N==false);
    test([LDY_IMM, 0x00, INY], 2, s=>s.Y==0x01 && s.flags.Z==false && s.flags.N==false);
}
void jmp() {
    // write LDA_IMM, 0x12 to 0x0203, 0x0204
    // write LDA_IMM, 0x13 to 0x0205, 0x0206
    writeBytes(0x0203, [LDA_IMM, 0x12, LDA_IMM, 0x13]);

    test([JMP_ABS, 0x05, 0x02], 2, s=>s.A==0x13);

    // 0x0400 = 0x0203
    writeBytes(0x0400, [0x03, 0x02]);
    test([JMP_IND, 0x00, 0x04], 2, s=>s.A==0x12);
}
void jsr() {
    // create a subroutine
    writeBytes(0x0203, [
        /* 0x0203 */ LDA_IMM, 0x12,
        /* 0x0205 */ LDA_IMM, 0x13,  // <-- jsr to here and execute 1 instruction
        /* 0x0207 */ LDA_IMM, 0x14
    ]);

    // before SP = 0xfd

    // [01fd] 02
    // [01fc] 05-1

    // after SP = 0xfb

    // PC = 0x200, after JSR instruction is 0x203
    test([JSR, 0x05, 0x02], 2, s=>s.A==0x13 && s.SP==0xfb &&
        bus.read(0x01fd)==0x02 &&   // hi
        bus.read(0x01fc)==0x02);    // lo (-1)
}
void lda() {
    test([LDA_IMM, 0x40], 1, s=>s.A==0x40); // imm
    test([LDA_ZP, 0x00], 1, s=>s.A==0x01);  // zp
    test([LDA_ZP, 0x01], 1, s=>s.A==0x02);  // zp
    test([LDX_IMM, 0x01, LDA_ZP_X, 0x00], 2, s=>s.A==0x02); // zp x
    test([LDX_IMM, 0x02, LDA_ZP_X, 0x01], 2, s=>s.A==0x04); // zp x
    test([LDA_ABS, 0x00, 0x03], 1, s=>s.A==0x05);  // abs
    test([LDX_IMM, 0x01, LDA_ABS_X, 0x00, 0x03], 2, s=>s.A==0x06); // abs x
    test([LDY_IMM, 0x01, LDA_ABS_Y, 0x00, 0x03], 2, s=>s.A==0x06); // abs y
    test([LDX_IMM, 0x01, LDA_IND_X, 0x03], 2, s=>s.A==0x05); // ind x
    test([LDY_IMM, 0x01, LDA_IND_Y, 0x04], 2, s=>s.A==0x06); // ind y
}
void ldx() {
    test([LDX_IMM, 40], 1, s=>s.X==40); // imm
    test([LDX_ZP, 0x00], 1, s=>s.X==0x01); // zp
    test([LDY_IMM, 0x01, LDX_ZP_Y, 0x00], 2, s=>s.X==0x02); // zp y
    test([LDX_ABS, 0x00, 0x03], 1, s=>s.X==0x05);  // abs
    test([LDY_IMM, 0x01, LDX_ABS_Y, 0x00, 0x03], 2, s=>s.X==0x06); // abs y
}
void ldy() {
    test([LDY_IMM, 40], 1, s=>s.Y==40); // imm
    test([LDY_ZP, 0x00], 1, s=>s.Y==0x01); // zp
    test([LDX_IMM, 0x01, LDY_ZP_X, 0x00], 2, s=>s.Y==0x02); // zp x
    test([LDY_ABS, 0x00, 0x03], 1, s=>s.Y==0x05);  // abs
    test([LDX_IMM, 0x01, LDY_ABS_X, 0x00, 0x03], 2, s=>s.Y==0x06); // abs x
}
void lsr() {
    // acc
    test([LDA_IMM, 0b0000_0001, LSR_ACC], 2, s=>s.A==0b0000_0000 && s.flags.C==true && s.flags.Z==true);
    test([LDA_IMM, 0b1111_0000, LSR_ACC], 2, s=>s.A==0b0111_1000 && s.flags.C==false && s.flags.Z==false);
    test([LDA_IMM, 0b1000_0001, LSR_ACC], 2, s=>s.A==0b0100_0000 && s.flags.C==true && s.flags.Z==false);
    // zp
    writeBytes(0x0080, [0b0000_0001, 0b1111_0000, 0b1000_0001]);
    test([LSR_ZP, 0x80], 1, s=>bus.read(0x0080)==0b0000_0000 && s.flags.C==true && s.flags.Z==true);
    test([LSR_ZP, 0x81], 1, s=>bus.read(0x0081)==0b0111_1000 && s.flags.C==false && s.flags.Z==false);
    test([LSR_ZP, 0x82], 1, s=>bus.read(0x0082)==0b0100_0000 && s.flags.C==true && s.flags.Z==false);
    // zp x
    writeBytes(0x0081, [0b0000_0001, 0b1111_0000, 0b1000_0001]);
    test([LDX_IMM, 0x01, LSR_ZP_X, 0x80], 2, s=>bus.read(0x0081)==0b0000_0000 && s.flags.C==true && s.flags.Z==true);
    test([LDX_IMM, 0x01, LSR_ZP_X, 0x81], 2, s=>bus.read(0x0082)==0b0111_1000 && s.flags.C==false && s.flags.Z==false);
    test([LDX_IMM, 0x01, LSR_ZP_X, 0x82], 2, s=>bus.read(0x0083)==0b0100_0000 && s.flags.C==true && s.flags.Z==false);
    // abs
    writeBytes(0x0400, [0b0000_0001, 0b1111_0000, 0b1000_0001]);
    test([LSR_ABS, 0x00, 0x04], 1, s=>bus.read(0x0400)==0b0000_0000 && s.flags.C==true && s.flags.Z==true);
    test([LSR_ABS, 0x01, 0x04], 1, s=>bus.read(0x0401)==0b0111_1000 && s.flags.C==false && s.flags.Z==false);
    test([LSR_ABS, 0x02, 0x04], 1, s=>bus.read(0x0402)==0b0100_0000 && s.flags.C==true && s.flags.Z==false);
    // abs x
    writeBytes(0x0401, [0b0000_0001, 0b1111_0000, 0b1000_0001]);
    test([LDX_IMM, 0x01, LSR_ABS_X, 0x00, 0x04], 2, s=>bus.read(0x0401)==0b0000_0000 && s.flags.C==true && s.flags.Z==true);
    test([LDX_IMM, 0x01, LSR_ABS_X, 0x01, 0x04], 2, s=>bus.read(0x0402)==0b0111_1000 && s.flags.C==false && s.flags.Z==false);
    test([LDX_IMM, 0x01, LSR_ABS_X, 0x02, 0x04], 2, s=>bus.read(0x0403)==0b0100_0000 && s.flags.C==true && s.flags.Z==false);
}
void nop() {

}
void ora() {
    // imm
    test([LDA_IMM, 0b0000_0000, ORA_IMM, 0b1111_1111], 2, s=>s.A==0b1111_1111 && s.flags.Z==false && s.flags.N==true);
    test([LDA_IMM, 0b0000_0000, ORA_IMM, 0b0000_0000], 2, s=>s.A==0b0000_0000 && s.flags.Z==true && s.flags.N==false);
    // zp
    writeBytes(0x0080, [0b1111_1111]);
    test([LDA_IMM, 0b0000_0000, ORA_ZP, 0x80], 2, s=>s.A==0b1111_1111);
    // zp x
    writeBytes(0x0081, [0b1111_1111]);
    test([LDX_IMM, 0x01, LDA_IMM, 0b0000_0000, ORA_ZP_X, 0x80], 3, s=>s.A==0b1111_1111);
    // abs
    writeBytes(0x0400, [0b1111_1111]);
    test([LDA_IMM, 0b0000_0000, ORA_ABS, 0x00, 0x04], 2, s=>s.A==0b1111_1111);
    // abs x
    writeBytes(0x0401, [0b1111_1111]);
    test([LDX_IMM, 0x01, LDA_IMM, 0b0000_0000, ORA_ABS_X, 0x00, 0x04], 3, s=>s.A==0b1111_1111);
    // abs y
    writeBytes(0x0401, [0b1111_1111]);
    test([LDY_IMM, 0x01, LDA_IMM, 0b0000_0000, ORA_ABS_Y, 0x00, 0x04], 3, s=>s.A==0b1111_1111);
    // ind x
    writeBytes(0x0081, [0x00, 0x04]);
    writeBytes(0x0400, [0b1111_1111]);
    test([LDX_IMM, 0x01, LDA_IMM, 0b0000_0000, ORA_IND_X, 0x80], 3, s=>s.A==0b1111_1111);
    // ind y
    writeBytes(0x0080, [0x00, 0x04]);
    writeBytes(0x0401, [0b1111_1111]);
    test([LDY_IMM, 0x01, LDA_IMM, 0b0000_0000, ORA_IND_X, 0x80], 3, s=>s.A==0b1111_1111);
}
void pha() {
    // SP = 0xfd
    test([LDA_IMM, 0x20, PHA], 2, s=>s.SP==0xfc && bus.read(0x01fd)==0x20);
}
void php() {
    // SP =0xfd
    test([PHP], 1, s=>s.SP==0xfc && bus.read(0x01fd)==0b0011_0000);
}
void pla() {
    test([LDA_IMM, 0x20, PHA, LDA_IMM, 0x00, PLA], 4,
        s=>s.SP==0xfd && s.A==0x20);
}
void plp() {
    test([SEC, PHP, CLC, PLP], 4,
        s=>s.SP==0xfd && s.flags.C==true);
}
void rol() {
    // acc
    test([SEC, LDA_IMM, 0b1111_1111, ROL_ACC], 3, s=>s.A==0b1111_1111 && s.flags.C==true && s.flags.Z==false && s.flags.N==true);
    test([CLC, LDA_IMM, 0b0111_1111, ROL_ACC], 3, s=>s.A==0b1111_1110 && s.flags.C==false);
    test([CLC, LDA_IMM, 0b0000_0000, ROL_ACC], 3, s=>s.A==0b0000_0000 && s.flags.C==false && s.flags.Z==true && s.flags.N==false);
    // zp
    writeBytes(0x0080, [0b1111_1111]);
    test([SEC, ROL_ZP, 0x80], 2, s=>bus.read(0x0080)==0b1111_1111 && s.flags.C==true);
    writeBytes(0x0080, [0b0111_1111]);
    test([CLC, ROL_ZP, 0x80], 2, s=>bus.read(0x0080)==0b1111_1110 && s.flags.C==false && s.flags.Z==false && s.flags.N==true);
    writeBytes(0x0080, [0b0000_0000]);
    test([CLC, ROL_ZP, 0x80], 2, s=>bus.read(0x0080)==0b0000_0000 && s.flags.C==false && s.flags.Z==true && s.flags.N==false);
    // zp x
    writeBytes(0x0081, [0b1111_1111]);
    test([LDX_IMM, 0x01, SEC, ROL_ZP_X, 0x80], 3, s=>bus.read(0x0081)==0b1111_1111 && s.flags.C==true);
    // abs
    writeBytes(0x0400, [0b1111_1111]);
    test([SEC, ROL_ABS, 0x00, 0x04], 2, s=>bus.read(0x0400)==0b1111_1111 && s.flags.C==true);
    // abs x
    writeBytes(0x0401, [0b1111_1111]);
    test([LDX_IMM, 0x01, SEC, ROL_ABS_X, 0x00, 0x04], 3, s=>bus.read(0x0401)==0b1111_1111 && s.flags.C==true);
}
void ror() {
    // acc
    test([SEC, LDA_IMM, 0b1111_1111, ROR_ACC], 3, s=>s.A==0b1111_1111 && s.flags.C==true && s.flags.Z==false && s.flags.N==true);
    test([CLC, LDA_IMM, 0b1111_1110, ROR_ACC], 3, s=>s.A==0b0111_1111 && s.flags.C==false && s.flags.N==false);
    test([CLC, LDA_IMM, 0b0000_0000, ROR_ACC], 3, s=>s.A==0b0000_0000 && s.flags.C==false && s.flags.Z==true && s.flags.N==false);
    // zp
    writeBytes(0x0080, [0b1111_1111]);
    test([SEC, ROR_ZP, 0x80], 2, s=>bus.read(0x0080)==0b1111_1111 && s.flags.C==true && s.flags.Z==false && s.flags.N==true);
    writeBytes(0x0080, [0b1111_1110]);
    test([CLC, ROR_ZP, 0x80], 2, s=>bus.read(0x0080)==0b0111_1111 && s.flags.C==false && s.flags.Z==false && s.flags.N==false);
    writeBytes(0x0080, [0b0000_0000]);
    test([CLC, ROR_ZP, 0x80], 2, s=>bus.read(0x0080)==0b0000_0000 && s.flags.C==false && s.flags.Z==true && s.flags.N==false);
    // zp x
    writeBytes(0x0081, [0b1111_1111]);
    test([LDX_IMM, 0x01, SEC, ROR_ZP_X, 0x80], 3, s=>bus.read(0x0081)==0b1111_1111 && s.flags.C==true && s.flags.Z==false && s.flags.N==true);
    writeBytes(0x0081, [0b1111_1110]);
    test([LDX_IMM, 0x01, CLC, ROR_ZP_X, 0x80], 3, s=>bus.read(0x0081)==0b0111_1111 && s.flags.C==false && s.flags.Z==false && s.flags.N==false);
    writeBytes(0x0081, [0b0000_0000]);
    test([LDX_IMM, 0x01, CLC, ROR_ZP_X, 0x80], 3, s=>bus.read(0x0081)==0b0000_0000 && s.flags.C==false && s.flags.Z==true && s.flags.N==false);
    // abs
    writeBytes(0x0400, [0b1111_1111]);
    test([SEC, ROR_ABS, 0x00, 0x04], 2, s=>bus.read(0x0400)==0b1111_1111 && s.flags.C==true && s.flags.Z==false && s.flags.N==true);
    writeBytes(0x0400, [0b1111_1110]);
    test([CLC, ROR_ABS, 0x00, 0x04], 2, s=>bus.read(0x0400)==0b0111_1111 && s.flags.C==false && s.flags.Z==false && s.flags.N==false);
    writeBytes(0x0400, [0b0000_0000]);
    test([CLC, ROR_ABS, 0x00, 0x04], 2, s=>bus.read(0x0400)==0b0000_0000 && s.flags.C==false && s.flags.Z==true && s.flags.N==false);
    // abs x
    writeBytes(0x0401, [0b1111_1111]);
    test([LDX_IMM, 0x01, SEC, ROR_ABS_X, 0x00, 0x04], 3, s=>bus.read(0x0401)==0b1111_1111 && s.flags.C==true && s.flags.Z==false && s.flags.N==true);
    writeBytes(0x0401, [0b1111_1110]);
    test([LDX_IMM, 0x01, CLC, ROR_ABS_X, 0x00, 0x04], 3, s=>bus.read(0x0401)==0b0111_1111 && s.flags.C==false && s.flags.Z==false && s.flags.N==false);
    writeBytes(0x0401, [0b0000_0000]);
    test([LDX_IMM, 0x01, CLC, ROR_ABS_X, 0x00, 0x04], 3, s=>bus.read(0x0401)==0b0000_0000 && s.flags.C==false && s.flags.Z==true && s.flags.N==false);
}
void rti() {
    // interrupt routine at 0x0220
    writeBytes(0x0220, [PHP, LDA_IMM, 0x13, RTI]);

    test([JSR, 0x20, 0x02], 4, s=>s.A==0x13 && s.SP==0xfd);
}
void rts() {
    // subroutine at 0x0220
    writeBytes(0x0220, [LDA_IMM, 0x13, RTS]);

    test([JSR, 0x20, 0x02], 3, s=>s.A==0x13 && s.SP==0xfd);
}
void sbc() {
    // imm
    test([LDA_IMM, 0x20, SEC, SBC_IMM, 0x10], 3,
        s=>s.A==0x10 && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDA_IMM, 0x20, CLC, SBC_IMM, 0x10], 3,
        s=>s.A==0x0f && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDA_IMM, 0x20, SEC, SBC_IMM, 0x20], 3,
        s=>s.A==0x00 && s.flags.C==true && s.flags.Z==true && s.flags.V==false && s.flags.N==false);
    test([LDA_IMM, 0x20, SEC, SBC_IMM, 0x80], 3,
       s=>s.A==0xa0 && s.flags.C==false && s.flags.Z==false && s.flags.V==true && s.flags.N==true);
    // zp
    writeBytes(0x0080, [0x10, 0x10, 0x20, 0x80]);
    test([LDA_IMM, 0x20, SEC, SBC_ZP, 0x80], 3,
        s=>s.A==0x10 && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDA_IMM, 0x20, CLC, SBC_ZP, 0x81], 3,
        s=>s.A==0x0f && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDA_IMM, 0x20, SEC, SBC_ZP, 0x82], 3,
        s=>s.A==0x00 && s.flags.C==true && s.flags.Z==true && s.flags.V==false && s.flags.N==false);
    test([LDA_IMM, 0x20, SEC, SBC_ZP, 0x83], 3,
       s=>s.A==0xa0 && s.flags.C==false && s.flags.Z==false && s.flags.V==true && s.flags.N==true);
    // zp x
    writeBytes(0x0081, [0x10, 0x10, 0x20, 0x80]);
    test([LDX_IMM, 0x01, LDA_IMM, 0x20, SEC, SBC_ZP_X, 0x80], 4,
        s=>s.A==0x10 && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDX_IMM, 0x02, LDA_IMM, 0x20, CLC, SBC_ZP_X, 0x80], 4,
        s=>s.A==0x0f && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDX_IMM, 0x03, LDA_IMM, 0x20, SEC, SBC_ZP_X, 0x80], 4,
        s=>s.A==0x00 && s.flags.C==true && s.flags.Z==true && s.flags.V==false && s.flags.N==false);
    test([LDX_IMM, 0x04, LDA_IMM, 0x20, SEC, SBC_ZP_X, 0x80], 4,
       s=>s.A==0xa0 && s.flags.C==false && s.flags.Z==false && s.flags.V==true && s.flags.N==true);
    // abs
    writeBytes(0x0400, [0x10, 0x10, 0x20, 0x80]);
    test([LDA_IMM, 0x20, SEC, SBC_ABS, 0x00, 0x04], 3,
        s=>s.A==0x10 && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDA_IMM, 0x20, CLC, SBC_ABS, 0x01, 0x04], 3,
        s=>s.A==0x0f && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDA_IMM, 0x20, SEC, SBC_ABS, 0x02, 0x04], 3,
        s=>s.A==0x00 && s.flags.C==true && s.flags.Z==true && s.flags.V==false && s.flags.N==false);
    test([LDA_IMM, 0x20, SEC, SBC_ABS, 0x03, 0x04], 3,
       s=>s.A==0xa0 && s.flags.C==false && s.flags.Z==false && s.flags.V==true && s.flags.N==true);
    // abs x
    writeBytes(0x0401, [0x10, 0x10, 0x20, 0x80]);
    test([LDX_IMM, 0x01, LDA_IMM, 0x20, SEC, SBC_ABS_X, 0x00, 0x04], 4,
        s=>s.A==0x10 && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDX_IMM, 0x02, LDA_IMM, 0x20, CLC, SBC_ABS_X, 0x00, 0x04], 4,
        s=>s.A==0x0f && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDX_IMM, 0x03, LDA_IMM, 0x20, SEC, SBC_ABS_X, 0x00, 0x04], 4,
        s=>s.A==0x00 && s.flags.C==true && s.flags.Z==true && s.flags.V==false && s.flags.N==false);
    test([LDX_IMM, 0x04, LDA_IMM, 0x20, SEC, SBC_ABS_X, 0x00, 0x04], 4,
       s=>s.A==0xa0 && s.flags.C==false && s.flags.Z==false && s.flags.V==true && s.flags.N==true);
    // abs y
    writeBytes(0x0401, [0x10, 0x10, 0x20, 0x80]);
    test([LDY_IMM, 0x01, LDA_IMM, 0x20, SEC, SBC_ABS_Y, 0x00, 0x04], 4,
        s=>s.A==0x10 && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDY_IMM, 0x02, LDA_IMM, 0x20, CLC, SBC_ABS_Y, 0x00, 0x04], 4,
        s=>s.A==0x0f && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDY_IMM, 0x03, LDA_IMM, 0x20, SEC, SBC_ABS_Y, 0x00, 0x04], 4,
        s=>s.A==0x00 && s.flags.C==true && s.flags.Z==true && s.flags.V==false && s.flags.N==false);
    test([LDY_IMM, 0x04, LDA_IMM, 0x20, SEC, SBC_ABS_Y, 0x00, 0x04], 4,
       s=>s.A==0xa0 && s.flags.C==false && s.flags.Z==false && s.flags.V==true && s.flags.N==true);
    // ind x
    writeBytes(0x0081, [0x00, 0x04,  0x01, 0x04,  0x02, 0x04,  0x03, 0x04]);
    writeBytes(0x0400, [0x10, 0x10, 0x20, 0x80]);
    test([LDX_IMM, 0x01, LDA_IMM, 0x20, SEC, SBC_IND_X, 0x80], 4,
        s=>s.A==0x10 && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDX_IMM, 0x03, LDA_IMM, 0x20, CLC, SBC_IND_X, 0x80], 4,
        s=>s.A==0x0f && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDX_IMM, 0x05, LDA_IMM, 0x20, SEC, SBC_IND_X, 0x80], 4,
        s=>s.A==0x00 && s.flags.C==true && s.flags.Z==true && s.flags.V==false && s.flags.N==false);
    test([LDX_IMM, 0x07, LDA_IMM, 0x20, SEC, SBC_IND_X, 0x80], 4,
       s=>s.A==0xa0 && s.flags.C==false && s.flags.Z==false && s.flags.V==true && s.flags.N==true);
    // ind y
    writeBytes(0x0080, [0x00, 0x04]);
    writeBytes(0x0401, [0x10, 0x10, 0x20, 0x80]);
    test([LDY_IMM, 0x01, LDA_IMM, 0x20, SEC, SBC_IND_Y, 0x80], 4,
        s=>s.A==0x10 && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDY_IMM, 0x02, LDA_IMM, 0x20, CLC, SBC_IND_Y, 0x80], 4,
        s=>s.A==0x0f && s.flags.C==true && s.flags.Z==false && s.flags.V==false && s.flags.N==false);
    test([LDY_IMM, 0x03, LDA_IMM, 0x20, SEC, SBC_IND_Y, 0x80], 4,
        s=>s.A==0x00 && s.flags.C==true && s.flags.Z==true && s.flags.V==false && s.flags.N==false);
    test([LDY_IMM, 0x04, LDA_IMM, 0x20, SEC, SBC_IND_Y, 0x80], 4,
       s=>s.A==0xa0 && s.flags.C==false && s.flags.Z==false && s.flags.V==true && s.flags.N==true);
}
void sec() {
    test([SEC], 1, s=>s.flags.C==true);
    test([CLC, SEC], 2, s=>s.flags.C==true);
}
void sed() {
    test([SED], 1, s=>s.flags.D==true);
    test([CLD, SED], 2, s=>s.flags.D==true);
}
void sei() {
    test([SEI], 1, s=>s.flags.I==true);
    test([CLI, SEI], 2, s=>s.flags.I==true);
}
void sta() {
    test([LDA_IMM, 0x10, STA_ZP, 0x80], 2, s=>bus.read(0x0080)==0x10); // zp
    test([LDX_IMM, 0x01, LDA_IMM, 0x10, STA_ZP_X, 0x80], 3, s=>bus.read(0x0081)==0x10); // zp x
    test([LDA_IMM, 0x10, STA_ABS, 0x00, 0x80], 2, s=>bus.read(0x0080)==0x10); // abs
    test([LDA_IMM, 0x10, LDX_IMM, 0x01, STA_ABS_X, 0x00, 0x80], 3, s=>bus.read(0x0081)==0x10); // abs x
    test([LDA_IMM, 0x10, LDY_IMM, 0x01, STA_ABS_Y, 0x00, 0x80], 3, s=>bus.read(0x0081)==0x10); // abs y
    test([LDA_IMM, 0x10, LDX_IMM, 0x01, STA_IND_X, 0x05], 3, s=>bus.read(0x0400)==0x10); // ind x
    test([LDA_IMM, 0x10, LDY_IMM, 0x01, STA_IND_Y, 0x05], 3, s=>bus.read(0x0400)==0x10); // ind y

}
void stx() {
    test([LDX_IMM, 0x10, STX_ZP, 0x80], 2, s=>bus.read(0x0080)==0x10); // zp
    test([LDY_IMM, 0x01, LDX_IMM, 0x10, STX_ZP_Y, 0x80], 3, s=>bus.read(0x0081)==0x10); // zp y
    test([LDX_IMM, 0x10, STX_ABS, 0x00, 0x80], 2, s=>bus.read(0x0080)==0x10); // abs
}
void sty() {
    test([LDY_IMM, 0x10, STY_ZP, 0x80], 2, s=>bus.read(0x0080)==0x10); // zp
    test([LDX_IMM, 0x01, LDY_IMM, 0x10, STY_ZP_X, 0x80], 3, s=>bus.read(0x0081)==0x10); // zp x
    test([LDY_IMM, 0x10, STY_ABS, 0x00, 0x80], 2, s=>bus.read(0x0080)==0x10); // abs
}
void tax() {
    test([LDA_IMM, 0x23, TAX], 2, s=>s.X==0x23 && s.flags.Z==false && s.flags.N==false);
    test([LDA_IMM, 0xff, TAX], 2, s=>s.X==0xff && s.flags.Z==false && s.flags.N==true);
    test([LDA_IMM, 0x00, TAX], 2, s=>s.X==0x00 && s.flags.Z==true && s.flags.N==false);
}
void tay() {
    test([LDA_IMM, 0x23, TAY], 2, s=>s.Y==0x23 && s.flags.Z==false && s.flags.N==false);
    test([LDA_IMM, 0xff, TAY], 2, s=>s.Y==0xff && s.flags.Z==false && s.flags.N==true);
    test([LDA_IMM, 0x00, TAY], 2, s=>s.Y==0x00 && s.flags.Z==true && s.flags.N==false);
}
void tsx() {
    // SP = 0xfd
    test([TSX], 1, s=>s.X==0xfd);
}
void txa() {
    test([LDA_IMM, 0xff, LDX_IMM, 0x00, TXA], 3, s=>s.A==0x00 && s.flags.Z==true && s.flags.N==false);
    test([LDA_IMM, 0x00, LDX_IMM, 0xff, TXA], 3, s=>s.A==0xff && s.flags.Z==false && s.flags.N==true);
}
void txs() {
    test([LDX_IMM, 0xff, TXS], 2, s=>s.SP==0xff);
}
void tya() {
    test([LDA_IMM, 0xff, LDY_IMM, 0x00, TYA], 3, s=>s.A==0x00 && s.flags.Z==true && s.flags.N==false);
    test([LDA_IMM, 0x00, LDY_IMM, 0xff, TYA], 3, s=>s.A==0xff && s.flags.Z==false && s.flags.N==true);
}
/**
 * Run the test suite :
 * Get the tests from here and compile using the included instructions.
 * https://github.com/Klaus2m5/6502_65C02_functional_tests
 */
void klaus() {
    auto testBinFile = "C:/Temp/as65/func_tests.bin";
    auto file = File(testBinFile, "rb");
    ubyte[] bytes = new ubyte[file.size()];
    file.rawRead(bytes);
    file.close();

    cpu.reset();
    cpu.load(0x000a, bytes);
    cpu.setPC(0x0400);

    uint prev;

    while(true) {
        cpu.execute();

        if(cpu.getState().PC == prev) {
            writefln("%s", cpu);
            writefln("If PC is 336d then everything worked");
            break;
        }
        prev = cpu.getState().PC;
    }
}

setup();
adc();
and();
asl();
bcc();
bcs();
beq();
bit();
bmi();
bne();
bpl();
brk();
bvc();
bvs();
clc();
cld();
cli();
clv();
cmp();
cpx();
cpy();
dec();
dex();
dey();
eor();
inc();
inx();
iny();
jmp();
jsr();
lda();
ldx();
ldy();
lsr();
nop();
ora();
pha();
php();
pla();
plp();
rol();
ror();
rti();
rts();
sbc();
sec();
sed();
sei();
sta();
stx();
sty();
tax();
tay();
tsx();
txa();
txs();
tya();
static if(false) {
    klaus();
}

} // unittest