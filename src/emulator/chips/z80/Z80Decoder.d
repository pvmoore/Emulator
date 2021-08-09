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
        bool decLiteralIndex = false;

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
                    if(b==0xcb) {
                        if(code.length > 2) {
                            numBytes++;

                            // displacement comes next
                            auto dis = code[2];
                            decLiteralIndex = true;

                            b = code[3];
                            instr = &groupDDCB[b];
                        }
                    } else {
                        instr = &groupDD[b];
                    }
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
                    if(b==0xcb) {
                        if(code.length > 2) {
                            numBytes++;

                            // displacement comes next
                            auto dis = code[2];
                            decLiteralIndex = true;

                            b = code[3];
                            instr = &groupFDCB[b];
                        }
                    } else {
                        instr = &groupFD[b];
                    }
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
            dec.literalBytesIndex = numBytes;
            dec.tokens = instr.tokens.dup;

            if(decLiteralIndex) {
                // ddcb and fdcb instructions have displacement which is not at the end
                dec.literalBytesIndex--;
            }

            //writefln("DECODED %s %s %s %s", dec.tokens, dec.numBytes, dec.numLiteralBytes, dec.literalBytesIndex);
        }
    }
private:

}