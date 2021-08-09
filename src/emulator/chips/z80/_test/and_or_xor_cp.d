module emulator.chips.z80._test.and_or_xor_cp;

import emulator.chips.z80.all;
import emulator.chips.z80._test._tests;

unittest {
static if(true) {

enum {
    AND_IX = [0xdd, 0xa6],
    XOR_IX = [0xdd, 0xae],
    OR_IX  = [0xdd, 0xb6],
    CP_IX  = [0xdd, 0xbe],

    AND_IY = [0xfd, 0xa6],
    XOR_IY = [0xfd, 0xae],
    OR_IY  = [0xfd, 0xb6],
    CP_IY  = [0xfd, 0xbe],
}

void and() {
    cpu.reset();

    test("
        and a, a
        and a, b
        and a, c
        and a, d
        and a, e
        and a, h
        and a, l
        and a, (hl)
        and a, $ff

        ;and a, ixh
        ;and a, ixl
        ;and a, ayh
        ;and a, iyl

        and a, (ix + $01)
        and a, (iy + $01)
    ", [0xa7, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xe6, 0xff] ~
       AND_IX ~ [0x01] ~
       AND_IY ~ [0x01]);

    // Flags: H always set, N,C always cleared
    assertFlagsSet(H);
    assertFlagsClear(N, C);

    //-----------------------------------
    test({
        state.A = 0xff;
        state.B = 0xff;
        state.HL = 0x0000;
        state.IX = 0x0000;
        state.IY = 0x0000;
        writeBytes(0, [0xff]);
    },
        ["and a, b",
        "and a, $ff",
        "and $ff",
        "and a, (hl)",
        "and a, (ix+$00)",
        "and a, (iy+$00)"
        ],
        [S, PV],
        [Z]
    );

    test({
        state.A = 0xff;
        state.B = 0x00;
        state.HL = 0x0000;
        state.IX = 0x0000;
        state.IY = 0x0000;
        writeBytes(0, [0x00]);
    },
        ["and a, b",
        "and a, $00",
        "and $00",
        "and a, (hl)",
        "and a, (ix+$00)",
        "and a, (iy+$00)"
        ],
        [Z, PV],
        [S]
    );

    test({
        state.A = 0xff;
        state.B = 0x01;
        state.HL = 0x0000;
        state.IX = 0x0000;
        state.IY = 0x0000;
        writeBytes(0, [0x01]);
    },
        ["and a, b",
        "and a, $01",
        "and $01",
        "and a, (hl)",
        "and a, (ix+$00)",
        "and a, (iy+$00)"
        ],
        [],
        [Z, S, PV]
    );
}
void or() {
    cpu.reset();

    test("
        or a, a
        or a, b
        or a, c
        or a, d
        or a, e
        or a, h
        or a, l
        or a, (hl)
        or a, $ff

        ;or a, ixh
        ;or a, ixl
        ;or a, ayh
        ;or a, iyl

        or a, (ix + $01)
        or a, (iy + $01)
    ", [0xb7, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xf6, 0xff] ~
       OR_IX ~ [0x01] ~
       OR_IY ~ [0x01]);

    // Flags: H,N,C always cleared
    assertFlagsSet();
    assertFlagsClear(H, N, C);

    //--------------------------------
    test({
        state.A = 0xff;
        state.B = 0xff;
        state.HL = 0x0000;
        state.IX = 0x0000;
        state.IY = 0x0000;
        writeBytes(0, [0xff]);
    },
        ["or a, b",
        "or a, $ff",
        "or $ff",
        "or a, (hl)",
        "or a, (ix+$00)",
        "or a, (iy+$00)"
        ],
        [S, PV],
        [Z]
    );

    test({
        state.A = 0x00;
        state.B = 0x00;
        state.HL = 0x0000;
        state.IX = 0x0000;
        state.IY = 0x0000;
        writeBytes(0, [0x00]);
    },
        ["or a, b",
        "or a, $00",
        "or $00",
        "or a, (hl)",
        "or a, (ix+$00)",
        "or a, (iy+$00)"
        ],
        [Z, PV],
        [S]
    );
}
void xor() {
    cpu.reset();

    test("
        xor a, a
        xor a, b
        xor a, c
        xor a, d
        xor a, e
        xor a, h
        xor a, l
        xor a, (hl)
        xor a, $ff

        ;xor a, ixh
        ;xor a, ixl
        ;xor a, ayh
        ;xor a, iyl

        xor a, (ix + $01)
        xor a, (iy + $01)
    ", [0xaf, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xee, 0xff] ~
       XOR_IX ~ [0x01] ~
       XOR_IY ~ [0x01]);

    // Flags: H,N,C always cleared
    //assertFlagsSet();
    assertFlagsClear(H, N, C);

    //--------------------------------
    test({
        state.A = 0xff;
        state.B = 0xff;
        state.HL = 0x0000;
        state.IX = 0x0000;
        state.IY = 0x0000;
        writeBytes(0, [0xff]);
    },
        ["xor a, b",
        "xor a, $ff",
        "xor $ff",
        "xor a, (hl)",
        "xor a, (ix+$00)",
        "xor a, (iy+$00)"
        ],
        [Z, PV],
        [S]
    );

    test({
        state.A = 0x00;
        state.B = 0xff;
        state.HL = 0x0000;
        state.IX = 0x0000;
        state.IY = 0x0000;
        writeBytes(0, [0xff]);
    },
        ["xor a, b",
        "xor a, $ff",
        "xor $ff",
        "xor a, (hl)",
        "xor a, (ix+$00)",
        "xor a, (iy+$00)"
        ],
        [S, PV],
        [Z]
    );
}
void cp() {
    cpu.reset();

    test("
        cp a, a
        cp a, b
        cp a, c
        cp a, d
        cp a, e
        cp a, h
        cp a, l
        cp a, (hl)
        cp a, $ff

        ;cp a, ixh
        ;cp a, ixl
        ;cp a, ayh
        ;cp a, iyl

        cp a, (ix + $01)
        cp a, (iy + $01)

    ", [0xbf, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xfe, 0xff] ~
       CP_IX ~ [0x01] ~
       CP_IY ~ [0x01]);

    // Flags: N is always set
    assertFlagsSet(N);
    assertFlagsClear();

    //--------------------------------
    test({
        state.A = 0xff;
        state.B = 0xff;
        state.HL = 0x0000;
        state.IX = 0x0000;
        state.IY = 0x0000;
        writeBytes(0, [0xff]);
    },
        ["cp a, b",
        "cp a, $ff",
        "cp $ff",
        "cp a, (hl)",
        "cp a, (ix+$00)",
        "cp a, (iy+$00)"
        ],
        [Z],
        [S, C, H, PV]
    );

    test({
        state.A = 0xff;
        state.B = 0x00;
        state.HL = 0x0000;
        state.IX = 0x0000;
        state.IY = 0x0000;
        writeBytes(0, [0x00]);
    },
        ["cp a, b",
        "cp a, $00",
        "cp $00",
        "cp a, (hl)",
        "cp a, (ix+$00)",
        "cp a, (iy+$00)"
        ],
        [S],
        [Z, C, H, PV]
    );

    test({
        state.A = 0xfe;
        state.B = 0xff;
        state.HL = 0x0000;
        state.IX = 0x0000;
        state.IY = 0x0000;
        writeBytes(0, [0xff]);
    },
        ["cp a, b",
        "cp a, $ff",
        "cp $ff",
        "cp a, (hl)",
        "cp a, (ix+$00)",
        "cp a, (iy+$00)"
        ],
        [S, H, C],
        [Z]
    );

    test({
        state.A = 0x7f;
        state.B = 0x81;
        state.HL = 0x0000;
        state.IX = 0x0000;
        state.IY = 0x0000;
        writeBytes(0, [0x81]);
    },
        ["cp a, b",
        "cp a, $81",
        "cp $81",
        "cp a, (hl)",
        "cp a, (ix+$00)",
        "cp a, (iy+$00)"
        ],
        [S, C, PV],
        [Z]
    );
}

writefln("and or xor cp tests");

setup();

and();
or();
xor();
cp();

// state.updateV(0x7f, 0x81, 0xfe);
// state.updateH(0x7f, 0x81, 0xfe);
// writefln("PV = %s", state);

} // static if
} // unittest