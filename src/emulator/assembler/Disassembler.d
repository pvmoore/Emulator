module emulator.assembler.Disassembler;

import emulator.assembler.all;

final class Disassembler {
    this(bool littleEndian, Decoder decoder) {
        this.littleEndian = littleEndian;
        this.decoder = decoder;
        this.decoding = new Decoder.Decoding();
    }
    Lines decode(ubyte[] code, uint pc, int offset = 0) {
        log("Running disassembler ...");
        log("code length = %s", code.length);

        Line[] lines;

        while(offset < code.length.as!int) {
            log("%s %s", offset, code.length.as!int);
            lines ~= Line.atAddress(pc);
            auto line = &lines[$-1];
            decoding.reset();

            decoder.decode(decoding, code[offset..$]);

            if(decoding.match) {
                log("match %s num bytes = %s", decoding.tokens, decoding.numBytes);

                line.tokens = decoding.tokens;
                line.code   = code[offset..offset+decoding.numBytes];

                auto literalIndex = decoding.literalBytesIndex;

                foreach(i, tok; line.tokens) {
                    if(tok=="%02x") {
                        line.tokens[i] = "$" ~ line.tokens[i].format(line.code[literalIndex]);
                        literalIndex++;
                    } else if(tok=="%04x") {
                        line.tokens[i] = "$" ~ line.tokens[i].format(
                            line.code[literalIndex] | (line.code[literalIndex+1]<<8)
                        );
                        literalIndex += 2;
                    }
                }

                pc     += decoding.numBytes;
                offset += decoding.numBytes;
            } else {
                log("db %02x", code[offset]);

                line.tokens = ["db", "$%02x".format(code[offset])];
                line.code   = code[offset..offset+1];

                pc     += 1;
                offset += 1;
            }
        }

        return new Lines(lines);
    }
private:
    void log(A...)(string fmt, A args) {
        static if(false)
            format(fmt, args);
    }
    bool littleEndian;
    Decoder decoder;
    Decoder.Decoding decoding;
}