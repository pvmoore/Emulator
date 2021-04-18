module emulator.assembler.Token;

import emulator.assembler.all;

__gshared NO_TOKEN = Token(-1,-1,-1,Kind.NONE);

struct Token {
    int start;
    int length;
    int line;
    bool firstColumn;
    Kind kind;

    string text(string t) {
        return t[start..start+length];
    }

    string toString(string text) {
        if(length==0) throw new Exception("length is zero");
        if(start+length>text.length) throw new Exception("array index oob %s %s".format(start, length));
        string s = text[start..start+length];
        return "[%s:%s] %s '%s'".format(line, firstColumn ? "f" : "-", kind, s);
    }
}

enum Kind {
    NONE,
    TEXT,
    NUMBER,
    STRING,
    LABEL,
    VAR,

    COMMA,
    PLUS,
    MINUS,
    MUL,
    DIV,
    MOD,

    LBRACKET,
    RBRACKET
}

string toString(Kind k) {
    switch(k) with(Kind) {
        case COMMA: return ",";
        case PLUS: return "+";
        case MINUS: return "-";
        case MUL: return "*";
        case DIV: return "/";
        case MOD: return "%";
        case LBRACKET: return "(";
        case RBRACKET: return ")";
        default:
            return "%s".format(k);
    }
}