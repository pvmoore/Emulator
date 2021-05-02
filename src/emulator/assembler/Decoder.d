module emulator.assembler.Decoder;

import emulator.assembler.all;

interface Decoder {
    static class Decoding {
        bool match;
        string[] tokens;
        int numBytes;
        int numLiteralBytes;
        int literalTokenIndex;

        void reset() {
            match = false;
            tokens.length = 0;
            numBytes = 0;
            numLiteralBytes = 0;
            literalTokenIndex = 0;
        }
    }

    void decode(Decoding decoding, ubyte[] code);
}