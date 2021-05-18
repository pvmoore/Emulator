module emulator.chips.z80.Z80Decoder;

import emulator.chips.z80.all;
import emulator.assembler.all;

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
                    instr = &groupED[b - 0x40];
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
        dec.match = instr.strategy !is null;

        if(dec.match) {
            auto numLiteralBytes = instr.numExtraBytes();
            dec.numBytes = numBytes + numLiteralBytes;
            dec.tokens = instr.tokens.dup;
            dec.numLiteralBytes = instr.numExtraBytes();
            dec.literalTokenIndex = instr.indexOfLiteral();
        }
    }
private:

}