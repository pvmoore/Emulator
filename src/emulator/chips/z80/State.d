module emulator.chips.z80.State;

import emulator.chips.z80.all;

enum Reg {
    A,
    B,
    C,
    D,
    E,
    F,
    H,
    L,
    I,
    R,
    AF,
    BC,
    DE,
    HL,
    IX,
    IY,
    SP,
    PC
}
bool is8Bit(Reg r) {
    switch(r) with(Reg) {
        case A:..case R: return true;
        default: return false;
    }
    assert(false);
}
bool is16Bit(Reg r) {
    return !is8Bit(r);
}

final class State {
public:
    enum Flag : ubyte {
        C   = 1 << 0,   // 0x01 Carry
        N   = 1 << 1,   // 0x02 Add/Subtract
        PV  = 1 << 2,   // 0x04 Parity/Overflow
        H   = 1 << 4,   // 0x10 Half Carry
        Z   = 1 << 6,   // 0x40 Zero
        S   = 1 << 7    // 0x80 Sign
    }
    ushort AF;
    ushort BC;
    ushort DE;
    ushort HL;
    ushort IX;
    ushort IY;
    ushort SP;
    ushort PC;
    ubyte I;    // interrupt
    ubyte R;    // refresh

    // shadows
    ushort AF1;
    ushort BC1;
    ushort DE1;
    ushort HL1;

    // maskable interrupt flipflops
    bool IFF1 = true; // should be false at reset?
    bool IFF2 = true; // should be false at reset?

    void reset() {
        AF = BC = DE = HL = IX = IY = SP = PC = 0;
        I = R = 0;
        AF1 = BC1 = DE1 = HL1 = 0;
        IFF1 = true;
        IFF2 = true;
    }
    State clone() {
        auto s = new State();
        s.AF = this.AF;
        s.BC = this.BC;
        s.DE = this.DE;
        s.HL = this.HL;
        s.IX = this.IX;
        s.IY = this.IY;
        s.SP = this.SP;
        s.PC = this.PC;
        s.I  = this.I;
        s.R  = this.R;
        s.AF1 = this.AF1;
        s.BC1 = this.BC1;
        s.DE1 = this.DE1;
        s.HL1 = this.HL1;
        s.IFF1 = this.IFF1;
        s.IFF2 = this.IFF2;
        return s;
    }
    override bool opEquals(const Object other) const {
        auto s = other.as!State;
        if(s is null) return false;
        if(s is this) return true;
        return
            s.AF == this.AF &&
            s.BC == this.BC &&
            s.DE == this.DE &&
            s.HL == this.HL &&
            s.IX == this.IX &&
            s.IY == this.IY &&
            s.SP == this.SP &&
            s.PC == this.PC &&
            s.I == this.I &&
            s.R == this.R &&
            s.AF1 == this.AF1 &&
            s.BC1 == this.BC1 &&
            s.DE1 == this.DE1 &&
            s.HL1 == this.HL1 &&
            s.IFF1 == this.IFF1 &&
            s.IFF2 == this.IFF2;
    }
    override string toString() {
        string flags =
            (flag(Flag.S) ? "S" : "-") ~
            (flag(Flag.Z) ? "Z" : "-") ~
            (flag(Flag.H) ? "H" : "-") ~
            (flag(Flag.PV) ? "P" : "-") ~
            (flag(Flag.N) ? "N" : "-") ~
            (flag(Flag.C) ? "C" : "-");

        return "[%04x] %s AF:%04x BC:%04x DE:%04x HL:%04x SP:%04x I:%02x R:%02x IFF:%b,%b"
            .format(PC, flags, AF, BC, DE, HL, SP, I, R, IFF1, IFF2);
    }

