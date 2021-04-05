module emulator.chips._6502.instructions;

import emulator.all;

enum {
    ADC_IMM     = 0x69,
    ADC_ZP      = 0x65,
    ADC_ZP_X    = 0x75,
    ADC_ABS     = 0x6d,
    ADC_ABS_X   = 0x7d,
    ADC_ABS_Y   = 0x79,
    ADC_IND_X   = 0x61,
    ADC_IND_Y   = 0x71,

    AND_IMM     = 0x29,
    AND_ZP      = 0x25,
    AND_ZP_X    = 0x35,
    AND_ABS     = 0x2d,
    AND_ABS_X   = 0x3d,
    AND_ABS_Y   = 0x39,
    AND_IND_X   = 0x21,
    AND_IND_Y   = 0x31,

    ASL_ACC     = 0x0a,
    ASL_ZP      = 0x06,
    ASL_ZP_X    = 0x16,
    ASL_ABS     = 0x0e,
    ASL_ABS_X   = 0x1e,

    BCC         = 0x90,
    BCS         = 0xb0,
    BEQ         = 0xf0,

    BIT_ZP      = 0x24,
    BIT_ABS     = 0x2c,

    BMI         = 0x30,
    BNE         = 0xd0,
    BPL         = 0x10,

    BRK         = 0x00,

    BVC         = 0x50,
    BVS         = 0x70,

    CLC         = 0x18,
    CLD         = 0xd8,
    CLI         = 0x58,
    CLV         = 0xb8,

    CMP_IMM     = 0xc9,
    CMP_ZP      = 0xc5,
    CMP_ZP_X    = 0xd5,
    CMP_ABS     = 0xcd,
    CMP_ABS_X   = 0xdd,
    CMP_ABS_Y   = 0xd9,
    CMP_IND_X   = 0xc1,
    CMP_IND_Y   = 0xd1,

    CPX_IMM     = 0xe0,
    CPX_ZP      = 0xe4,
    CPX_ABS     = 0xec,

    CPY_IMM     = 0xc0,
    CPY_ZP      = 0xc4,
    CPY_ABS     = 0xcc,

    DEC_ZP      = 0xc6,
    DEC_ZP_X    = 0xd6,
    DEC_ABS     = 0xce,
    DEC_ABS_X   = 0xde,

    DEX         = 0xca,
    DEY         = 0x88,

    EOR_IMM     = 0x49,
    EOR_ZP      = 0x45,
    EOR_ZP_X    = 0x55,
    EOR_ABS     = 0x4d,
    EOR_ABS_X   = 0x5d,
    EOR_ABS_Y   = 0x59,
    EOR_IND_X   = 0x41,
    EOR_IND_Y   = 0x51,

    INC_ZP      = 0xe6,
    INC_ZP_X    = 0xf6,
    INC_ABS     = 0xee,
    INC_ABS_X   = 0xfe,

    INX         = 0xe8,
    INY         = 0xc8,

    JMP_ABS     = 0x4c,
    JMP_IND     = 0x6c,

    JSR         = 0x20,

    LDA_IMM     = 0xa9,
    LDA_ZP      = 0xa5,
    LDA_ZP_X    = 0xb5,
    LDA_ABS     = 0xad,
    LDA_ABS_X   = 0xbd,
    LDA_ABS_Y   = 0xb9,
    LDA_IND_X   = 0xa1,
    LDA_IND_Y   = 0xb1,

    LDX_IMM     = 0xa2,
    LDX_ZP      = 0xa6,
    LDX_ZP_Y    = 0xb6,
    LDX_ABS     = 0xae,
    LDX_ABS_Y   = 0xbe,

    LDY_IMM     = 0xa0,
    LDY_ZP      = 0xa4,
    LDY_ZP_X    = 0xb4,
    LDY_ABS     = 0xac,
    LDY_ABS_X   = 0xbc,

    LSR_ACC     = 0x4a,
    LSR_ZP      = 0x46,
    LSR_ZP_X    = 0x56,
    LSR_ABS     = 0x4e,
    LSR_ABS_X   = 0x5e,

