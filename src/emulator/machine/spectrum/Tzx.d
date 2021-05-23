module emulator.machine.spectrum.Tzx;

import emulator.machine.spectrum.all;
import std.stdio : File, writefln;
import std.format: format;

/**
 *  http://k1.spdns.de/Develop/Projects/zasm/Info/TZX%20format.html#TEXTDESCR
 */
final class Tzx : Tap {
private:
    ubyte[] data;
    ushort startAddress;
public:
    this(string filename) {
        super(filename);
    }
    override Tap load() {
        scope(exit) close();
        // writefln("size = %s", reader.size);

        ubyte[] header = read(10);
        if(cast(char[])header[0..7] != "ZXTape!" || header[7]!=0x1a) {
            throw new Exception("This is not a TZX file");
        }
        auto major = header[8];
        auto minor = header[9];
        //writefln("%s.%s", major, minor);

        // 1.10

        while(numBytesLoaded < size) {
            auto id = readByte();

            switch(id) {
                case 0x10: block10(); break;
                case 0x11: block11(); break;
                case 0x30: block30(); break;
                case 0x32: block32(); break;
                default:
                    throw new Exception("Unhandled block %02x".format(id));
            }
        }

        return this;
    }
private:
    // Standard speed data block
    void block10() {
        auto pause = readWord();
        auto len = readWord();
        auto blk = read(len);

        decodeBlock(blk);
    }
    // Turbo speed block
    void block11() {
        auto pilotPulseLength = readWord();
        auto syncFirstPulseLength = readWord();
        auto syncSecondPulseLength = readWord();
        auto zeroBitPulseLength = readWord();
        auto oneBitPulseLength = readWord();
        auto pilotToneLength = readWord();
        auto lastByteUsedBits = readByte();
        auto pauseLength = readWord();
        auto dataLen = read3bytes();
        auto blk = read(dataLen);

        decodeBlock(blk);
    }
    // Text Description
    void block30() {
        auto len = readByte();
        auto str = cast(char[])read(len);
        writefln("30:: '%s'", str);
    }
    // Archive Info
    void block32() {
        writefln("32::");
        auto len = readWord();
        auto numStrings = readByte();
        foreach(i; 0..numStrings) {
            auto id = readByte();
            auto l = readByte();
            auto chars = cast(char[])read(l);
            writefln("%s: '%s'", id, chars);
        }
    }
}