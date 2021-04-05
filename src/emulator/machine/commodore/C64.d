module emulator.machine.commodore.C64;

import emulator.all;

final class C64 {
private:
    CPU6502 cpu;
    Memory mem;
    Bus bus;
public:
    this() {
        this.mem = new Memory(65536);
        this.bus = new Bus().add(mem);
        this.cpu = new CPU6502();

        cpu.addBus(bus);
        cpu.reset();
    }
    void load(ubyte[] program) {
        cpu.load(0x200, program);
    }
    void execute() {
        cpu.execute();
        writefln("%s", cpu);
    }
}