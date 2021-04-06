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
    Strategy _ldddnn    = new LD_dd_nn();
    Strategy _ldrn      = new LD_r_n();
    Strategy _ldrr      = new LD_r_r();
    Strategy _ldbca     = new LD_BC_A();
    Strategy _lddea     = new LD_DE_A();
    Strategy _ldabc     = new LD_A_BC();
    Strategy _ldade     = new LD_A_DE();
    Strategy _ldnnhl    = new LD_nn_REG(Reg.HL);
    Strategy _ldnna     = new LD_nn_REG(Reg.A);
    Strategy _ldhlnn    = new LD_REG_nn(Reg.HL, true);
    Strategy _ldann     = new LD_REG_nn(Reg.A, true);
    Strategy _incss     = new INCss();
    Strategy _decss     = new DECss();
    Strategy _incr      = new INCr();
    Strategy _decr      = new DECr();
    Strategy _rla       = new RLA();
    Strategy _rra       = new RRA();
    Strategy _rlca      = new RLCA();
    Strategy _rrca      = new RRCA();
    Strategy _exaf      = new EXaf();
    Strategy _addhlss   = new ADD_HLss();
    Strategy _daa       = new DAA();
    Strategy _cpl       = new CPL();
    Strategy _scf       = new CF(true);
    Strategy _ccf       = new CF(false);

    Strategy _jre       = new JRe(BranchType.JR);
    Strategy _jrnze     = new JRe(BranchType.NZ);
    Strategy _jrze      = new JRe(BranchType.Z);
    Strategy _jrnce     = new JRe(BranchType.NC);
    Strategy _jrce      = new JRe(BranchType.C);
    Strategy _djnze     = new JRe(BranchType.DJNZ);
}

//══════════════════════════════════════════════════════════════════════════════════════════════════
// Strategies
//══════════════════════════════════════════════════════════════════════════════════════════════════
abstract class Strategy {
    void execute(Z80 cpu, Op op) const;
}

