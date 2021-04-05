module emulator.chips.z80.strategies;

import emulator.chips.z80.all;

/**
r       Identifies any of the registers A, B, C, D, E, H, or L
(HL)    Identifies the contents of the memory location, whose address is specified by
        the contents of the register pair HL
(IX+d)  Identifies the contents of the memory location, whose address is specified by
        the contents of the Index register pair IX plus the signed displacement d
(IY+d)  Identifies the contents of the memory location, whose address is specified by
        the contents of the Index register pair IY plus the signed displacement d
n       Identifies a one-byte unsigned integer expression in the range (0 to 255)
nn      Identifies a two-byte unsigned integer expression in the range (0 to 65535)
d       Identifies a one-byte signed integer expression in the range (-128 to +127)
b       Identifies a one-bit expression in the range (0 to 7). The most-significant bit
        to the left is bit 7 and the least-significant bit to the right is bit 0
e       Identifies a one-byte signed integer expression in the range (-126 to +129)
        for relative jump offset from current location
cc      Identifies the status of the Flag Register as any of (NZ, Z, NC, C, PO, PE, P, or M)
        for the conditional jumps, calls, and return instructions

dd      Identifies any of the register pairs BC, DE, HL or SP
qq      Identifies any of the register pairs BC, DE, HL or AF
ss      Identifies any of the register pairs BC, DE, HL or SP
pp      Identifies any of the register pairs BC, DE, IX or SP
rr      Identifies any of the register pairs BC, DE, IY or SP
s       Identifies any of r, n, (HL), (IX+d) or (IY+d)
m       Identifies any of r, (HL), (IX+d) or (IY+d)

*/

__gshared const {
    Strategy _nop       = new Nop();
    Strategy _lddd      = new LD_dd();
    Strategy _ldr       = new LDr();
    Strategy _ldbca     = new LD_BC_A();
    Strategy _ldabc     = new LD_A_BC();
    Strategy _incss     = new INCss();
    Strategy _decss     = new DECss();
    Strategy _incr      = new INCr();
    Strategy _decr      = new DECr();
    Strategy _rlca      = new RLCA();
    Strategy _exaf      = new EXaf();
    Strategy _addhlss   = new ADD_HLss();


    SrcStrategy _n      = new N();
    SrcStrategy _nn     = new NN();
}
//══════════════════════════════════════════════════════════════════════════════════════════════════
// Strategies
//══════════════════════════════════════════════════════════════════════════════════════════════════
abstract class Strategy {
    void execute(Z80 cpu, Op op, const SrcStrategy src) const;
}

