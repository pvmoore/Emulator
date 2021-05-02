module emulator.chips.z80._test.shift_roll;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {

void rla() {
    cpu.reset();

}
void rra() {
    cpu.reset();

}
void rlca() {
    cpu.reset();

}
void rrca() {
    cpu.reset();

}

setup();

rla();
rra();
rlca();
rrca();

} // unittest