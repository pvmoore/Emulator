module emulator.chips.z80.all;

public:

import std.stdio    : writef, writefln;
import std.format   : format;

import common;

import emulator.Bus;
import emulator.Pins;
import emulator.util;

import emulator.Memory;

import emulator.chips.z80.State;
import emulator.chips.z80.Z80;
import emulator.chips.z80.Z80Decoder;
import emulator.chips.z80.Z80Encoder;
import emulator.chips.z80.Z80Pins;
import emulator.chips.z80.Z80Ports;

import emulator.chips.z80.instr.instructions;
import emulator.chips.z80.instr.instructions_cb;
import emulator.chips.z80.instr.instructions_dd;
import emulator.chips.z80.instr.instructions_ddcb;
import emulator.chips.z80.instr.instructions_ed;
import emulator.chips.z80.instr.instructions_fd;
import emulator.chips.z80.instr.instructions_fdcb;

import emulator.chips.z80.instr.strategies;
import emulator.chips.z80.instr.strategies_cb;
import emulator.chips.z80.instr.strategies_ed;

version(unittest) {
    import emulator.chips.z80._test._tests;
}

import emulator.assembler.all;

Assembler createZ80Assembler() {
    return new Assembler(true, new Z80Encoder());
}
Disassembler createZ80Disassembler() {
    return new Disassembler(true, new Z80Decoder());
}