final class Nop : Strategy {
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        // do nothing
    }
}
final class LD_BC_A : Strategy {
    /** ld (bc), a */
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        cpu.writeWord(cpu.state.BC, cpu.state.A);
    }
}
final class LDr : Strategy {
    /**
     * 00rrr110
     *   000    ld b,   06
     *   001    ld c,   0e
     *   010    ld d,   16
     *   011    ld e,   1e
     *   100    ld h    26
     *   101    ld l,   2e
     *   110    ----    36
     *   111    ld a    3e
     *
     * Flags: unchanged
     */
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        cpu.writeWord(cpu.state.BC, cpu.state.A);
    }
}
final class INCr : Strategy {
    /**
     * 00rrr100
     * 00000100 inc b   04
     * 00001100 inc c   0c
     * 00010100 inc d   14
     * 00011100 inc e   1c
     * 00100100 inc h   24
     * 00101100 inc l   2c
     * 00110100 unused  34
     * 00111100 inc a   3c
     */
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        auto s = cpu.state;
        auto bits = (op.byte1 >>> 3) & 7;
        switch(bits) {
            case 0: s.B((s.B+1).as!ubyte); break;
            case 1: s.C((s.C+1).as!ubyte); break;
            case 2: s.D((s.D+1).as!ubyte); break;
            case 3: s.E((s.E+1).as!ubyte); break;
            case 4: s.H((s.H+1).as!ubyte); break;
            case 5: s.L((s.L+1).as!ubyte); break;
            case 6: break;
            case 7: s.A((s.A+1).as!ubyte); break;
            default: break;
        }
    }
}
final class DECr : Strategy {
    /**
     * 00rrr101
     * 00000101 dec b    05
     * 00001101 dec c    0d
     * 00010101 dec d    15
     * 00011101 dec e    1d
     * 00100101 dec h    25
     * 00101101 dec l    2d
     * 00110101 dec (hl) 35
     * 00111101 dec a    3d
     *
     * Flags: TODO
     */
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        auto s = cpu.state;
        auto bits = (op.byte1 >>> 3) & 7;
        switch(bits) {
            case 0:
                s.B((s.B-1).as!ubyte);
                break;
            case 1:
                s.C((s.C-1).as!ubyte);
                break;
            case 2:
                s.D((s.D-1).as!ubyte);
                break;
            case 3:
                s.E((s.E-1).as!ubyte);
                break;
            case 4:
                s.H((s.H-1).as!ubyte);
                break;
            case 5:
                s.L((s.L-1).as!ubyte);
                break;
            case 6:
                auto value = cpu.readByte(s.HL);
                cpu.writeByte(s.HL, (value-1).as!ubyte);
                break;
            case 7:
                s.A((s.A-1).as!ubyte);
                break;
            default: break;
        }
        s.setN(true);
    }
}
final class INCss : Strategy {
    /**
     *  00ss0011
     *    00     inc bc     03
     *    01     inc de     13
     *    10     inc hl     23
     *    11     inc sp     33
     */
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        auto bits = (op.byte1 >>> 4) & 3;
        switch(bits) {
            case 0: cpu.state.BC++; break;
            case 1: cpu.state.DE++; break;
            case 2: cpu.state.HL++; break;
            case 3: cpu.state.SP++; break;
            default: break;
        }
    }
}
final class DECss : Strategy {
    /**
     *  00ss1011
     *    00     dec bc     0b
     *    01     dec de     1b
     *    10     dec hl     2b
     *    11     dec sp     3b
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        auto bits = (op.byte1 >>> 4) & 3;
        switch(bits) {
            case 0: cpu.state.BC--; break;
            case 1: cpu.state.DE--; break;
            case 2: cpu.state.HL--; break;
            case 3: cpu.state.SP--; break;
            default: break;
        }
    }
}
final class LD_dd : Strategy {
    /**
     * 00dd0001
     * 00000001 ld bc, nn
     * 00010001 ld de, nn
     * 00100001 ld hl, nn
     * 00110001 ld sp, nn
     */
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        auto bits = (op.byte1 >>> 4) & 3;
        auto value = src.readWord(cpu);
        switch(bits) {
            case 0: cpu.state.BC = value; break;
            case 1: cpu.state.DE = value; break;
            case 2: cpu.state.HL = value; break;
            case 3: cpu.state.SP = value; break;
            default: break;
        }
    }
}
final class RLCA : Strategy {
    /**
     * Roll A left 1 bit
     * Copy sign bit to carry flag and also to bit 0
     *
     * Flags: C,H,N
     */
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        auto s = cpu.state;
        auto bit7 = isBitSet(s.A, 7);
        s.A = ((s.A<<1) | bit7 ? 1 : 0).as!ubyte;
        s.setH(false);
        s.setN(false);
        s.setC(bit7);
    }
}
final class EXaf : Strategy {
    /**
     * Exchange AF, AF'
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        auto s = cpu.state;
        auto af = s.AF;
        s.AF1 = s.AF;
        s.AF = af;
    }
}
final class ADD_HLss : Strategy {
    /**
     *  00ss1001
     *    00    add hl, bc      09
     *    01    add hl, de      19
     *    10    add hl, hl      29
     *    11    add hl, sp      39
     *
     * Flags: N,H
     */
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        auto s = cpu.state;
        auto bits = (op.byte1 >>> 4) &  3;
        switch(bits) {
            case 0: s.HL = (s.HL + s.BC).as!ushort; break;
            case 1: s.HL = (s.HL + s.DE).as!ushort; break;
            case 2: s.HL = (s.HL + s.HL).as!ushort; break;
            case 3: s.HL = (s.HL + s.SP).as!ushort; break;
            default: break;
        }
        // TODO H
        s.setN(false);
    }
}
final class LD_A_BC : Strategy {
    /**
     * ld a, (bc)
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op, const SrcStrategy src) const {
        auto s = cpu.state;
        ubyte value = cpu.readByte(s.BC);
        s.A = value;
    }
}


//══════════════════════════════════════════════════════════════════════════════════════════════════
// SrcStrategies
//══════════════════════════════════════════════════════════════════════════════════════════════════
abstract class SrcStrategy {
    ubyte readByte(Z80 cpu) const;
    ushort readWord(Z80 cpu) const;
}

final class N : SrcStrategy {
    override ubyte readByte(Z80 cpu) const { return cpu.fetchByte(); }
    override ushort readWord(Z80 cpu) const { throw new Exception("");}
}
final class NN : SrcStrategy {
    override ubyte readByte(Z80 cpu) const { throw new Exception(""); }
    override ushort readWord(Z80 cpu) const { return cpu.fetchWord(); }
}