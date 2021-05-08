module emulator.chips.z80.instr.instructions;

import emulator.chips.z80.all;

enum {
// row 0
    NOP         = 0x00, // nop
    LD_BC_nn    = 0x01, // ld bc, 0x8543
    LDD_BC_A    = 0x02, // ldd (bc),a       (bc) = a, dec bc
    INC_BC      = 0x03, // inc bc
    INC_B       = 0x04, // inc b
    DEC_B       = 0x05, // dec b
    LD_B_n      = 0x06, // ld b, 6
    RLCA        = 0x07, // rlca
    EX_AF_AF1   = 0x08, // ex af, af'       swap af with shadow af
    ADD_HL_BC   = 0x09, // add hl, bc
    LD_A_BC     = 0x0a, // ld a, (bc)
    DEC_BC      = 0x0b, // dec bc
    INC_C       = 0x0c, // inc c
    DEC_C       = 0x0d, // dec c
    LD_C_n      = 0x0e, // ld c, 4
    RRCA        = 0x0f, // rrca
// row 1
    DJNZ_n      = 0x10, // djnz 10          decrement b, jump if not zero
    LD_DE_nn    = 0x11, // ld de, 0x1234
    LD_DE_A     = 0x12, // ld (de), a
    INC_DE      = 0x13, // inc de
    INC_D       = 0x14, // inc d
    DEC_D       = 0x15, // dec d
    LD_D_n      = 0x16, // ld d, 5
    RLA         = 0x17, // rla
    JR_e        = 0x18, // jr 0x7f          (-126 to +129)
}

struct Instruction {
    ubyte code;
    const Strategy strategy;
    string[] tokens;
    string[] alt;   // alternative syntax

