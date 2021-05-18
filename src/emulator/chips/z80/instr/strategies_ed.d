module emulator.chips.z80.instr.strategies_ed;

import emulator.chips.z80.all;

__gshared const {
    Strategy _inrc      = new IN_r_C();
    Strategy _outcr     = new OUT_C_r();
    Strategy _sbchlss   = new SBC_HL_ss();
    Strategy _adchhss   = new ADC_HL_ss();
    Strategy _ldnndd    = new LD_nn_dd();
    Strategy _neg       = new NEG();
    Strategy _im        = new IM();
    Strategy _reti      = new RETI();
    Strategy _retn      = new RETN();
    Strategy _ldia      = new LD_i_a();
    Strategy _ldai      = new LD_a_i();
    Strategy _ldra      = new LD_R_a();
    Strategy _ldar      = new LD_a_R();
    Strategy _ldddnni   = new LD_dd_nn_indirect();
    Strategy _rrd       = new RRD();
    Strategy _rld       = new RLD();
    Strategy _ldi       = new LDI();
    Strategy _cpi       = new CPI();
    Strategy _ini       = new INI();
    Strategy _outi      = new OUTI();
    Strategy _ind       = new IND();
    Strategy _indr      = new INDR();
    Strategy _outd      = new OUTD();
    Strategy _otdr      = new OTDR();
    Strategy _ldd       = new LDD();
    Strategy _cpd       = new CPD();
    Strategy _cpdr      = new CPDR();
    Strategy _ldir      = new LDIR();
    Strategy _cpir      = new CPIR();
    Strategy _inir      = new INIR();
    Strategy _otir      = new OTIR();
    Strategy _lddr      = new LDDR();
}

private:

