module emulator.assembler.Disassembler;

import emulator.assembler.all;

final class Disassembler {
    this(bool littleEndian, Decoder decoder) {
        this.littleEndian = littleEndian;
        this.decoder = decoder;
    }
    auto fromFile(string filename) {
        this.bytes = cast(ubyte[])From!"std.file".read(filename);
        return this;
    }
    auto fromBytes(ubyte[] code) {
        this.bytes = code;
        return this;
    }
    void decode() {
        
    }
private:
    bool littleEndian;
    Decoder decoder;

    ubyte[] bytes;
}