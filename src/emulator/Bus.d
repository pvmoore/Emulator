module emulator.Bus;

import emulator.all;

final class Bus {
private:
    BusComponent[] components;
public:
    auto add(BusComponent c) {
        components ~= c;
        return this;
    }
    void write(uint addr, ubyte value) {
        foreach(c; components) {
            if(c.write(addr, value)) break;
        }
    }
    void writeWord(uint addr, ushort value) {
        foreach(c; components) {
            if(c.writeWord(addr, value)) break;
        }
    }
    ubyte read(uint addr) {
        ubyte value;
        foreach(c; components) {
            if(c.read(addr, value)) break;
        }
        return value;
    }
    ushort readWord(uint addr) {
        ushort value;
        foreach(c; components) {
            if(c.readWord(addr, value)) break;
        }
        return value;
    }
}