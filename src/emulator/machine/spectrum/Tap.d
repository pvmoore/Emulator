module emulator.machine.spectrum.Tap;

import emulator.machine.spectrum.all;
import std.stdio : File, writefln;
import std.format: format;
import emulator.util;

/**
 *  https://sinclair.wiki.zxnet.co.uk/wiki/TAP_format
 *  https://worldofspectrum.org/faq/reference/formats.html
 */
class Tap : Loader {
private:
    static struct Header { static assert(Header.sizeof==17); align(1):
        ubyte type;
        char[10] filename;
        ushort dataLength;
        ushort param1;
        ushort param2;
    }
    Header header;
    MemBlock[] memBlocks;
    ushort autoStartLine;
    ubyte[] basicProgram;
    ubyte[] basicData;
public:
    static struct MemBlock {
        ushort address;
        string filename;
        ubyte[] data;
        string toString() {
            return "MemBlock(%04x, '%s' %s bytes)".format(address, filename, data.length);
        }
    }

    MemBlock[] getMemBlocks() { return memBlocks; }
    ushort getAutoStartLine() { return autoStartLine; }
    ubyte[] getBasicProgram() { return basicProgram; }
    ubyte[] getBasicData()    { return basicData; }

    this(string filename) {
        open(filename);
    }

    override Tap load() {
        scope(exit) close();

        while(numBytesLoaded < size) {
            uint length = readWord();
            ubyte[] buf = read(length);
            decodeBlock(buf);

            //writefln("bytes read = %s / %s", loader.numBytesLoaded, loader.size);
        }
        return this;
    }

    void decodeBlock(ubyte[] buf) {
        ubyte flag = buf[0];
        //writefln("===============================");
        //writefln("BLOCK:: length = %s flag = %s", buf.length, flag);
        //writefln("%s", buf);

        if(buf.length == 19 && flag==0) {
            decodeHeader(buf);
        } else if(flag==0xff) {
            decodeHeaderlessData(buf);
        } else {
            throw new Exception("Bad format. flag = %02x length = %s".format(flag, buf.length));
        }
    }
private:
    void decodeHeader(ubyte[] buf) {
        //writefln("HEADER:: type = %s", buf[1]);

        this.header = *cast(Header*)(buf.ptr+1);
        writefln("  %s", header);
    }
    void decodeHeaderlessData(ubyte[] buf) {
        writefln("HEADERLESS_DATA:: type=%s %s bytes", header.type, buf.length-2);

        if(header.type==0) {
            // program data
            this.autoStartLine = header.param1;
            auto dataStart = header.param2;

            // if(basicProgram.length == 0) {
            //     writefln("buf.length = %s", buf.length);
            //     writefln("dataStart = %s", header.param2);

                this.basicProgram = buf[1..dataStart+1];
                this.basicData = buf[dataStart+1..$-1];
            //}
        } else if(header.type==3) {
            memBlocks ~= MemBlock(header.param1, getFilename(header.filename), buf[1..$-1]);
        } else {
            throw new Exception("Unsupported header.type %s".format(header.type));
        }
    }
    string getFilename(char[] chars) {
        auto i = chars.length-1;
        while(i>0 && chars[i]==32) { i--; }
        return chars[0..i+1].idup;
    }
    // void decodeNumberArray(ubyte[] buf) {
    //     writefln("decodeNumberArray");
    // }
    // void decodeCharArray(ubyte[] buf) {
    //     writefln("decodeCharArray");
    // }
    // void decodeCode(ubyte[] buf) {
    //     writefln("decodeCode");
    // }
}