module emulator.chips._6502.all;

public:

import std.stdio    : writef, writefln;
import std.format   : format;

import common;

import emulator.Bus;
import emulator.util;

import emulator.chips._6502._6502;
import emulator.chips._6502.instructions;

version(unittest) {
    import emulator.chips._6502._tests;
}