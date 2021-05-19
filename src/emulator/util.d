module emulator.util;

import emulator.all;

/**
 * bit is 0..7
 */
bool isBitSet(uint value, uint bit) {
    return (value & (1<<bit)) !=0;
}
/**
 * @return true if bit 7 is set
 */
bool isNeg(uint value) {
    return (value & 0x80) != 0;
}
/**
 * @return true if bit 7 is 0
 */
bool isPos(uint value) {
    return (value & 0x80) == 0;
}
/**
 * @return true if value is even
 */
bool isEven(ubyte value) {
    return (value&1) == 0;
}

bool isDigit(char c) {
    return c>='0' && c<='9';
}

string toHexStringArray(ubyte[] bytes) {
    string s;
    for(auto i=0; i<bytes.length; i++) {
        if(i>0) s ~= " ";
        s ~= "%02x".format(bytes[i]);
    }
    return s;
}
string toString(inout string[] tokens) {
    string buf;
    foreach(i, s; tokens) {
        if(i>0) buf ~= " ";
        buf ~= s;
    }
    return buf;
}