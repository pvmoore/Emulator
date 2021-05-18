module emulator.machine.acorn.BBCMicro;

import emulator.all;

final class BBCMicro {
private:
    _6502 cpu;
    Memory mem;
    Bus bus;
    Pins pins;
public:
    this() {
        this.pins = new Pins6502();
        this.mem = new Memory(65536);
        this.bus = new Bus().add(mem);
        this.cpu = new _6502();

        cpu.addBus(bus);
    }
}