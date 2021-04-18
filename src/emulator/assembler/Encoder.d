module emulator.assembler.Encoder;

import emulator.assembler.all;

interface Encoder {
    static class Encoding {
        int numBytes;           // total num bytes of this encoding
        ubyte* temp;            // temp[0..numBytes] encoded bytes

        // Fixup stuff
        int numFixupBytes;      // immediate or address bytes
        int fixupTokenIndex;    // index of fixup within tokens strings (if numFixupBytes!=0)
        string[] fixupTokens;



        void reset() {
            numBytes = 0;
            numFixupBytes = 0;
            fixupTokenIndex = 0;
            fixupTokens = null;
        }
    }

    /**
     *  @return the Encoding with the actual byte values in _temp_.
     *          Sets numBytes to 0 if the instruction is not known
     *
     *
     */
    void encode(Encoding enc, string[] tokens);
}