    NOP         = 0xea,

    ORA_IMM     = 0x09,
    ORA_ZP      = 0x05,
    ORA_ZP_X    = 0x15,
    ORA_ABS     = 0x0d,
    ORA_ABS_X   = 0x1d,
    ORA_ABS_Y   = 0x19,
    ORA_IND_X   = 0x01,
    ORA_IND_Y   = 0x11,

    PHA         = 0x48,
    PHP         = 0x08,
    PLA         = 0x68,
    PLP         = 0x28,

    ROL_ACC     = 0x2a,
    ROL_ZP      = 0x26,
    ROL_ZP_X    = 0x36,
    ROL_ABS     = 0x2e,
    ROL_ABS_X   = 0x3e,

    ROR_ACC     = 0x6a,
    ROR_ZP      = 0x66,
    ROR_ZP_X    = 0x76,
    ROR_ABS     = 0x6e,
    ROR_ABS_X   = 0x7e,

    RTI         = 0x40,
    RTS         = 0x60,

    SBC_IMM     = 0xe9,
    SBC_ZP      = 0xe5,
    SBC_ZP_X    = 0xf5,
    SBC_ABS     = 0xed,
    SBC_ABS_X   = 0xfd,
    SBC_ABS_Y   = 0xf9,
    SBC_IND_X   = 0xe1,
    SBC_IND_Y   = 0xf1,

    SEC         = 0x38,
    SED         = 0xf8,
    SEI         = 0x78,

    STA_ZP      = 0x85,
    STA_ZP_X    = 0x95,
    STA_ABS     = 0x8d,
    STA_ABS_X   = 0x9d,
    STA_ABS_Y   = 0x99,
    STA_IND_X   = 0x81,
    STA_IND_Y   = 0x91,

    STX_ZP      = 0x86,
    STX_ZP_Y    = 0x96,
    STX_ABS     = 0x8e,

    STY_ZP      = 0x84,
    STY_ZP_X    = 0x94,
    STY_ABS     = 0x8c,

    TAX         = 0xaa,
    TAY         = 0xa8,
    TSX         = 0xba,
    TXA         = 0x8a,
    TXS         = 0x9a,
    TYA         = 0x98,

    // Undocumented illegal instruction below here (Not implemented)

    ANC_IMM     = 0x0b, // A = A & imm
    ANC_IMM2    = 0x2b,

    AHX_ZP_Y    = 0x93, // (addr) = A & Y & H
    AHX_ABS_Y   = 0x9f,

    ALR_IMM     = 0x4b, // A = (A & imm) / 2
    ARR_IMM     = 0x6b, // A = (A & imm) / 2

    AXS_IMM     = 0xcb, // X = A & X - imm

    DCP_ZP      = 0xc7, // (addr) = addr) - 1 , A -= (addr)
    DCP_ZP_X    = 0xd7,
    DCP_ABS     = 0xcf,
    DCP_ABS_X   = 0xdf,
    DCP_ABS_Y   = 0xdb,
    DCP_IND_X   = 0xc3,
    DCP_IND_Y   = 0xd3,

    ISC_ZP      = 0xe7, // (ISB) (addr) = (addr) + 1, A += (addr)
    ISC_ZP_X    = 0xf7,
    ISC_ABS     = 0xef,
    ISC_ABS_X   = 0xff,
    ISC_ABS_Y   = 0xfb,
    ISC_IND_X   = 0xe3,
    ISC_IND_Y   = 0xf3,

    LAX_IMM     = 0xab, // (<-- unstable)
    LAX_ZP      = 0xa7, // A,X = (addr)
    LAX_ZP_Y    = 0xb7,
    LAX_ABS     = 0xaf,
    LAX_ABS_Y   = 0xbf,
    LAX_ABS_Y_2 = 0xbb, // A,X,SP = (addr) & SP
    LAX_IND_X   = 0xa3,
    LAX_IND_Y   = 0xb3,

