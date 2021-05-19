module emulator.assembler.Encoder;

import emulator.assembler.all;

interface Encoder {
    static class Encoding {
        ubyte[] bytes;          // encoded bytes
        Fixup[] fixups;         // Immediate value tokens

        uint totalFixupBytes() {
            uint count = 0;
            foreach(f; fixups) {
                count += f.numBytes;
            }
            return count;
        }

        void reset() {
            bytes.length = 0;
            fixups.length = 0;
        }
    }
    static struct Fixup {
        int numBytes;
        int tokenIndex;
        string[] tokens;
    }

    void encode(Encoding enc, string[] tokens);
}