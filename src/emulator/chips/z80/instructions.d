module emulator.chips.z80.instructions;

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
enum Reg {
    A,
    F,
    B,
    C,
    D,
    E,
    H,
    L,
    AF,
    BC,
    DE,
    HL,
    IX,
    IY,
    SP,
    PC
}
enum RegR : ubyte {
    B   = 0,
    C   = 1,
    D   = 2,
    E   = 3,
    H   = 4,
    L   = 5,
    //  = 6,
    A   = 7
}

struct Instruction {
    ubyte code;
    string name;
    uint clocks;
    const Strategy strategy;
    const SrcStrategy src;

    void execute(Z80 cpu, Op op) const {
        strategy.execute(cpu, op, src);
    }
}
struct Op {
    ubyte byte1;
}

__gshared const {
Instruction[16][16] primary = [
    // row 0
    [
        Instruction(0x00, "nop",        4,  _nop),
        Instruction(0x01, "ld bc,nn",   10, _lddd, _nn),
        Instruction(0x02, "ld (bc),a",  7,  _ldbca),
        Instruction(0x03, "inc bc",     6,  _incss),
        Instruction(0x04, "inc b",      4,  _incr),
        Instruction(0x05, "dec b",      4,  _decr),
        Instruction(0x06, "ld b,n",     2,  _ldr, _n),
        Instruction(0x07, "rlca",       4,  _rlca),
        Instruction(0x08, "ex af,af'",  4,  _exaf),
        Instruction(0x09, "add hl,bc",  11, _addhlss),
        Instruction(0x0a, "ld a,(bc)",  7,  _ldabc),
        Instruction(0x0b, "dec bc",     6,  _decss),
        Instruction(0x0c, "inc c",      4,  _incr),
        Instruction(0x0d, "dec c",      4,  _decr),
        Instruction(0x0e, "ld c,n",     2,  _ldr, _n),
        Instruction(0x0f),
    ],
    // row 1
    [
        Instruction(0x10),
        Instruction(0x11, "ld de,nn",   10, _lddd, _nn),
        Instruction(0x12),
        Instruction(0x13, "inc de",     6,  _incss),
        Instruction(0x14, "inc d",      4,  _incr),
        Instruction(0x15, "dec d",      4,  _decr),
        Instruction(0x16, "ld d,n",     2, _ldr, _n),
        Instruction(0x17),
        Instruction(0x18),
        Instruction(0x19, "add hl,de",  11, _addhlss),
        Instruction(0x1a),
        Instruction(0x1b, "dec de",     6,  _decss),
        Instruction(0x1c, "inc e",      4,  _incr),
        Instruction(0x1d, "dec e",      4,  _decr),
        Instruction(0x1e, "ld e,n",     2, _ldr, _n),
        Instruction(0x1f),
    ],
    // row 2
    [
        Instruction(0x20),
        Instruction(0x21, "ld hl,nn",   10, _lddd, _nn),
        Instruction(0x22),
        Instruction(0x23, "inc hl",     6,  _incss),
        Instruction(0x24, "inc h",      4,  _incr),
        Instruction(0x25, "dec h",      4,  _decr),
        Instruction(0x26, "ld h,n",     2,  _ldr, _n),
        Instruction(0x27),
        Instruction(0x28),
        Instruction(0x29, "add hl,hl",  11, _addhlss),
        Instruction(0x2a),
        Instruction(0x2b, "dec hl",     6,  _decss),
        Instruction(0x2c, "inc l",      4,  _incr),
        Instruction(0x2d, "dec l",      4,  _decr),
        Instruction(0x2e, "ld l,n",     2,  _ldr, _n),
        Instruction(0x2f),
    ],
    // row 3
    [
        Instruction(0x30),
        Instruction(0x31, "ld sp,nn",   10, _lddd, _nn),
        Instruction(0x32),
        Instruction(0x33, "inc sp",     6,  _incss),
        Instruction(0x34),
        Instruction(0x35, "dec (hl)",   4,  _decr),
        Instruction(0x36),
        Instruction(0x37),
        Instruction(0x38),
        Instruction(0x39, "add hl,sp",  11, _addhlss),
        Instruction(0x3a),
        Instruction(0x3b, "dec sp",     6,  _decss),
        Instruction(0x3c, "inc a",      4,  _incr),
        Instruction(0x3d, "dec a",      4,  _decr),
        Instruction(0x3e, "ld a,n",     2,  _ldr, _n),
        Instruction(0x3f),
    ],
    // row 4
    [
        Instruction(0x40),
        Instruction(0x41),
        Instruction(0x42),
        Instruction(0x43),
        Instruction(0x44),
        Instruction(0x45),
        Instruction(0x46),
        Instruction(0x47),
        Instruction(0x48),
        Instruction(0x49),
        Instruction(0x4a),
        Instruction(0x4b),
        Instruction(0x4c),
        Instruction(0x4d),
        Instruction(0x4e),
        Instruction(0x4f),
    ],
    // row 5
    [
        Instruction(0x50),
        Instruction(0x51),
        Instruction(0x52),
        Instruction(0x53),
        Instruction(0x54),
        Instruction(0x55),
        Instruction(0x56),
        Instruction(0x57),
        Instruction(0x58),
        Instruction(0x59),
        Instruction(0x5a),
        Instruction(0x5b),
        Instruction(0x5c),
        Instruction(0x5d),
        Instruction(0x5e),
        Instruction(0x5f),
    ],
    // row 6
    [
        Instruction(0x60),
        Instruction(0x61),
        Instruction(0x62),
        Instruction(0x63),
        Instruction(0x64),
        Instruction(0x65),
        Instruction(0x66),
        Instruction(0x67),
        Instruction(0x68),
        Instruction(0x69),
        Instruction(0x6a),
        Instruction(0x6b),
        Instruction(0x6c),
        Instruction(0x6d),
        Instruction(0x6e),
        Instruction(0x6f),
    ],
    // row 7
    [
        Instruction(0x70),
        Instruction(0x71),
        Instruction(0x72),
        Instruction(0x73),
        Instruction(0x74),
        Instruction(0x75),
        Instruction(0x76),
        Instruction(0x77),
        Instruction(0x78),
        Instruction(0x79),
        Instruction(0x7a),
        Instruction(0x7b),
        Instruction(0x7c),
        Instruction(0x7d),
        Instruction(0x7e),
        Instruction(0x7f),
    ],
    // row 68
    [
        Instruction(0x80),
        Instruction(0x81),
        Instruction(0x82),
        Instruction(0x83),
        Instruction(0x84),
        Instruction(0x85),
        Instruction(0x86),
        Instruction(0x87),
        Instruction(0x88),
        Instruction(0x89),
        Instruction(0x8a),
        Instruction(0x8b),
        Instruction(0x8c),
        Instruction(0x8d),
        Instruction(0x8e),
        Instruction(0x8f),
    ],
    // row 9
    [
        Instruction(0x90),
        Instruction(0x91),
        Instruction(0x92),
        Instruction(0x93),
        Instruction(0x94),
        Instruction(0x95),
        Instruction(0x96),
        Instruction(0x97),
        Instruction(0x98),
        Instruction(0x99),
        Instruction(0x9a),
        Instruction(0x9b),
        Instruction(0x9c),
        Instruction(0x9d),
        Instruction(0x9e),
        Instruction(0x9f),
    ],
    // row a
    [
        Instruction(0xa0),
        Instruction(0xa1),
        Instruction(0xa2),
        Instruction(0xa3),
        Instruction(0xa4),
        Instruction(0xa5),
        Instruction(0xa6),
        Instruction(0xa7),
        Instruction(0xa8),
        Instruction(0xa9),
        Instruction(0xaa),
        Instruction(0xab),
        Instruction(0xac),
        Instruction(0xad),
        Instruction(0xae),
        Instruction(0xaf),
    ],
    // row b
    [
        Instruction(0xb0),
        Instruction(0xb1),
        Instruction(0xb2),
        Instruction(0xb3),
        Instruction(0xb4),
        Instruction(0xb5),
        Instruction(0xb6),
        Instruction(0xb7),
        Instruction(0xb8),
        Instruction(0xb9),
        Instruction(0xba),
        Instruction(0xbb),
        Instruction(0xbc),
        Instruction(0xbd),
        Instruction(0xbe),
        Instruction(0xbf),
    ],
    // row c
    [
        Instruction(0xc0),
        Instruction(0xc1),
        Instruction(0xc2),
        Instruction(0xc3),
        Instruction(0xc4),
        Instruction(0xc5),
        Instruction(0xc6),
        Instruction(0xc7),
        Instruction(0xc8),
        Instruction(0xc9),
        Instruction(0xca),
        Instruction(0xcb),
        Instruction(0xcc),
        Instruction(0xcd),
        Instruction(0xce),
        Instruction(0xcf),
    ],
    // row d
    [
        Instruction(0xd0),
        Instruction(0xd1),
        Instruction(0xd2),
        Instruction(0xd3),
        Instruction(0xd4),
        Instruction(0xd5),
        Instruction(0xd6),
        Instruction(0xd7),
        Instruction(0xd8),
        Instruction(0xd9),
        Instruction(0xda),
        Instruction(0xdb),
        Instruction(0xdc),
        Instruction(0xdd),
        Instruction(0xde),
        Instruction(0xdf),
    ],
    // row e
    [
        Instruction(0xe0),
        Instruction(0xe1),
        Instruction(0xe2),
        Instruction(0xe3),
        Instruction(0xe4),
        Instruction(0xe5),
        Instruction(0xe6),
        Instruction(0xe7),
        Instruction(0xe8),
        Instruction(0xe9),
        Instruction(0xea),
        Instruction(0xeb),
        Instruction(0xec),
        Instruction(0xed),
        Instruction(0xee),
        Instruction(0xef),
    ],
    // row f
    [
        Instruction(0xf0),
        Instruction(0xf1),
        Instruction(0xf2),
        Instruction(0xf3),
        Instruction(0xf4),
        Instruction(0xf5),
        Instruction(0xf6),
        Instruction(0xf7),
        Instruction(0xf8),
        Instruction(0xf9),
        Instruction(0xfa),
        Instruction(0xfb),
        Instruction(0xfc),
        Instruction(0xfd),
        Instruction(0xfe),
        Instruction(0xff),
    ]
];
Instruction[] groupCB = [

];
Instruction[] groupDD = [

];
Instruction[] groupED = [

];
Instruction[] groupFD = [

];

} // __gshared const
