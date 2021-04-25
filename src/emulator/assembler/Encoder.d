module emulator.assembler.Encoder;

import emulator.assembler.all;

interface Encoder {
    static class Encoding {
        ubyte[] bytes;          // encoded bytes

        // Fixup stuff
        int numFixupBytes;      // immediate or address bytes
        int fixupTokenIndex;    // index of fixup within tokens strings (if numFixupBytes!=0)
        string[] fixupTokens;

        void reset() {
            bytes.length = 0;
            numFixupBytes = 0;
            fixupTokenIndex = 0;
            fixupTokens.length = 0;
        }
    }

    void encode(Encoding enc, string[] tokens);
}