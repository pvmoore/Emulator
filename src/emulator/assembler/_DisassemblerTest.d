module emulator.assembler._DisassemblerTest;

import emulator.assembler.all;
import emulator.chips.z80.all;

unittest {

static if(true) {

__gshared Disassembler disassembler;

void setup() {
    writefln("Disassembler tests");
    disassembler = createZ80Disassembler();
}

void disassemble1() {

    auto lines = disassembler.decode([
        0xdd, 0xcb, 0x07, 0xce
    ], 0, 0);

    assert(lines.length == 1);
    assert(lines[0].tokens == ["set", "1", ",", "(", "ix", "+", "$07", ")"]);
}
void ldIX() {
    auto lines = disassembler.decode([
        0xdd, 0x36, 0x01, 0x88
    ], 0, 0);

    assert(lines.length == 1);
    assert(lines[0].tokens == ["ld", "(", "ix", "+", "$01", ")", ",", "$88"]);
}

setup();

disassemble1();
ldIX();

} // static if
} // unittest