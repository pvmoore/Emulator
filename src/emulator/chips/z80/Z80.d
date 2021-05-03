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
        state.reset();
    }
    void load(ushort addr, ubyte[] bytes) {
        foreach(i; 0..bytes.length.as!uint) {
            bus.write(addr+i, bytes[i]);
        }
    }
    void setPC(ushort addr) {
        state.PC = addr;
    }
    Instruction execute() {
        auto op     = Op(fetchByte());
        auto index  = op.byte1;
        auto table  = cast(Instruction*)&primary;
        auto offset = 0;

        switch(index) {
            case 0xCB:
                table = cast(Instruction*)groupCB;
                index = op.byte2 = fetchByte();
                break;
            case 0xDD:
                table = cast(Instruction*)groupDD;
                index = op.byte2 = fetchByte();
                break;
            case 0xED:
                table  = cast(Instruction*)groupED;
                index  = op.byte2 = fetchByte();
                offset = 0x40;
                break;
            case 0xFD:
                table = cast(Instruction*)groupFD;
                index = op.byte2 = fetchByte();
                break;
            default:
                break;
        }

        Instruction instruction = table[index - offset];

        if(instruction.strategy is null) {
            throw new Exception("op %02x not implemented".format(op.byte1));
        }

        instruction.execute(this, op);

        return instruction;
    }
    ubyte pop() {
        return readByte(state.SP++);
    }
    ushort popWord() {
        return (pop() | (pop()<<8)).as!ushort;
    }
    void push(ubyte value) {
        writeByte(--state.SP, value);
    }
    void pushWord(ushort value) {
        push((value>>>8) & 0xff);
        push(value & 0xff);
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