    RLA_ZP      = 0x2f, // rol (addr), A = A & (addr)
    RLA_ZP_X    = 0x37,
    RLA_ABS     = 0x2f,
    RLA_ABS_X   = 0x3f,
    RLA_ABS_Y   = 0x3b,
    RLA_IND_X   = 0x23,
    RLA_IND_Y   = 0x33,

    RRA_ZP      = 0x67,
    RRA_ZP_X    = 0x77,
    RRA_ABS     = 0x6f,
    RRA_ABS_X   = 0x7f,
    RRA_ABS_Y   = 0x7b,
    RRA_IND_X   = 0x63,
    RRA_IND_Y   = 0x73,

    SAX_ZP      = 0x87, // (addr) =  A & X
    SAX_ZP_Y    = 0x97,
    SAX_ABS     = 0x8f,
    SAX_IND_X   = 0x83,

    SBC_IMM2    = 0xeb, // A = A - imm

    SHX_ABS_Y   = 0x9e, // (addr) = X & H
    SHY_ABS_X   = 0x9c, // (addr) = Y & H

    SLO_ZP      = 0x07, // (ASO) // (addr) = (addr)*2, A = A | (addr)
    SLO_ZP_X    = 0x17,
    SLO_ABS     = 0x0f,
    SLO_ABS_X   = 0x1f,
    SLO_ABS_Y   = 0x1b,
    SLO_IND_X   = 0x03,
    SLO_IND_Y   = 0x13,

    SRE_ZP      = 0x47, // (LSE) (addr) = (addr) / 2, A = A ^ (addr)
    SRE_ZP_X    = 0x57,
    SRE_ABS     = 0x4f,
    SRE_ABS_X   = 0x5f,
    SRE_ABS_Y   = 0x5b,
    SRE_IND_X   = 0x43,
    SRE_IND_Y   = 0x53,

    TAS_ABS_Y   = 0x9b, // SP = A & X, (addr) = SP & H

    XAA         = 0x8b, // A = X & imm (unstable)

    NOP2_1      = 0x80, // 2 byte nop
    NOP2_2      = 0x89, // 2 byte nop
    NOP1        = 0xda,
    NOP3        = 0xfa,

}

string decode(ubyte i) {
    auto p = i in instrToString;
    if(!p) {
        throw new Exception("Unhandled opcode %02x".format(i));
    }
    return *p;
}

private string[ubyte] instrToString;

