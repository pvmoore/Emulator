module emulator.machine.spectrum.Spectrum;

import emulator.machine.spectrum.all;

final class Spectrum {
private:
    Z80 cpu;
    Memory memory;
    Z80Ports ports;
    Bus bus;
public:
    auto getCpu()    { return cpu; }
    auto getMemory() { return memory; }
    auto getPorts()  { return ports; }
    auto getBus()    { return bus; }

    this() {
        this.cpu = new Z80();

        this.ports = new Z80Ports(cpu.pins);
        this.memory = new Memory(65536);
        this.bus = new Bus().add(ports).add(memory);

        cpu.addBus(bus);
    }
}