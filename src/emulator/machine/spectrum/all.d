module emulator.machine.spectrum.all;

public:

import emulator.all;
import emulator.machine.spectrum;

struct WatchRange {
    uint start;
    uint numBytes;

    static WatchRange from(ulong u) {
        return WatchRange((u >>> 32).as!uint, (u & 0xffffffff).as!uint);
    }
    ulong toUlong() {
        return (start.as!ulong << 32) | numBytes;
    }
}