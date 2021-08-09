module emulator.chips.z80._test.push_pop;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {
static if(true) {

void pushPop() {
    cpu.reset();

    state.AF = 0x0101;
    state.BC = 0x0202;
    state.DE = 0x0303;
    state.HL = 0x0404;
    state.IX = 0x0505;
    state.IY = 0x0606;

    test("
        push af
        push bc
        push de
        push hl
        push ix
        push iy
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
    ", [0xf5, 0xc5, 0xd5, 0xe5, 0xdd, 0xe5, 0xfd, 0xe5,
        0xfd, 0xe1, 0xdd, 0xe1, 0xe1, 0xd1, 0xc1, 0xf1]);

    assert(state.AF == 0x0101);
    assert(state.BC == 0x0202);
    assert(state.DE == 0x0303);
    assert(state.HL == 0x0404);
    assert(state.IX == 0x0505);
    assert(state.IY == 0x0606);
}

writefln("push pop tests");

setup();

pushPop();

} // static if
} // unit test