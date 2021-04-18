module emulator.chips._6502._6502;

import emulator.chips._6502.all;

/**
 *  0000-00ff  Zero page memory
 *  0100-01ff  Stack
 *  0200-fff9  Usable memory
 *  fffa-fffb  Address of NMI handler
 *  fffc-fffd  Address of Power on handler
 *  fffe-ffff  Address of BRK/interrupt handler
 *
 *  Notes: Decimal mode not currently supported.
 */
final class _6502 {
private:
    Bus bus;
    Op[][16] opcodes;

    ushort PC;
    ubyte SP;
    StatusRegister flags;
    ubyte A, X, Y;
public:
    static struct State {
        ushort PC;
        ubyte SP;
        StatusRegister flags;
        ubyte A, X, Y;
    }
    this() {
        setOpcodes();
    }
    auto addBus(Bus bus) {
        this.bus = bus;
        return this;
    }
    void reset() {
        A = X = Y = 0;
        PC = bus.read(0xfffc) | (bus.read(0xfffd) << 8);
        SP = 0xfd;
        flags.clear();
    }
    void load(ushort addr, ubyte[] bytes) {
        foreach(i; 0..bytes.length.as!uint) {
            bus.write(addr+i, bytes[i]);
        }
    }
    void setPC(ushort addr) {
        PC = addr;
    }
    /**
     *  Execute a single instruction
     */
    void execute(bool dumpState = false) {
        auto instr = fetchByte();

        auto op = opcodes[instr>>>4][instr&0xf];
        if(!op.valid()) {
            throw new Exception("Unsupported instruction %02x".format(instr));
        }

        op.addrMode.prepare();
        op.func(op.addrMode);

        if(dumpState) {
            writefln("%s", this);
        }
    }
    State getState() {
        return State(PC, SP, flags, A, X, Y);
    }
    override string toString() {
        string s;
        s ~= "[0x%04x] A: %02x, X: %02x, Y: %02x %s SP: %04x".format(PC, A, X, Y, flags, getSP());
        return s;
    }
private:
    ubyte fetchByte() {
        return bus.read(PC++);
    }
    ushort fetchWord() {
        return bus.read(PC++) | (bus.read(PC++) << 8);
    }
    ushort getSP() {
        return 0x100 + SP;
    }
    void push(ubyte value) {
        bus.write(getSP(), value);
        SP--;
    }
    void pushPC(int plus = 0) {
        // push hi,lo
        auto pc = PC + plus;
        push((pc >>> 8) & 0xff);
        push(pc & 0xff);
    }
    void pushFlags() {
        ubyte f = flags.toByte();
        // set break flag
        f |= 0b0001_0000;
        push(f);
    }
    ubyte pop() {
        SP++;
        return bus.read(getSP());
    }
    void popPC() {
        // pop lo,hi
        PC = pop() | (pop()<<8);
    }
    void popPCMinus1() {
        // pop lo,hi
        PC = pop() | (pop()<<8);
        PC++;
    }
    void popFlags() {
        flags.fromByte(pop());
        flags.B = false;
    }
    void jumpRelative(short offset) {
        short* p = cast(short*)&PC;
        *p += offset;
    }
    void jumpAbsolute(ushort addr) {
        PC = addr;
    }
    static struct StatusRegister {
        bool C; // Carry
        bool Z; // Zero
        bool I; // Interupt (disable if 1)
        bool D; // Decimal
        bool B; // Break (set if an interrupt request has been triggered by a BRK instruction)
        bool U = true; // Unused - always set
        bool V; // Overflow
        bool N; // Negative

        void updateZN(ubyte value) {
            Z = value == 0;
            N = (value & 0b1000_0000) != 0;
        }
        void clear() {
            C = Z = I = D = B = V = N = false;
        }
        ubyte toByte() {
            return cast(ubyte)(C | (Z<<1) | (I<<2) | (D<<3) | (B<<4) | (U<<5) | (V<<6) | (N<<7));
        }
        void fromByte(ubyte b) {
            C = (b & 1) != 0;
            Z = (b & 2) != 0;
            I = (b & 4) != 0;
            D = (b & 8) != 0;
            B = (b & 16) != 0;
            U = true;
            V = (b & 64) != 0;
            N = (b & 128) != 0;
        }
        string toString() {
            return (N ? "N" : "-") ~
                   (V ? "V" : "-") ~
                   (B ? "B" : "-") ~
                   (D ? "D" : "-") ~
                   (I ? "I" : "-") ~
                   (Z ? "Z" : "-") ~
                   (C ? "C" : "-");
        }
    }
    alias Func = void delegate(AddressingMode);

