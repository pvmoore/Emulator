module emulator.Memory;

import emulator.all;

/**
 *  Little-endian Memory
 */
final class Memory : BusComponent {
public:
    ubyte[] data;

    this(int numBytes) {
        this.data.length = numBytes;
    }

    @Implements("BusComponent")
    override bool write(uint addr, ubyte value) {
        data[addr] = value;
        return true;
    }
    @Implements("BusComponent")
    override bool writeWord(uint addr, ushort value) {
        data[addr]   = value & 0xff;
        data[addr+1] = value >>> 8;
        return true;
    }
    @Implements("BusComponent")
    override bool read(uint addr, ref ubyte value) {
        value = data[addr];
        return true;
    }
    @Implements("BusComponent")
    override bool readWord(uint addr, ref ushort value) {
        value = data[addr] | (data[addr+1]<<8);
        return true;
    }
}