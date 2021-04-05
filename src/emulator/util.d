module emulator.util;

/**
 * bit is 0..7
 */
bool isBitSet(ubyte value, uint bit) {
    return (value & (1<<bit)) !=0;
}