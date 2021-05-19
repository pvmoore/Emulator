module emulator.chips.z80.Z80;

import emulator.chips.z80.all;

final class Z80 {
private:
    Bus bus;
public:
    State state;
    Z80Pins pins;

    this() {
        this.state = new State();
        this.pins = new Z80Pins();
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
        ubyte[] codes;
        const(Instruction)* instruction;
        auto op = Op(0x00, Reg.HL);

        void _fetch() {
            codes ~= (op.code = fetchByte());
        }
        void _decodePrimary() {
            instruction = &primary[op.code];
        }
        void _decodeCB() {
            _fetch();
            instruction = &groupCB[op.code];
        }
        void _decodeED() {
            _fetch();
            instruction = &groupED[op.code];
        }
        void _decodeDD() {
            _fetch();
            op.indexReg = Reg.IX;
            if(op.code == 0xcb) {
                _decodeCB();
            } else {
                instruction = &groupDD[op.code];
                if(!instruction) {
                    //instruction = primary[op.code];
                }
            }
        }
        void _decodeFD() {
            _fetch();
            op.indexReg = Reg.IY;
            if(op.code == 0xcb) {
                _decodeCB();
            } else {
                instruction = &groupFD[op.code];
                if(!instruction) {
                    //instruction = primary[op.code];
                }
            }
        }

        _fetch();

        switch(op.code) {
            case 0xCB: _decodeCB(); break;
            case 0xDD: _decodeDD(); break;
            case 0xED: _decodeED(); break;
            case 0xFD: _decodeFD(); break;
            default: _decodePrimary(); break;
        }

        if(!instruction) {
            throw new Exception("op %s not implemented".format(toHexStringArray(codes)));
        }

        instruction.execute(this, op);

        return cast(Instruction)*instruction;
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
    void pushWord(uint value) {
        // push hi, lo
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
    ubyte readPort(ubyte port) {
        pins.setIOReq(true);
        ubyte value = readByte(port);
        pins.setMReq(true);
        return value;
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
    void writePort(ubyte port, ubyte value) {
        pins.setIOReq(true);
        writeByte(port, value);
        pins.setMReq(true);
    }
    /**
     *  Write a word to the Bus
     */
    void writeWord(ushort addr, ushort value) {
        bus.writeWord(addr, value);
    }
private:

}