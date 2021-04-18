module main;

import std.stdio;
import emulator.all;
import emulator.chips.z80.Z80Encoder;

void main() {

    //auto bbc = new BBCMicro();
    // auto commodore = new C64();
    // auto p = program1();
    // commodore.load(p);
    // commodore.execute();

    auto assembler = new Assembler(new Z80Encoder())
        //.fromFile("/temp/spectrum/aticatac.asm");
        .fromFile("/temp/spectrum/test1.asm");
        //.fromFile("/temp/spectrum/test1.asm");

    assembler.run();


}

ubyte[] program1() {
    ubyte[] program = [
        LDA_IMM, 0x50
    ];
    return program;
}