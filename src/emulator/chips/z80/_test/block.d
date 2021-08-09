module emulator.chips.z80._test.block;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {
static if(true) {

enum {
    LDI = [0xed, 0xa0],
    LDD = [0xed, 0xa8],
    CPI = [0xed, 0xa1],
    CPD = [0xed, 0xa9],
    INI = [0xed, 0xa2],
    IND = [0xed, 0xaa],
    OUTI = [0xed, 0xa3],
    OUTD = [0xed, 0xab],
    LDIR = [0xed, 0xb0],
    LDDR = [0xed, 0xb8],
    CPIR = [0xed, 0xb1],
    CPDR = [0xed, 0xb9],
    INIR = [0xed, 0xb2],
    INDR = [0xed, 0xba],
    OTIR = [0xed, 0xb3],
    OTDR = [0xed, 0xbb],
}

void ldi() {
    cpu.reset();

    writeBytes(0x0000, [0x12]);
    state.HL = 0x0000;
    state.DE = 0x0100;
    state.BC = 0x02;
    test("
        ldi
    ", LDI);

    assert(state.DE == 0x0101);
    assert(state.HL == 0x0001);
    assert(state.BC == 1);
    assert(bus.read(0x0100) == 0x12);
    assertFlagsSet(PV);
    assertFlagsClear(H, N);

    //---------------------------------

    writeBytes(0x0000, [0x12]);
    state.HL = 0x0000;
    state.DE = 0x0100;
    state.BC = 0x01;
    test("
        ldi
    ", LDI);

    assert(state.DE == 0x0101);
    assert(state.HL == 0x0001);
    assert(state.BC == 0);
    assert(bus.read(0x0100) == 0x12);
    assertFlagsSet();
    assertFlagsClear(H, N, PV);
}
void ldd() {
    cpu.reset();

    writeBytes(0x0000, [0x12]);
    state.HL = 0x0000;
    state.DE = 0x0100;
    state.BC = 0x02;
    test("
        ldd
    ", LDD);

    assert(state.DE == 0x00ff);
    assert(state.HL == 0xffff);
    assert(state.BC == 1);
    assert(bus.read(0x0100) == 0x12);
    assertFlagsSet(PV);
    assertFlagsClear(H, N);

    //---------------------------------

    writeBytes(0x0000, [0x12]);
    state.HL = 0x0000;
    state.DE = 0x0100;
    state.BC = 0x01;
    test("
        ldd
    ", LDD);

    assert(state.DE == 0x00ff);
    assert(state.HL == 0xffff);
    assert(state.BC == 0);
    assert(bus.read(0x0100) == 0x12);
    assertFlagsSet();
    assertFlagsClear(H, N, PV);
}
void cpi() {
    cpu.reset();

    state.A = 0x00;
    state.HL = 0x0000;
    state.BC = 2;
    writeBytes(0x0000, [0x12]);
    test("
        cpi
    ", CPI);

    assert(state.BC == 1);
    assert(state.HL == 0x0001);
    assertFlagsSet(N, S, PV);
    assertFlagsClear(Z, H);

    //---------------------------

    state.A = 0x00;
    state.HL = 0x0000;
    state.BC = 1;
    writeBytes(0x0000, [0x12]);
    test("
        cpi
    ", CPI);

    assert(state.BC == 0);
    assert(state.HL == 0x0001);
    assertFlagsSet(N, S);
    assertFlagsClear(Z, H, PV);
}
void cpd() {
    cpu.reset();

    state.A = 0x00;
    state.HL = 0x0000;
    state.BC = 2;
    writeBytes(0x0000, [0x12]);
    test("
        cpd
    ", CPD);

    assert(state.BC == 1);
    assert(state.HL == 0xffff);
    assertFlagsSet(N, S, PV);
    assertFlagsClear(Z, H);

    //-------------------------------

    state.A = 0x00;
    state.HL = 0x0000;
    state.BC = 1;
    writeBytes(0x0000, [0x12]);
    test("
        cpd
    ", CPD);

    assert(state.BC == 0);
    assert(state.HL == 0xffff);
    assertFlagsSet(N, S);
    assertFlagsClear(Z, H, PV);
}
void ini() {
    cpu.reset();

    writePort(7, 0x55);

    state.B = 2;
    state.C = 7;
    state.HL = 0x0100;
    test("
        ini
    ", INI);

    assert(state.B == 1);
    assert(state.HL == 0x0101);
    assert(bus.read(0x0100) == 0x55);
    assertFlagsSet(N);
    assertFlagsClear(Z);

    //------------------------------------

    state.B = 1;
    state.C = 7;
    state.HL = 0x0100;
    test("
        ini
    ", INI);

    assert(state.B == 0);
    assert(state.HL == 0x0101);
    assert(bus.read(0x0100) == 0x55);
    assertFlagsSet(N, Z);
    assertFlagsClear();

}
void ind() {
    cpu.reset();

    writePort(7, 0x55);

    state.B = 2;
    state.C = 7;
    state.HL = 0x0100;
    test("
        ind
    ", IND);

    assert(state.B == 1);
    assert(state.HL == 0x00ff);
    assert(bus.read(0x0100) == 0x55);
    assertFlagsSet(N);
    assertFlagsClear(Z);

    //------------------------------------

    state.B = 1;
    state.C = 7;
    state.HL = 0x0100;
    test("
        ind
    ", IND);

    assert(state.B == 0);
    assert(state.HL == 0x00ff);
    assert(bus.read(0x0100) == 0x55);
    assertFlagsSet(N, Z);
    assertFlagsClear();
}
void outi() {
    cpu.reset();

    state.B = 2;
    state.C = 8;
    state.HL = 0x0100;
    writeBytes(0x0100, [0x66]);
    test("
        outi
    ", OUTI);

    assert(state.B == 1);
    assert(state.HL == 0x0101);
    assert(readPort(8) == 0x66);

    assertFlagsSet(N);
    assertFlagsClear(Z);

    //---------------------------------

    state.B = 1;
    state.C = 8;
    state.HL = 0x0100;
    writeBytes(0x0100, [0x66]);
    test("
        outi
    ", OUTI);

    assert(state.B == 0);
    assert(state.HL == 0x0101);
    assert(readPort(8) == 0x66);

    assertFlagsSet(N, Z);
    assertFlagsClear();
}
void outd() {
    cpu.reset();

    state.B = 2;
    state.C = 8;
    state.HL = 0x0100;
    writeBytes(0x0100, [0x66]);
    test("
        outd
    ", OUTD);

    assert(state.B == 1);
    assert(state.HL == 0x00ff);
    assert(readPort(8) == 0x66);

    assertFlagsSet(N);
    assertFlagsClear(Z);

    //---------------------------------

    state.B = 1;
    state.C = 8;
    state.HL = 0x0100;
    writeBytes(0x0100, [0x66]);
    test("
        outd
    ", OUTD);

    assert(state.B == 0);
    assert(state.HL == 0x00ff);
    assert(readPort(8) == 0x66);

    assertFlagsSet(N, Z);
    assertFlagsClear();
}
void ldir() {
    cpu.reset();

    writeBytes(0x0200, [0x11, 0x22]);
    state.BC = 2;
    state.DE = 0x0100;
    state.HL = 0x0200;
    test("
        ldir
    ", LDIR);

    assert(state.BC == 1);
    assert(state.DE == 0x0101);
    assert(state.HL == 0x0201);
    assert(bus.read(0x0200) == 0x11);
    assertFlagsSet(PV);
    assertFlagsClear(H, N);

    test("
        ldir
    ", LDIR);

    assert(state.BC == 0);
    assert(state.DE == 0x0102);
    assert(state.HL == 0x0202);
    assert(bus.read(0x0201) == 0x22);
    assertFlagsSet();
    assertFlagsClear(H, N, PV);
}
void lddr() {
    cpu.reset();
    state.F = 0;

    writeBytes(0x01ff, [0x22, 0x11]);
    state.BC = 2;
    state.DE = 0x0100;
    state.HL = 0x0200;
    test("
        lddr
    ", LDDR);

    assert(state.BC == 1);
    assert(state.DE == 0x00ff);
    assert(state.HL == 0x01ff);
    assert(bus.read(0x0200) == 0x11);
    assertFlagsSet();
    assertFlagsClear(H, N, PV);

    test("
        lddr
    ", LDDR);

    assert(state.BC == 0);
    assert(state.DE == 0x00fe);
    assert(state.HL == 0x01fe);
    assert(bus.read(0x01ff) == 0x22);
    assertFlagsSet();
    assertFlagsClear(H, N, PV);
}
void cpir() {
    cpu.reset();

    writeBytes(0x0000, [0x33, 0x00]);
    state.BC = 2;
    state.HL = 0x0000;
    state.A = 0x00;
    test("
        cpir
    ", CPIR);

    assert(state.BC == 1);
    assert(state.HL == 0x0001);
    assertFlagsSet(N, PV, S);
    assertFlagsClear(Z);

    test("
        cpir
    ", CPIR);

    assert(state.BC == 0);
    assert(state.HL == 0x0002);
    assertFlagsSet(N, Z);
    assertFlagsClear(S, PV);
}
void cpdr() {
    cpu.reset();

    writeBytes(0x0000, [0x33, 0x00]);
    state.BC = 2;
    state.HL = 0x0001;
    state.A = 0x00;
    test("
        cpdr
    ", CPDR);

    assert(state.BC == 1);
    assert(state.HL == 0x0000);
    assertFlagsSet(N, PV, Z);
    assertFlagsClear(S);

    test("
        cpdr
    ", CPDR);

    assert(state.BC == 0);
    assert(state.HL == 0xffff);
    assertFlagsSet(N, S);
    assertFlagsClear(Z, PV);
}
void inir() {
    cpu.reset();

    writePort(9, 0x50);
    state.B = 2;
    state.C = 9;
    state.HL = 0x0000;
    test("
        inir
    ", INIR);

    assert(state.B == 1);
    assert(state.HL == 0x0001);
    assert(bus.read(0x0000) == 0x50);
    assertFlagsSet(N, Z);

    writePort(9, 0x51);
    test("
        inir
    ", INIR);

    assert(state.B == 0);
    assert(state.HL == 0x0002);
    assert(bus.read(0x0001) == 0x51);
    assertFlagsSet(N, Z);
}
void indr() {
    cpu.reset();

    writePort(9, 0x50);
    state.B = 2;
    state.C = 9;
    state.HL = 0x0001;
    test("
        indr
    ", INDR);

    assert(state.B == 1);
    assert(state.HL == 0x0000);
    assert(bus.read(0x0001) == 0x50);
    assertFlagsSet(N, Z);

    writePort(9, 0x51);
    test("
        indr
    ", INDR);

    assert(state.B == 0);
    assert(state.HL == 0xffff);
    assert(bus.read(0x0000) == 0x51);
    assertFlagsSet(N, Z);
}
void otir() {
    cpu.reset();

    writeBytes(0x0000, [0x01, 0x02]);
    state.C = 10;
    state.B = 2;
    state.HL = 0x0000;
    test("
        otir
    ", OTIR);

    assert(state.B == 1);
    assert(state.HL == 0x0001);
    assert(readPort(10) == 0x01);
    assertFlagsSet(N, Z);

    test("
        otir
    ", OTIR);

    assert(state.B == 0);
    assert(state.HL == 0x0002);
    assert(readPort(10) == 0x02);
    assertFlagsSet(N, Z);
}
void otdr() {
    cpu.reset();

    writeBytes(0x0000, [0x01, 0x02]);
    state.C = 10;
    state.B = 2;
    state.HL = 0x0001;
    test("
        otdr
    ", OTDR);

    assert(state.B == 1);
    assert(state.HL == 0x0000);
    assert(readPort(10) == 0x02);
    assertFlagsSet(N, Z);

    test("
        otdr
    ", OTDR);

    assert(state.B == 0);
    assert(state.HL == 0xffff);
    assert(readPort(10) == 0x01);
    assertFlagsSet(N, Z);
}

writefln("block tests");

setup();

ldi();
ldd();
cpi();
cpd();
ini();
ind();
outi();
outd();
ldir();
lddr();
cpir();
cpdr();
inir();
indr();
otir();
otdr();

} // static if
} // unittest