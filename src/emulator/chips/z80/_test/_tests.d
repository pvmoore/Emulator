module emulator.chips.z80._test._tests;

import emulator.chips.z80.all;
import std.string : lineSplitter, strip;

pragma(lib, "user32.lib");

__gshared Z80 cpu;
__gshared Memory mem;
__gshared Bus bus;
__gshared Z80Pins pins;
__gshared Z80Ports ports;
__gshared Assembler assembler;
__gshared Disassembler disassembler;
__gshared State state;

enum {
    C   = State.Flag.C,     // carry
    N   = State.Flag.N,     // add/subtract
    PV  = State.Flag.PV,    // parity/overflow
    H   = State.Flag.H,     // half carry
    Z   = State.Flag.Z,     // zero
    S   = State.Flag.S      // sign
}
void resetInstructionData() {
    ubyte[] bytes = new ubyte[100];
    writeBytes(0x1000, bytes);
}
void writeBytes(uint addr, ubyte[] bytes) {
    foreach(i; 0..cast(uint)bytes.length) {
        bus.write(addr + i, bytes[i]);
    }
}
void writePort(ubyte port, ubyte value) {
    pins.setIOReq(true);
    ports.write(port, value);
    pins.setMReq(true);
}
ubyte readPort(ubyte port) {
    pins.setIOReq(true);
    ubyte value;
    ports.read(port, value);
    pins.setMReq(true);
    return value;
}
void assertFlagsSet(State.Flag[] flags...) {
    foreach(f; flags) {
        assert(state.flag(f), "Expecting flag %s to be set".format(f));
    }
}
void assertFlagsClear(State.Flag[] flags...) {
    foreach(f; flags) {
        assert(!state.flag(f), "Expecting flag %s to be clear".format(f));
    }
}
State.Flag[] allFlags() {
    return [C, N, PV, H, Z, S];
}
string removeSpace(string s) {
    string buf;
    if(s.contains(';')) {
        s = s[0..From!"std.string".indexOf(s, ";")];
    }
    foreach(ch; s) {
        if(ch>' ') buf ~= ch;
    }
    return buf;
}
string concatAndRemoveSpace(string[] tokens) {
    string buf;
    foreach(s; tokens) {
        buf ~= strip(s);
    }
    return buf;
}
string[] getSourceLines(string source) {
    return lineSplitter(source).map!(it=>strip(it))
                               .filter!(it=>it.length>0)
                               .filter!(it=>it[0]!=';')
                               .array;
}
void setup() {
    cpu = new Z80();

    ports = new Z80Ports(cpu.pins);
    mem = new Memory(65536);
    bus = new Bus().add(ports).add(mem);

    cpu.addBus(bus);

    assembler = createZ80Assembler();
    disassembler = createZ80Disassembler();
    state = cpu.state;
    pins = cpu.pins;
}
void executeCode(ubyte[] code, long count, bool dumpState = true) {
    {
        // Write code to the memory at address 0x1000
        int addr = 0x1000;
        foreach(i; 0..code.length.as!uint) {
            bus.write(addr+i, code[i]);
        }
    }

    cpu.setPC(0x1000);

    foreach(i; 0..count) {
        auto instr = cpu.execute();
        if(dumpState) {
            writefln("%s", .toString(instr.tokens));
            writefln("%s", cpu.state);
        }
    }
}
void execute(string source) {
    string[] sourceLines = getSourceLines(source);
    assembler.reset();
    auto aLines = assembler.encode(source);
    auto code = extractCode(aLines);
    executeCode(code, sourceLines.length);
}
void test(string source, ubyte[] code) {

    string[] sourceLines = getSourceLines(source);
    //writefln("source lines = %s", sourceLines);

    // Assemble source
    assembler.reset();
    auto aLines = assembler.encode(source);
    // writefln("aLines:");
    // foreach(al; aLines) {
    //    writefln("\t%s", al);
    // }
    assert(aLines.length==sourceLines.length,
        "aLines.length = %s, sourceLines.length = %s".format(aLines.length, sourceLines.length));
    auto encoded = extractCode(aLines);
    //writefln("code == %s", encoded);
    assert(encoded == code, "%s != %s".format(encoded, code));

    // Disassemble code
    auto dLines = disassembler.decode(code, 0);
    // writefln("dLines:");
    // foreach(dl; dLines) {
    //    writefln("\t%s", dl);
    // }
    assert(dLines.length==sourceLines.length, "%s != %s".format(dLines.length, sourceLines.length));
    foreach(i, l; dLines) {
        assert(concatAndRemoveSpace(l.tokens) == removeSpace(sourceLines[i]),
            "%s != %s".format(concatAndRemoveSpace(l.tokens), removeSpace(sourceLines[i])));
    }

    //writefln("execute");

    // Execute
    executeCode(code, sourceLines.length);
}
void test(void function() preState,
          string[] source,
          State.Flag[] expectSet,
          State.Flag[] expectClear,
          void function() postAssert = null)
{

    foreach(src; source) {
        cpu.reset();
        assembler.reset();

        if(preState) preState();

        // Avoid instructions looking like labels
        src = "\t" ~ src;

        auto aLines = assembler.encode(src);
        auto code = extractCode(aLines);
        string[] sourceLines = getSourceLines(src);

        executeCode(code, sourceLines.length);

        assertFlagsSet(expectSet);
        assertFlagsClear(expectClear);
        if(postAssert) postAssert();
    }
}
