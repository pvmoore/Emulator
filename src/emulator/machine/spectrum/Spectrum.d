module emulator.machine.spectrum.Spectrum;

import emulator.all;
import emulator.machine.spectrum.all;

final class Spectrum {
private:
    enum ROM48K = "resources/roms/48k.rom";
    Z80 cpu;
    Memory memory;
    Z80Ports ports;
    Z80Pins pins;
    Bus bus;
public:
    auto getCpu()    { return cpu; }
    auto getMemory() { return memory; }
    auto getPorts()  { return ports; }
    auto getBus()    { return bus; }

    this() {
        this.cpu = new Z80();
        this.pins = cpu.pins;

        this.ports = new Z80Ports(cpu.pins);
        this.memory = new Memory(65536);
        
        this.bus = new Bus()
            .add(ports)
            .add(memory);

        cpu.addBus(bus);
    }

    void reset() {
        cpu.reset();
        loadROM48K();
    }
    void loadROM48K() {
        log("Loading ROM");
        auto data = cast(ubyte[])From!"std.file".read(ROM48K);
        writeToMemory(0, data);
        log("ROM loaded");
    }
    void loadTape(string filename) {

    }
    ubyte[] readFromMemory(ushort addr, ushort numBytes) {
        pins.setMReq(true);
        ubyte[] data;
        foreach(i; 0..numBytes) {
            data ~= bus.read(addr+i);
        }
        return data;
    }
    void writeToMemory(ushort addr, ubyte[] data) {
        pins.setMReq(true);
        foreach(i; 0..data.length.as!uint) {
            bus.write(addr+i, data[i]);
        }
    }
private:

}