__gshared static this() {
    instrToString = [
        ADC_IMM     : "adc",
        ADC_ZP      : "adc",
        ADC_ZP_X    : "adc",
        ADC_ABS     : "adc",
        ADC_ABS_X   : "adc",
        ADC_ABS_Y   : "adc",
        ADC_IND_X   : "adc",
        ADC_IND_Y   : "adc",

        AND_IMM     : "and",
        AND_ZP      : "and",
        AND_ZP_X    : "and",
        AND_ABS     : "and",
        AND_ABS_X   : "and",
        AND_ABS_Y   : "and",
        AND_IND_X   : "and",
        AND_IND_Y   : "and",

        ASL_ACC     : "asl",
        ASL_ZP      : "asl",
        ASL_ZP_X    : "asl",
        ASL_ABS     : "asl",
        ASL_ABS_X   : "asl",

        BCC         : "bcc",
        BCS         : "bcs",
        BEQ         : "beq",

        BIT_ZP      : "bit",
        BIT_ABS     : "bit",

        BMI         : "bmi",
        BNE         : "bne",
        BPL         : "bpl",

        BRK         : "brk",

        BVC         : "bvc",
        BVS         : "bvs",

        CLC         : "clc",
        CLD         : "cld",
        CLI         : "cli",
        CLV         : "clv",

        CMP_IMM     : "cmp",
        CMP_ZP      : "cmp",
        CMP_ZP_X    : "cmp",
        CMP_ABS     : "cmp",
        CMP_ABS_X   : "cmp",
        CMP_ABS_Y   : "cmp",
        CMP_IND_X   : "cmp",
        CMP_IND_Y   : "cmp",

        CPX_IMM     : "cpx",
        CPX_ZP      : "cpx",
        CPX_ABS     : "cpx",

        CPY_IMM     : "cpy",
        CPY_ZP      : "cpy",
        CPY_ABS     : "cpy",

        DEC_ZP      : "dec",
        DEC_ZP_X    : "dec",
        DEC_ABS     : "dec",
        DEC_ABS_X   : "dec",

        DEX         : "dex",
        DEY         : "dey",

        EOR_IMM     : "eor",
        EOR_ZP      : "eor",
        EOR_ZP_X    : "eor",
        EOR_ABS     : "eor",
        EOR_ABS_X   : "eor",
        EOR_ABS_Y   : "eor",
        EOR_IND_X   : "eor",
        EOR_IND_Y   : "eor",

        INC_ZP      : "inc",
        INC_ZP_X    : "inc",
        INC_ABS     : "inc",
        INC_ABS_X   : "inc",

        INX         : "inx",
        INY         : "iny",

        JMP_ABS     : "jmp",
        JMP_IND     : "jmp",

        JSR         : "jsr",

        LDA_IMM     : "lda",
        LDA_ZP      : "lda",
        LDA_ZP_X    : "lda",
        LDA_ABS     : "lda",
        LDA_ABS_X   : "lda",
        LDA_ABS_Y   : "lda",
        LDA_IND_X   : "lda",
        LDA_IND_Y   : "lda",

        LDX_IMM     : "ldx",
        LDX_ZP      : "ldx",
        LDX_ZP_Y    : "ldx",
        LDX_ABS     : "ldx",
        LDX_ABS_Y   : "ldx",

        LDY_IMM     : "ldy",
        LDY_ZP      : "ldy",
        LDY_ZP_X    : "ldy",
        LDY_ABS     : "ldy",
        LDY_ABS_X   : "ldy",

        LSR_ACC     : "lsr",
        LSR_ZP      : "lsr",
        LSR_ZP_X    : "lsr",
        LSR_ABS     : "lsr",
        LSR_ABS_X   : "lsr",

        NOP         : "nop",

        ORA_IMM     : "ora",
        ORA_ZP      : "ora",
        ORA_ZP_X    : "ora",
        ORA_ABS     : "ora",
        ORA_ABS_X   : "ora",
        ORA_ABS_Y   : "ora",
        ORA_IND_X   : "ora",
        ORA_IND_Y   : "ora",

        PHA         : "pha",
        PHP         : "php",
        PLA         : "pla",
        PLP         : "plp",

        ROL_ACC     : "rol",
        ROL_ZP      : "rol",
        ROL_ZP_X    : "rol",
        ROL_ABS     : "rol",
        ROL_ABS_X   : "rol",

        ROR_ACC     : "ror",
        ROR_ZP      : "ror",
        ROR_ZP_X    : "ror",
        ROR_ABS     : "ror",
        ROR_ABS_X   : "ror",

        RTI         : "rti",
        RTS         : "rts",

        SBC_IMM     : "sbc",
        SBC_ZP      : "sbc",
        SBC_ZP_X    : "sbc",
        SBC_ABS     : "sbc",
        SBC_ABS_X   : "sbc",
        SBC_ABS_Y   : "sbc",
        SBC_IND_X   : "sbc",
        SBC_IND_Y   : "sbc",

        SEC         : "sec",
        SED         : "sed",
        SEI         : "sei",

        STA_ZP      : "sta",
        STA_ZP_X    : "sta",
        STA_ABS     : "sta",
        STA_ABS_X   : "sta",
        STA_ABS_Y   : "sta",
        STA_IND_X   : "sta",
        STA_IND_Y   : "sta",

        STX_ZP      : "stx",
        STX_ZP_Y    : "stx",
        STX_ABS     : "stx",

        STY_ZP      : "sty",
        STY_ZP_X    : "sty",
        STY_ABS     : "sty",

        TAX         : "tax",
        TAY         : "tay",
        TSX         : "tsx",
        TXA         : "txa",
        TXS         : "txs",
        TYA         : "tya",

        // Undocumented
        //SAX         : "sax!",
    ];
}