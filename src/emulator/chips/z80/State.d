module emulator.chips.z80.State;

import emulator.chips.z80.all;

final class State {
public:
    enum Flag : ubyte {
        C   = 1 << 0,   // Carry
        N   = 1 << 1,   // Add/Subtract
        PV  = 1 << 2,   // Parity/Overflow
        H   = 1 << 4,   // Half Carry
        Z   = 1 << 6,   // Zero
        S   = 1 << 7    // Sign
    }
    ushort AF;
    ushort BC;
    ushort DE;
    ushort HL;
    ushort IX;
    ushort IY;
    ushort SP;
    ushort PC;

    ushort AF1;

    override string toString() {
        string flags =
            (flag(Flag.S) ? "S" : "-") ~
            (flag(Flag.Z) ? "Z" : "-") ~
            (flag(Flag.H) ? "H" : "-") ~
            (flag(Flag.PV) ? "P" : "-") ~
            (flag(Flag.N) ? "N" : "-") ~
            (flag(Flag.C) ? "C" : "-");

        return "[%04x] %s (A:%02x B:%02x C:%02x D:%02x E:%02x H:%02x L:%02x) BC:%04x, DE:%04x, HL:%04x SP:%04x"
            .format(PC, flags, A, B, C, D, E, H, L, BC, DE, HL, SP);
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

    void setC(bool f) { flag(Flag.C, f); }
    void setN(bool f) { flag(Flag.N, f); }
    void setPV(bool f) { flag(Flag.PV, f); }
    void setH(bool f) { flag(Flag.H, f); }
    void setZ(bool f) { flag(Flag.Z, f); }
    void setS(bool f) { flag(Flag.S, f); }

    void updateSZHPV(ubyte before, ubyte after) {
        setS((after&80)!=0);
        setZ(after==0);
        // todo H
        setPV(before==0x80); // check this
    }
}