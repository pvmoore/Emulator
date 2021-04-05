module emulator.chips.z80._tests;

import emulator.chips.z80.all;
import emulator.component.Memory;

unittest {

__gshared Z80 cpu;
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
    cpu = new Z80();
    assert(cpu);
    assert(mem);
    assert(bus);
    cpu.addBus(bus);
}
void test(ubyte[] p, int count, bool function(State state) checker, bool dumpState = false) {
    cpu.reset();
    cpu.load(0x0000, p);
    cpu.setPC(0x0000);

    foreach(i; 0..count) {
        cpu.execute(dumpState);
    }
    assert(checker(cpu.state));
}
void nop_00() {
    test([NOP], 1, s=>true);
}
void ld_01() {
    test([LD_BC_nn, 0x01, 0x23], 1, s=>true, true);
}

setup();
nop_00();
ld_01();

} // unittest