    static struct Op {
        Func func;
        AddressingMode addrMode;
        bool valid() { return addrMode !is null; }
    }
    enum NOOP = Op();

    void setOpcodes() {
        this.imp = new Imp();
        this.imm = new Imm();
        this.rel = new Rel();
        this.ind = new Ind();
        this.zp = new Zp();
        this.zpx = new Zpx();
        this.zpy = new Zpy();
        this.abs = new Abs();
        this.absx = new Absx();
        this.absy = new Absy();
        this.indx = new Indx();
        this.indy = new Indy();

        opcodes[0] = [
            Op(&brk, imp),  Op(&ora, indx), NOOP,             NOOP,    // 0-3
            NOOP,           Op(&ora, zp),   Op(&asl, zp),     NOOP,    // 4-7
            Op(&php, imp),  Op(&ora, imm),  Op(&asl, imp),    NOOP,    // 8-b
            NOOP,           Op(&ora, abs),  Op(&asl, abs),    NOOP     // c-f
        ];
        opcodes[1] = [
            Op(&bpl, rel),  Op(&ora, indy), NOOP,             NOOP,    // 0-3
            NOOP,           Op(&ora, zpx),  Op(&asl, zpx),    NOOP,    // 4-7
            Op(&clc, imp),  Op(&ora, absy), NOOP,             NOOP,    // 8-b
            NOOP,           Op(&ora, absx), Op(&asl, absx),   NOOP     // c-f
        ];
        opcodes[2] = [
            Op(&jsr, abs),  Op(&and, indx), NOOP,           NOOP,    // 0-3
            Op(&bit, zp),   Op(&and, zp),   Op(&rol, zp),   NOOP,    // 4-7
            Op(&plp, imp),  Op(&and, imm),  Op(&rol, imp),  NOOP,    // 8-b
            Op(&bit, abs),  Op(&and, abs),  Op(&rol, abs),  NOOP     // c-f
        ];
        opcodes[3] = [
            Op(&bmi, rel),  Op(&and, indy), NOOP,           NOOP,    // 0-3
            NOOP,           Op(&and, zpx),  Op(&rol, zpx),  NOOP,    // 4-7
            Op(&sec, imp),  Op(&and, absy), NOOP,           NOOP,    // 8-b
            NOOP,           Op(&and, absx), Op(&rol, absx), NOOP     // c-f
        ];
        opcodes[4] = [
            Op(&rti, imp),  Op(&eor, indx),   NOOP,             NOOP,    // 0-3
            NOOP,           Op(&eor, zp),     Op(&lsr, zp),     NOOP,    // 4-7
            Op(&pha, imp),  Op(&eor, imm),    Op(&lsr, imp),    NOOP,    // 8-b
            Op(&jmp, abs),  Op(&eor, abs),    Op(&lsr, abs),    NOOP     // c-f
        ];
        opcodes[5] = [
            Op(&bvc, rel),  Op(&eor, indy), NOOP,           NOOP,    // 0-3
            NOOP,           Op(&eor, zpx),  Op(&lsr, zpx),  NOOP,    // 4-7
            Op(&cli, imp),  Op(&eor, absy), NOOP,           NOOP,    // 8-b
            NOOP,           Op(&eor, absx), Op(&lsr, absx), NOOP     // c-f
        ];
        opcodes[6] = [
            Op(&rts, imp),  Op(&adc, indx), NOOP,           NOOP,    // 0-3
            NOOP,           Op(&adc, zp),   Op(&ror, zp),   NOOP,    // 4-7
            Op(&pla, imp),  Op(&adc, imm),  Op(&ror, imp),  NOOP,    // 8-b
            Op(&jmp, ind),  Op(&adc, abs),  Op(&ror, abs),  NOOP     // c-f
        ];
        opcodes[7] = [
            Op(&bvs, rel),  Op(&adc, indy), NOOP,           NOOP,    // 0-3
            NOOP,           Op(&adc, zpx),  Op(&ror, zpx),  NOOP,    // 4-7
            Op(&sei, imp),  Op(&adc, absy), NOOP,           NOOP,    // 8-b
            NOOP,           Op(&adc, absx), Op(&ror, absx), NOOP     // c-f
        ];
        opcodes[8] = [
            NOOP,           Op(&sta, indx), NOOP,          NOOP,           // 0-3
            Op(&sty, zp),   Op(&sta, zp),   Op(&stx, zp),  NOOP,           // 4-7
            Op(&dey, imp),  NOOP,           Op(&txa, imp), NOOP,           // 8-b
            Op(&sty, abs),  Op(&sta, abs),  Op(&stx, abs), NOOP            // c-f
        ];
        opcodes[9] = [
            Op(&bcc, rel),  Op(&sta, indy), NOOP,           NOOP,    // 0-3
            Op(&sty, zpx),  Op(&sta, zpx),  Op(&stx, zpy),  NOOP,    // 4-7
            Op(&tya, imp),  Op(&sta, absy), Op(&txs, imp),  NOOP,    // 8-b
            NOOP,           Op(&sta, absx), NOOP,           NOOP     // c-f
        ];
        opcodes[0xa] = [
            Op(&ldy, imm),  Op(&lda, indx), Op(&ldx, imm), NOOP, // 0-3
            Op(&ldy, zp),   Op(&lda, zp),   Op(&ldx, zp),  NOOP, // 4-7
            Op(&tay, imp),  Op(&lda, imm),  Op(&tax, imp), NOOP, // 8-b
            Op(&ldy, abs),  Op(&lda, abs),  Op(&ldx, abs), NOOP  // c-f
        ];
        opcodes[0xb] = [
            Op(&bcs, rel),  Op(&lda, indy), NOOP,           NOOP, // 0-3
            Op(&ldy, zpx),  Op(&lda, zpx),  Op(&ldx, zpy),  NOOP, // 4-7
            Op(&clv, imp),  Op(&lda, absy), Op(&tsx, imp),  NOOP, // 8-b
            Op(&ldy, absx), Op(&lda, absx), Op(&ldx, absy), NOOP  // c-f
        ];
        opcodes[0xc] = [
            Op(&cpy, imm),  Op(&cmp, indx),   NOOP,             NOOP,    // 0-3
            Op(&cpy, zp),   Op(&cmp, zp),     Op(&dec, zp),     NOOP,    // 4-7
            Op(&iny, imp),  Op(&cmp, imm),    Op(&dex, imp),    NOOP,    // 8-b
            Op(&cpy, abs),  Op(&cmp, abs),    Op(&dec, abs),    NOOP     // c-f
        ];
        opcodes[0xd] = [
            Op(&bne, rel),  Op(&cmp, indy), NOOP,           NOOP,    // 0-3
            NOOP,           Op(&cmp, zpx),  Op(&dec, zpx),  NOOP,    // 4-7
            Op(&cld, imp),  Op(&cmp, absy), NOOP,           NOOP,    // 8-b
            NOOP,           Op(&cmp, absx), Op(&dec, absx), NOOP     // c-f
        ];
        opcodes[0xe] = [
            Op(&cpx, imm),  Op(&sbc, indx), NOOP,           NOOP,    // 0-3
            Op(&cpx, zp),   Op(&sbc, zp),   Op(&inc, zp),   NOOP,    // 4-7
            Op(&inx, imp),  Op(&sbc, imm),  Op(&nop, imp),  NOOP,    // 8-b
            Op(&cpx, abs),  Op(&sbc, abs),  Op(&inc,  abs), NOOP     // c-f
        ];
        opcodes[0xf] = [
            Op(&beq, rel),  Op(&sbc, indy), NOOP,             NOOP,    // 0-3
            NOOP,           Op(&sbc, zpx),  Op(&inc, zpx),    NOOP,    // 4-7
            Op(&sed, imp),  Op(&sbc, absy), NOOP,             NOOP,    // 8-b
            NOOP,           Op(&sbc, absx), Op(&inc, absx),   NOOP     // c-f
        ];
    }

