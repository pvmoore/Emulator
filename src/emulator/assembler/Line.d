module emulator.assembler.Line;

import emulator.assembler.all;

static struct Line {
    uint number;
    uint address;
    ubyte[] code;
    string[] tokens;
    string[] labels;

    static Line atAddress(uint pc) {
        return Line(0, pc);
    }

    bool isEmpty() {
        return code.length==0 && tokens.length==0 && labels.length==0;
    }

    string toString() {
        string c = code? "[%s]".format(code.toHexStringArray()) : "";
        string l = labels? "labels: %s ".format(.toString(labels)) : "";
        string t = tokens? "tokens: '%s'".format(.toString(tokens)) : "";
        return "%04x: %s %s %s".format(address, l, c, t);
    }
}

ubyte[] extractCode(Line[] lines) {
    ubyte[] code;
    foreach(l; lines) {
        code ~= l.code;
    }
    return code;
}

string formatDisassembly(string[] tokens) {
    string buf;
    foreach(i, s; tokens) {
        if(i>0 && s!=",") buf ~= " ";
        buf ~= s;
    }
    return buf;
}