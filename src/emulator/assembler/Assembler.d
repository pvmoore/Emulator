module emulator.assembler.Assembler;

import emulator.assembler.all;

/**
 *  Generic assembler.
 *  Expects raw string data or an assembly file.
 */
final class Assembler {
    this(Encoder encoder) {
        this.encoder = encoder;
        this.dataDirectives = new Set!string;
        dataDirectives.add([
            "defb", "defw", "db", "dw", ".db", ".dw", ".byte", ".word",
            "defm", "dm", ".dm", ".text", ".ascii", ".asciiz",
            "defs", "ds", ".ds", ".block", "blkb", "data"
        ]);
        this.encoding = new Encoder.Encoding();
        this.encoding.temp = new ubyte[32].ptr;
    }
    auto fromFile(string filename) {
        this.text = cast(string)From!"std.file".read(filename);
        this.lexer = new Lexer(text);
        return this;
    }
    auto fromSource(string text) {
        this.text = text;
        this.lexer = new Lexer(text);
        return this;
    }
    void run() {
        writefln("Running assembler ...");
        this.tokens = lexer.tokenise();
        if(tokens.length==0) return;

        pass1();

        writefln("constants:");
        foreach(c; constants.keys) {
            writefln("  %s = %s", c, constants[c]);
        }
        writefln("labels:");
        foreach(k,v; labelToAddress) {
            writefln("  %s: addr %s", k, v);
        }

        writefln("fixups:");
        foreach(f; fixups) {
            writefln("%s", f);
        }

        pass2();
    }
private:
    Set!string dataDirectives;
    string text;
    Lexer lexer;
    Encoder encoder;
    Token[] tokens;

    static struct Line {
        uint address;
        ubyte[] code;
        string toString() { return "Line(addr:%04x, code:%s)".format(address, code); }
    }
    static struct Fixup {
        int line;
        int numBytes;
        string[] expressionTokens;
    }

    string[][string] constants;     // pass1 - equ
    uint[string] labelToAddress;    // pass1
    uint[uint] lineToAddress;       // pass1

    Line[uint] lines;
    Fixup[] fixups;                 // pass2

    int pos;
    int pc;
    int lineNumber;
    Encoder.Encoding encoding;

    /**
     * Create Line objects for each line of the source.
     * Collect labels, assign labels to lines
     * Collect constants
     * Generate an address per line
     */
    void pass1() {
        pos = 0;
        pc = 0;
        while(pos<tokens.length) {
            auto tup            = fetchLine();
            string[] strings    = tup[0];
            bool startsOnMargin = tup[1];
            int length          = strings.length.as!int;
            assert(length>0);

            lineToAddress[lineNumber] = pc;

            Line line = Line(pc);

            string first  = strings[0].toLower();
            string second = strings.length > 1 ? strings[1].toLower() : "";

            if(dataDirectives.contains(first)) {
                continue;
            }

            if(first.isOneOf("if", "endif", "align", ".align", "macro", "rept", ".rept", "dup",
                            ".dup")) {
                todo();
            }
            if("include"==first) {
                todo();
            }

            if(strings.length > 2) {
                // equ
                if(second.isOneOf("equ", ".equ", ".loc")) {
                    auto key = strings[0];
                    constants[key] = convertNumbersToInt(strings[2..$]);
                    continue;
                }
            }

            // org
            if(strings.length > 1) {
                if(first.isOneOf("org", ".org", ".loc")) {
                    pc = convertToInt(convertToHex(strings[1]));
                    writefln("pc = %s", pc);
                    continue;
                }
            }

            // label
            if(first.endsWith(":")) {
                labelToAddress[first[0..$-1]] = pc;
                if(length==1) continue;
                if(dataDirectives.contains(second)) continue;
            } else if(startsOnMargin) {
                labelToAddress[first] = pc;
                if(length==1) continue;
                if(dataDirectives.contains(second)) continue;
            }

            // if we get here then this is an opcode

            string[] lower = strings.map!(it=>it.toLower()).array;

            encoding.reset();

            encoder.encode(encoding, lower);

            if(encoding.numBytes==0) {
                throw new Exception("Bad instruction on line %s".format(lineNumber+1));
            }

            line.code = encoding.temp[0..encoding.numBytes].dup;

            if(encoding.numFixupBytes>0) {
                uint index = encoding.fixupTokenIndex;

                writefln("fixup index: %s, expression: %s", index, encoding.fixupTokens);

                fixups ~= Fixup(lineNumber, encoding.numFixupBytes, encoding.fixupTokens);
            }

            lines[lineNumber] = line;
            pc += line.code.length.as!int;
        }
    }
    /**
     * Resolve constants and Fixup expressions.
     * Implement Fixups.
     */
    void pass2() {
        auto exprParser = new ExpressionParser!int;
        foreach(k,v; constants) {
            exprParser.addReference(k, v);
        }
        foreach(k,v; labelToAddress) {
            exprParser.addReference(k, v);
        }


        foreach(f; fixups) {
            auto line = f.line in lines;
            auto numBytes = f.numBytes;

            uint value = exprParser.parse(f.expressionTokens);
            writefln("fixup line %s value = %s", f.line+1, value);
            if(numBytes==1) {

            } else if(numBytes==2) {

            } else {
                todo("handle more than 2 fixup bytes");
            }

        }
    }
    Tuple!(string[],bool) fetchLine() {
        lineNumber = tokens[pos].line;
        bool startsOnMargin = tokens[pos].firstColumn;

        writefln("--------------");
        writefln("■ Line %s", lineNumber);
        writefln("--------------");
        string[] strings;
        while(pos<tokens.length && tokens[pos].line == lineNumber) {
            string str = tokens[pos].text(text);
            strings ~= str;
            pos++;
        }
        writefln("  %s", strings);
        return tuple(strings, startsOnMargin);
    }

    /**
     *  Convert an ascii string def to an array of bytes
     */
    ubyte[] convertStringToBytes(string s) {
        return null;
    }
    /**
     * Also remove $ and & characters
     */
    string convertToHex(string dec) {
        if(dec[0]=='$' || dec[0]=='&') {
            return dec[1..$].toLower();
        }
        import std.conv;
        return to!string(to!uint(dec), 16);
    }
    int convertToInt(string hex) {
        import std.conv;
        return to!uint(hex, 16);
    }
    string convertToIntValue(string hex) {
        import std.conv;
        return to!string(to!uint(hex, 16));
    }
    bool isNumber(string value) {
        if(value[0]=='$' || value[0]=='&') return true;
        if(value[0]=='-') value = value[1..$];
        return value[0]>='0' && value[0]<='9';
    }
    string[] convertNumbersToInt(string[] tokens) {
        return tokens.map!(it=>isNumber(it) ? convertToIntValue(convertToHex(it)) : it).array;
    }
}