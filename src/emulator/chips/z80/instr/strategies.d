module emulator.chips.z80.instr.strategies;

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

__gshared immutable Reg[8] REGS = [Reg.B, Reg.C, Reg.D, Reg.E, Reg.H, Reg.L, Reg.HL, Reg.A];

abstract class Strategy {
    void execute(Z80 cpu, Op op) const;
}

__gshared const {
    Strategy _nop       = new Nop();
    Strategy _ldddnn    = new LD_dd_nn();
    Strategy _ldrn      = new LD_r_n();
    Strategy _ldrr      = new LD_r_r();     // 8-bit load group
    Strategy _ldbca     = new LD_BC_A();
    Strategy _lddea     = new LD_DE_A();
    Strategy _ldabc     = new LD_A_BC();
    Strategy _ldade     = new LD_A_DE();
    Strategy _ldsphl    = new LD_SP_HL();
    Strategy _ldnnhl    = new LD_nn_REG(Reg.HL);
    Strategy _ldnna     = new LD_nn_REG(Reg.A);
    Strategy _ldhlnn    = new LD_REG_nn(Reg.HL, true);
    Strategy _ldann     = new LD_REG_nn(Reg.A, true);

    Strategy _algar     = new ALG_a_r();    // Arithmetic and Logic group
    Strategy _addhlss   = new ADD_HLss();
    Strategy _addan     = new ADD_a_n();
    Strategy _adcan     = new ADC_a_n();
    Strategy _suban     = new SUB_a_n();
    Strategy _sbcan     = new SBC_a_n();
    Strategy _andan     = new AND_a_n();
    Strategy _xoran     = new XOR_a_n();
    Strategy _oran      = new OR_a_n();
    Strategy _cpan      = new CP_a_n();

    Strategy _incss     = new INCss();
    Strategy _decss     = new DECss();
    Strategy _incr      = new INCr();
    Strategy _decr      = new DECr();
    Strategy _rla       = new RLA();
    Strategy _rra       = new RRA();
    Strategy _rlca      = new RLCA();
    Strategy _rrca      = new RRCA();
    Strategy _exaf      = new EXaf();
    Strategy _daa       = new DAA();
    Strategy _cpl       = new CPL();
    Strategy _di        = new DI();
    Strategy _ei        = new EI();
    Strategy _exx       = new EXX();
    Strategy _scf       = new CF(true);
    Strategy _ccf       = new CF(false);
    Strategy _halt      = new HALT();
    Strategy _popqq     = new POPqq();
    Strategy _pushqq    = new PUSHqq();
    Strategy _rstp      = new RSTp();
    Strategy _exsphl    = new EX_SP_HL();
    Strategy _exdehl    = new EX_DE_HL();

    Strategy _jre       = new JRe(BranchType.JR);
    Strategy _jrnze     = new JRe(BranchType.NZ);
    Strategy _jrze      = new JRe(BranchType.Z);
    Strategy _jrnce     = new JRe(BranchType.NC);
    Strategy _jrce      = new JRe(BranchType.C);
    Strategy _djnze     = new JRe(BranchType.DJNZ);

    Strategy _jpccnn    = new JPccnn();
    Strategy _jpnn      = new JPnn();
    Strategy _jphl      = new JP_HL();

    Strategy _callnn    = new CALLnn();
    Strategy _callccnn  = new CALLccnn();

    Strategy _ret       = new RET();
    Strategy _retcc     = new RETcc();

    Strategy _outna     = new OUT_n_a();
    Strategy _inan      = new IN_a_n();
}

private:

