module emulator.assembler.Disassembler;

import emulator.assembler.all;

final class Disassembler {
    this(bool littleEndian, Decoder decoder) {
        this.littleEndian = littleEndian;
        this.decoder = decoder;
        this.decoding = new Decoder.Decoding();
    }
    Line[] decode(ubyte[] code, uint pc, int offset = 0) {
        writefln("Running disassembler ...");
        writefln("code length = %s", code.length);

        Line[] lines;

        while(offset < code.length.as!int) {
            writefln("%s %s", offset, code.length.as!int);
            lines ~= Line(pc);
            auto line = &lines[$-1];
            decoding.reset();

            decoder.decode(decoding, code[offset..$]);

            if(decoding.match) {
                writefln("match %s num bytes = %s", decoding.tokens, decoding.numBytes);

                line.tokens = decoding.tokens;
                line.code   = code[offset..offset+decoding.numBytes];

                if(decoding.numLiteralBytes == 1) {
                    auto i = decoding.literalTokenIndex;
                    line.tokens[i] = "$" ~ line.tokens[i].format(line.code[decoding.numBytes-1]);
                } else if(decoding.numLiteralBytes == 2) {
                    auto i = decoding.literalTokenIndex;
                    line.tokens[i] = "$" ~ line.tokens[i].format(
                        (line.code[decoding.numBytes-1]<<8) | line.code[decoding.numBytes-2]);
                }

                pc     += decoding.numBytes;
                offset += decoding.numBytes;
            } else {
                writefln("db %02x", code[offset]);

                line.tokens = ["db", "$%02x".format(code[offset])];
                line.code   = code[offset..offset+1];

                pc     += 1;
                offset += 1;
            }
        }

        return lines;
    }
private:
    bool littleEndian;
    Decoder decoder;
    Decoder.Decoding decoding;
}