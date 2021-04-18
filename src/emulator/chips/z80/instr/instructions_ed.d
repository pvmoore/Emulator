module emulator.chips.z80.instr.instructions_ed;

import emulator.chips.z80.all;

__gshared const {

private enum {
    A = "a", B = "b", C = "c", D = "d", E = "e", H = "h", L = "l", R = "r", I = "i",
    BC = "bc", DE = "de", HL = "hl", SP = "sp",
    LBR = "(", RBR = ")", _ = ",", NN = "%04x",
    ADC = "adc", SBC = "sbc", IN = "in", OUT = "out", LD = "ld", IM = "im",
}

Instruction[256-112] groupED = [ // Starts at 40, ends at bf
// row 4
    Instruction(0x40, _inrc,      [IN, B, _, LBR, C, RBR]),
    Instruction(0x41, _outcr,     [OUT, LBR, C, RBR, _, B]),
    Instruction(0x42, _sbchlss,   [SBC, HL, _, BC]),
    Instruction(0x43, _ldnndd,    [LD, LBR, NN, RBR, _, BC]),
    Instruction(0x44, _neg,       ["neg"]),
    Instruction(0x45, _retn,      ["retn"]),
    Instruction(0x46, _im,        [IM, "0"]),
    Instruction(0x47, _ldia,      [LD, I, _, A]),
    Instruction(0x48, _inrc,      [IN, C, _, LBR, C, RBR]),
    Instruction(0x49, _outcr,     [OUT, LBR, C, RBR, _, C]),
    Instruction(0x4a, _adchhss,   [ADC, HL, _, BC]),
    Instruction(0x4b, _ldddnni,   [LD, BC, _, LBR, NN, RBR]),
    Instruction(0x4c), // nothing here ? neg
    Instruction(0x4d, _reti,      ["reti"]),
    Instruction(0x4e), // nothing here
    Instruction(0x4f, _ldra,      [LD, R, _, A]),
// row 5
    Instruction(0x50, _inrc,      [IN, D, _, LBR, C, RBR]),
    Instruction(0x51, _outcr,     [OUT, LBR, C, RBR, _, D]),
    Instruction(0x52, _sbchlss,   [SBC, HL, _, DE]),
    Instruction(0x53, _ldnndd,    [LD, LBR, NN, RBR, _, DE]),
    Instruction(0x54), // nothing here ? neg
    Instruction(0x55), // nothing here ? retn
    Instruction(0x56, _im,        [IM, "1"]),
    Instruction(0x57, _ldai,      [LD, A, _, I]),
    Instruction(0x58, _inrc,      [IN, E, _, LBR, C, RBR]),
    Instruction(0x59, _outcr,     [OUT, LBR, C, RBR, _, E]),
    Instruction(0x5a, _adchhss,   [ADC, HL, _, DE]),
    Instruction(0x5b, _ldddnni,   [LD, DE, _, LBR, NN, RBR]),
    Instruction(0x5c), // nothing here ? neg
    Instruction(0x5d), // nothing here ? retn
    Instruction(0x5e, _im,        [IM, "2"]),
    Instruction(0x5f, _ldar,      [LD, A, _, R]),
// row 6
    Instruction(0x60, _inrc,      [IN, H, _, LBR, C, RBR]),
    Instruction(0x61, _outcr,     [OUT, LBR, C, RBR, _, H]),
    Instruction(0x62, _sbchlss,   [SBC, HL, _, HL]),
    Instruction(0x63, _ldnndd,    [LD, LBR, NN, RBR, _, HL]),
    Instruction(0x64), // nothing here ? neg
    Instruction(0x65), // nothing here ? retn
    Instruction(0x66), // nothing here
    Instruction(0x67, _rrd,       ["rrd"]),
    Instruction(0x68, _inrc,      [IN, L, _, LBR, C, RBR]),
    Instruction(0x69, _outcr,     [OUT, LBR, C, RBR, _, L]),
    Instruction(0x6a, _adchhss,   [ADC, HL, HL]),
    Instruction(0x6b, _ldddnni,   [LD, HL, _, LBR, NN, RBR]),
    Instruction(0x6c), // nothing here ? neg
    Instruction(0x6d), // nothing here ? retn
    Instruction(0x6e), // nothing here
    Instruction(0x6f, _rld,       ["rld"]),
// row 7
    Instruction(0x70),  // nothing here ? in f, (c)
    Instruction(0x71),  // nothing here ? out (c), f
    Instruction(0x72, _sbchlss,    [SBC, HL, SP]),
    Instruction(0x73, _ldnndd,     [LD, LBR, NN, RBR, _, SP]),
    Instruction(0x74), // nothing here ? neg
    Instruction(0x75), // nothing here ? retn
    Instruction(0x76), // nothing here
    Instruction(0x77), // nothing here
    Instruction(0x78, _inrc,       [IN, A, _, LBR, C, RBR]),
    Instruction(0x79, _outcr,      [OUT, LBR, C, RBR, _, A]),
    Instruction(0x7a, _adchhss,    [ADC, HL, _, SP]),
    Instruction(0x7b, _ldddnni,    [LD, SP, _, LBR, NN, RBR]),
    Instruction(0x7c), // nothing here ? neg
    Instruction(0x7d), // nothing here ? reti
    Instruction(0x7e), // nothing here
    Instruction(0x7f), // nothing here
// row 8
    Instruction(0x80), // nothing here
    Instruction(0x81), // nothing here
    Instruction(0x82), // nothing here
    Instruction(0x83), // nothing here
    Instruction(0x84), // nothing here
    Instruction(0x85), // nothing here
    Instruction(0x86), // nothing here
    Instruction(0x87), // nothing here
    Instruction(0x88), // nothing here
    Instruction(0x89), // nothing here
    Instruction(0x8a), // nothing here
    Instruction(0x8b), // nothing here
    Instruction(0x8c), // nothing here
    Instruction(0x8d), // nothing here
    Instruction(0x8e), // nothing here
    Instruction(0x8f), // nothing here
// row 9
    Instruction(0x90), // nothing here
    Instruction(0x91), // nothing here
    Instruction(0x92), // nothing here
    Instruction(0x93), // nothing here
    Instruction(0x94), // nothing here
    Instruction(0x95), // nothing here
    Instruction(0x96), // nothing here
    Instruction(0x97), // nothing here
    Instruction(0x98), // nothing here
    Instruction(0x99), // nothing here
    Instruction(0x9a), // nothing here
    Instruction(0x9b), // nothing here
    Instruction(0x9c), // nothing here
    Instruction(0x9d), // nothing here
    Instruction(0x9e), // nothing here
    Instruction(0x9f), // nothing here
// row a
    Instruction(0xa0, _ldi,      ["ldi"]),
    Instruction(0xa1, _cpi,      ["cpi"]),
    Instruction(0xa2, _ini,      ["ini"]),
    Instruction(0xa3, _outi,     ["outi"]),
    Instruction(0xa4), // nothing here
    Instruction(0xa5), // nothing here
    Instruction(0xa6), // nothing here
    Instruction(0xa7), // nothing here
    Instruction(0xa8, _ldd,      ["ldd"]),
    Instruction(0xa9, _cpd,      ["cpd"]),
    Instruction(0xaa, _ind,      ["ind"]),
    Instruction(0xab, _outd,     ["outd"]),
    Instruction(0xac), // nothing here
    Instruction(0xad), // nothing here
    Instruction(0xae), // nothing here
    Instruction(0xaf), // nothing here
// row b
    Instruction(0xb0, _ldir,      ["ldir"]),
    Instruction(0xb1, _cpir,      ["cpir"]),
    Instruction(0xb2, _inir,      ["inir"]),
    Instruction(0xb3, _otir,      ["otir"]),
    Instruction(0xb4), // nothing here
    Instruction(0xb5), // nothing here
    Instruction(0xb6), // nothing here
    Instruction(0xb7), // nothing here
    Instruction(0xb8, _lddr,      ["lddr"]),
    Instruction(0xb9, _cpdr,      ["cpdr"]),
    Instruction(0xba, _indr,      ["indr"]),
    Instruction(0xbb, _otdr,      ["otdr"]),
    Instruction(0xbc), // nothing here
    Instruction(0xbd), // nothing here
    Instruction(0xbe), // nothing here
    Instruction(0xbf), // nothing here
];

} // __gshared const