module emulator.util;

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