    ubyte getReg8(Reg r) {
        switch(r) with(Reg) {
            case A: return this.A;
            case B: return this.B;
            case C: return this.C;
            case D: return this.D;
            case E: return this.E;
            case F: return this.F;
            case H: return this.H;
            case L: return this.L;
            case I: return this.I;
            case R: return this.R;
            default: throw new Exception("Bad 8 bit reg");
        }
    }
    void setReg8(Reg r, ubyte value) {
        switch(r) with(Reg) {
            case A: this.A = value; break;
            case B: this.B = value; break;
            case C: this.C = value; break;
            case D: this.D = value; break;
            case E: this.E = value; break;
            case F: this.F = value; break;
            case H: this.H = value; break;
            case L: this.L = value; break;
            case I: this.I = value; break;
            case R: this.R = value; break;
            default: throw new Exception("Bad 8 bit reg");
        }
    }
    ushort getReg16(Reg r) {
        switch(r) with(Reg) {
            case AF: return this.AF;
            case BC: return this.BC;
            case DE: return this.DE;
            case HL: return this.HL;
            case IX: return this.IX;
            case IY: return this.IY;
            case SP: return this.SP;
            default: throw new Exception("Bad 16 bit reg");
        }
    }
    void setReg16(Reg r, ushort value) {
        switch(r) with(Reg) {
            case AF: this.AF = value; break;
            case BC: this.BC = value; break;
            case DE: this.DE = value; break;
            case HL: this.HL = value; break;
            case IX: this.IX = value; break;
            case IY: this.IY = value; break;
            case SP: this.SP = value; break;
            default: throw new Exception("Bad 16 bit reg");
        }
    }
    /**
     *  r can be one of AF, BC, DE, HL
     */
    void exchangeWithShadow(Reg r) {
        ushort temp;
        switch(r) {
            case Reg.AF: temp = AF; AF = AF1; AF1 = temp; break;
            case Reg.BC: temp = BC; BC = BC1; BC1 = temp; break;
            case Reg.DE: temp = DE; DE = DE1; DE1 = temp; break;
            case Reg.HL: temp = HL; HL = HL1; HL1 = temp; break;
            default: throw new Exception("Invalid shadow register %s".format(r));
        }
    }
    //══════════════════════════════════════════════════════════════════════════════════════════════
    void A(ubyte value) { AF &= 0x00ff; AF |= (value<<8); }
    ubyte A()           { return (AF>>>8) & 0xff; }
    void F(ubyte value) { AF &= 0xff00; AF |= value; }
    ubyte F()           { return AF & 0xff; }
    //══════════════════════════════════════════════════════════════════════════════════════════════
    void B(ubyte value) { BC &= 0x00ff; BC |= (value<<8); }
    ubyte B()           { return (BC>>>8) & 0xff; }
    void C(ubyte value) { BC &= 0xff00; BC |= value; }
    ubyte C()           { return BC & 0xff; }
    //══════════════════════════════════════════════════════════════════════════════════════════════
    void D(ubyte value) { DE &= 0x00ff; DE |= (value<<8); }
    ubyte D()           { return (DE>>>8) & 0xff; }
    void E(ubyte value) { DE &= 0xff00; DE |= value; }
    ubyte E()           { return DE & 0xff; }
    //══════════════════════════════════════════════════════════════════════════════════════════════
    void H(ubyte value) { HL &= 0x00ff; HL |= (value<<8); }
    ubyte H()           { return (HL>>>8) & 0xff; }
    void L(ubyte value) { HL &= 0xff00; HL |= value; }
    ubyte L()           { return HL & 0xff; }
    //══════════════════════════════════════════════════════════════════════════════════════════════
    bool flag(Flag f)           { return (F & f) != 0; }
    void flag(Flag f, bool set) { F(set ? F|f : F&~cast(uint)f); }

    bool flagC()  { return flag(Flag.C); }
    bool flagN()  { return flag(Flag.N); }
    bool flagPV() { return flag(Flag.PV); }
    bool flagH()  { return flag(Flag.H); }
    bool flagZ()  { return flag(Flag.Z); }
    bool flagS()  { return flag(Flag.S); }

    void flagC(bool f)  { flag(Flag.C, f); }
    void flagN(bool f)  { flag(Flag.N, f); }
    void flagPV(bool f) { flag(Flag.PV, f); }
    void flagH(bool f)  { flag(Flag.H, f); }
    void flagZ(bool f)  { flag(Flag.Z, f); }
    void flagS(bool f)  { flag(Flag.S, f); }

    void updateH(ubyte left, ubyte right, ubyte result) {
        auto h = (left ^ right ^ result) & 0x10;
        flagH(h!=0);
    }
    void updateP(ubyte result) {
        flagPV((result&1)==0);
    }
    void updateV(ubyte left, ubyte right, ubyte result) {
        auto v = (left ^ right) & (left ^ result) & 0x80;
        flagPV(v!=0);
    }
    void updateZ(ubyte result) {
        flagZ(result==0);
    }
    void updateS(ubyte result) {
        flagS((result&0x80)!=0);
    }
}