module emulator.chips.z80.instr.strategies_cb;

import emulator.chips.z80.all;

__gshared const {
    Strategy _rlcr      = new RLC_r();
    Strategy _rrcr      = new RRC_r();
    Strategy _rlr       = new RL_r();
    Strategy _rrr       = new RR_r();
    Strategy _slar      = new SLA_r();
    Strategy _srar      = new SRA_r();
    Strategy _srlr      = new SRL_r();
    Strategy _bitr      = new BIT_r();
    Strategy _resr      = new RES_r();
    Strategy _setr      = new SET_r();
}

private:

final class RLC_r : Strategy {
    /**
     * 11001011 CB
     * 00000rrr
     *
     *      000 b
     *      001 c
     *      010 d
     *      011 e
     *      100 h
     *      101 l
     *      110 (hl)
     *      111 a
     *
     * Flags: S,Z,H,PV,N,C
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto rrr = (op.code) & 7;
        ubyte before;
        ubyte after;

        // 2 cycles
        switch(rrr) {
            case 0: before = s.B; s.B = after = ((s.B<<1) | (before>>>7)).as!ubyte; break;
            case 1: before = s.C; s.C = after = ((s.C<<1) | (before>>>7)).as!ubyte; break;
            case 2: before = s.D; s.D = after = ((s.D<<1) | (before>>>7)).as!ubyte; break;
            case 3: before = s.E; s.E = after = ((s.E<<1) | (before>>>7)).as!ubyte; break;
            case 4: before = s.H; s.H = after = ((s.H<<1) | (before>>>7)).as!ubyte; break;
            case 5: before = s.L; s.L = after = ((s.L<<1) | (before>>>7)).as!ubyte; break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                before = cpu.readByte(addr);
                cpu.writeByte(addr, after = ((before<<1) | (before>>>7)).as!ubyte);
                break;
            default:  before = s.A; s.A = after = ((s.A<<1) | (before>>>7)).as!ubyte; break;
        }
        s.updateS(after);
        s.updateZ(after);
        s.flagH(false);
        s.updateP(after);
        s.flagN(false);
        s.flagC((before&0x80)!=0);
    }
}
final class RRC_r : Strategy {
    /**
     * 11001011 CB
     * 00001rrr
     *
     *      000 b
     *      001 c
     *      010 d
     *      011 e
     *      100 h
     *      101 l
     *      110 (hl)
     *      111 a
     *
     * Flags: S,Z,H,PV,N,C
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto rrr = (op.code) & 7;
        ubyte before;
        ubyte after;

        // 2 cycles
        switch(rrr) {
            case 0: before = s.B; s.B = after = ((s.B>>>1) | ((before<<7)&0x80)).as!ubyte; break;
            case 1: before = s.C; s.C = after = ((s.C>>>1) | ((before<<7)&0x80)).as!ubyte; break;
            case 2: before = s.D; s.D = after = ((s.D>>>1) | ((before<<7)&0x80)).as!ubyte; break;
            case 3: before = s.E; s.E = after = ((s.E>>>1) | ((before<<7)&0x80)).as!ubyte; break;
            case 4: before = s.H; s.H = after = ((s.H>>>1) | ((before<<7)&0x80)).as!ubyte; break;
            case 5: before = s.L; s.L = after = ((s.L>>>1) | ((before<<7)&0x80)).as!ubyte; break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                before = cpu.readByte(addr);
                cpu.writeByte(addr, after = ((before>>>1) | ((before<<7)&0x80)).as!ubyte);
                break;
            default:  before = s.A; s.A = after = ((s.A>>>1) | ((before<<7)&0x80)).as!ubyte; break;
        }
        s.updateS(after);
        s.updateZ(after);
        s.flagH(false);
        s.updateP(after);
        s.flagN(false);
        s.flagC((before&1)!=0);
    }
}
final class RL_r : Strategy {
    /**
     * 11001011 CB
     * 00010rrr
     *
     *      000 b
     *      001 c
     *      010 d
     *      011 e
     *      100 h
     *      101 l
     *      110 (hl)
     *      111 a
     *
     * Flags: S,Z,H,PV,N,C
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto rrr = (op.code) & 7;
        ubyte before;
        ubyte after;
        ubyte c = s.flagC() ? 1 : 0;

        // 2 cycles
        switch(rrr) {
            case 0: before = s.B; s.B = after = ((s.B<<1) | c).as!ubyte; break;
            case 1: before = s.C; s.C = after = ((s.C<<1) | c).as!ubyte; break;
            case 2: before = s.D; s.D = after = ((s.D<<1) | c).as!ubyte; break;
            case 3: before = s.E; s.E = after = ((s.E<<1) | c).as!ubyte; break;
            case 4: before = s.H; s.H = after = ((s.H<<1) | c).as!ubyte; break;
            case 5: before = s.L; s.L = after = ((s.L<<1) | c).as!ubyte; break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                before = cpu.readByte(addr);
                cpu.writeByte(addr, after = ((before<<1) | c).as!ubyte);
                break;
            default:  before = s.A; s.A = after = ((s.A<<1) | c).as!ubyte; break;
        }
        s.updateS(after);
        s.updateZ(after);
        s.flagH(false);
        s.updateP(after);
        s.flagN(false);
        s.flagC((before&0x80)!=0);
    }
}
final class RR_r : Strategy {
    /**
     * 11001011 CB
     * 00011rrr
     *
     *      000 b
     *      001 c
     *      010 d
     *      011 e
     *      100 h
     *      101 l
     *      110 (hl)
     *      111 a
     *
     * Flags: S,Z,H,PV,N,C
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto rrr = (op.code) & 7;
        ubyte before;
        ubyte after;
        ubyte c = s.flagC() ? 0x80 : 0;

        // 2 cycles
        switch(rrr) {
            case 0: before = s.B; s.B = after = ((s.B>>>1) | c).as!ubyte; break;
            case 1: before = s.C; s.C = after = ((s.C>>>1) | c).as!ubyte; break;
            case 2: before = s.D; s.D = after = ((s.D>>>1) | c).as!ubyte; break;
            case 3: before = s.E; s.E = after = ((s.E>>>1) | c).as!ubyte; break;
            case 4: before = s.H; s.H = after = ((s.H>>>1) | c).as!ubyte; break;
            case 5: before = s.L; s.L = after = ((s.L>>>1) | c).as!ubyte; break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                before = cpu.readByte(addr);
                cpu.writeByte(addr, after = ((before>>>1) | c).as!ubyte);
                break;
            default:  before = s.A; s.A = after = ((s.A>>>1) | c).as!ubyte; break;
        }
        s.updateS(after);
        s.updateZ(after);
        s.flagH(false);
        s.updateP(after);
        s.flagN(false);
        s.flagC((before&1)!=0);
    }
}
final class SLA_r : Strategy {
    /**
     * 11001011 CB
     * 00100rrr
     *
     *      000 b
     *      001 c
     *      010 d
     *      011 e
     *      100 h
     *      101 l
     *      110 (hl)
     *      111 a
     *
     * Flags: S,Z,H,PV,N,C
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto rrr = op.code & 7;
        ubyte before;
        ubyte after;

        // 2 cycles

        switch(rrr) {
            case 0: before = s.B; s.B = after = (s.B<<1).as!ubyte; break;
            case 1: before = s.C; s.C = after = (s.C<<1).as!ubyte; break;
            case 2: before = s.D; s.D = after = (s.D<<1).as!ubyte; break;
            case 3: before = s.E; s.E = after = (s.E<<1).as!ubyte; break;
            case 4: before = s.H; s.H = after = (s.H<<1).as!ubyte; break;
            case 5: before = s.L; s.L = after = (s.L<<1).as!ubyte; break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                before = cpu.readByte(addr);
                cpu.writeByte(addr, after = (before<<1).as!ubyte);
                break;
            default:  before = s.A; s.A = after = (s.A<<1).as!ubyte; break;
        }
        s.updateS(after);
        s.updateZ(after);
        s.flagH(false);
        s.updateP(after);
        s.flagN(false);
        s.flagC((before&0x80)!=0);
    }
}

final class SRA_r : Strategy {
    /**
     * 11001011 CB
     * 00101rrr
     *
     *      000 b
     *      001 c
     *      010 d
     *      011 e
     *      100 h
     *      101 l
     *      110 (hl)
     *      111 a
     *
     * Flags: S,Z,H,PV,N,C
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto rrr = op.code & 7;
        ubyte before;
        ubyte after;

        // 2 cycles

        switch(rrr) {
            case 0: before = s.B; s.B = after = ((s.B>>>1) | (before&0x80)).as!ubyte; break;
            case 1: before = s.C; s.C = after = ((s.C>>>1) | (before&0x80)).as!ubyte; break;
            case 2: before = s.D; s.D = after = ((s.D>>>1) | (before&0x80)).as!ubyte; break;
            case 3: before = s.E; s.E = after = ((s.E>>>1) | (before&0x80)).as!ubyte; break;
            case 4: before = s.H; s.H = after = ((s.H>>>1) | (before&0x80)).as!ubyte; break;
            case 5: before = s.L; s.L = after = ((s.L>>>1) | (before&0x80)).as!ubyte; break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                before = cpu.readByte(addr);
                cpu.writeByte(addr, after = ((before>>>1) | (before&0x80)).as!ubyte);
                break;
            default:  before = s.A; s.A = after = ((s.A>>>1) | (before&0x80)).as!ubyte; break;
        }
        s.updateS(after);
        s.updateZ(after);
        s.flagH(false);
        s.updateP(after);
        s.flagN(false);
        s.flagC((before&1)!=0);
    }
}
final class SRL_r : Strategy {
    /**
     * 11001011 CB
     * 00111rrr
     *
     *      000 b
     *      001 c
     *      010 d
     *      011 e
     *      100 h
     *      101 l
     *      110 (hl)
     *      111 a
     *
     * Flags: S,Z,H,PV,N,C
     */
    override void execute(Z80 cpu, Op op) const {
        auto s = cpu.state;
        auto rrr = (op.code) & 7;
        ubyte before;
        ubyte after;

        // 2 cycles
        switch(rrr) {
            case 0: before = s.B; s.B = after = (s.B>>>1).as!ubyte; break;
            case 1: before = s.C; s.C = after = (s.C>>>1).as!ubyte; break;
            case 2: before = s.D; s.D = after = (s.D>>>1).as!ubyte; break;
            case 3: before = s.E; s.E = after = (s.E>>>1).as!ubyte; break;
            case 4: before = s.H; s.H = after = (s.H>>>1).as!ubyte; break;
            case 5: before = s.L; s.L = after = (s.L>>>1).as!ubyte; break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                before = cpu.readByte(addr);
                cpu.writeByte(addr, after = (before>>>1).as!ubyte);
                break;
            default:  before = s.A; s.A = after = (s.A>>>1).as!ubyte; break;
        }
        s.updateS(after);
        s.updateZ(after);
        s.flagH(false);
        s.updateP(after);
        s.flagN(false);
        s.flagC((before&1)!=0);
    }
}
final class BIT_r : Strategy {
    /**
     * 11001011 CB
     * 01bbbrrr
     *
     *      000 b
     *      001 c
     *      010 d
     *      011 e
     *      100 h
     *      101 l
     *      110 (hl)
     *      111 a
     *
     * Flags: Z,H,N
     */
    override void execute(Z80 cpu, Op op) const {
        auto s    = cpu.state;
        auto rrr  = (op.code) & 7;
        auto bbb  = (op.code>>>3) & 7;
        auto mask = 1<<bbb;
        ubyte value;

        // 8 clocks

        switch(rrr) {
            case 0: value = s.B; break;
            case 1: value = s.C; break;
            case 2: value = s.D; break;
            case 3: value = s.E; break;
            case 4: value = s.H; break;
            case 5: value = s.L; break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                value = cpu.readByte(addr);
                break;
            default: value = s.A; break;
        }

        s.flagZ((value&mask)==0);
        s.flagH(true);
        s.flagN(false);
    }
}
final class RES_r : Strategy {
    /**
     * 11001011 CB
     * 10bbbrrr
     *
     *      000 b
     *      001 c
     *      010 d
     *      011 e
     *      100 h
     *      101 l
     *      110 (hl)
     *      111 a
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s    = cpu.state;
        auto rrr  = (op.code) & 7;
        auto bbb  = (op.code>>>3) & 7;
        auto mask = ~(1<<bbb);

        // 4 clocks

        switch(rrr) {
            case 0: s.B = (s.B&mask).as!ubyte; break;
            case 1: s.C = (s.C&mask).as!ubyte; break;
            case 2: s.D = (s.D&mask).as!ubyte; break;
            case 3: s.E = (s.E&mask).as!ubyte; break;
            case 4: s.H = (s.H&mask).as!ubyte; break;
            case 5: s.L = (s.L&mask).as!ubyte; break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                ubyte value = (cpu.readByte(addr)&mask).as!ubyte;
                cpu.writeByte(addr, value);
                break;
            default: s.A = (s.A&mask).as!ubyte; break;
        }
    }
}
final class SET_r : Strategy {
    /**
     * 11001011 CB
     * 11bbbrrr
     *
     *      000 b
     *      001 c
     *      010 d
     *      011 e
     *      100 h
     *      101 l
     *      110 (hl)
     *      111 a
     *
     * Flags: None
     */
    override void execute(Z80 cpu, Op op) const {
        auto s    = cpu.state;
        auto rrr  = (op.code) & 7;
        auto bbb  = (op.code>>>3) & 7;
        auto or   = 1<<bbb;

        // 4 clocks
        switch(rrr) {
            case 0: s.B = (s.B|or).as!ubyte; break;
            case 1: s.C = (s.C|or).as!ubyte; break;
            case 2: s.D = (s.D|or).as!ubyte; break;
            case 3: s.E = (s.E|or).as!ubyte; break;
            case 4: s.H = (s.H|or).as!ubyte; break;
            case 5: s.L = (s.L|or).as!ubyte; break;
            case 6:
                auto addr = getHLIXdIYd(cpu, op);
                ubyte value = (cpu.readByte(addr)|or).as!ubyte;
                cpu.writeByte(addr, value);
                break;
            default: s.A = (s.A|or).as!ubyte; break;
        }
    }
}