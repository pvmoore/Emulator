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

    //auto filename = "/temp/emulators/spectrum/spectrum-rom.asm";
    //auto filename = "/temp/emulators/spectrum/jetpac.asm";
    auto filename = "/temp/emulators/spectrum/manic-miner.asm";

    auto src = cast(string)From!"std.file".read(filename);

    auto assembler = createZ80Assembler();

    auto lines = assembler.encode(src);

    foreach(l; lines) {
        writefln("%s", l);
    }

}
