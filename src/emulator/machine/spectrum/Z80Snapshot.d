module emulator.machine.spectrum.Z80Snapshot;

import emulator.machine.spectrum.all;
import emulator.chips.z80.all;

/**
 *  https://worldofspectrum.org/faq/reference/z80format.htm
 */
final class Z80Snapshot : Loader {
private:
public:
    this(string filename) {
        open(filename);
    }
    override void load(Z80 cpu) {
        readHeader(cpu);
        readMem(cpu);
    }
private:
    void readHeader(Z80 cpu) {
        State state = cpu.state;

        auto header = read(30);

        state.A = header[0];
        state.F = header[1];
        state.C = header[2];
        state.B = header[3];
        state.L = header[4];
        state.H = header[5];
        state.PC = (header[7]<<8) | header[6];
        state.SP = (header[9]<<8) | header[8];
        state.I = header[10];
        state.R = header[11];
        ubyte bits = header[12];
        if(bits==0xff) bits = 1;
        state.E = header[13];
        state.D = header[14];
        state.BC1 = (header[16]<<8) | header[15];
        state.DE1 = (header[18]<<8) | header[17];
        state.HL1 = (header[20]<<8) | header[19];
        state.AF1 = (header[21]<<8) | header[22];   // [21] A', [22] F'
        state.IY = (header[24]<<8) | header[23];
        state.IX = (header[26]<<8) | header[25];
        state.IFF1 = header[27] != 0;
        state.IFF2 = header[28] != 0;
        ubyte bits2 = header[29];
        state.IM = bits2 & 3;

        auto version_ = 1;

        if(state.PC != 0) {
            throw new Exception("Version 1 not supported");
        }

        // version 2 or 3

        auto len = readWord();
        auto header2 = read(len);
        writefln("addtnl header block = %s bytes", len);
        writefln("%s", header2);

        if(len == 23) {
            version_ = 2;
        } else if(len == 54 || len == 55) {
            version_ = 3;
        }

        // version 2 properties
        enum {
            PC = 0,
            HWMODE = 2,
            FLAGS = 5,
        }
        state.PC = (header2[PC+1]<<8) | header2[PC];
        ubyte hwmode = header2[HWMODE];
        ubyte flags = header2[FLAGS];

        writefln("pc = %04x", state.PC);
        writefln("hardware mode = %s", hwmode);
        writefln("flags = %02x", flags);

        writefln("version = %s", version_);

        // version 3 properties
    }
    void readMem(Z80 cpu) {
        while(numBytesLoaded < size) {
            auto page = readPage();
            switch(page.page) {
                case 8:
                    writefln("4000-7fff : %s -> %s bytes", page.data.length, page.uncompressed.length);
                    break;
                case 4:
                    writefln("8000-bfff : %s -> %s bytes", page.data.length, page.uncompressed.length);
                    break;
                case 5:
                    writefln("c000-ffff : %s -> %s bytes", page.data.length, page.uncompressed.length);
                    break;
                default:
                    throw new Exception("Ungandled page %s".format(page.page));
            }
        }

        // auto dataLen = reader.readWord();
        // auto page = reader.readByte();
        // writefln("data length = %s page %s", dataLen, page);
        // auto data = reader.read(dataLen);

        // auto dataLen2 = reader.readWord();
        // auto page2 = reader.readByte();
        // writefln("data length2 = %s page2 %s", dataLen2, page2);
        // auto data2 = reader.read(dataLen2);

        // writefln("size = %s", reader.size);
        // writefln("btes read = %s", reader.numBytesLoaded);


        // auto dataLen3 = reader.readWord();
        // auto page3 = reader.readByte();
        // writefln("data length3 = %s page3 %s", dataLen3, page3);
        // auto data3 = reader.read(dataLen3);

        // writefln("size = %s", reader.size);
        // writefln("btes read = %s", reader.numBytesLoaded);
    }
    static struct Page {
        uint page;
        ubyte[] data;
        ubyte[] uncompressed;
    }
    Page readPage() {
        auto dataLen = readWord();
        auto isCompressed = dataLen != 0xffff;
        dataLen = isCompressed ? dataLen : 16384;

        auto page = readByte();
        auto data = read(dataLen);
        auto decomp = decompress(data);
        return Page(page, data, decomp);
    }
    /**
     * Replace repetitions of at least five equal bytes by a four-byte code [ED,ED,x,y],
     * which stands for "byte y repeated x times". Only sequences of length at least 5
     * are coded.
     *
     * The exception is sequences consisting of ED's; if they are encountered,
     * even two ED's are encoded into [ED,ED,02,ED].
     *
     * Finally, any byte directly following a single ED is not taken into a block,
     * for example [ED,0,0,0,0,0,0] is not encoded into [ED,ED,ED,06,00] but into
     * [ED,00]  [ED,ED,05,00].
     *
     * The block is terminated by an end marker, [00,ED,ED,00].
     */
    ubyte[] decompress(ubyte[] data) {
        ubyte[] temp;
        int i;
        ubyte peek(int offset) {
            if(i+offset>=data.length) return 0;
            return data[i+offset];
        }
        while(i < data.length) {
            auto ch = peek(0);
            if(ch==0xed) {
                if(peek(1)==0xed) {
                    // [ed,ed,x,y] (RLE)
                    auto count = peek(2);
                    auto b = peek(3);
                    foreach(j; 0..count) {
                        temp ~= b;
                    }
                    i+=3;
                } else {
                    // [ed,x]
                    temp ~= ch;
                    temp ~= peek(1);
                    i++;
                }
            } else {
                temp ~= ch;
            }
            i++;
        }
        return temp;
    }
}