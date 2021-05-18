module emulator.chips.z80.Z80Ports;

import emulator.all;

final class Z80Ports : BusComponent {
private:
    Z80Pins pins;
    ubyte[256] data;
public:
    this(Z80Pins pins) {
        this.pins = pins;
    }

    @Implements("BusComponent")
    override bool write(uint addr, ubyte value) {
        if(!pins.isIOReq()) return false;
        auto port = addr & 0xff;
        data[port] = value;
        return true;
    }
    @Implements("BusComponent")
    override bool writeWord(uint addr, ushort value) {
        return false;
    }
    @Implements("BusComponent")
    override bool read(uint addr, ref ubyte value) {
        if(!pins.isIOReq()) return false;
        auto port = addr & 0xff;
        value = data[port];
        return true;
    }
    @Implements("BusComponent")
    override bool readWord(uint addr, ref ushort value) {
        return false;
    }
}