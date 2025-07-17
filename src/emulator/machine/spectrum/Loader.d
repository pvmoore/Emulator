module emulator.machine.spectrum.AbsLoader;

import emulator.machine.spectrum.all;
import emulator.chips.z80.all;
import std.stdio : File, writefln;
import std.string : toLower;
import common.utils : endsWith;
import std.path : extension;

/**
 *  Non-standard loading schemes that may not work:
 *  https://www.alessandrogrussu.it/loading/Schemes/schemes.html
 */
abstract class Loader {
protected:
    string filename;
    File file;
    uint size;
    uint numBytesLoaded;
public:
    static Tap loadTape(string filename) {
        string e = extension(filename).toLower();
        switch(e) {
            case ".tap": return new Tap(filename).load();
            case ".tzx": return new Tzx(filename).load();
            default: throw new Exception("Unsupported file type");
        }
        assert(false);
    }
    Tap load()         { throw new Exception("Unsupported"); }
    void load(Z80 cpu) { throw new Exception("Unsupported"); }
protected:
    void open(string filename) {
        this.file = File(filename, "rb");
        this.size = cast(uint)file.size();
        this.numBytesLoaded = 0;
    }
    void close() {
        file.close();
    }
    uint readByte() {
        ubyte[1] b;
        file.rawRead(b);
        numBytesLoaded++;
        return b[0];
    }
    uint readWord() {
        ubyte[2] b;
        file.rawRead(b);
        numBytesLoaded+=2;
        return b[0] | (b[1]<<8);
    }
    uint read3bytes() {
        ubyte[3] b;
        file.rawRead(b);
        numBytesLoaded+=3;
        return b[0] | (b[1]<<8) | (b[2]<<16);
    }
    ubyte[] read(uint len) {
        ubyte[] b = new ubyte[len];
        file.rawRead(b);
        numBytesLoaded+=len;
        return b;
    }
private:
    // Tap loadTap(string filename) {
    //     auto tap = new Tap();
    //     tap.load(this, filename);
    //     return tap;
    //     // open(filename);
    //     // scope(exit) close();
    //     // auto tap = new Tap();
    //     // while(numBytesLoaded < size) {
    //     //     uint length = readWord();
    //     //     ubyte[] buf = read(length);
    //     //     tap.decodeBlock(buf);

    //     //     //writefln("bytes read = %s / %s", reader.numBytesLoaded, reader.size);
    //     // }
    //     // return tap;
    // }
}