final class Nop : Strategy {
    /**
     *  Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        // do nothing for 4 clocks
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
     *   110    lh (hl),    36 ; ld (ix+d), n ; ld (iy+d), n
     *   111    ld a        3e
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        ubyte value = cpu.fetchByte();
        auto bits = (op.code >>> 3) & 7;
        switch(bits) {
            case 0: s.B = value; break;
            case 1: s.C = value; break;
            case 2: s.D = value; break;
            case 3: s.E = value; break;
            case 4: s.H = value; break;
            case 5: s.L = value; break;
            case 6:
                cpu.writeByte(getHLIXdIYd(cpu, op), value);
                break;
            case 7: s.A = value; break;
            default: break;
        }
    }
}
/** 8-bit Load Group */
final class LD_r_r : Strategy {
    /**
     * 40 - 7f (excluding 76)
     * 01dddsss
     *
     * ld b,b       40      01 000 000
     * ld b,c       41      01 000 001
     * ld b,d       42      01 000 010
     * ld b,e       43      01 000 011
     * ld b,h       44      01 000 100
     * ld b,l       45      01 000 101
     * ld b, (hl)   46      01 000 110  ld b, (ix+d) ; ld b, (iy+d)
     * ld b,a       47      01 000 111
     *
     * ld c,b       48      01 001 000
     * ld c,c       49      01 001 001
     * ld c,d       4a      01 001 010
     * ld c,e       4b      01 001 011
     * ld c,h       4c      01 001 100
     * ld c,l       4d      01 001 101
     * ld c,(hl)    4e      01 001 110  ld c, (ix+d) ; ld c, (iy+d)
     * ld c,a       4f      01 001 111
     *
     * ld d,b       50      01 010 000
     * ld d,c       51      01 010 001
     * ld d,d       52      01 010 010
     * ld d,e       53      01 010 011
     * ld d,h       54      01 010 100
     * ld d,l       55      01 010 101
     * ld d,(hl)    56      01 010 110  ld d, (ix+d) ; ld d, (iy+d)
     * ld d,a       57      01 010 111
     *
     * ld e,b       58      01 011 000
     * ld e,c       59      01 011 001
     * ld e,d       5a      01 011 010
     * ld e,e       5b      01 011 011
     * ld e,h       5c      01 011 100
     * ld e,l       5d      01 011 101
     * ld e,(hl)    5e      01 011 110  ld e, (ix+d) ; ld e, (iy+d)
     * ld e,a       5f      01 011 111
     *
     * ld h,b       60      01 100 000
     * ld h,c       61      01 100 001
     * ld h,d       62      01 100 010
     * ld h,e       63      01 100 011
     * ld h,h       64      01 100 100
     * ld h,l       65      01 100 101
     * ld h,(hl)    66      01 100 110  ld h, (ix+d) ; ld h, (iy+d)
     * ld h,a       67      01 100 111
     *
     * ld l,b       68      01 101 000
     * ld l,c       69      01 101 001
     * ld l,d       6a      01 101 010
     * ld l,e       6b      01 101 011
     * ld l,h       6c      01 101 100
     * ld l,l       6d      01 101 101
     * ld l,(hl)    6e      01 101 110  ld l, (ix+d) ; ld l, (iy+d)
     * ld l,a       6f      01 101 111
     *
     * ld (hl),b    70      01 110 000  ld (ix+d), b ; ld (iy+d), b
     * ld (hl),c    71      01 110 001  ld (ix+d), c ; ld (iy+d), c
     * ld (hl),d    72      01 110 010  ld (ix+d), d ; ld (iy+d), d
     * ld (hl),e    73      01 110 011  ld (ix+d), e ; ld (iy+d), e
     * ld (hl),h    74      01 110 100  ld (ix+d), h ; ld (iy+d), h
     * ld (hl),l    75      01 110 101  ld (ix+d), l ; ld (iy+d), l
     * halt         76
     * ld (hl),a    77      01 110 111  ld (ix+d), a ; ld (iy+d), a
     *
     * ld a,b       78      01 111 000
     * ld a,c       79      01 111 001
     * ld a,d       7a      01 111 010
     * ld a,e       7b      01 111 011
     * ld a,h       7c      01 111 100
     * ld a,l       7d      01 111 101
     * ld a,(hl)    7e      01 111 110  ld a, (ix+d) ; ld a, (iy+d)
     * ld a,a       7f      01 111 111
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto src  = op.code & 7;
        auto dest = (op.code >>> 3) & 7;
        auto srcReg = REGS[src];
        auto destReg = REGS[dest];

        if(destReg==Reg.HL) {
            auto addr = getHLIXdIYd(cpu, op);
            cpu.writeWord(addr, s.getReg8(srcReg));
        } else if(srcReg==Reg.HL) {
            auto addr = getHLIXdIYd(cpu, op);
            s.setReg8(destReg, cpu.readByte(addr));
        } else {
            s.setReg8(destReg, s.getReg8(srcReg));
        }
    }
}
/** 8-bit Arithmetic and Logic Group */
final class ALG_a_r : Strategy {
    /**
     *              10cccrrr
     * add 80-87    10000
     * adc 88-8f    10001
     * sub 90-97    10010
     * sbc 98-9f    10011
     * and a0-a7    10100
     * xor a8-af    10101
     * or  b0-b7    10110
     * cp  b8-bf    10111
     */
    override void execute(Z80 cpu, Op op) const {
        auto s      = cpu.state;
        auto rrr    = REGS[op.code & 7];
        auto ccc    = (op.code>>>3) & 7;
        auto src    = rrr==Reg.HL ? cpu.readByte(getHLIXdIYd(cpu, op))
                                  : s.getReg8(rrr);
        auto before = s.A;
        auto c      = s.flagC() ? 1 : 0;
        uint after;

        switch(ccc) {
            case 0:
                // add (4 clocks)
                after = s.A + src;
                s.A = after.as!ubyte;
                s.updateS(s.A);
                s.updateZ(s.A);
                s.updateH(before, src, after);
                s.updateV(before, src, after);
                s.flagN(false);
                s.flagC(after > 0xff);
                break;
            case 1:
                // adc (4 clocks)
                after = s.A + src + c;
                s.A = after.as!ubyte;
                s.updateS(s.A);
                s.updateZ(s.A);
                s.updateH(before, src+c, after);
                s.updateV(before, src+c, after);
                s.flagN(false);
                s.flagC(after > 0xff);
                break;
            case 2:
                // sub (4 clocks)
                after = s.A - src;
                s.A = after.as!ubyte;
                s.updateS(s.A);
                s.updateZ(s.A);
                s.updateH(before, src, after);
                s.updateV(before, src, after);
                s.flagN(true);
                s.flagC(after > 0xff);
                break;
            case 3:
                // sbc (4 clocks)
                after = s.A - src - c;
                s.A = after.as!ubyte;
                s.updateS(s.A);
                s.updateZ(s.A);
                s.updateH(before, src+c, after);
                s.updateV(before, src+c, after);
                s.flagN(true);
                s.flagC(after > 0xff);
                break;
            case 4:
                // and (4 clocks)
                s.A = (s.A & src).as!ubyte;
                s.updateS(s.A);
                s.updateZ(s.A);
                s.flagH(true);
                s.updateP(s.A);
                s.flagN(false);
                s.flagC(false);
                break;
            case 5:
                // xor (4 clocks)
                s.A = (s.A ^ src).as!ubyte;
                s.updateS(s.A);
                s.updateZ(s.A);
                s.flagH(false);
                s.updateP(s.A);
                s.flagN(false);
                s.flagC(false);
                break;
            case 6:
                // or (4 clocks)
                s.A = (s.A | src).as!ubyte;
                s.updateS(s.A);
                s.updateZ(s.A);
                s.flagH(false);
                s.updateP(s.A);
                s.flagN(false);
                s.flagC(false);
                break;
            default:
                // cp (4 clocks)
                after = s.A - src;
                ubyte a = after.as!ubyte;
                s.updateS(a);
                s.updateZ(a);
                s.updateH(s.A, src, after);
                s.updateV(s.A, src, after);
                s.flagN(true);
                s.flagC(after > 0xff);
                break;
        }
    }
}
final class LD_dd_nn : Strategy {
    /**
     * 00dd0001
     * 00000001 ld bc, nn
     * 00010001 ld de, nn
     * 00100001 ld hl, nn ; ld ix, nn ; ld iy, nn
     * 00110001 ld sp, nn
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.code >>> 4) & 3;
        auto value = cpu.fetchWord();

        switch(bits) {
            case 0: s.BC = value; break;
            case 1: s.DE = value; break;
            case 2: s.setReg16(op.indexReg, value); break;
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
final class LD_SP_HL : Strategy {
    /**
     * ld sp, hl
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 6 clocks
        s.SP = s.getReg16(op.indexReg);
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
            // HL, IX, IY
            auto r = reg==Reg.HL ? op.indexReg : reg;

            cpu.writeWord(addr, s.getReg16(r));
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
            // HL, IX, IY
            auto r = reg==Reg.HL ? op.indexReg : reg;

            s.setReg16(r, cpu.readWord(addr));
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
     * 00110100 inc (hl) 34 ; inc (ix+d); inc (iy+d)
     * 00111100 inc a    3c
     *
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.code >>> 3) & 7;
        ubyte before;
        switch(bits) {
            case 0: before = s.B; s.B((s.B+1).as!ubyte); break;
            case 1: before = s.C; s.C((s.C+1).as!ubyte); break;
            case 2: before = s.D; s.D((s.D+1).as!ubyte); break;
            case 3: before = s.E; s.E((s.E+1).as!ubyte); break;
            case 4: before = s.H; s.H((s.H+1).as!ubyte); break;
            case 5: before = s.L; s.L((s.L+1).as!ubyte); break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                auto value = before = cpu.readByte(addr);
                cpu.writeByte(addr, (value+1).as!ubyte);
                break;
            case 7: before = s.A; s.A((s.A+1).as!ubyte); break;
            default: break;
        }
        s.flagN(false);
        s.flagPV(before==0x7f);
        s.flagH((before&0xf)==0xf);
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
     * 00110101 dec (hl) 35 ; dec (ix+d) ; dec (iy+d)
     * 00111101 dec a    3d
     *
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.code >>> 3) & 7;
        ubyte before;
        switch(bits) {
            case 0: before = s.B; s.B((s.B-1).as!ubyte); break;
            case 1: before = s.C; s.C((s.C-1).as!ubyte); break;
            case 2: before = s.D; s.D((s.D-1).as!ubyte); break;
            case 3: before = s.E; s.E((s.E-1).as!ubyte); break;
            case 4: before = s.H; s.H((s.H-1).as!ubyte); break;
            case 5: before = s.L; s.L((s.L-1).as!ubyte); break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                auto value = before = cpu.readByte(addr);
                cpu.writeByte(addr, (value-1).as!ubyte);
                break;
            case 7: before = s.A; s.A((s.A-1).as!ubyte); break;
            default: break;
        }
        s.flagS((before-1).isNeg());
        s.flagZ(before==1);
        s.flagH((before&0xf)==0);
        s.flagPV(before==0x80);
        s.flagN(true);
    }
}
final class INCss : Strategy {
    /**
     *  00ss0011
     *    00     inc bc     03
     *    01     inc de     13
     *    10     inc hl     23 ; inc ix; inc iy
     *    11     inc sp     33
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.code >>> 4) & 3;
        switch(bits) {
            case 0: s.BC++; break;
            case 1: s.DE++; break;
            case 2:
                ushort old = s.getReg16(op.indexReg);
                s.setReg16(op.indexReg, (old+1).as!ushort);
                break;
            case 3: s.SP++; break;
            default: break;
        }
    }
}
final class DECss : Strategy {
    /**
     *  00ss1011
     *    00     dec bc     0b
     *    01     dec de     1b
     *    10     dec hl     2b  ; dec ix; dec iy
     *    11     dec sp     3b
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.code >>> 4) & 3;
        switch(bits) {
            case 0: s.BC--; break;
            case 1: s.DE--; break;
            case 2:
                ushort old = s.getReg16(op.indexReg);
                s.setReg16(op.indexReg, (old-1).as!ushort);
                break;
            case 3: s.SP--; break;
            default: break;
        }
    }
}
final class RLA : Strategy {
    /**
     * Roll A left 1 bit
     * Copy bit 7 to carry flag and carry to bit 0
     *
     * Flags: C,H,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bit7 = isBitSet(s.A, 7);
        s.A = ((s.A<<1) | (s.flagC() ? 1 : 0)).as!ubyte;
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
        s.A = ((s.A>>>1) | (s.flagC() ? 0x80 : 0)).as!ubyte;
        s.flagH(false);
        s.flagN(false);
        s.flagC(bit0);
    }
}
final class RLCA : Strategy {
    /**
     * Roll A left 1 bit
     * Copy bit 7 to carry flag and also to bit 0
     *
     * Flags: C,H,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bit7 = isBitSet(s.A, 7);
        s.A = ((s.A<<1) | (bit7 ? 1 : 0)).as!ubyte;
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
        s.A = ((s.A>>>1) | (bit0 ? 0x80 : 0)).as!ubyte;
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

        s.exchangeWithShadow(Reg.AF);
    }
}
final class ADD_HLss : Strategy {
    /**
     *  00ss1001
     *    00    add hl, bc      09  ; add ix, bc ; add iy, bc
     *    01    add hl, de      19  ; add ix, de ; add iy, de
     *    10    add hl, hl      29  ; add ix, ix ; add iy, iy
     *    11    add hl, sp      39  ; add ix, sp ; add iy, sp
     *
     * Flags: N,H
     */
    override void execute(Z80 cpu, Op op) const {
        auto s    = cpu.state;
        auto bits = (op.code >>> 4) &  3;
        auto reg  = op.indexReg;
        ushort left = s.getReg16(reg);
        ushort right;

        switch(bits) {
            case 0: right = s.BC; break;
            case 1: right = s.DE; break;
            case 2: right = left; break;
            case 3: right = s.SP; break;
            default: break;
        }

        uint result = left + right;

        s.setReg16(reg, result.as!ushort);

        s.updateH16(left, right, result);
        s.flagN(false);
    }
}
final class ADD_a_n : Strategy {
    /**
     *
     * Flags:
     */
    override void execute(Z80 cpu, Op op) const {
        auto s       = cpu.state;
        ubyte n      = cpu.fetchByte();
        ubyte before = s.A;
        uint after   = s.A + n;

        s.A = after.as!ubyte;

        s.updateS(s.A);
        s.updateZ(s.A);
        s.updateH(before, n, after);
        s.updateV(before, n, after);
        s.flagN(false);
        s.flagC(after > 0xff);
    }
}
final class ADC_a_n : Strategy {
    /**
     *
     * Flags:
     */
    override void execute(Z80 cpu, Op op) const {
        auto s       = cpu.state;
        ubyte n      = cpu.fetchByte();
        ubyte before = s.A;
        ubyte c      = s.flagC() ? 1 : 0;
        uint after   = s.A + n + c;

        // (7 clocks)

        s.A = after.as!ubyte;

        s.updateS(s.A);
        s.updateZ(s.A);
        s.updateH(before, n+c, after);
        s.updateV(before, n+c, after);
        s.flagN(false);
        s.flagC(after > 0xff);
    }
}
final class SUB_a_n : Strategy {
    /**
     *
     * Flags:
     */
    override void execute(Z80 cpu, Op op) const {
        auto s       = cpu.state;
        ubyte n      = cpu.fetchByte();
        ubyte before = s.A;
        uint after   = s.A - n;

        // (7 clocks)

        s.A = after.as!ubyte;

        s.updateS(s.A);
        s.updateZ(s.A);
        s.updateH(before, n, after);
        s.updateV(before, n, after);
        s.flagN(true);
        s.flagC(after > 0xff);
    }
}
final class SBC_a_n : Strategy {
    /**
     *
     * Flags:
     */
    override void execute(Z80 cpu, Op op) const {
        auto s       = cpu.state;
        ubyte n      = cpu.fetchByte();
        ubyte c      = s.flagC() ? 1 : 0;
        ubyte before = s.A;
        uint after   = before - n - c;

        // (7 clocks)

        s.A = after.as!ubyte;

        s.updateS(s.A);
        s.updateZ(s.A);
        s.updateH(before, n+c, after);
        s.updateV(before, n+c, after);
        s.flagN(true);
        s.flagC(after > 0xff);
    }
}
final class AND_a_n : Strategy {
    /**
     *
     * Flags:
     */
    override void execute(Z80 cpu, Op op) const {
        auto s       = cpu.state;
        ubyte n      = cpu.fetchByte();
        ubyte before = s.A;
        uint after   = before & n;

        // (7 clocks)

        s.A = after.as!ubyte;

        s.updateS(s.A);
        s.updateZ(s.A);
        s.flagH(true);
        s.updateP(s.A);
        s.flagN(false);
        s.flagC(false);
    }
}
final class XOR_a_n : Strategy {
    /**
     *
     * Flags:
     */
    override void execute(Z80 cpu, Op op) const {
        auto s       = cpu.state;
        ubyte n      = cpu.fetchByte();
        ubyte before = s.A;

        // (7 clocks)

        s.A = (s.A ^ n).as!ubyte;

        s.updateS(s.A);
        s.updateZ(s.A);
        s.flagH(false);
        s.updateP(s.A);
        s.flagN(false);
        s.flagC(false);
    }
}
final class OR_a_n : Strategy {
    /**
     *
     * Flags:
     */
    override void execute(Z80 cpu, Op op) const {
        auto s       = cpu.state;
        ubyte n      = cpu.fetchByte();
        ubyte before = s.A;

        // (7 clocks)

        s.A = (s.A | n).as!ubyte;

        s.updateS(s.A);
        s.updateZ(s.A);
        s.flagH(false);
        s.updateP(s.A);
        s.flagN(false);
        s.flagC(false);
    }
}
final class CP_a_n : Strategy {
    /**
     *
     * Flags:
     */
    override void execute(Z80 cpu, Op op) const {
        auto s       = cpu.state;
        ubyte n      = cpu.fetchByte();

        // (7 clocks)

        uint result = s.A - n;
        ubyte a = result.as!ubyte;

        s.updateS(a);
        s.updateZ(a);
        s.updateH(s.A, n, result);
        s.updateV(s.A, n, result);
        s.flagN(true);
        s.flagC(result > 0xff);
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
            case JR:
                taken = true;
                break;
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
            s.PC = ((s.PC-2).as!short + e).as!ushort;
        }
    }
}
final class JPccnn : Strategy {
    /**
     * 11ccc010
     *
     *   000 nz     c2
     *   001 z      ca
     *   010 nc     d2
     *   011 c      da
     *   100 po     e2
     *   101 pe     ea
     *   110 p      f2
     *   111 m      fa
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s     = cpu.state;
        auto cc    = (op.code>>>3) & 7;
        ushort nn  = cpu.fetchWord();
        bool taken = jumpTaken(s, cc);

        if(taken) {
            // (10 clocks)
            s.PC = nn;
        } else {
            // (10 clocks)
        }
    }
}
final class CALLnn : Strategy {
    /**
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s     = cpu.state;
        ushort nn  = cpu.fetchWord();

        // (17 clocks)
        cpu.pushWord(s.PC-3);
        s.PC = nn;
    }
}
final class CALLccnn : Strategy {
    /**
     * 11ccc100
     *
     *   000 nz     c4
     *   001 z      cc
     *   010 nc     d4
     *   011 c      dc
     *   100 po     e4
     *   101 pe     ec
     *   110 p      f4
     *   111 m      fc
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s     = cpu.state;
        auto cc    = (op.code>>>3) & 7;
        ushort nn  = cpu.fetchWord();
        bool taken = jumpTaken(s, cc);

        if(taken) {
            // (17 clocks)
            cpu.pushWord(s.PC);
            s.PC = nn;
        } else {
            // (10 clocks)
        }
    }
}
final class JPnn : Strategy {
    /**
     * jp nn
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s    = cpu.state;
        ushort nn = cpu.fetchWord();

        // (10 clocks)
        s.PC = nn;
    }
}
final class JP_HL : Strategy {
    /**
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto addr = cpu.readWord(s.getReg16(op.indexReg));

        // 4 clocks (hl)
        // 8 clocks (ix) or (iy)

        // CHECK - does this use displacement?

        s.PC = addr;
    }
}

final class RET : Strategy {
    /**
     * ret
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // (10 cycles)
        s.PC = cpu.popWord();
    }
}
final class RETcc : Strategy {
    /**
     * ret cc
     *
     * 11ccc000
     *
     *   000 nz     c0
     *   001 z      c8
     *   010 nc     d0
     *   011 c      d8
     *   100 po     e0
     *   101 pe     e8
     *   110 p      f0
     *   111 m      f8
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s      = cpu.state;
        auto cc     = (op.code>>>3) & 7;
        bool taken  = jumpTaken(s, cc);

        if(taken) {
            // (11 cycles)
            s.PC = cpu.popWord();
        } else {
            // (5 cycles)
        }
    }
}
final class DAA : Strategy {
    /**
     * daa
     *
     * Conditionally adjust A for BCD add/subtract.
     *
     * Flags: S, Z, H, C, PV
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        auto c = s.flagC();
        auto h = s.flagH();
        auto n = s.flagN();
        auto ah = s.A>>>4;
        auto al = s.A&0xf;
        auto add = 0;

        if(al > 0x9 || h) {
            add += 0x06;
        }
        if(ah > 0x9 || c) {
            add += 0x60;
        }
        if(n) {
            s.A = (s.A - add).as!ubyte;
        } else {
            s.A = (s.A + add).as!ubyte;
        }

        if(c || ah > 9) {
            s.flagC(true);
        }
        if(n && h) {
            s.flagH(al < 0x06);
        } else {
            s.flagH(al > 0x09);
        }

        s.updateS(s.A);
        s.updateZ(s.A);
        s.updateP(s.A);
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
final class DI : Strategy {
    /**
     * di
     *
     * Disables maskable interrupt
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        s.IFF1 = false;
        s.IFF2 = false;
    }
}
final class EI : Strategy {
    /**
     * ei
     *
     * Enabled maskable interrupt
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        s.IFF1 = true;
        s.IFF2 = true;
    }
}
final class EXX : Strategy {
    /**
     * exx
     *
     * Exchange with shadow regs
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        s.exchangeWithShadow(Reg.BC);
        s.exchangeWithShadow(Reg.DE);
        s.exchangeWithShadow(Reg.HL);
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
final class EX_SP_HL : Strategy {
    /**
     * ex (sp), hl
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 19 clocks

        ushort temp = s.getReg16(op.indexReg);
        s.HL = cpu.readWord(s.SP);
        cpu.writeWord(s.SP, temp);
    }
}
final class EX_DE_HL : Strategy {
    /**
     * ex de, hl
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 4 clocks
        ushort temp = s.DE;
        s.DE = s.HL;
        s.HL = temp;
    }
}
final class HALT : Strategy {
    /**
     * halt
     *
     * Execute nop until an interrupt is received
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        // todo - Check for interrupt
        todo();
    }
}
final class PUSHqq : Strategy {
    /**
     * 11qq0101
     *
     *   00 bc  c5
     *   01 de  d5
     *   10 hl  e5
     *   11 af  f5
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s  = cpu.state;
        auto qq = (op.code>>>4) & 3;
        ushort value;

        switch(qq) {
            case 0: value = s.BC; break;
            case 1: value = s.DE; break;
            case 2: value = s.getReg16(op.indexReg); break;
            default: value = s.AF; break;
        }
        cpu.pushWord(value);
    }
}
final class POPqq : Strategy {
    /**
     * 11qq0001
     *
     *   00 bc  c1
     *   01 de  d1
     *   10 hl  e1
     *   11 af  f1
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s  = cpu.state;
        auto qq = (op.code>>>4) & 3;
        ushort value = cpu.popWord();

        switch(qq) {
            case 0: s.BC = value; break;
            case 1: s.DE = value; break;
            case 2:
                s.setReg16(op.indexReg, value);
                break;
            default: s.AF = value; break;
        }
    }
}
final class RSTp : Strategy {
    /**
     * 11ttt111
     *
     *   000 00     c7
     *   001 08     cf
     *   010 10     d7
     *   011 18     df
     *   100 20     e7
     *   101 28     ef
     *   110 30     f7
     *   111 38     ff
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto p = (op.code>>>3) & 7;

        // 11 cycles

        cpu.pushWord(s.PC);
        s.PC = (p*8).as!ushort;
    }
}
final class IN_a_n : Strategy {
    /**
     * in a, (n)
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s  = cpu.state;
        ubyte n = cpu.fetchByte();

        s.A = cpu.readPort(n);
    }
}
final class OUT_n_a : Strategy {
    /**
     * out(n), a
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s  = cpu.state;
        ubyte n = cpu.fetchByte();

        cpu.writePort(n, s.A);
    }
}

/**
 * 000 nz
 * 001 z
 * 010 nc
 * 011 c
 * 100 po
 * 101 pe
 * 110 p
 * 111 m
 */
bool jumpTaken(State s, uint cc) {
    switch(cc) {
        case 0: return !s.flagZ();
        case 1: return s.flagZ();
        case 2: return !s.flagC();
        case 3: return s.flagC();
        case 4: return !s.flagPV();
        case 5: return s.flagPV();
        case 6: return !s.flagS();
        default: return s.flagS();
    }
    assert(false);
}
