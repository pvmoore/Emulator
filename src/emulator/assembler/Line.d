module emulator.assembler.Line;

import emulator.assembler.all;

struct Line {
    uint number;
    uint address;
    ubyte[] code;
    string[] tokens;
    string[] labels;
    string[] comments;

    static Line atAddress(uint pc) {
        return Line(0, pc);
    }
    bool isEmpty() {
        return code.length==0 && tokens.length==0 && labels.length==0;
    }
    string formatDisassembly() {
        string buf;
        foreach(i, s; tokens) {
            if(i>0 && s!=",") buf ~= " ";
            buf ~= s;
        }
        return buf;
    }

    string toString() {
        string c = code? "[%s]".format(code.toHexStringArray()) : "";
        string l = labels? "labels: %s ".format(.toString(labels)) : "";
        string t = tokens? "tokens: '%s'".format(.toString(tokens)) : "";
        return "%04x: %s %s %s".format(address, l, c, t);
    }
}