    // ╔═══════════════════════════════════════════════════════════════════════════════════════════╗
    // ║ Addressing Functions ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░║
    // ╚═══════════════════════════════════════════════════════════════════════════════════════════╝
    AddressingMode imp, imm, rel, ind, zp, zpx, zpy, abs, absx, absy, indx, indy;

    abstract class AddressingMode {
    public:
        ushort addr;
        uint value;

        void prepare() {
            addr = 0;
            value = uint.max;
        }
        ubyte read() {
            return value = bus.read(addr);
        }
        void write(ubyte value) {
            bus.write(addr, value);
        }
        abstract int numBytes();
    }
    final class Imp : AddressingMode {
        override ubyte read() { throw new Exception(""); }
        override void write(ubyte) { throw new Exception(""); }
        override int numBytes() { return 0; }
    }
    final class Imm : AddressingMode {
        override ubyte read() { return value = fetchByte(); }
        override void write(ubyte) { throw new Exception(""); }
        override int numBytes() { return 1; }
    }
    final class Rel : AddressingMode {
        override ubyte read() { return value = fetchByte(); }
        override void write(ubyte) { throw new Exception(""); }
        override int numBytes() { return 1; }
    }
    final class Ind : AddressingMode {
        override void prepare() {
            addr = addrInd();
        }
        override void write(ubyte) { throw new Exception(""); }
        override int numBytes() { return 2; }
    }
    final class Zp : AddressingMode {
        override void prepare() {
            addr = addrZp();
        }
        override int numBytes() { return 1; }
    }
    final class Zpx : AddressingMode {
        override void prepare() {
            addr = addrZpX();
        }
        override int numBytes() { return 1; }
    }
    final class Zpy : AddressingMode {
        override void prepare() {
            addr = addrZpY();
        }
        override int numBytes() { return 1; }
    }
    final class Abs : AddressingMode {
        override void prepare() {
            addr = addrAbs();
        }
        override int numBytes() { return 2; }
    }
    final class Absx : AddressingMode {
        override void prepare() {
            addr = addrAbsX();
        }
        override int numBytes() { return 2; }
    }
    final class Absy : AddressingMode {
        override void prepare() {
            addr = addrAbsY();
        }
        override int numBytes() { return 2; }
    }
    final class Indx : AddressingMode {
        override void prepare() {
            addr = addrIndX();
        }
        override int numBytes() { return 1; }
    }
    final class Indy : AddressingMode {
        override void prepare() {
            addr = addrIndY();
        }
        override int numBytes() { return 1; }
    }
    ushort addrInd() {
        auto ind = fetchWord();
        return bus.read(ind) | (bus.read(ind+1)<<8);
    }
    ushort addrZp() {
        return fetchByte();
    }
    ushort addrZpX() {
        return (fetchByte() + X) & 0xff;
    }
    ushort addrZpY() {
        return (fetchByte() + Y) & 0xff;
    }
    ushort addrAbs() {
        return fetchWord();
    }
    ushort addrAbsX() {
        return cast(ushort)(fetchWord() + X);
    }
    ushort addrAbsY() {
        return cast(ushort)(fetchWord() + Y);
    }
    ushort addrIndX() {
        auto i = fetchByte();
        auto lo = bus.read((i + X) & 0xff);
        auto hi = bus.read((i + 1 + X) & 0xff);
        return cast(ushort)(lo + (hi<<8));
    }
    ushort addrIndY() {
        auto i = fetchByte();
        return cast(ushort) ((bus.read(i) | (bus.read(i+1)<<8)) + Y);
    }
    // ╔═══════════════════════════════════════════════════════════════════════════════════════════╗
    // ║ Instructions ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░║
    // ╚═══════════════════════════════════════════════════════════════════════════════════════════╝
    /** Note D flag can operate on this instruction */
    void adc(AddressingMode addrMode) {
        ubyte a = A;
        ubyte value = addrMode.read();
        uint result = value + A + flags.C;

        A = result & 0xff;
        flags.updateZN(A);
        flags.C = result > 0xff;
        flags.V = (!((a ^ value) & 0x80) && ((a ^ result) & 0x80)) != 0;
    }
    void and(AddressingMode addrMode) {
        ubyte value = addrMode.read();
        A = value & A;
        flags.updateZN(A);
    }
    void asl(AddressingMode addrMode) {
        if(addrMode.isA!Imp) {
            // accumulator
            flags.C = (A & 0b1000_0000) != 0;
            A <<= 1;
            flags.updateZN(A);
        } else {
            // memory
            ubyte value = addrMode.read();
            flags.C = (value & 0b1000_0000) != 0;
            value <<= 1;
            addrMode.write(value);
            flags.updateZN(value);
        }
    }
    /** Branch if carru clear */
    void bcc(AddressingMode addrMode) {
        byte offset = addrMode.read();
        if(flags.C == false) {
            jumpRelative(offset);
        }
    }
    /** Branch if carry set */
    void bcs(AddressingMode addrMode) {
        byte offset = addrMode.read();
        if(flags.C) {
            jumpRelative(offset);
        }
    }
    /** Branch if equal (Z set) */
    void beq(AddressingMode addrMode) {
        byte offset = addrMode.read();
        if(flags.Z) {
            jumpRelative(offset);
        }
    }
    void bit(AddressingMode addrMode) {
        ubyte value = addrMode.read();
        ubyte result = A & value;
        flags.Z = result == 0;
        flags.V = (value & 0b0100_0000) != 0;
        flags.N = (value & 0b1000_0000) != 0;
    }
    /** Branch if mius (N set) */
    void bmi(AddressingMode addrMode) {
        byte offset = addrMode.read();
        if(flags.N) {
            jumpRelative(offset);
        }
    }
    /** Branch if not equal (Z clear) */
    void bne(AddressingMode addrMode) {
        // 2 cycles + 1 if branch taken + 2 if to a new page
        byte offset = addrMode.read();
        if(flags.Z==false) {
            jumpRelative(offset);
        }
    }
    /** Branch if positive (N clear) */
    void bpl(AddressingMode addrMode) {
        // 2 cycles + 1 if branch taken + 2 if to a new page
        byte offset = addrMode.read();
        if(flags.N==false) {
            jumpRelative(offset);
        }
    }
    void brk(AddressingMode addrMode) {
        // 7 cycles
        pushPC(1);
        pushFlags();
        PC = bus.read(0xfffe) | (bus.read(0xffff)<<8);
        flags.I = true;
    }
    /** Branch if no overflow (V clear) */
    void bvc(AddressingMode addrMode) {
        // 2 cycles + 1 if branch taken + 2 if to a new page
        byte offset = addrMode.read();
        if(flags.V==false) {
            jumpRelative(offset);
        }
    }
    /** Branch if overflow (V set) */
    void bvs(AddressingMode addrMode) {
        // 2 cycles + 1 if branch taken + 2 if to a new page
        byte offset = addrMode.read();
        if(flags.V==true) {
            jumpRelative(offset);
        }
    }
    void clc(AddressingMode addrMode) {
        // cycles = 2
        flags.C = false;
    }
    void cld(AddressingMode addrMode) {
        // cycles = 2
        flags.D = false;
    }
    void cli(AddressingMode addrMode) {
        // cycles = 2
        flags.I = false;
    }
    void clv(AddressingMode addrMode) {
        // cycles = 2
        flags.V = false;
    }
    void cmp(AddressingMode addrMode) {
        ubyte value = addrMode.read();
        flags.Z = A == value;
        flags.C = A >= value;
        flags.N = ((A-value) & 0b1000_0000) != 0;
    }
    void cpx(AddressingMode addrMode) {
        ubyte value = addrMode.read();
        flags.Z = X == value;
        flags.C = X >= value;
        flags.N = ((X-value) & 0b1000_0000) != 0;
    }
    void cpy(AddressingMode addrMode) {
        ubyte value = addrMode.read();
        flags.Z = Y == value;
        flags.C = Y >= value;
        flags.N = ((Y-value) & 0b1000_0000) != 0;
    }
    void dec(AddressingMode addrMode) {
        ubyte value = addrMode.read();
        value--;
        flags.updateZN(value);
        addrMode.write(value);
    }
    void dex(AddressingMode addrMode) {
        X--;
        flags.updateZN(X);
    }
    void dey(AddressingMode addrMode) {
        Y--;
        flags.updateZN(Y);
    }
    void eor(AddressingMode addrMode) {
        ubyte value = addrMode.read();
        A ^= value;
        flags.updateZN(A);
    }
    void inc(AddressingMode addrMode) {
        ubyte value = addrMode.read();
        value++;
        flags.updateZN(value);
        addrMode.write(value);
    }
    void inx(AddressingMode addrMode) {
        // 2 cycles
        X++;
        flags.updateZN(X);
    }
    void iny(AddressingMode addrMode) {
        // 2 cycles
        Y++;
        flags.updateZN(Y);
    }
    void jmp(AddressingMode addrMode) {
        jumpAbsolute(addrMode.addr);
    }
    void jsr(AddressingMode addrMode) {
        pushPC(-1);
        jumpAbsolute(addrMode.addr);
    }
    void lda(AddressingMode addrMode) {
        A = addrMode.read();
        flags.updateZN(A);
    }
    void ldx(AddressingMode addrMode) {
        X = addrMode.read();
        flags.updateZN(X);
    }
    void ldy(AddressingMode addrMode) {
        Y = addrMode.read();
        flags.updateZN(Y);
    }
    void lsr(AddressingMode addrMode) {
        if(addrMode.isA!Imp) {
            // accumulator (1 cycle)
            flags.C = (A & 1) != 0;
            A >>>= 1;
            flags.updateZN(A);
        } else {
            // memory
            ubyte value = addrMode.read();
            flags.C = (value & 1) != 0;
            value >>>= 1;
            addrMode.write(value);
            flags.updateZN(value);
        }
    }
    void nop(AddressingMode addrMode) {
        // 2 cycles
    }
    void ora(AddressingMode addrMode) {
        ubyte value = addrMode.read();
        A |= value;
        flags.updateZN(A);
    }
    void pha(AddressingMode addrMode) {
        // 3 cycles
        push(A);
    }
    void php(AddressingMode addrMode) {
        // 3 cycles
        pushFlags();
    }
    void pla(AddressingMode addrMode) {
        // 4 cycles
        A = pop();
        flags.updateZN(A);
    }
    /** Pop flags from stack */
    void plp(AddressingMode addrMode) {
        // 4 cycles
        popFlags();
    }
    void rol(AddressingMode addrMode) {
        if(addrMode.isA!Imp) {
            // accumulator (2 cycles)
            bool oldBit7 = (A & 0b1000_0000) != 0;
            A <<= 1;
            A |= flags.C ? 1 : 0;
            flags.C = oldBit7;
            flags.updateZN(A);
        } else {
            // memory
            ubyte value = addrMode.read();
            bool oldBit7 = (value & 0b1000_0000) != 0;
            value <<= 1;
            value |= flags.C ? 1 : 0;
            flags.C = oldBit7;
            addrMode.write(value);
            flags.updateZN(value);
        }
    }
    void ror(AddressingMode addrMode) {
        if(addrMode.isA!Imp) {
            // accumulator (2 cycles)
            bool oldBit0 = (A & 1) != 0;
            A >>>= 1;
            A |= flags.C ? 0b1000_0000 : 0;
            flags.C = oldBit0;
            flags.updateZN(A);
        } else {
            // memory
            ubyte value = addrMode.read();
            bool oldBit0 = (value & 1) != 0;
            value >>>= 1;
            value |= flags.C ? 0b1000_0000 : 0;
            flags.C = oldBit0;
            addrMode.write(value);
            flags.updateZN(value);
        }
    }
    void rti(AddressingMode addrMode) {
        // 6 cycles
        popFlags();
        popPC();
    }
    void rts(AddressingMode addrMode) {
        // 6 cycles
        popPCMinus1();
    }
    void sbc(AddressingMode addrMode) {
        ubyte a = A;
        ubyte b = addrMode.read();
        uint value = b ^ 0b1111_1111;
        uint result = value + A + flags.C;
        A = result & 0xff;
        flags.updateZN(A);
        flags.C = result > 0xff;
        flags.V = (!((a ^ value) & 0x80) && ((a ^ result) & 0x80)) != 0;
    }
    void sec(AddressingMode addrMode) {
        flags.C = true;
    }
    void sed(AddressingMode addrMode) {
        flags.D = true;
    }
    void sei(AddressingMode addrMode) {
        flags.I = true;
    }
    void sta(AddressingMode addrMode) {
        addrMode.write(A);
    }
    void stx(AddressingMode addrMode) {
        addrMode.write(X);
    }
    void sty(AddressingMode addrMode) {
        addrMode.write(Y);
    }
    void tax(AddressingMode addrMode) {
        // 2 cycles
        X = A;
        flags.updateZN(X);
    }
    void tay(AddressingMode addrMode) {
        // 2 cycles
        Y = A;
        flags.updateZN(Y);
    }
    /** Transfer SP to X */
    void tsx(AddressingMode addrMode) {
        // 2 cycles
        X = SP;
        flags.updateZN(X);
    }
    void txa(AddressingMode addrMode) {
        // 2 cycles
        A = X;
        flags.updateZN(A);
    }
    /** Transfer X to SP */
    void txs(AddressingMode addrMode) {
        // 2 cycles
        SP = X;
    }
    void tya(AddressingMode addrMode) {
        // 2 cycles
        A = Y;
        flags.updateZN(A);
    }
}