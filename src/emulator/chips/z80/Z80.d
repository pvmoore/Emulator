module emulator.chips.z80.Z80;

import emulator.chips.z80.all;

final class Z80 {
private:
    Bus bus;
public:
    State state;

    this() {
        this.state = new State();
    }
    auto addBus(Bus bus) {
        this.bus = bus;
        return this;
    }
    void reset() {

    }
    void load(ushort addr, ubyte[] bytes) {
        foreach(i; 0..bytes.length.as!uint) {
            bus.write(addr+i, bytes[i]);
        }
    }
    void setPC(ushort addr) {
        state.PC = addr;
    }
    void execute(bool dumpState = false) {
        auto op = Op(fetchByte());
        auto row = op.byte1>>>4;
        auto col = op.byte1&0b1111;
        auto instruction = primary[row][col];
        if(instruction.strategy is null) {
            throw new Exception("op %02x not implemented".format(op.byte1));
        }
        //writefln("instruction = %s", instruction);

        instruction.execute(this, op);

        if(dumpState) {
            writefln("%s", state);
        }

    }
    /**
     *  Read the next byte at PC and inc PC.
     */
    ubyte fetchByte() {
        return bus.read(state.PC++);
    }
    /**
     *  Read the next word at PC and add 2 to PC.
     */
    ushort fetchWord() {
        return bus.read(state.PC++) | (bus.read(state.PC++) << 8);
    }

    /**
     *  Read a byte from the Bus
     */
    ubyte readByte(ushort addr) {
        return bus.read(addr);
    }
    /**
     *  Read a word from the Bus
     */
    ushort readWord(ushort addr) {
        return bus.readWord(addr);
    }

    /**
     *  Write a byte to the Bus
     */
    void writeByte(ushort addr, ubyte value) {
        bus.write(addr, value);
    }
    /**
     *  Write a word to the Bus
     */
    void writeWord(ushort addr, ushort value) {
        bus.writeWord(addr, value);
    }
}