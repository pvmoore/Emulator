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
            "bc","de","hl","sp","ix","iy",
        ]);
        this.CC = new Set!string;
        this.CC.add(["c", "nc", "z", "nz", "po", "pe", "p", "m"]);
    }
    @Implements("Encoder")
    void encode(Encoder.Encoding enc, string[] asmTokens) {
        //writefln("encode %s", asmTokens);

        match.reset();

        match.possibleCC = checkForCC(asmTokens[0]);

        findInstruction(asmTokens);

        if(match.instr) {

            if(match.hashBytes[0]!=0) {
                enc.bytes ~= match.hashBytes;
            }
            enc.bytes ~= match.instr.code;

            handleAwkwardInstructions(enc, asmTokens);

            foreach(f; match.fixups) {
                enc.fixups = match.fixups.dup;

                foreach(n; 0..f.numBytes) {
                    enc.bytes ~= 0;
                }
            }

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

    void findInstruction(string[] tokens) {
        handleSpecialCases(tokens);

        string opcode = tokens[0];

        foreach(i, h; hashes) {
            if(checkHash(h, opcode, tokens)) {
                match.hashBytes = prefixes[i].dup;
                return;
            }
        }
    }
    /** Prepare 'rst' instructions */
    void handleSpecialCases(string[] tokens) {
        // rst - convert decimal to hex and remove $ or &
        if(tokens.length==2 && "rst"==tokens[0]) {
            auto n = tokens[1];
            if(n.startsWith("$") || n.startsWith("&")) {
                tokens[1] = tokens[1][1..$];
            } else if(!n.isOneOf("10", "18", "20", "28", "30", "38")) {
                tokens[1] = "%02x".format(tokens[1].to!int(10));
            }
        }
    }
    /** Fix the two awkward 0x36 cases */
    void handleAwkwardInstructions(Encoder.Encoding enc, string[] asmTokens) {
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
    bool checkHash(InstrPtr[][string] h, string opcode, string[] tokens) {
        auto p = opcode in h;
        if(p) {
            foreach(i; *p) {
                //writefln("  %s %s", i.code, i.tokens);
                if(matchesInstruction(tokens, i)) {
                    match.instr = i;
                    return true;
                }
            }
        }
        return false;
    }
    bool matchesInstruction(string[] tokens, InstrPtr i) {
        if(matchesTokens(tokens, i.tokens)) {
            match.isAlt = false;
            return true;
        }
        if(matchesTokens(tokens, i.alt)) {
            match.isAlt = true;
            return true;
        }
        return false;
    }
    bool matchesTokens(string[] asmTokens, const(string[]) instrTokens) {
        for(int i=0; i<asmTokens.length && i<instrTokens.length; i++) {

            auto isn  = isN(asmTokens[i], instrTokens[i]);
            auto isnn = !isn && isNN(asmTokens[i], instrTokens[i]);
            Encoder.Fixup fixup;

            if(isn || isnn) {
                fixup.numBytes = isn ? 1 : 2;
                fixup.tokenIndex = i;
                fixup.isRelative = asmTokens[0] == "jr" ||
                                   asmTokens[0] == "djnz";

                if(asmTokens[i]=="(") {
                    // assume this instruction has indirect memory access
                    // rather than an expression surrounded by brackets
                    return false;
                }

                auto end = matchTokensBackwards(asmTokens, instrTokens);
                if(end != -1) {
                    fixup.tokens = asmTokens[i..end+1];
                    match.fixups ~= fixup;
                    return true;
                } else {
                    return false;
                }

            } else if(asmTokens[i] != instrTokens[i]) {
                return false;
            }
        }
        return asmTokens.length == instrTokens.length;
    }
    /**
     * @return last offset of fixup expression or -1 if no match
     */
    int matchTokensBackwards(string[] asmTokens, const(string[]) instrTokens) {
        int a = asmTokens.length.as!int-1;
        int i = instrTokens.length.as!int-1;

        while(a>=0 && i>=0) {
            if(isNN(asmTokens[a], instrTokens[i])) {
                return a;
            } else if(isN(asmTokens[a], instrTokens[i])) {
                return a;
            } else if(asmTokens[a] != instrTokens[i]) {
                break;
            }
            a--;
            i--;
        }
        return -1;
    }
    bool isN(string asmToken, string instrToken) {
        if("%02x"!=instrToken) return false;
        return !REGS.contains(asmToken) && (!match.possibleCC || !CC.contains(asmToken));
    }
    bool isNN(string asmToken, string instrToken) {
        if("%04x"!=instrToken) return false;
        return !REGS.contains(asmToken) && (!match.possibleCC || !CC.contains(asmToken));
    }
    /**
     * @return true if the instruction can possibly contain a CC identifier eg. "nz"
     */
    bool checkForCC(string instrToken) {
        return instrToken.isOneOf("call", "ret", "jp", "jr");
    }
}

