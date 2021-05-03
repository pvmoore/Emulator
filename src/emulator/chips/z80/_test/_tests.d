module emulator.chips.z80._test._tests;

import emulator.chips.z80.all;
import emulator.component.Memory;
import std.string : lineSplitter, strip;

__gshared Z80 cpu;
__gshared Memory mem;
__gshared Bus bus;
__gshared Assembler assembler;
__gshared Disassembler disassembler;
__gshared State state;
__gshared State prevState;


enum {
    C   = State.Flag.C,     // carry
    N   = State.Flag.N,     // add/subtract
    PV  = State.Flag.PV,    // parity/overflow
    H   = State.Flag.H,     // half carry
    Z   = State.Flag.Z,     // zero
    S   = State.Flag.S      // sign
}

void writeBytes(uint addr, ubyte[] bytes) {
    foreach(i; 0..cast(uint)bytes.length) {
        bus.write(addr + i, bytes[i]);
    }
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
    mem = new Memory(65536);
    bus = new Bus().add(mem);
    cpu = new Z80();
    assert(cpu);
    assert(mem);
    assert(bus);
    cpu.addBus(bus);

    assembler = createZ80Assembler();
    disassembler = createZ80Disassembler();
    state = cpu.state;
}
void executeCode(ubyte[] code, long count, bool dumpState = true) {
    cpu.load(0x1000, code);
    cpu.setPC(0x1000);

    prevState = state.clone();

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
    writefln("source lines = %s", sourceLines);

    // Assemble source
    assembler.reset();
    auto aLines = assembler.encode(source);
    //writefln("aLines = %s", aLines);
    assert(aLines.length==sourceLines.length,
        "aLines.length = %s, sourceLines.length = %s".format(aLines.length, sourceLines.length));
    auto encoded = extractCode(aLines);
    //writefln("code == %s", encoded);
    assert(encoded == code, "%s != %s".format(encoded, code));

    // Disassemble code
    auto dLines = disassembler.decode(code, 0);
    //writefln("dLines = %s", dLines);
    assert(dLines.length==sourceLines.length);
    foreach(i, l; dLines) {
        assert(concatAndRemoveSpace(l.tokens) == removeSpace(sourceLines[i]),
            "%s != %s".format(concatAndRemoveSpace(l.tokens), removeSpace(sourceLines[i])));
    }

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

        auto aLines = assembler.encode(src);
        auto code = extractCode(aLines);
        string[] sourceLines = getSourceLines(src);

        executeCode(code, sourceLines.length);

        assertFlagsSet(expectSet);
        assertFlagsClear(expectClear);
        if(postAssert) postAssert();
    }
}


unittest {



//##################################################################################################

void add_adc() {
    cpu.reset();
}
void sub_sbc() {
    cpu.reset();
}
void shift_and_roll() {
    cpu.reset();
}
void jumps() {
    cpu.reset();
}
void call_ret() {
    cpu.reset();
}
void push_pop() {
    cpu.reset();
}
void in_out() {
    cpu.reset();
}
void rst() {
    cpu.reset();
}

} // unittest
