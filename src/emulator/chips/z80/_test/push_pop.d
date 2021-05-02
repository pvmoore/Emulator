module emulator.chips.z80._test.push_pop;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

void pushPop() {
    cpu.reset();

    state.AF = 0x0101;
    state.BC = 0x0202;
    state.DE = 0x0303;
    state.HL = 0x0404;

    test("
        push af
        push bc
        push de
        push hl
        pop hl
        pop de
        pop bc
        pop af
    ", [0xf5, 0xc5, 0xd5, 0xe5,
        0xe1, 0xd1, 0xc1, 0xf1]);

    assert(state.AF == 0x0101);
    assert(state.BC == 0x0202);
    assert(state.DE == 0x0303);
    assert(state.HL == 0x0404);
}

setup();
pushPop();

// state.updateV(0x7f, 0x81, 0xfe);
// state.updateH(0x7f, 0x81, 0xfe);
// writefln("PV = %s", state);

} // unit test