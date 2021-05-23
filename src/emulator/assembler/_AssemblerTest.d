module emulator.assembler._AssemblerTest;

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
    assert(lines[1].tokens == ["ld", "a", ",", "$01"], "%s".format(lines[1].tokens));

    //-------------------------------------------
    assembler.reset();

    lines = assembler.encode("
N   equ 2
        ld a, (ix+$01)
        ld a, (ix-1)
        ld a, (iy+N)
        ld a, (iy-N)
        ld a, (ix+1+1)
        ld a, (iy-N+1)
    ");

    assert(lines[0].code == [0xdd, 0x7e, 0x01]);
    assert(lines[1].code == [0xdd, 0x7e, 0xff]);
    assert(lines[2].code == [0xfd, 0x7e, 0x02]);
    assert(lines[3].code == [0xfd, 0x7e, 0xfe]);
    assert(lines[4].code == [0xdd, 0x7e, 0x02]);
    assert(lines[5].code == [0xfd, 0x7e, 0xfd]);
}
void asmProblems() {
    assembler.reset();

    auto lines = assembler.encode("
        add	a,'a'-'9'-1
    ");
    // expression tokens: ["'a'", "-", "'9'", "4294967295"])
    // fixup tokens     : 'add a , 'a' - '9' -1'

    // 'a' = 97
    // '9' = 57
    // 97-57-1 = 39 = 0x27
    assert(lines.length==1);
    assert(lines[0].code == [0xc6, 0x27]);
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

    //-------------------------------------------
    assembler.reset();
    lines = assembler.encode("
        ld a, $00   ; 0x0000
        djnz here   ; 0x0002
        inc a       ; 0x0004
here:   inc a       ; 0x0005
    ");
    assert(lines.length == 4);
    assert(lines[1].code == [0x10, 0x03], "%s".format(lines[1].code));

    //------------------------------------------
    assembler.reset();
    lines = assembler.encode("
label1:push af
    ");
    assert(lines.length==1);
}
void immediateLiterals() {
    assembler.reset();

    auto lines = assembler.encode("
        ld a, 16
        ld a, -16
        ld a, $10
        ld a, &10
        ld a, 0x10
        ld a, 010h
    ");

    assert(lines[0].code == [0x3e, 0x10]);
    assert(lines[1].code == [0x3e, 0xf0]);
    assert(lines[2].code == [0x3e, 0x10]);
    assert(lines[3].code == [0x3e, 0x10]);
    assert(lines[4].code == [0x3e, 0x10]);
    assert(lines[5].code == [0x3e, 0x10]);
}
void constants() {
    assembler.reset();

    auto lines = assembler.encode("
a   equ 3
b:  equ 4
c   .equ 5
d   equ 1 + 5
    ");

    assert(lines.length==0);
    assert(assembler.getConstantValue("a") == 3);
    assert(assembler.getConstantValue("b") == 4);
    assert(assembler.getConstantValue("c") == 5);
    assert(assembler.getConstantValue("d") == 6);
}
void dataDB() {
    assembler.reset();

    auto lines = assembler.encode("
n   equ 4
a: db 0, 1, 1+1, n
   db 5
   .db 6
b:
   defb 0xfe
   .byte 99
   db -1
   db -n
   DEFB %00011111,%00011111
    ");

    assert(lines.length==8);
    assert(assembler.getLabelAddress("a") == 0x0000);
    assert(assembler.getLabelAddress("b") == 0x0006);

    assert(lines[0].code == [0x00, 0x01, 0x02, 0x04]);
    assert(lines[0].tokens == []);
    assert(lines[0].labels == ["a"]);

    assert(lines[1].code == [0x05]);
    assert(lines[1].tokens == []);
    assert(lines[1].labels == []);

    assert(lines[2].code == [0x06]);
    assert(lines[3].code == [0xfe]);
    assert(lines[4].code == [99]);
    assert(lines[5].code == [0xff]);
    assert(lines[6].code == [0xfc]);
    assert(lines[7].code == [0x1f, 0x1f]);
}
void dataDW() {
    assembler.reset();

    auto lines = assembler.encode("
n   equ 4
a: dw 0, 1, 1+1, n
   dw 5
   .dw 6
b:
   defw 0xfffe
   .word 99
    ");

    assert(lines.length==5);
    assert(assembler.getLabelAddress("a") == 0x0000);
    assert(assembler.getLabelAddress("b") == 0x000c);

    assert(lines[0].code == [0x00, 0x00, 0x01, 0x00, 0x02, 0x00, 0x04, 0x00]);
    assert(lines[0].tokens == []);
    assert(lines[0].labels == ["a"]);

    assert(lines[1].code == [0x05, 0x00]);
    assert(lines[1].tokens == []);
    assert(lines[1].labels == []);

    assert(lines[2].code == [0x06, 0x00]);
    assert(lines[3].code == [0xfe, 0xff]);
    assert(lines[4].code == [99, 0]);
}
void dataDS() {
    assembler.reset();

    auto lines = assembler.encode("
a:  ds 2
    ds 3
    defs 2, $10
    .block 1
    .blkb 2, 9
    ");

    assert(lines.length==5);
    assert(assembler.getLabelAddress("a") == 0x0000);

    assert(lines[0].code == [0x00, 0x00]);
    assert(lines[1].code == [0x00, 0x00, 0x00]);
    assert(lines[2].code == [0x10, 0x10]);
    assert(lines[3].code == [0x00]);
    assert(lines[4].code == [9, 9]);
}
void dataDM() {
    assembler.reset();

    auto lines = assembler.encode("
N   equ 7
a:  dm 'abc def'
    DEFM 'a\\' '
b   defm 'hello', 255
    defm 'a', 3, 'bc', 1+1, N
data_here
defb 6
    .text 'LOA','D'+$80
    .ascii 'LOA'+$80
    .asciz 'abc'
    ");

    assert(lines.length==8);
    assert(assembler.getLabelAddress("a") == 0x0000);
    assert(assembler.getLabelAddress("b") == 0x000a);
    assert(assembler.getLabelAddress("data_here") == 0x0016);
    assert(lines[0].code == [97, 98, 99, 32, 100, 101, 102]);
    assert(lines[1].code == [97, 39, 32]);
    assert(lines[2].code == [104, 101, 108, 108, 111, 255]);
    assert(lines[3].code == [97, 3, 98, 99, 2, 7]);
    assert(lines[4].code == [0x06]);
    assert(lines[5].code == [0x4c, 0x4f, 0x41, 0xc4]);
    assert(lines[6].code == [0x4c, 0x4f, 0xc1]);
    assert(lines[7].code == [97, 98, 99, 0]);
}

setup();

assemble1();
asmProblems();
labels();
immediateLiterals();
constants();
dataDB();
dataDW();
dataDS();
dataDM();

} // unittest