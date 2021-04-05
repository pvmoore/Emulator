module main;

import std.stdio;
import emulator.all;

void main() {
    writefln("Hello world");

    //auto bbc = new BBCMicro();
    auto commodore = new C64();

    auto p = program1();

    commodore.load(p);

    commodore.execute();


}

ubyte[] program1() {
    ubyte[] program = [
        LDA_IMM, 0x50
    ];
    return program;
}