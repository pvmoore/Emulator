module emulator.component.Memory;

import emulator.all;

final class Memory : BusComponent {
private:
    ubyte[] data;
public:
    this(int numBytes) {
        this.data.length = numBytes;
    }

    @Implements("BusComponent")
    override bool write(uint addr, ubyte value) {
        data[addr] = value;
        return true;
    }
    @Implements("BusComponent")
    override bool read(uint addr, ref ubyte value) {
        value = data[addr];
        return true;
    }
}