final class Nop : Strategy {
    /**
     *  Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        // do nothing
    }
}
final class LD_BC_A : Strategy {
    /**
     * ld (bc), a
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        cpu.writeWord(cpu.state.BC, cpu.state.A);
    }
}
final class LD_DE_A : Strategy {
    /**
     * ld (de), a
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        cpu.writeWord(cpu.state.DE, cpu.state.A);
    }
}
final class LD_r_n : Strategy {
    /**
     * 00rrr110
     *   000    ld b,       06
     *   001    ld c,       0e
     *   010    ld d,       16
     *   011    ld e,       1e
     *   100    ld h        26
     *   101    ld l,       2e
     *   110    lh (hl),    36
     *   111    ld a        3e
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        ubyte value = cpu.fetchByte();
        auto bits = (op.byte1 >>> 3) & 7;
        switch(bits) {
            case 0: s.B = value; break;
            case 1: s.C = value; break;
            case 2: s.D = value; break;
            case 3: s.E = value; break;
            case 4: s.H = value; break;
            case 5: s.L = value; break;
            case 6:
                cpu.writeByte(s.HL, value);
                break;
            case 7: s.A = value; break;
            default: break;
        }
    }
}
final class LD_r_r : Strategy {
    /**
     * ld a,b       78      01111 000
     * ld a,c       79      01111 001
     * ld a,d       7a      01111 010
     * ld a,e       7b      01111 011
     * ld a,f       7c      01111 100
     * ld a,l       7d      01111 101
     * ld a,(hl)    7e      01111 110
     * ld a,a       7f      01111 111
     *
     * ld b,b       40      01000 000
     * ld b,c       41      01000 001
     * ld b,d       42      01000 010
     * ld b,e       43      01000 011
     * ld b,f       44      01000 100
     * ld b,l       45      01000 101
     * ld b, (hl)   46      01000 110
     * ld b,a       47      01000 111
     *
     * ld c,b       48      01001 000
     * ld c,c       49      01001 001
     * ld c,d       4a      01001 010
     * ld c,e       4b      01001 011
     * ld c,f       4c      01001 100
     * ld c,l       4d      01001 101
     * ld c,(hl)    4e      01001 110
     * ld c,a       4f      01001 111
     *
     * ld d,b       50      01010 000
     * ld d,c       51      01010 001
     * ld d,d       52      01010 010
     * ld d,e       53      01010 011
     * ld d,f       54      01010 100
     * ld d,l       55      01010 101
     * ld d,(hl)    56      01010 110
     * ld d,a       57      01010 111
     *
     * ld e,b       58      01011 000
     * ld e,c       59      01011 001
     * ld e,d       5a      01011 010
     * ld e,e       5b      01011 011
     * ld e,f       5c      01011 100
     * ld e,l       5d      01011 101
     * ld e,(hl)    5e      01011 110
     * ld e,a       5f      01011 111
     *
     * ld h,b       60      01100 000
     * ld h,c       61      01100 001
     * ld h,d       62      01100 010
     * ld h,e       63      01100 011
     * ld h,f       64      01100 100
     * ld h,l       65      01100 101
     * ld h,(hl)    66      01100 110
     * ld h,a       67      01100 111
     *
     * ld l,b       68      01101 000
     * ld l,c       69      01101 001
     * ld l,d       6a      01101 010
     * ld l,e       6b      01101 011
     * ld l,f       6c      01101 100
     * ld l,l       6d      01101 101
     * ld l,(hl)    6e      01101 110
     * ld l,a       6f      01101 111
     *
     * ld (hl),b    70
     * ld (hl),c    71
     * ld (hl),d    72
     * ld (hl),e    73
     * ld (hl),f    74
     * ld (hl),l    75
     *
     * ld (hl),a    77
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        ubyte value = cpu.fetchByte();
        auto bits = (op.byte1 >>> 3) & 7;
        switch(bits) {
            case 0: s.B = value; break;
            case 1: s.C = value; break;
            case 2: s.D = value; break;
            case 3: s.E = value; break;
            case 4: s.H = value; break;
            case 5: s.L = value; break;
            case 6:
                cpu.writeByte(s.HL, value);
                break;
            case 7: s.A = value; break;
            default: break;
        }
    }
}
final class LD_dd_nn : Strategy {
    /**
     * 00dd0001
     * 00000001 ld bc, nn
     * 00010001 ld de, nn
     * 00100001 ld hl, nn
     * 00110001 ld sp, nn
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.byte1 >>> 4) & 3;
        auto value = cpu.fetchWord();
        switch(bits) {
            case 0: s.BC = value; break;
            case 1: s.DE = value; break;
            case 2: s.HL = value; break;
            case 3: s.SP = value; break;
            default: break;
        }
    }
}
final class LD_A_BC : Strategy {
    /**
     * ld a, (bc)
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        ubyte value = cpu.readByte(s.BC);
        s.A = value;
    }
}
final class LD_A_DE : Strategy {
    /**
     * ld a, (de)
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        ubyte value = cpu.readByte(s.DE);
        s.A = value;
    }
}
final class LD_nn_REG : Strategy {
    private Reg reg;
    this(Reg reg) { this.reg = reg; }
    /**
     * ld (nn), register
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto addr = cpu.fetchWord();
        if(is8Bit(reg)) {
            cpu.writeByte(addr, s.getReg8(reg));
        } else {
            cpu.writeWord(addr, s.getReg16(reg));
        }
    }
}
final class LD_REG_nn : Strategy {
    private Reg reg;
    private bool indirect;
    this(Reg reg, bool indirect) {
        this.reg = reg;
        this.indirect = indirect;
    }
    /**
     * ld register, (nn)        // indirect = true
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto addr = cpu.fetchWord();

        if(!indirect) todo("fixme");

        if(is8Bit(reg)) {
            s.setReg8(reg, cpu.readByte(addr));
        } else {
            s.setReg16(reg, cpu.readWord(addr));
        }
    }
}
final class INCr : Strategy {
    /**
     * 00rrr100
     * 00000100 inc b    04
     * 00001100 inc c    0c
     * 00010100 inc d    14
     * 00011100 inc e    1c
     * 00100100 inc h    24
     * 00101100 inc l    2c
     * 00110100 inc (hl) 34
     * 00111100 inc a    3c
     *
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.byte1 >>> 3) & 7;
        ubyte before;
        switch(bits) {
            case 0: before = s.B; s.B((s.B+1).as!ubyte); break;
            case 1: before = s.C; s.C((s.C+1).as!ubyte); break;
            case 2: before = s.D; s.D((s.D+1).as!ubyte); break;
            case 3: before = s.E; s.E((s.E+1).as!ubyte); break;
            case 4: before = s.H; s.H((s.H+1).as!ubyte); break;
            case 5: before = s.L; s.L((s.L+1).as!ubyte); break;
            case 6:
                auto value = cpu.readByte(s.HL);
                before = value;
                cpu.writeByte(s.HL, (value+1).as!ubyte);
                break;
            case 7: before = s.A; s.A((s.A+1).as!ubyte); break;
            default: break;
        }
        s.flagN(false);
        s.flagPV(before==0x7f);
        s.flagH((before&0xf) == 0xf);
        s.flagZ(before==0xff);
        s.flagS((before+1).isNeg());
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
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.byte1 >>> 3) & 7;
        ubyte before;
        switch(bits) {
            case 0: before = s.B; s.B((s.B-1).as!ubyte); break;
            case 1: before = s.C; s.C((s.C-1).as!ubyte); break;
            case 2: before = s.D; s.D((s.D-1).as!ubyte); break;
            case 3: before = s.E; s.E((s.E-1).as!ubyte); break;
            case 4: before = s.H; s.H((s.H-1).as!ubyte); break;
            case 5: before = s.L; s.L((s.L-1).as!ubyte); break;
            case 6:
                auto value = cpu.readByte(s.HL);
                before = value;
                cpu.writeByte(s.HL, (value-1).as!ubyte);
                break;
            case 7: before = s.A; s.A((s.A-1).as!ubyte); break;
            default: break;
        }
        s.flagS((before-1).isNeg());
        s.flagZ(before==1);
        s.flagH((before&0xf0)==0xf0);
        s.flagPV(before==0x80);
        s.flagN(true);
    }
}
final class INCss : Strategy {
    /**
     *  00ss0011
     *    00     inc bc     03
     *    01     inc de     13
     *    10     inc hl     23
     *    11     inc sp     33
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.byte1 >>> 4) & 3;
        switch(bits) {
            case 0: s.BC++; break;
            case 1: s.DE++; break;
            case 2: s.HL++; break;
            case 3: s.SP++; break;
            default: break;
        }
    }
}
// final class INC_REG : Strategy {
//     private Reg reg;
//     bool indirect;
//     this(Reg reg, bool indirect) {
//         this.reg = reg;
//         this.indirect = indirect;
//     }
//     /**
//      * inc (reg16)   // indirect = true
//      * inc reg16     // indirect = false
//      *
//      * Flags: None
//      */
//     override void execute(Z80 cpu, Op op) const {
//         auto s = cpu.state;
//         auto r = s.getReg16(reg);
//         if(indirect) {
//             // inc byte
//             auto value = (cpu.readByte(r) + 1).as!ubyte;
//             cpu.writeByte(r, value);

//             s.flagS(value.isNeg());
//             s.flagZ(value==0);
//             s.flagH(value==0x10); // check this
//             s.flagN(false);
//         } else {
//             s.setReg16(reg, (r+1).as!ushort);
//         }
//     }
// }
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
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.byte1 >>> 4) & 3;
        switch(bits) {
            case 0: s.BC--; break;
            case 1: s.DE--; break;
            case 2: s.HL--; break;
            case 3: s.SP--; break;
            default: break;
        }
    }
}
final class RLA : Strategy {
    /**
     * Roll A left 1 bit
     * Copy sign bit to carry flag and carry to bit 0
     *
     * Flags: C,H,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bit7 = isBitSet(s.A, 7);
        s.A = ((s.A<<1) | s.flagC() ? 1 : 0).as!ubyte;
        s.flagH(false);
        s.flagN(false);
        s.flagC(bit7);
    }
}
final class RRA : Strategy {
    /**
     * Roll A right 1 bit
     * Copy 0 bit to carry flag and carry to bit 0
     *
     * Flags: C,H,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bit0 = isBitSet(s.A, 0);
        s.A = ((s.A>>>1) | s.flagC() ? 0x80 : 0).as!ubyte;
        s.flagH(false);
        s.flagN(false);
        s.flagC(bit0);
    }
}
final class RLCA : Strategy {
    /**
     * Roll A left 1 bit
     * Copy sign bit to carry flag and also to bit 0
     *
     * Flags: C,H,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bit7 = isBitSet(s.A, 7);
        s.A = ((s.A<<1) | bit7 ? 1 : 0).as!ubyte;
        s.flagH(false);
        s.flagN(false);
        s.flagC(bit7);
    }
}
final class RRCA : Strategy {
    /**
     * Roll A right 1 bit
     * Copy bit 0 to carry flag and also to bit 7
     *
     * Flags: C,H,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bit0 = isBitSet(s.A, 0);
        s.A = ((s.A>>>1) | bit0 ? 0x80 : 0).as!ubyte;
        s.flagH(false);
        s.flagN(false);
        s.flagC(bit0);
    }
}
final class EXaf : Strategy {
    /**
     * Exchange AF, AF'
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
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
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.byte1 >>> 4) &  3;
        ushort before = s.HL;
        switch(bits) {
            case 0: s.HL = (s.HL + s.BC).as!ushort; break;
            case 1: s.HL = (s.HL + s.DE).as!ushort; break;
            case 2: s.HL = (s.HL + s.HL).as!ushort; break;
            case 3: s.HL = (s.HL + s.SP).as!ushort; break;
            default: break;
        }
        s.flagH((before<=0xfff && s.HL > 0xfff));
        s.flagN(false);
    }
}
/** All branches use displacement-2 eg. (-126 to +129) */
enum BranchType {
    JR,     // jr e
    DJNZ,   // djnz e
    NZ,     // jr nz, e
    Z,      // jr z, e
    NC,     // jr nc, e
    C,      // jr c, e
}
final class JRe : Strategy {
    BranchType type;
    this(BranchType type) {
        this.type = type;
    }
    /**
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        byte e = cpu.fetchByte();
        bool taken;
        final switch(type) with(BranchType) {
            case JR: taken = true; break;
            case DJNZ:
                s.B = (s.B-1).as!ubyte;
                taken = s.B!=0;
                break;
            case NZ:
                taken = !s.flagZ();
                break;
            case Z:
                taken = s.flagZ();
                break;
            case NC:
                taken = !s.flagC();
                break;
            case C:
                taken = s.flagC();
                break;

        }
        if(taken) {
            s.PC = ((s.PC).as!short + e).as!ushort;
        }
    }
}
final class DAA : Strategy {
    /**
     * daa
     *
     * Conditionally adjust A for BCD add/subtract.
     *
     * Flags: todo
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        todo();
    }
}
final class CPL : Strategy {
    /**
     * cpl
     *
     * Invert A
     *
     * Flags: H,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        s.A = (~(s.A).as!int).as!ubyte;
        s.flagH(true);
        s.flagN(true);
    }
}
final class CF : Strategy {
    private bool set;
    this(bool set) {
        this.set = set;
    }
    /**
     * scf
     * ccf
     *
     * Set/invert carry flag
     *
     * Flags: C,H,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        if(set) {
            s.flagC(true);
            s.flagH(false);
        } else {
            bool prevC = s.flagC();
            s.flagC(!prevC);
            s.flagH(prevC);
        }
        s.flagN(false);
    }
}
