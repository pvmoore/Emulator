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
            "db", ".db", "defb", ".byte",
            "dw", ".dw", "defw", ".word",
            "defm", "dm", ".dm", ".text", ".ascii", ".asciz",
            "defs", "ds", ".ds", ".block", ".blkb"
        ]);
        this.encoding = new Encoder.Encoding();
        reset();
    }
    void reset() {
        constants = null;
        labelToAddress = null;
        addressToLine = null;
        fixups = null;

        this.absExprParser = new ExpressionParser!uint;
        this.relExprParser = new ExpressionParser!uint;
    }
    Line[] encode(string text) {
        log("Running assembler ...");
        this.text = text;
        this.lexer = new Lexer(text);

        this.tokens = lexer.tokenise();
        if(tokens.length==0) return null;

        pass1();

        log("constants:");
        foreach(c; constants.keys) {
            log("  %s = %s", c, constants[c]);
        }
        log("labels:");
        foreach(k,v; labelToAddress) {
            log("  %s: addr = %s", k, v);
        }

        log("fixups:");
        foreach(f; fixups) {
            log("%s", f);
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
    uint getConstantValue(string key) {
        return absExprParser.getReference(key);
    }
    uint getLabelAddress(string label) {
        return labelToAddress[label];
    }
private:
    void log(A...)(string fmt, A args) {
        if(false)
            writefln(format(fmt, args));
    }
    bool littleEndian;
    Set!string dataDirectives;
    string text;
    Lexer lexer;
    Encoder encoder;
    Token[] tokens;
    ExpressionParser!uint absExprParser;
    ExpressionParser!uint relExprParser;

    static struct Fixup {
        uint address;
        uint numBytes;
        uint byteIndex;
        bool isRelative;
        bool negate;
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
            line.number = lineNumber;

            string first  = strings[0].toLower();
            string second = strings.length > 1 ? strings[1].toLower() : "";

            if(dataDirectives.contains(first)) {
                data(strings, line);
                continue;
            }

            if(first.isOneOf("if", "endif", "align", ".align", "macro", "rept", ".rept", "dup",
                            ".dup")) {
                todo("implement %s on line %s".format(first, lineNumber));
            }
            if("include"==first) {
                todo();
            }

            if(strings.length > 2) {
                // equ
                if(second.isOneOf("equ", ".equ")) {
                    auto key = strings[0];
                    if(key.endsWith(":")) key = key[0..$-1];
                    //writefln("key = %s %s", key, strings);
                    constants[key] = convertNumbersToInt(strings[2..$]);
                    continue;
                }
            }

            // org
            if(strings.length > 1) {
                if(first.isOneOf("org", ".org", ".loc")) {
                    pc = convertToInt(strings[1]);
                    continue;
                }
            }

            // label
            bool _handleLabel() {
                string label = strings[0].endsWith(":") ? strings[0][0..$-1] : strings[0];
                log("label: %s", label);
                line.labels ~= label;
                labelToAddress[label] = pc;

                if(length==1) return false;

                // Remove the label token
                strings = strings[1..$];

                if(dataDirectives.contains(second)) {
                    data(strings, line);
                    return false;
                }

                return true;
            }
            if(startsOnMargin || first.endsWith(":")) {
                if(!_handleLabel()) continue;
            }

            // ==============================================================
            // If we get here then this is an opcode
            // ==============================================================
            line.tokens = strings;
            string[] lower = strings.map!(it=>it.toLower()).array;

            encoding.reset();

            encoder.encode(encoding, strings, lower);

            if(encoding.bytes.length==0) {
                throw new Exception("Bad instruction on line %s".format(lineNumber+1));
            }

            line.code = encoding.bytes.dup;

            auto j = line.code.length.as!uint - encoding.totalFixupBytes();

            foreach(f; encoding.fixups) {
                uint index = f.tokenIndex;

                log("fixup tokenIindex: %s, byteIndex: %s, expression: %s", index, j, f.tokens);

                fixups ~= Fixup(pc, f.numBytes, j, f.isRelative, f.negate, f.tokens);

                j += f.numBytes;
            }

            pc += line.code.length.as!int;
        }
    }
    /**
     * Resolve constants and Fixup expressions.
     * Implement Fixups.
     */
    void pass2() {
        foreach(k,v; constants) {
            absExprParser.addReference(k, v);
            relExprParser.addReference(k, v);
        }
        foreach(k,v; labelToAddress) {
            absExprParser.addReference(k, v);
            relExprParser.addReference(k, ["(", v.to!string, "-", "$", ")"]);
        }

        foreach(f; fixups) {
            auto line = getLineAtAddress(f.address);
            auto numBytes = f.numBytes;
            auto byteIndex = f.byteIndex;
            try{

                absExprParser.addReference("$", f.address);
                relExprParser.addReference("$", f.address);

                auto tokens = convertNumbersToInt(f.expressionTokens);

                uint value = f.isRelative
                    ? relExprParser.parse(tokens)
                    : absExprParser.parse(tokens);

                if(f.negate) {
                    value = -value;
                }

                //log("fixup address %04x value = %s", f.address, value);

                if(numBytes==1) {
                    line.code[byteIndex] = value.as!ubyte;
                } else if(numBytes==2) {
                    if(littleEndian) {
                        line.code[byteIndex+0] = (value & 0xff).as!ubyte;
                        line.code[byteIndex+1] = ((value>>>8) & 0xff).as!ubyte;
                    } else {
                        line.code[byteIndex+0] = ((value>>>8) & 0xff).as!ubyte;
                        line.code[byteIndex+1] = (value & 0xff).as!ubyte;
                    }
                } else {
                    todo("handle more than 2 fixup bytes");
                }
            }catch(Exception e) {
                writefln("Fixup failed on line %s:\n\tfixup=%s\n\tline = %s"
                    .format(line.number, f, line.toString()));
                throw e;
            }
        }
    }
    Tuple!(string[],bool) fetchLine() {
        lineNumber = tokens[pos].line;
        bool startsOnMargin = tokens[pos].firstColumn;

        log("--------------");
        log("■ Line %s", lineNumber);
        log("--------------");
        string[] strings;
        while(pos<tokens.length && tokens[pos].line == lineNumber) {
            string str = tokens[pos].text(text);
            strings ~= str;
            pos++;
        }
        log("  %s", strings);
        return tuple(strings, startsOnMargin);
    }
    void data(string[] strings, Line* line) {
        switch(strings[0].toLower()) {
            case "dw":
            case ".dw":
            case "defw":
            case ".word":
                dataWord(strings[1..$], line);
                break;
            case "ds":
            case "defs":
            case ".block":
            case ".blkb":
                dataStorage(strings[1..$], line);
                break;
            case "db":
            case ".db":
            case "defb":
            case ".byte":
            case "defm":
            case "dm":
            case ".dm":
            case ".text":
            case ".ascii":
                dataByte(strings[1..$], line);
                break;
            case ".asciz":
                dataByte(strings[1..$], line, true);
                break;
            default:
                throw new Exception("Unhandled data type: %s".format(strings[0]));
        }
        pc += line.code.length.as!int;
    }
    /**
     *  Handle word data.
     */
    void dataWord(string[] strings, Line* line) {
        while(strings.length > 0) {
            auto end = strings.indexOf(",");
            int bump = 0;
            if(end==-1) {
                end = strings.length.as!int;
            } else {
                bump = 1;
            }

            if(end == 1 && strings[0].isNumber()) {
                ushort value = convertToInt(strings[0]).as!ushort;
                line.code ~= (value & 0xff).as!ubyte;
                line.code ~= (value>>>8).as!ubyte;
            } else {
                auto f = Fixup(
                    line.address,
                    2,
                    line.code.length.as!int,
                    false,
                    false,
                    strings[0..end].dup
                );
                fixups ~= f;
                line.code ~= 0;
                line.code ~= 0;
            }
            strings = strings[end+bump..$];
        }
    }
    /** count [, fillByte ] */
    void dataStorage(string[] strings, Line* line) {
        uint count = convertToInt(strings[0]);
        ubyte fill = 0x00;
        if(strings.length > 1) {
            if(strings.length==3 && strings[2].isNumber()) {
                fill = convertToInt(strings[2]).as!ubyte;
            } else {
                todo("Handle expression fill byte");
            }
        }
        foreach(i; 0..count) {
            line.code ~= fill;
        }
    }
    /**
     * Handle byte or string data.
     *
     * db 5, 3, 'f'
     * dm 'text'
     * dm "text", 5, 'hello' + $80
     */
    void dataByte(string[] strings, Line* line, bool zSuffix = false) {

        expandStringsToNumbers(strings);

        if(zSuffix) {
            strings ~= [",", "0"];
        }
        while(strings.length > 0) {
            db(strings, line);
        }
    }
    /**
     * Parse a single byte data element which can be a literal number
     * or an expression.
     */
    void db(ref string[] strings, Line* line) {
        auto end = strings.indexOf(",");
        int bump = 0;
        if(end==-1) {
            end = strings.length.as!int;
        } else {
            bump = 1;
        }

        if(end==1 && strings[0].isNumber()) {
            line.code ~= convertToInt(strings[0]).as!ubyte;
        } else {
            auto f = Fixup(
                line.address,
                1,
                line.code.length.as!int,
                false,
                false,
                strings[0..end].dup
            );
            fixups ~= f;
            line.code ~= 0;
        }
        strings = strings[end+bump..$];
    }
    /**
     * Convert an ascii string def to an array of numbers eg.
     * ["'abc'" + $80] -> ["97", "98", "99"]
     */
    void expandStringsToNumbers(ref string[] strings) {
        import std.conv : to;
        string[] temp;
        foreach(s; strings) {
            if(s[0].isQuote()) {
                foreach(ch; s[1..$-1]) {
                    if(ch=='\\') {
                        // Ignore back slashes
                    } else {
                        if(temp.length > 0 && temp[$-1]!=",") temp ~= ",";
                        temp ~= to!int(ch).to!string;
                    }
                }
            } else {
                temp ~= s;
            }
        }
        strings = temp;
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
            addressToLine[pc] = Line.atAddress(pc);
            return getLineAtAddress(pc);
        }
        return p;
    }
}