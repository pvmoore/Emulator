module emulator.chips.z80.Z80Encoder;

import emulator.chips.z80.all;
import emulator.assembler.all;

final class Z80Encoder : Encoder {
    this() {
        void _hash(InstrPtr instrs, long length, ref InstrPtr[][string] h) {
            foreach(i; 0..length) {
                InstrPtr ptr = instrs;
                if(ptr.tokens.length > 0) {
                    auto key = ptr.tokens[0];
                    h[key] ~= ptr;
                }
                instrs++;
            }
        }
        _hash(primary.ptr, primary.length, hash);
        _hash(groupCB.ptr, groupCB.length, hashCB);
        _hash(groupDD.ptr, groupDD.length, hashDD);
        _hash(groupED.ptr, groupED.length, hashED);
        _hash(groupFD.ptr, groupFD.length, hashFD);
        _hash(groupDDCB.ptr, groupDDCB.length, hashDDCB);
        _hash(groupFDCB.ptr, groupFDCB.length, hashFDCB);

        this.hashes   = [hash,   hashCB, hashDD, hashED, hashFD, hashDDCB,     hashFDCB];
        this.prefixes = [[0x00], [0xcb], [0xdd], [0xed], [0xfd], [0xdd, 0xcb], [0xfd, 0xcb]];
        this.match    = new Match();
        this.REGS = new Set!string;
        this.REGS.add([
            "a","b","c","d","e","h","l",
            "r", "i",
            "af","af'",
            "bc","de","hl","sp","ix","iy","ixh","ixl","iyh","iyl"
        ]);
        this.CC = new Set!string;
        this.CC.add(["c", "nc", "z", "nz", "po", "pe", "p", "m"]);
    }
    @Implements("Encoder")
    void encode(Encoder.Encoding enc, string[] asmTokens, string[] asmTokensLower) {
        //writefln("encode %s", asmTokens);

        match.reset();

        match.possibleCC = checkForCC(asmTokensLower[0]);

        findInstruction(asmTokens, asmTokensLower);

        if(match.instr) {

            if(match.hashBytes[0]!=0) {
                enc.bytes ~= match.hashBytes;
            }
            enc.bytes ~= match.instr.code;

            handleAwkwardInstructions(enc);

            enc.fixups = match.fixups.dup;

            foreach(i, f; match.fixups) {
                enc.fixups[i].byteIndex = enc.bytes.length.as!int;

                foreach(n; 0..f.numBytes) {
                    enc.bytes ~= 0;
                }
            }

            handleDDCB_FDCB(enc);

            //writefln("  %s fixup num:%s", enc.bytes.map!(it=>"%02x".format(it).array), enc.numFixupBytes);
        } else {
            writefln("no match found: %s", asmTokens);
        }
    }
private:
    alias InstrPtr = const(Instruction)*;
    alias Hash     = InstrPtr[][string];

    Set!string REGS;
    Set!string CC;
    Hash hash;
    Hash hashCB;
    Hash hashDD;
    Hash hashDDCB;
    Hash hashED;
    Hash hashFD;
    Hash hashFDCB;
    Hash[] hashes;
    ubyte[][] prefixes;

    static class Match {
        InstrPtr instr;
        ubyte[] hashBytes;
        bool isAlt;
        bool possibleCC;
        Encoder.Fixup[] fixups;

        void reset() {
            instr = null;
            hashBytes.length = 0;
            isAlt = false;
            possibleCC = false;
            fixups.length = 0;
        }
        override string toString() {
            if(instr is null) return "No match";
            if(hashBytes[0]!=0) return "Match %02x,%02x%s".format(hashBytes, instr.code, isAlt?" ALT" : "");
            return "Match %02x%s".format(instr.code, isAlt?" ALT" : "");
        }
    }

    Match match;

