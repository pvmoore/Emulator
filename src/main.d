module main;

import std.stdio;
import emulator.all;
import emulator.chips.z80.all;
import emulator.machine.spectrum.all;
import std.string : indexOf, strip, split;
import std.format : format;

void main() {

    //auto bbc = new BBCMicro();
    // auto commodore = new C64();
    // auto p = program1();
    // commodore.load(p);
    // commodore.execute();

    //decode();
    //loadTap();
    //loadZ80Snapshot();

    //rewriteZexdoc();

    loadAsm();
}
void rewriteZexdoc() {
    auto load = File("/temp/emulators/spectrum/zexdoc.asm", "rb");
    auto save = File("/temp/emulators/spectrum/zexdoc2.asm", "wb");
    scope(exit) load.close();
    scope(exit) save.close();

    auto str = new char[load.size()];
    load.rawRead(str);
    string dest = cast(string)str;
    writefln("loaded %s chars", str.length);

    while(true) {
        auto i = dest.indexOf("tmsg");
        if(i==-1) break;

        auto q = dest.indexOf("'", i);
        assert(q!=-1);

        auto q2 = dest.indexOf("'", q+1);
        assert(q2!=-1);

        dest = dest[0..i] ~ "dm\t\t" ~ dest[q..q2+1] ~ ",'$' " ~ dest[q2+1..$];
    }
    int count = 0;
    while(true) {
        auto i = dest.indexOf("tstr");
        if(i==-1) break;
        count++;
        auto eol = dest.indexOf(10, i);
        auto sc = dest.indexOf(';', i);
        if(sc!=-1 && sc < eol) eol = sc;
        auto line = dest[i+4..eol].strip();
        auto tokens = line.split(",");

        writefln("line = %s", line);
        writefln("%s", tokens);
        assert(tokens.length==13, "%s count=%s".format(tokens.length, count));

        auto db = "\n\tdb\t" ~ tokens[0] ~ "," ~ tokens[1] ~ "," ~
                           tokens[2] ~ "," ~ tokens[3] ~ "\n";
        auto dw = "\tdw\t" ~ tokens[4] ~ "," ~ tokens[5] ~ "," ~ tokens[6] ~ "," ~
                           tokens[7] ~ "," ~ tokens[8] ~ "," ~ tokens[9] ~ "\n";
        auto db2 = "\tdb\t" ~ tokens[10] ~ "," ~ tokens[11] ~ "\n";
        auto dw2 = "\tdw\t" ~ tokens[12];

        dest = dest[0..i] ~ db ~ dw ~ db2 ~ dw2 ~ dest[eol..$];
    }
    save.rawWrite(dest);
}
void loadAsm() {
    //auto filename = "/temp/emulators/spectrum/spectrum-rom.asm";
    //auto filename = "/temp/emulators/spectrum/jetpac.asm";
    //auto filename = "/temp/emulators/spectrum/manic-miner.asm";
    auto filename = "/temp/emulators/spectrum/zexdoc2.asm";

    auto src = cast(string)From!"std.file".read(filename);

    auto assembler = createZ80Assembler();

    auto lines = assembler.encode(src);
    auto code = lines.extractCode();

    lines._dump();


static if(false) {

    // This won't work. needs rom to be loaded. try running in the UI

    auto cpu = new Z80();
    auto ports = new Z80Ports(cpu.pins);
    auto mem = new Memory(65536);
    auto bus = new Bus().add(ports).add(mem);

    cpu.addBus(bus);

    // Write code to the memory at address 0x8000
    int addr = 0x8000;
    foreach(i; 0..code.length.as!uint) {
        bus.write(addr+i, code[i]);
    }

    cpu.setPC(0x8000);

    foreach(i; 0..100) {
        auto instr = cpu.execute();

        writefln("%s", .toString(instr.tokens));
        writefln("%s", cpu.state);
    }
}
}
void decode() {
    ubyte[] bytes = [243,221,33,0,176,17,17,0,62,0,55,205,86,5,221,33,0,64,17,88,27,62,255,55,205,86,5,195,4,91];
    auto disasm = createZ80Disassembler();
    auto lines = disasm.decode(bytes, 0);
    foreach(l; lines.lines) {
        writefln("%s", l.formatDisassembly());
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