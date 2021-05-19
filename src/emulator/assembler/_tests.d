module emulator.assembler._tests;

import emulator.assembler.all;
import emulator.chips.z80.all;

unittest {

__gshared Assembler assembler;
__gshared Disassembler disassembler;

void setup() {
    assembler = createZ80Assembler();
    disassembler = createZ80Disassembler();
}

void assemble1() {
    assembler.reset();

    auto lines = assembler.encode("

    ");
    assert(lines.length == 0);

    //-------------------------------------------
    assembler.reset();
    lines = assembler.encode("
        nop
        ld a, $01
    ");
    assert(lines.length == 2);

    assert(lines[0].address == 0x0000);
    assert(lines[0].code == [0x00]);
    assert(lines[0].tokens == ["nop"]);

    assert(lines[1].address == 0x0001);
    assert(lines[1].code == [0x3e, 0x01]);
    assert(lines[1].tokens == ["ld", "a", ",", "$01"]);

    //-------------------------------------------

}
void labels() {
    assembler.reset();
    auto lines = assembler.encode("
label1:
label2:
    nop
    ");
    assert(lines.length == 1);
    assert(lines[0].address == 0x0000);
    assert(lines[0].tokens == ["nop"]);
    assert(lines[0].labels == ["label1", "label2"]);

    //-------------------------------------------
    assembler.reset();
    lines = assembler.encode("
l1: nop
l2:
l3:

    nop
    ");
    // l1:      nop ; 0x0000
    // l2: l3:  nop ; 0x0001

    assert(lines.length == 2);
    assert(lines[0].address == 0x0000);
    assert(lines[0].tokens == ["nop"], "%s".format(lines[0].tokens));
    assert(lines[0].labels == ["l1"], "%s".format(lines[0].labels));

    assert(lines[1].address == 0x0001);
    assert(lines[1].tokens == ["nop"]);
    assert(lines[1].labels == ["l2", "l3"]);

    //-------------------------------------------
    assembler.reset();
    lines = assembler.encode("
        ld a, $00   ; 0x0000
        jp here     ; 0x0002
        inc a       ; 0x0005
here:   inc a       ; 0x0006
    ");

    assert(lines.length == 4);
    assert(lines[3].address == 0x0006);
    assert(lines[1].code == [0xc3, 0x06, 0x00]);

    //-------------------------------------------
    assembler.reset();
    lines = assembler.encode("
        ld a, $00   ; 0x0000
        jr here     ; 0x0002
        inc a       ; 0x0004
here:   inc a       ; 0x0005
    ");
    assert(lines.length == 4);
    assert(lines[1].code == [0x18, 0x03], "%s".format(lines[1].code));
}
void constants() {

}

setup();
assemble1();
labels();
constants();

} // unittest