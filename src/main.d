module main;

import std.stdio;
import emulator.all;
import emulator.chips.z80.all;
import emulator.machine.spectrum.all;

void main() {

    //auto bbc = new BBCMicro();
    // auto commodore = new C64();
    // auto p = program1();
    // commodore.load(p);
    // commodore.execute();

    //decode();
    loadTap();
    //loadZ80Snapshot();
}
void loadAsm() {
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
void decode() {
    ubyte[] bytes = [243,221,33,0,176,17,17,0,62,0,55,205,86,5,221,33,0,64,17,88,27,62,255,55,205,86,5,195,4,91];
    auto disasm = createZ80Disassembler();
    auto lines = disasm.decode(bytes, 0);
    foreach(l; lines) {
        writefln("%s", formatDisassembly(l.tokens));
    }
}
void loadTap() {
    auto filename = "/temp/emulators/spectrum/";
    //filename ~= "jetsetwilly.tap";
    filename ~= "manic-miner.tap";
    //filename ~= "avalon.tap";
    //filename ~= "aticatac.tap";
    //filename ~= "pssst.tap";
    //filename ~= "knightlore.tap";
    //filename ~= "sabrewulf.tap";
    //filename ~= "nightshade.tap";
    //filename ~= "underwurlde.tap";
    //filename ~= "Dynamite-Dan2.tap"; // obfuscated basic program

    //filename ~= "Wheelie.tzx"; // has obfuscated basic program
    //filename ~= "jetpac.tzx";
    //filename ~= "manic-miner.tzx";
    //filename ~= "Dynamite-Dan.tap";
    //filename ~= "scrabble.tzx";
    //filename ~= "skool daze.tzx"; // obfuscated basic
    //filename ~= "The Hobbit v1.0.tzx";
    //filename ~= "valhalla.tzx";
    //filename ~= "Chuckie Egg.tzx";
    //filename ~= "Chuckie Egg 2.tzx";
    //filename ~= "Doomdarks-Revenge.tap";
    //filename ~= "lords-of-midnight.tap";
    //filename ~= "back2skool.tap";
    //filename ~= "jet set willy2.tzx";
    //filename ~= "monty-mole.tap"; // broken

    auto tap = Loader.loadTape(filename);
    writefln("======================================== %s", filename);
    writefln("autoStart line: %s", tap.getAutoStartLine());
    writefln("%s", decodeBASIC(tap.getBasicProgram()));
    writefln("Data: %s", tap.getBasicData());
    foreach(m; tap.getMemBlocks()) {
        writefln("  %s", m);
    }
    writefln("========================================");
}
void loadZ80Snapshot() {
    auto filename = "/temp/emulators/spectrum/jetsetwilly.z80";
    auto snap = new Z80Snapshot(filename);
    auto z80 = new Z80();
    snap.load(z80);
}