final class IN_r_C : Strategy {
    /**
     * 11101101 ED
     * 01rrr000
     *
     * in b, (c)    ED 40
     * in c, (c)    ED 48
     * in d, (c)    ED 50
     * in e, (c)    ED 58
     * in h, (c)    ED 60
     * in l, (c)    ED 68
     *              ED 70
     * in a, (c)    ED 78
     *
     * Flags: S, Z, PV
     */
    override void execute(Z80 cpu, Op op) const {
        auto s   = cpu.state;
        auto rrr = (op.byte2>>>3) & 7;
        auto reg = REGS[rrr];

        // 12 clocks

        ubyte value = cpu.readPort(s.C);
        s.setReg8(reg, value);

        s.updateS(value);
        s.updateZ(value);
        s.flagH(false);
        s.flagN(false);
        s.updateP(value);
    }
}
final class OUT_C_r : Strategy {
    /**
     * 11101101 ED
     * 01rrr001
     *
     * out (c), b,     ED 41
     * out (c), c,     ED 49
     * out (c), d,     ED 51
     * out (c), e,     ED 59
     * out (c), h,     ED 61
     * out (c), l,     ED 69
     *                 ED 71
     * out (c), a      ED 79
     *
     * Flags:
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto rrr = (op.byte2>>>3) & 7;
        auto reg = REGS[rrr];

        // 12 clocks

        ubyte value = s.getReg8(reg);
        cpu.writePort(state.C, value);
    }
}
final class ADC_HL_ss : Strategy {
    /**
     *  11101101 ED
     *  01ss1010
     *
     *    00 BC -> 4a
     *    01 DE -> 5a
     *    10 HL -> 6a
     *    11 SP -> 7a
     *
     * Flags: S,Z,H,PV,N,C
     */
    override void execute(Z80 cpu, Op op) const {
        auto s        = cpu.state;
        auto ss       = (op.byte2>>>4) & 3;
        ushort left   = s.HL;
        ushort c      = s.flagC() ? 1 : 0;
        ushort right;

        // 15 clocks

        switch(ss) {
            case 0: right = s.BC; break;
            case 1: right = s.DE; break;
            case 2: right = s.HL; break;
            default: right = s.SP; break;
        }

        uint after = left + right + c;
        state.HL = after.as!ushort;

        s.flagS(state.HL >= 0x8000);
        s.flagZ(state.HL == 0);
        s.updateH16(left, right+c, after);
        s.updateV16(left, right+c, after);
        s.flagN(false);
        s.flagC(after > 0xffff);
    }
}
final class SBC_HL_ss : Strategy {
    /**
     *  11101101 ED
     *  01ss0010
     *
     *    00 BC -> 42
     *    01 DE -> 52
     *    10 HL -> 62
     *    11 SP -> 72
     *
     * Flags: S,Z,H,PV,N,C
     */
    override void execute(Z80 cpu, Op op) const {
        auto s        = cpu.state;
        auto ss       = (op.byte2>>>4) & 3;
        ushort left   = s.HL;
        ushort c      = s.flagC() ? 1 : 0;
        ushort right;

        // 15 clocks

        switch(ss) {
            case 0: right = s.BC; break;
            case 1: right = s.DE; break;
            case 2: right = s.HL; break;
            default: right = s.SP; break;
        }

        uint after = left - right - c;
        s.HL = after.as!ushort;

        s.flagS(s.HL >= 0x8000);
        s.flagZ(s.HL == 0);
        s.updateH16(left, right+c, after);
        s.updateV16(left, right+c, after);
        s.flagN(true);
        s.flagC(after > 0xffff);
    }
}
final class LD_nn_dd : Strategy {
    /**
     * 11101101 ED
     * 01dd0011
     * nnnnnnnn
     * nnnnnnnn
     *
     *   00
     *   01
     *   10
     *   11
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s    = cpu.state;
        auto dd   = (op.byte2>>>4) & 3;
        auto addr = cpu.fetchWord();
        ushort value;
        // 20 clocks

        switch(dd) {
            case 0: value = s.BC; break;
            case 1: value = s.DE; break;
            case 2: value = s.HL; break;
            default: value = s.SP; break;
        }
        cpu.writeWord(addr, value);
    }
}
final class NEG : Strategy {
    /**
     * 11101101 ED
     * 01000100 44
     *
     * neg
     *
     * Flags:
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto before = s.A;
        s.A = (0u-s.A).as!ubyte;

        s.updateS(s.A);
        s.updateZ(s.A);
        s.updateH(before, 0, s.A);
        s.flagPV(before==0x80);
        s.flagN(true);
        s.flagC(before!=0x00);
    }
}
final class IM : Strategy {
    /**
     * 11101101 ED
     * 01000110 46 im 0, 01010110 56 im 1, 01011110 5e
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto mode = op.byte2==0x46 ? 0
                  : op.byte2==0x56 ? 1 : 2;
        // 8 clocks

        // IM 0
        // the interrupting device can insert any instruction on the data bus for
        // execution by the CPU. The first byte of a multi-byte
        // instruction is read during the interrupt acknowledge cycle.
        // Subsequent bytes are read in by a normal memory read sequence.

        // IM 1
        // the processor responds to an interrupt by executing a restart at address 0038h

        // IM 2
        // allows an indirect call
        // to any memory location by an 8-bit vector supplied from the peripheral device. This vector
        // then becomes the least-significant eight bits of the indirect pointer, while the I Register in
        // the CPU provides the most-significant eight bits. This address points to an address in a
        // vector table that is the starting address for the interrupt service routine.
        s.IM = mode;
    }
}
final class RETI : Strategy {
    /**
     * 11101101 ED
     * 01001101 4d
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 14 clocks

        s.IFF1 = s.IFF2;
        s.PC = cpu.popWord();
    }
}
final class RETN : Strategy {
    /**
     * 11101101 ED
     * 01000101 45
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 14 clocks

        s.IFF1 = s.IFF2;
        s.PC = cpu.popWord();
    }
}
final class LD_i_a : Strategy {
    /**
     * 11101101 ED
     * 01000111 47
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 9 clocks

        s.I = s.A;
    }
}
final class LD_a_i : Strategy {
    /**
     * 11101101 ED
     * 01010111 57
     *
     * If an interrupt occurs during execution of this instruction, the parity flag contains a 0
     *
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 9 clocks

        s.A = s.I;

        s.updateS(s.A);
        s.updateZ(s.A);
        s.flagH(false);
        s.flagPV(s.IFF2);
        s.flagN(false);
    }
}
final class LD_R_a : Strategy {
    /**
     * 11101101 ED
     * 01001111 4f
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 9 clocks

        s.R = s.A;
    }
}
final class LD_a_R : Strategy {
    /**
     * 11101101 ED
     * 01011111 5f
     *
     * If an interrupt occurs during execution of this instruction, the parity flag contains a 0
     *
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 9 clocks

        s.A = s.R;

        s.updateS(s.A);
        s.updateZ(s.A);
        s.flagH(false);
        s.flagPV(s.IFF2);
        s.flagN(false);
    }
}
final class RLD : Strategy {
    /**
     * 11101101 ED
     * 01101111 6f
     *
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s       = cpu.state;
        ubyte value  = cpu.readByte(s.HL);
        ubyte before = s.A;

        // 18 clocks

        ubyte H = value & 0xf0;
        ubyte L = value & 0x0f;
        ubyte aH = s.A & 0xf0;
        ubyte aL = s.A & 0x0f;

        ubyte value2 = ((L<<4) | aL).as!ubyte;

        s.A = (aH | (H>>>4)).as!ubyte;

        cpu.writeByte(s.HL, value2);

        s.updateS(s.A);
        s.updateZ(s.A);
        s.flagH(false);
        s.updateP(s.A);
        s.flagN(false);
    }
}
final class RRD : Strategy {
    /**
     * 11101101 ED
     * 01100111 67
     *
     *
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s       = cpu.state;
        ubyte value  = cpu.readByte(s.HL);
        ubyte before = s.A;

        // 18 clocks

        ubyte H = value & 0xf0;
        ubyte L = value & 0x0f;
        ubyte aH = s.A & 0xf0;
        ubyte aL = s.A & 0x0f;

        ubyte value2 = ((aL<<4) | (H>>4)).as!ubyte;

        s.A = (aH | L).as!ubyte;

        cpu.writeByte(s.HL, value2);

        s.updateS(s.A);
        s.updateZ(s.A);
        s.flagH(false);
        s.updateP(s.A);
        s.flagN(false);
    }
}
final class LD_dd_nn_indirect : Strategy {
    /**
     *
     * 11101101 ED
     * 01dd1011
     *   00    ld bc, (nn)      4b
     *   01    ld de, (nn)      5b
     *   10    ld hl, (nn)      6b
     *   11    ld sp, (nn)      7b
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto bits = (op.byte2 >>> 4) & 3;
        auto addr = cpu.fetchWord();
        auto value = cpu.readWord(addr);

        // 20 clocks

        switch(bits) {
            case 0: s.BC = value; break;
            case 1: s.DE = value; break;
            case 2: s.HL = value; break;
            case 3: s.SP = value; break;
            default: break;
        }
    }
}
final class LDI : Strategy {
    /**
     * 11101101 ED
     * 10100000 A0
     *
     * Flags: H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        ubyte b = cpu.readByte(s.HL);
        cpu.writeByte(s.DE, b);

        s.HL = (s.HL+1).as!ushort;
        s.DE = (s.DE+1).as!ushort;
        s.BC = (s.BC-1).as!ushort;

        s.flagH(false);
        s.flagPV(s.BC!=0);
        s.flagN(false);
    }
}
final class CPI : Strategy {
    /**
     * 11101101 ED
     * 10100000 A1
     *
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        ubyte b = cpu.readByte(s.HL);

        uint result = s.A - b;

        s.HL = (s.HL+1).as!ushort;
        s.BC = (s.BC-1).as!ushort;

        s.flagS((result&0x80000000)!=0);
        s.flagZ(s.A==b);
        s.flagH(false);     // set if borrow from bit 4 - FIXME
        s.flagPV(s.BC!=0);
        s.flagN(true);
    }
}
final class CPD : Strategy {
    /**
     * 11101101 ED
     * 10100000 A1
     *
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        ubyte b = cpu.readByte(s.HL);

        uint result = s.A - b;

        s.HL = (s.HL-1).as!ushort;
        s.BC = (s.BC-1).as!ushort;

        s.flagS((result&0x80000000)!=0);
        s.flagZ(s.A==b);
        s.flagH(false);     // set if borrow from bit 4 - FIXME
        s.flagPV(s.BC!=0);
        s.flagN(true);
    }
}
final class CPDR : Strategy {
    /**
     * 11101101 ED
     * 10100000 A1
     *
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        ubyte b = cpu.readByte(s.HL);

        ubyte result = (s.A - b).as!ubyte;

        s.HL = (s.HL-1).as!ushort;
        s.BC = (s.BC-1).as!ushort;

        if(s.A==b && s.BC!=0) {
            // 21 clocks
            s.PC = (s.PC - 2).as!ushort;
        } else {
            // 16 clocks
        }

        s.updateS(result.as!ubyte);
        s.flagZ(s.A==b);
        s.updateH(s.A, b, result);
        s.flagPV(s.BC!=0);
        s.flagN(true);
    }
}
final class LDD : Strategy {
    /**
     * 11101101 ED
     * 10100000 A8
     *
     * Flags: H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 16 clocks

        ubyte b = cpu.readByte(s.HL);
        cpu.writeByte(s.DE, b);

        s.HL = (s.HL-1).as!ushort;
        s.DE = (s.DE-1).as!ushort;
        s.BC = (s.BC-1).as!ushort;

        s.flagH(false);
        s.flagPV(s.BC!=0);
        s.flagN(false);
    }
}
final class LDDR : Strategy {
    /**
     * 11101101 ED
     * 10100000 A8
     *
     * Flags: H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 16 clocks

        ubyte b = cpu.readByte(s.HL);
        cpu.writeByte(s.DE, b);

        s.HL = (s.HL-1).as!ushort;
        s.DE = (s.DE-1).as!ushort;
        s.BC = (s.BC-1).as!ushort;

        if(s.BC==0) {
            // 21 clocks
            s.PC = (s.PC - 2).as!ushort;
        } else {
            // 16 clocks
        }

        s.flagH(false);
        s.flagPV(false);
        s.flagN(false);
    }
}
final class INI : Strategy {
    /**
     * 11101101 ED
     * 10100000 A2
     *
     * Flags: Z,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        ubyte value = cpu.readPort(s.C);

        cpu.writeByte(s.HL, value);

        s.HL = (s.HL+1).as!ushort;
        s.B  = (s.B-1).as!ubyte;

        s.flagZ(s.B==0);
        s.flagN(true);
    }
}
final class OUTI : Strategy {
    /**
     * 11101101 ED
     * 10100000 A3
     *
     * Flags: Z,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        ubyte value = cpu.readByte(s.HL);

        cpu.writePort(s.C, value);

        s.HL = (s.HL+1).as!ushort;
        s.B  = (s.B-1).as!ubyte;

        s.flagZ(s.B==0);
        s.flagN(true);
    }
}
final class IND : Strategy {
    /**
     * 11101101 ED
     * 10100000 AA
     *
     * Flags: Z,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 16 clocks

        ubyte value = cpu.readPort(s.C);

        cpu.writeByte(s.HL, value);

        s.HL = (s.HL-1).as!ushort;
        s.B  = (s.B-1).as!ubyte;

        s.flagZ(s.B==0);
        s.flagN(true);
    }
}
final class INDR : Strategy {
    /**
     * 11101101 ED
     * 10100000 BA
     *
     * Flags: Z,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        ubyte value = cpu.readPort(s.C);
        cpu.writeByte(s.HL, value);

        s.HL = (s.HL-1).as!ushort;
        s.B  = (s.B-1).as!ubyte;

        if(s.B!=0) {
            // 21 clocks
            s.PC = (s.PC - 2).as!ushort;
        } else {
            // 16 clocks
        }

        s.flagZ(true);
        s.flagN(true);
    }
}
final class OUTD : Strategy {
    /**
     * 11101101 ED
     * 10100000 AB
     *
     * Flags: Z,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        ubyte value = cpu.readByte(s.HL);

        cpu.writePort(s.C, value);

        s.HL = (s.HL-1).as!ushort;
        s.B  = (s.B-1).as!ubyte;

        s.flagZ(s.B==0);
        s.flagN(true);
    }
}
final class OTDR : Strategy {
    /**
     * 11101101 ED
     * 10100000 BB
     *
     * Flags: Z,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        // 16 clocks

        ubyte value = cpu.readByte(s.HL);
        cpu.writePort(s.C, value);

        s.HL = (s.HL-1).as!ushort;
        s.B  = (s.B-1).as!ubyte;

        if(s.B!=0) {
            // 21 clocks
            s.PC = (s.PC - 2).as!ushort;
        } else {
            // 16 clocks
        }

        s.flagZ(true);
        s.flagN(true);
    }
}
final class LDIR : Strategy {
    /**
     * 11101101 ED
     * 10100000 B0
     *
     * Flags: H
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        ubyte b = cpu.readByte(s.HL);
        cpu.writeByte(s.DE, b);

        s.HL = (s.HL+1).as!ushort;
        s.DE = (s.DE+1).as!ushort;
        s.BC = (s.BC-1).as!ushort;

        // Repeat if BC is not 0
        if(s.BC!=0) {
            // 16 clocks
            s.PC = (s.PC - 2).as!ushort;
        } else {
            // 21 clocks
        }

        s.flagPV(s.BC!=0);
        s.flagH(false);
        s.flagN(false);
    }
}
final class CPIR : Strategy {
    /**
     * 11101101 ED
     * 10100000 B1
     *
     * Flags: S,Z,H,PV,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        ubyte b = cpu.readByte(s.HL);

        uint result = s.A - b;

        s.HL = (s.HL+1).as!ushort;
        s.BC = (s.BC-1).as!ushort;

        // Repeat if BC is not 0
        if(s.A!=b && s.BC!=0) {
            // 21 clocks
            s.PC = (s.PC - 2).as!ushort;
        } else {
            // 16 clocks
        }

        s.flagS((result & 0x80000000)!=0);
        s.flagZ(s.A==b);
        s.updateH(s.A, b, result);
        s.flagPV(s.BC!=0);
        s.flagN(true);
    }
}
final class INIR : Strategy {
    /**
     * 11101101 ED
     * 10100000 B2
     *
     * Flags: Z,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        ubyte value = cpu.readPort(s.C);
        cpu.writeByte(s.HL, value);

        s.HL = (s.HL+1).as!ushort;
        s.B  = (s.B-1).as!ubyte;

        // Repeat if BC is not 0
        if(s.B!=0) {
            // 21 clocks
            s.PC = (s.PC - 2).as!ushort;
        } else {
            // 16 clocks
        }

        s.flagZ(true);
        s.flagN(true);
    }
}
final class OTIR : Strategy {
    /**
     * 11101101 ED
     * 10100000 B3
     *
     * Flags: Z,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;

        ubyte value = cpu.readByte(s.HL);
        cpu.writePort(s.C, value);

        s.HL = (s.HL+1).as!ushort;
        s.B  = (s.B-1).as!ubyte;

        // Repeat if BC is not 0
        if(s.B!=0) {
            // 21 clocks
            s.PC = (s.PC - 2).as!ushort;
        } else {
            // 16 clocks
        }

        s.flagZ(true);
        s.flagN(true);
    }
}