module main;

import std.stdio;
import emulator.all;
import emulator.chips.z80.all;

void main() {

    //auto bbc = new BBCMicro();
    // auto commodore = new C64();
    // auto p = program1();
    // commodore.load(p);
    // commodore.execute();

    auto src = cast(string)From!"std.file".read("/temp/spectrum/test1.asm");

    auto assembler = createZ80Assembler();
        //.fromFile("/temp/spectrum/aticatac.asm");
        //.fromFile("/temp/spectrum/test1.asm");
        //.fromFile("/temp/spectrum/test1.asm");

    auto lines = assembler.encode(src);

    foreach(l; lines) {
        writefln("%s", l);
    }

}

ubyte[] program1() {
    ubyte[] program = [
        LDA_IMM, 0x50
    ];
    return program;
}