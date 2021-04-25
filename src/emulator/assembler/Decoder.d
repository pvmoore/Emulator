module emulator.assembler.Decoder;

import emulator.assembler.all;

interface Decoder {
    static class Decoding {
        bool match;
        string[] tokens;
        int numBytes;

        void reset() {
            match = false;
            tokens.length = 0;
            numBytes = 0;
        }
    }

    void decode(Decoding decoding, ubyte[] code);
}