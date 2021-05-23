module emulator.assembler.Number;

import emulator.assembler.all;
import std.conv : to;

string[] convertNumbersToInt(return string[] tokens) {
    foreach(ref t; tokens) {
        if(isNumber(t)) {
            t = to!string(convertToInt(t));
        }
    }
    return tokens;
}

bool isNumber(string value) {
    if(value=="&" || value=="$") return false;
    if(value[0]=='$' || value[0]=='&' || value[0]=='%') return true;
    if(value.length>2 && value[0]=='0' && value[1]=='x') return true;

    if(value.length>2 && value[0]=='\'' && value[$-1]=='\'') {
        // character literal
        if(value.length==3) return true;
        // todo - handle escape characters
    }
    if(value.length>1 && (value[$-1]=='h' || value[$-1]=='H')) {
        // 00h
        value = value[0..$-1];
    }
    if(value[0]=='-') value = value[1..$];
    return value.length > 0 && isDigit(value[0]);
}
uint convertToInt(string s) {
    if(s[0]=='$' || s[0]=='&') {
        return to!uint(s[1..$].toLower(), 16);
    }
    if(s[0]=='%') {
        return to!uint(s[1..$], 2);
    }
    if(s.length>2 && s[0]=='0' && s[1]=='x') {
        return to!uint(s[2..$].toLower(), 16);
    }
    if(s[$-1]=='h') {
        return to!uint(s[0..$-1], 16);
    }
    if(s[0]=='\'') {
        // 'a'
        s = s[1..$-1];
        if(s.length==1) {
            return cast(int)s[0];
        }
        todo("handle escape code charcter literals %s".format(s));
    }
    return cast(uint) to!int(s, 10);
}