    void execute(Z80 cpu, Op op) const {
        strategy.execute(cpu, op);
    }
    int numExtraBytes() const {
        return tokens.contains(N) ? 1 : tokens.contains(NN) ? 2 : 0;
    }
    int indexOfLiteral() const {
        auto a = tokens.indexOf(N);
        if(a!=-1) return a;
        return tokens.indexOf(NN);
    }
}
struct Op {
    ubyte byte1;
    ubyte byte2;
}
private {
    enum : string {
        A = "a", B = "b", C = "c", D = "d", E = "e", H = "h", L = "l",
        AF = "af", BC = "bc", DE = "de", HL = "hl", SP = "sp",
        AF1 = "af1",
        NN = "%04x", N  = "%02x",
        LBR = "(", RBR = ")", _ = ",",
        LD = "ld", INC = "inc", DEC = "dec", ADD = "add", ADC = "adc", SUB = "sub", SBC = "sbc",
        XOR = "xor", OR = "or", AND = "and", CP = "cp", RET = "ret", PUSH = "push", POP = "pop",
        JR = "jr", JP = "jp", CALL = "call", RST = "rst", IN = "in", OUT = "out",
    }
}
__gshared const {
Instruction[256] primary = [
// row 0
    Instruction(0x00, _nop,       ["nop"]),
    Instruction(0x01, _ldddnn,    [LD, BC, _, NN]),
    Instruction(0x02, _ldbca,     [LD, LBR, BC, RBR, _, A]),
    Instruction(0x03, _incss,     [INC, BC]),
    Instruction(0x04, _incr,      [INC, B]),
    Instruction(0x05, _decr,      [DEC, B]),
    Instruction(0x06, _ldrn,      [LD, B, _, N]),
    Instruction(0x07, _rlca,      ["rlca"]),
    Instruction(0x08, _exaf,      ["ex", AF, _, AF1]),
    Instruction(0x09, _addhlss,   [ADD, HL, _, BC]),
    Instruction(0x0a, _ldabc,     [LD, A, _, LBR, BC, RBR]),
    Instruction(0x0b, _decss,     [DEC, BC]),
    Instruction(0x0c, _incr,      [INC, C]),
    Instruction(0x0d, _decr,      [DEC, C]),
    Instruction(0x0e, _ldrn,      [LD, C, _, N]),
    Instruction(0x0f, _rrca,      ["rrca"]),
// row 1
    Instruction(0x10, _djnze,    ["djnz", N]),
    Instruction(0x11, _ldddnn,   [LD, DE, _, NN]),
    Instruction(0x12, _lddea,    [LD, LBR, DE, RBR, _, A]),
    Instruction(0x13, _incss,    [INC, DE]),
    Instruction(0x14, _incr,     [INC, D]),
    Instruction(0x15, _decr,     [DEC, D]),
    Instruction(0x16, _ldrn,     [LD, D, _, N]),
    Instruction(0x17, _rla,      ["rla"]),
    Instruction(0x18, _jre,      [JR, N]),
    Instruction(0x19, _addhlss,  [ADD, HL, _, DE]),
    Instruction(0x1a, _ldade,    [LD, A, _, LBR, DE, RBR]),
    Instruction(0x1b, _decss,    [DEC, DE]),
    Instruction(0x1c, _incr,     [INC, E]),
    Instruction(0x1d, _decr,     [DEC, E]),
    Instruction(0x1e, _ldrn,     [LD, E, _, N]),
    Instruction(0x1f, _rra,      ["rra"]),
// row 2
    Instruction(0x20, _jrnze,    [JR, "nz", _, N]),
    Instruction(0x21, _ldddnn,   [LD, HL, _, NN]),
    Instruction(0x22, _ldnnhl,   [LD, LBR, NN, RBR, _, HL]),
    Instruction(0x23, _incss,    [INC, HL]),
    Instruction(0x24, _incr,     [INC, H]),
    Instruction(0x25, _decr,     [DEC, H]),
    Instruction(0x26, _ldrn,     [LD, H, _, N]),
    Instruction(0x27, _daa,      ["daa"]),
    Instruction(0x28, _jrze,     [JR, "z", _, N]),
    Instruction(0x29, _addhlss,  [ADD, HL, _, HL]),
    Instruction(0x2a, _ldhlnn,   [LD, HL, _, LBR, NN, RBR]),
    Instruction(0x2b, _decss,    [DEC, HL]),
    Instruction(0x2c, _incr,     [INC, L]),
    Instruction(0x2d, _decr,     [DEC, L]),
    Instruction(0x2e, _ldrn,     [LD, L, _, N]),
    Instruction(0x2f, _cpl,      ["cpl"]),
// row 3
    Instruction(0x30, _jrnce,    [JR, "nc", _, N]),
    Instruction(0x31, _ldddnn,   [LD, SP, _, NN]),
    Instruction(0x32, _ldnna,    [LD, LBR, NN, RBR, _, A]),
    Instruction(0x33, _incss,    [INC, SP]),
    Instruction(0x34, _incr,     [INC, LBR, HL, RBR]),
    Instruction(0x35, _decr,     [DEC, LBR, HL, RBR]),
    Instruction(0x36, _ldrn,     [LD, LBR, HL, RBR, _, N]),
    Instruction(0x37, _scf,      ["scf"]),
    Instruction(0x38, _jrce,     [JR, C, _, N]),
    Instruction(0x39, _addhlss,  [ADD, HL, _, SP]),
    Instruction(0x3a, _ldann,    [LD, A, _, LBR, NN, RBR]),
    Instruction(0x3b, _decss,    [DEC, SP]),
    Instruction(0x3c, _incr,     [INC, A]),
    Instruction(0x3d, _decr,     [DEC, A]),
    Instruction(0x3e, _ldrn,     [LD, A, _, N]),
    Instruction(0x3f, _ccf,      ["ccf"]),
// row 4
    Instruction(0x40, _ldrr,     [LD, B, _, B]),
    Instruction(0x41, _ldrr,     [LD, B, _, C]),
    Instruction(0x42, _ldrr,     [LD, B, _, D]),
    Instruction(0x43, _ldrr,     [LD, B, _, E]),
    Instruction(0x44, _ldrr,     [LD, B, _, H]),
    Instruction(0x45, _ldrr,     [LD, B, _, L]),
    Instruction(0x46, _ldrr,     [LD, B, _, LBR, HL, RBR]),
    Instruction(0x47, _ldrr,     [LD, B, _, A]),
    Instruction(0x48, _ldrr,     [LD, C, _, B]),
    Instruction(0x49, _ldrr,     [LD, C, _, C]),
    Instruction(0x4a, _ldrr,     [LD, C, _, D]),
    Instruction(0x4b, _ldrr,     [LD, C, _, E]),
    Instruction(0x4c, _ldrr,     [LD, C, _, H]),
    Instruction(0x4d, _ldrr,     [LD, C, _, L]),
    Instruction(0x4e, _ldrr,     [LD, C, _, LBR, HL, RBR]),
    Instruction(0x4f, _ldrr,     [LD, C, _, A]),
// row 5
    Instruction(0x50, _ldrr,     [LD, D, _, B]),
    Instruction(0x51, _ldrr,     [LD, D, _, C]),
    Instruction(0x52, _ldrr,     [LD, D, _, D]),
    Instruction(0x53, _ldrr,     [LD, D, _, E]),
    Instruction(0x54, _ldrr,     [LD, D, _, H]),
    Instruction(0x55, _ldrr,     [LD, D, _, L]),
    Instruction(0x56, _ldrr,     [LD, D, _, LBR, HL, RBR]),
    Instruction(0x57, _ldrr,     [LD, D, _, A]),
    Instruction(0x58, _ldrr,     [LD, E, _, B]),
    Instruction(0x59, _ldrr,     [LD, E, _, C]),
    Instruction(0x5a, _ldrr,     [LD, E, _, D]),
    Instruction(0x5b, _ldrr,     [LD, E, _, E]),
    Instruction(0x5c, _ldrr,     [LD, E, _, H]),
    Instruction(0x5d, _ldrr,     [LD, E, _, L]),
    Instruction(0x5e, _ldrr,     [LD, E, _, LBR, HL, RBR]),
    Instruction(0x5f, _ldrr,     [LD, E, _, A]),
// row 6
    Instruction(0x60, _ldrr,    [LD, H, _, B]),
    Instruction(0x61, _ldrr,    [LD, H, _, C]),
    Instruction(0x62, _ldrr,    [LD, H, _, D]),
    Instruction(0x63, _ldrr,    [LD, H, _, E]),
    Instruction(0x64, _ldrr,    [LD, H, _, H]),
    Instruction(0x65, _ldrr,    [LD, H, _, L]),
    Instruction(0x66, _ldrr,    [LD, H, _, LBR, HL, RBR]),
    Instruction(0x67, _ldrr,    [LD, H, _, A]),
    Instruction(0x68, _ldrr,    [LD, L, _, B]),
    Instruction(0x69, _ldrr,    [LD, L, _, C]),
    Instruction(0x6a, _ldrr,    [LD, L, _, D]),
    Instruction(0x6b, _ldrr,    [LD, L, _, E]),
    Instruction(0x6c, _ldrr,    [LD, L, _, H]),
    Instruction(0x6d, _ldrr,    [LD, L, _, L]),
    Instruction(0x6e, _ldrr,    [LD, L, _, LBR, HL, RBR]),
    Instruction(0x6f, _ldrr,    [LD, L, _, A]),
// row 7
    Instruction(0x70, _ldrr,     [LD, LBR, HL, RBR, _, B]),
    Instruction(0x71, _ldrr,     [LD, LBR, HL, RBR, _, C]),
    Instruction(0x72, _ldrr,     [LD, LBR, HL, RBR, _, D]),
    Instruction(0x73, _ldrr,     [LD, LBR, HL, RBR, _, E]),
    Instruction(0x74, _ldrr,     [LD, LBR, HL, RBR, _, H]),
    Instruction(0x75, _ldrr,     [LD, LBR, HL, RBR, _, L]),
    Instruction(0x76, _halt,     ["halt"]),
    Instruction(0x77, _ldrr,     [LD, LBR, HL, RBR, _, A]),
    Instruction(0x78, _ldrr,     [LD, A, _, B]),
    Instruction(0x79, _ldrr,     [LD, A, _, C]),
    Instruction(0x7a, _ldrr,     [LD, A, _, D]),
    Instruction(0x7b, _ldrr,     [LD, A, _, E]),
    Instruction(0x7c, _ldrr,     [LD, A, _, H]),
    Instruction(0x7d, _ldrr,     [LD, A, _, L]),
    Instruction(0x7e, _ldrr,     [LD, A, _, LBR, HL, RBR]),
    Instruction(0x7f, _ldrr,     [LD, A, _, A]),
// row 8
    Instruction(0x80, _algar,    [ADD, A, _, B]),
    Instruction(0x81, _algar,    [ADD, A, _, C]),
    Instruction(0x82, _algar,    [ADD, A, _, D]),
    Instruction(0x83, _algar,    [ADD, A, _, E]),
    Instruction(0x84, _algar,    [ADD, A, _, H]),
    Instruction(0x85, _algar,    [ADD, A, _, L]),
    Instruction(0x86, _algar,    [ADD, A, _, LBR, HL, RBR]),
    Instruction(0x87, _algar,    [ADD, A, _, A]),
    Instruction(0x88, _algar,    [ADC, A, _, B]),
    Instruction(0x89, _algar,    [ADC, A, _, C]),
    Instruction(0x8a, _algar,    [ADC, A, _, D]),
    Instruction(0x8b, _algar,    [ADC, A, _, E]),
    Instruction(0x8c, _algar,    [ADC, A, _, H]),
    Instruction(0x8d, _algar,    [ADC, A, _, L]),
    Instruction(0x8e, _algar,    [ADC, A, _, LBR, HL, RBR]),
    Instruction(0x8f, _algar,    [ADC, A, _, A]),
// row 9
    Instruction(0x90, _algar,    [SUB, A, _, B], [SUB, B]),
    Instruction(0x91, _algar,    [SUB, A, _, C], [SUB, C]),
    Instruction(0x92, _algar,    [SUB, A, _, D], [SUB, D]),
    Instruction(0x93, _algar,    [SUB, A, _, E], [SUB, E]),
    Instruction(0x94, _algar,    [SUB, A, _, H], [SUB, H]),
    Instruction(0x95, _algar,    [SUB, A, _, L], [SUB, L]),
    Instruction(0x96, _algar,    [SUB, A, _, LBR, HL, RBR], [SUB, LBR, HL, RBR]),
    Instruction(0x97, _algar,    [SUB, A, _, A], [SUB, A]),
    Instruction(0x98, _algar,    [SBC, A, _, B]),
    Instruction(0x99, _algar,    [SBC, A, _, C]),
    Instruction(0x9a, _algar,    [SBC, A, _, D]),
    Instruction(0x9b, _algar,    [SBC, A, _, E]),
    Instruction(0x9c, _algar,    [SBC, A, _, H]),
    Instruction(0x9d, _algar,    [SBC, A, _, L]),
    Instruction(0x9e, _algar,    [SBC, A, _, LBR, HL, RBR]),
    Instruction(0x9f, _algar,    [SBC, A, _, A]),
// row a
    Instruction(0xa0, _algar,    [AND, A, _, B], [AND, B]),
    Instruction(0xa1, _algar,    [AND, A, _, C], [AND, C]),
    Instruction(0xa2, _algar,    [AND, A, _, D], [AND, D]),
    Instruction(0xa3, _algar,    [AND, A, _, E], [AND, E]),
    Instruction(0xa4, _algar,    [AND, A, _, H], [AND, H]),
    Instruction(0xa5, _algar,    [AND, A, _, L], [AND, L]),
    Instruction(0xa6, _algar,    [AND, A, _, LBR, HL, RBR], [AND, LBR, HL, RBR]),
    Instruction(0xa7, _algar,    [AND, A, _, A], [AND, A]),
    Instruction(0xa8, _algar,    [XOR, A, _, B], [XOR, B]),
    Instruction(0xa9, _algar,    [XOR, A, _, C], [XOR, C]),
    Instruction(0xaa, _algar,    [XOR, A, _, D], [XOR, D]),
    Instruction(0xab, _algar,    [XOR, A, _, E], [XOR, E]),
    Instruction(0xac, _algar,    [XOR, A, _, H], [XOR, H]),
    Instruction(0xad, _algar,    [XOR, A, _, L], [XOR, L]),
    Instruction(0xae, _algar,    [XOR, A, _, LBR, HL, RBR], [XOR, LBR, HL, RBR]),
    Instruction(0xaf, _algar,    [XOR, A, _, A], [XOR, A]),
// row b
    Instruction(0xb0, _algar,    [OR, A, _, B], [OR, B]),
    Instruction(0xb1, _algar,    [OR, A, _, C], [OR, C]),
    Instruction(0xb2, _algar,    [OR, A, _, D], [OR, D]),
    Instruction(0xb3, _algar,    [OR, A, _, E], [OR, E]),
    Instruction(0xb4, _algar,    [OR, A, _, H], [OR, H]),
    Instruction(0xb5, _algar,    [OR, A, _, L], [OR, L]),
    Instruction(0xb6, _algar,    [OR, A, _, LBR, HL, RBR], [OR, LBR, HL, RBR]),
    Instruction(0xb7, _algar,    [OR, A, _, A], [OR, A]),
    Instruction(0xb8, _algar,    [CP, A, _, B], [CP, B]),
    Instruction(0xb9, _algar,    [CP, A, _, C], [CP, C]),
    Instruction(0xba, _algar,    [CP, A, _, D], [CP, D]),
    Instruction(0xbb, _algar,    [CP, A, _, E], [CP, E]),
    Instruction(0xbc, _algar,    [CP, A, _, H], [CP, H]),
    Instruction(0xbd, _algar,    [CP, A, _, L], [CP, L]),
    Instruction(0xbe, _algar,    [CP, A, _, LBR, HL, RBR], [CP, LBR, HL, RBR]),
    Instruction(0xbf, _algar,    [CP, A, _, A], [CP, A]),
// row c
    Instruction(0xc0, _retcc,     [RET, "nz"]),
    Instruction(0xc1, _popqq,     [POP, BC]),
    Instruction(0xc2, _jpccnn,    [JP, "nz", _, NN]),
    Instruction(0xc3, _jpnn,      [JP, NN]),
    Instruction(0xc4, _callccnn,  [CALL, "nz", _, NN]),
    Instruction(0xc5, _pushqq,    [PUSH, BC]),
    Instruction(0xc6, _addan,     [ADD, A, _, N]),
    Instruction(0xc7, _rstp,      [RST, "00"]),
    Instruction(0xc8, _retcc,     [RET, "z"]),
    Instruction(0xc9, _ret,       [RET]),
    Instruction(0xca, _jpccnn,    [JP, "z", _, NN]),
    Instruction(0xcb),                                  // CB group
    Instruction(0xcc, _callccnn,  [CALL, "z", _, NN]),
    Instruction(0xcd, _callnn,    [CALL, NN]),
    Instruction(0xce, _adcan,     [ADC, A, _, N]),
    Instruction(0xcf, _rstp,      [RST, "08"]),
// row d
    Instruction(0xd0, _retcc,     [RET, "nc"]),
    Instruction(0xd1, _popqq,     [POP, DE]),
    Instruction(0xd2, _jpccnn,    [JP, "nc", _, NN]),
    Instruction(0xd3, _outna,     [OUT, LBR, N, RBR, _, A]),
    Instruction(0xd4, _callccnn,  [CALL, "nc", _, NN]),
    Instruction(0xd5, _pushqq,    [PUSH, DE]),
    Instruction(0xd6, _suban,     [SUB, A, _, N]),
    Instruction(0xd7, _rstp,      [RST, "10"]),
    Instruction(0xd8, _retcc,     [RET, C]),
    Instruction(0xd9, _exx,       ["exx"]),
    Instruction(0xda, _jpccnn,    [JP, C, _, NN]),
    Instruction(0xdb, _inan,      [IN, A, _, LBR, N, RBR]),
    Instruction(0xdc, _callccnn,  [CALL, C, _, NN]),
    Instruction(0xdd),                                  // DD group
    Instruction(0xde, _sbcan,     [SBC, A, _, N]),
    Instruction(0xdf, _rstp,      [RST, "18"]),
// row e
    Instruction(0xe0, _retcc,     [RET, "po"]),
    Instruction(0xe1, _popqq,     [POP, HL]),
    Instruction(0xe2, _jpccnn,    [JP, "po", _, NN]),
    Instruction(0xe3, _exsphl,    ["ex", LBR, SP, RBR, _, HL]),
    Instruction(0xe4, _callccnn,  [CALL, "po", _, NN]),
    Instruction(0xe5, _pushqq,    [PUSH, HL]),
    Instruction(0xe6, _andan,     [AND, A, _, N], [AND, N]),
    Instruction(0xe7, _rstp,      [RST, "20"]),
    Instruction(0xe8, _retcc,     [RET, "pe"]),
    Instruction(0xe9, _jphl,      [JP, LBR, HL, RBR]),
    Instruction(0xea, _jpccnn,    [JP, "pe", _, NN]),
    Instruction(0xeb, _exdehl,    ["ex", DE, _, HL]),
    Instruction(0xec, _callccnn,  [CALL, "pe", _, NN]),
    Instruction(0xed),                              // ED group
    Instruction(0xee, _xoran,     [XOR, A, _, N]),
    Instruction(0xef, _rstp,      [RST, "28"]),
// row f
    Instruction(0xf0, _retcc,     [RET, "p"]),
    Instruction(0xf1, _popqq,     [POP, AF]),
    Instruction(0xf2, _jpccnn,    [JP, "p", _, NN]),
    Instruction(0xf3, _di,        ["di"]),
    Instruction(0xf4, _callccnn,  [CALL, "p", _, NN]),
    Instruction(0xf5, _pushqq,    [PUSH, AF]),
    Instruction(0xf6, _oran,      [OR, A, _, N]),
    Instruction(0xf7, _rstp,      [RST, "30"]),
    Instruction(0xf8,  _retcc,    [RET, "m"]),
    Instruction(0xf9, _ldsphl,    [LD, SP, _, HL]),
    Instruction(0xfa, _jpccnn,    [JP, "m", _, NN]),
    Instruction(0xfb, _ei,        ["ei"]),
    Instruction(0xfc, _callccnn,  [CALL, "m", _, NN]),
    Instruction(0xfd),                              // FD group
    Instruction(0xfe, _cpan,      [CP, A, _, N]),
    Instruction(0xff, _rstp,      [RST, "38"]),
];

} // __gshared const
