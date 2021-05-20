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
    if(value[0]=='$' || value[0]=='&') return true;
    if(value.length>2 && value[0]=='0' && value[1]=='x') return true;
    if(value[0]=='-') value = value[1..$];
    return isDigit(value[0]);
}
uint convertToInt(string s) {
    if(s[0]=='$' || s[0]=='&') {
        return to!uint(s[1..$].toLower(), 16);
    }
    if(s.length>2 && s[0]=='0' && s[1]=='x') {
        return to!uint(s[2..$].toLower(), 16);
    }
    if(s[$-1]=='h') {
        return to!uint(s[0..$-1], 16);
    }
    return cast(uint) to!int(s, 10);
}
