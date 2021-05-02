module emulator.chips.z80._test.misc;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

void nop() {
    cpu.reset();
    test("
        nop
", [0x00]);

    prevState.PC = state.PC;
    assert(prevState == state);
    assertFlagsClear(allFlags());
}

setup();

nop();

} // unittest