    void findInstruction(string[] asmTokens, string[] asmTokensLower) {
        handleSpecialCases(asmTokensLower);

        string opcode = asmTokensLower[0];

        foreach(i, h; hashes) {
            if(checkHash(h, opcode, asmTokens, asmTokensLower)) {
                match.hashBytes = prefixes[i].dup;
                return;
            }
        }
    }
    /** Prepare 'rst' instructions */
    void handleSpecialCases(string[] asmTokensLower) {
        // rst - convert decimal to hex and remove $ or &
        if(asmTokensLower.length==2 && "rst"==asmTokensLower[0]) {
            auto n = asmTokensLower[1];

            if(n.endsWith("h") || n.startsWith("0x")) {
                asmTokensLower[1] = "%02x".format(convertToInt(n));
            } else if(n.startsWith("$") || n.startsWith("&")) {
                asmTokensLower[1] = asmTokensLower[1][1..$];
            } else if(!n.isOneOf("10", "18", "20", "28", "30", "38")) {
                asmTokensLower[1] = "%02x".format(asmTokensLower[1].to!int(10));
            }
        }
    }
    /** Move displacement byte for ddcb and fdcb instructions */
    void handleDDCB_FDCB(Encoder.Encoding enc) {
        bool filter = enc.bytes.length == 4 &&
                      (enc.bytes[0] == 0xdd || enc.bytes[0] == 0xfd) &&
                      enc.bytes[1] == 0xcb;
        if(filter) {
            // swap displacement byte
            ubyte temp = enc.bytes[2];
            enc.bytes[2] = enc.bytes[3];
            enc.bytes[3] = temp;

            enc.fixups[0].byteIndex--;
        }
    }
    /** Fix the two awkward 0x36 cases */
    void handleAwkwardInstructions(Encoder.Encoding enc) {
        if(enc.bytes.length > 1) {
            auto isDD36 = enc.bytes[0] == 0xdd && enc.bytes[1]==0x36;
            auto isFD36 = enc.bytes[0] == 0xfd && enc.bytes[1]==0x36;

            //  ld (ix+d), n  [0xdd, 0x36, d, n]
            //  ld (iy+d), n  [0xfd, 0x36, d, n]
            // ["ld", "(", "ix", "+", "$01", ")", ",", "$11"]
            if(isDD36 || isFD36) {
                // Split the single Fixup into two

                assert(match.fixups.length == 1);
                match.fixups ~= Encoder.Fixup();

                auto f1 = match.fixups.ptr;
                auto f2 = f1+1;

                auto comma = match.fixups[0].tokens.indexOf(",");
                assert(comma!=-1);
                assert(f1.tokens[comma-1] == ")");
                f2.numBytes = 1;
                f2.tokenIndex = f1.tokenIndex + comma + 1;
                f2.tokens = f1.tokens[comma+1..$].dup;

                f1.tokens = f1.tokens[0..comma-1];
            }
        }
    }
    bool checkHash(InstrPtr[][string] h, string opcode, string[] asmTokens, string[] asmTokensLower) {
        auto p = opcode in h;
        if(p) {
            foreach(i; *p) {
                //writefln("  %s %s", i.code, i.tokens);
                if(matchesInstruction(asmTokens, asmTokensLower, i)) {
                    match.instr = i;
                    return true;
                }
            }
        }
        return false;
    }
    bool matchesInstruction(string[] asmTokens, string[] asmTokensLower, InstrPtr i) {
        if(matchesTokens(asmTokens, asmTokensLower, i.tokens)) {
            match.isAlt = false;
            return true;
        }
        if(matchesTokens(asmTokens, asmTokensLower, i.alt)) {
            match.isAlt = true;
            return true;
        }
        return false;
    }
    bool matchesTokens(string[] asmTokens, string[] asmTokensLower, const(string[]) instrTokens) {
        Encoder.Fixup fixup;
        bool negate;

        for(int i=0; i<asmTokens.length && i<instrTokens.length; i++) {

            const isn  = isN(asmTokensLower[i], instrTokens[i]);
            const isnn = !isn && isNN(asmTokensLower[i], instrTokens[i]);

            if(isn || isnn) {

                if(asmTokens[i]=="(") {
                    // assume this instruction has indirect memory access
                    // rather than an expression surrounded by brackets
                    return false;
                }

                auto end = matchTokensBackwards(asmTokens, asmTokensLower, instrTokens);
                if(end != -1) {
                    fixup.numBytes   = isn ? 1 : 2;
                    fixup.tokenIndex = i;
                    fixup.isRelative = asmTokensLower[0] == "jr" ||
                                       asmTokensLower[0] == "djnz";
                    fixup.negate = negate;
                    fixup.tokens = asmTokens[i..end+1].dup;

                    match.fixups ~= fixup;
                    return true;
                } else {
                    return false;
                }
            } else if(asmTokensLower[i] == "-" && instrTokens[i] == "+") {
                // Allow this to match but remember to negate the displacement later
                negate = true;
            } else if(asmTokensLower[i] != instrTokens[i]) {
                return false;
            }
        }
        return asmTokens.length == instrTokens.length;
    }
    /**
     * @return last offset of fixup expression or -1 if no match
     */
    int matchTokensBackwards(string[] asmTokens, string[] asmTokensLower, const(string[]) instrTokens) {
        int a = asmTokens.length.as!int-1;
        int i = instrTokens.length.as!int-1;

        while(a>=0 && i>=0) {
            if(isNN(asmTokensLower[a], instrTokens[i])) {
                return a;
            } else if(isN(asmTokensLower[a], instrTokens[i])) {
                return a;
            } else if(asmTokensLower[a] != instrTokens[i]) {
                break;
            }
            a--;
            i--;
        }
        return -1;
    }
    bool isN(string asmTokenLower, string instrToken) {
        if("%02x"!=instrToken) return false;
        return !REGS.contains(asmTokenLower) && (!match.possibleCC || !CC.contains(asmTokenLower));
    }
    bool isNN(string asmTokenLower, string instrToken) {
        if("%04x"!=instrToken) return false;
        return !REGS.contains(asmTokenLower) && (!match.possibleCC || !CC.contains(asmTokenLower));
    }
    /**
     * @return true if the instruction can possibly contain a CC identifier eg. "nz"
     */
    bool checkForCC(string instrToken) {
        return instrToken.isOneOf("call", "ret", "jp", "jr");
    }
}

