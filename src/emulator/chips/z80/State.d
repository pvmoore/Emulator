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
    IXH,
    IYH,
    L,
    IXL,
    IYL,
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
        X   = 1 << 3,
        H   = 1 << 4,   // 0x10 Half Carry
        Y   = 1 << 5,
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
    bool IFF1 = false;
    bool IFF2 = false;

    // Interrupt mode
    //  0 -
    //  1 -
    //  2 -
    uint IM;

    void reset() {
        //AF = BC = DE = HL = IX = IY = SP = 0;
        //AF1 = BC1 = DE1 = HL1 = 0;
        // I think these are the only registers that get cleared on Z80
        PC = 0;
        I = R = 0;
        IM = 0;
        IFF1 = false;
        IFF2 = false;
    }
    override string toString() {
        string flags =
            (flag(Flag.S) ? "S" : "-") ~
            (flag(Flag.Z) ? "Z" : "-") ~
            (flag(Flag.H) ? "H" : "-") ~
            (flag(Flag.PV) ? "P" : "-") ~
            (flag(Flag.N) ? "N" : "-") ~
            (flag(Flag.C) ? "C" : "-");

        return ("[%04x] %s AF:%04x BC:%04x DE:%04x HL:%04x IX:%04x IY:%04x SP:%04x" ~
               " I:%02x R:%02x IFF:%b,%b IM:%s")
            .format(PC, flags, AF, BC, DE, HL, IX, IY, SP,
                    I, R, IFF1, IFF2, IM);
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
            case IXH: return (this.IX>>>8).as!ubyte;
            case IYH: return (this.IY>>>8).as!ubyte;
            case L: return this.L;
            case IXL: return (this.IX&0xff).as!ubyte;
            case IYL: return (this.IY&0xff).as!ubyte;
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
            case IXH: this.IX = (this.IX & 0xff) | ((value<<8) & 0xff00); break;
            case IYH: this.IY = (this.IY & 0xff) | ((value<<8) & 0xff00); break;
            case L: this.L = value; break;
            case IXL: this.IX = (this.IX & 0xff00) | (value & 0xff); break;
            case IYL: this.IY = (this.IY & 0xff00) | (value & 0xff); break;
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
    void H(ubyte value) { HL = (HL&0x00ff) | (value<<8); }
    ubyte H()           { return (HL>>>8) & 0xff; }
    void L(ubyte value) { HL = (HL&0xff00) | (value); }
    ubyte L()           { return HL & 0xff; }
    //══════════════════════════════════════════════════════════════════════════════════════════════
    void IXH(ubyte value) { IX = (IX&0x00ff) | (value<<8); }
    ubyte IXH()           { return (IX>>>8) & 0xff; }
    void IXL(ubyte value) { IX = (IX&0xff00) | (value); }
    ubyte IXL()           { return IX & 0xff; }
    //══════════════════════════════════════════════════════════════════════════════════════════════
    void IYH(ubyte value) { IY = (IY&0x00ff) | (value<<8); }
    ubyte IYH()           { return (IY>>>8) & 0xff; }
    void IYL(ubyte value) { IY = (IY&0xff00) | (value); }
    ubyte IYL()           { return IY & 0xff; }
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

    void updateH(uint left, uint right, uint result) {
        auto h = (left ^ right ^ result) & 0x10;
        flagH(h!=0);
    }
    void updateH16(uint left, uint right, uint result) {
        auto h = (left ^ right ^ result) & 0x1000;
        flagH(h!=0);
    }
    void updateP(ubyte result) {
        import core.bitop : popcnt;
        flagPV((popcnt(result) & 1)==0);
    }
    // void updateV(uint left, uint right, uint result) {
    //     auto v = (left ^ right) & (left ^ result) & 0x80;
    //     flagPV(v!=0);
    // }
    void updateV(uint left, uint right, uint result) {
        auto v = ((left ^ right ^ result) >>> 7) & 3;
        flagPV(v == 1 || v == 2);
    }
    void updateV16(uint left, uint right, uint result) {
        auto v = ((left ^ right ^ result) >>> 15) & 3;
        flagPV(v == 1 || v == 2);
    }
    void updateZ(uint result) {
        flagZ(result==0);
    }
    void updateS(uint result) {
        flagS((result&0x80)!=0);
    }
}