module emulator.chips.z80.Z80Decoder;

import emulator.chips.z80.all;
import emulator.assembler.all;

/**
 * Decode Z80 assembly bytes
 */
final class Z80Decoder : Decoder {
    this() {

    }
    override void decode(Decoding dec, ubyte[] code) {
        assert(code.length>0);

        auto a = code[0];
        const(Instruction)* instr;
        int numBytes = 1;

        switch(a) {
            case 0xCB: {
                if(code.length>1) {
                    numBytes++;
                    auto b = code[1];
                    instr = &groupCB[b];
                }
                break;
            }
            case 0xDD: {
                if(code.length>1) {
                    numBytes++;
                    auto b = code[1];
                    instr = &groupDD[b];
                }
                break;
            }
            case 0xED: {
                if(code.length>1) {
                    numBytes++;
                    auto b = code[1];
                    instr = &groupED[b];
                }
                break;
            }
            case 0xFD: {
                if(code.length>1) {
                    numBytes++;
                    auto b = code[1];
                    instr = &groupFD[b];
                }
                break;
            }
            default:
                instr = &primary[a];
                break;
        }
        dec.match = instr.isValid();

        if(dec.match) {
            auto numLiteralBytes = instr.numExtraBytes();

            dec.numLiteralBytes = numLiteralBytes;
            dec.numBytes = numBytes + numLiteralBytes;

            if(instr.alt.contains("ix") || instr.alt.contains("iy")) {
                // Prefer the alt tokens if this is a DD or FD instruction
                dec.tokens = instr.alt.dup;
            } else {
                dec.tokens = instr.tokens.dup;
            }
        }
    }
private:

}