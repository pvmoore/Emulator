module emulator.assembler.Assembler;

import emulator.assembler.all;

/**
 *  Generic assembler.
 *  Expects raw string data or an assembly file.
 *
 *  TODO - handle data
 */
final class Assembler {

    this(bool littleEndian, Encoder encoder) {
        this.littleEndian = littleEndian;
        this.encoder = encoder;

        this.dataDirectives = new Set!string;
        dataDirectives.add([
            "defb", "defw", "db", "dw", ".db", ".dw", ".byte", ".word",
            "defm", "dm", ".dm", ".text", ".ascii", ".asciiz",
            "defs", "ds", ".ds", ".block", "blkb", "data"
        ]);
        this.encoding = new Encoder.Encoding();
    }
    void reset() {
        constants = null;
        labelToAddress = null;
        addressToLine = null;
        fixups = null;
    }
    Line[] encode(string text) {
        writefln("Running assembler ...");
        this.text = text;
        this.lexer = new Lexer(text);

        this.tokens = lexer.tokenise();
        if(tokens.length==0) return null;

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

        return getLinesInOrder();
    }
    /**
     *  @return the Line at address or an empty Line
     */
    Line getLine(uint pc) {
        return addressToLine.get(pc, Line(0));
    }
private:
    bool littleEndian;
    Set!string dataDirectives;
    string text;
    Lexer lexer;
    Encoder encoder;
    Token[] tokens;

    static struct Fixup {
        uint address;
        uint numBytes;
        string[] expressionTokens;
    }

    string[][string] constants;
    uint[string] labelToAddress;
    Line[uint] addressToLine;
    Fixup[] fixups;

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

            auto line = getLineAtAddress(pc);

            line.tokens = strings;

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
                string label = first[0..$-1];
                line.labels ~= label;
                labelToAddress[label] = pc;
                if(length==1) continue;
                if(dataDirectives.contains(second)) continue;
            } else if(startsOnMargin) {
                labelToAddress[first] = pc;
                line.labels ~= first;
                if(length==1) continue;
                if(dataDirectives.contains(second)) continue;
            }

            // if we get here then this is an opcode

            string[] lower = strings.map!(it=>it.toLower()).array;

            encoding.reset();

            encoder.encode(encoding, lower);

            if(encoding.bytes.length==0) {
                throw new Exception("Bad instruction on line %s".format(lineNumber+1));
            }

            line.code = encoding.bytes.dup;

            if(encoding.numFixupBytes>0) {
                uint index = encoding.fixupTokenIndex;

                writefln("fixup index: %s, expression: %s", index, encoding.fixupTokens);

                fixups ~= Fixup(pc, encoding.numFixupBytes, encoding.fixupTokens);
            }

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
            auto line = getLineAtAddress(f.address);
            auto numBytes = f.numBytes;

            uint value = exprParser.parse(convertNumbersToInt(f.expressionTokens));
            //writefln("fixup address %04x value = %s", f.address, value);
            if(numBytes==1) {
                line.code[$-1] = value.as!ubyte;
            } else if(numBytes==2) {
                if(littleEndian) {
                    line.code[$-2] = (value & 0xff).as!ubyte;
                    line.code[$-1] = ((value>>>8) & 0xff).as!ubyte;
                } else {
                    line.code[$-2] = ((value>>>8) & 0xff).as!ubyte;
                    line.code[$-1] = (value & 0xff).as!ubyte;
                }
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
    Line[] getLinesInOrder() {
        import std;
        // Sort by address
        Line[] a = addressToLine.values().filter!(it=>!it.isEmpty()).array;
        sort!"a.address < b.address"(a);
        return a;
    }
    Line* getLineAtAddress(uint pc) {
        auto p = pc in addressToLine;
        if(!p) {
            addressToLine[pc] = Line(pc);
            return getLineAtAddress(pc);
        }
        return p;
    }
}