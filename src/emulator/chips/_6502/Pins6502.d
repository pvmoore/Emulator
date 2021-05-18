module emulator.chips._6502.Pins6502;

import emulator.chips._6502.all;

final class Pins6502 : Pins {
private:

public:
    @Implements("Pins")
    bool getPin(string name) {
        return false;
    }
    @Implements("Pins")
    bool getPin(uint index) {
        return false;
    }
    @Implements("Pins")
    void setPin(string name) {
        todo();
    }
    @Implements("Pins")
    void setPin(uint index) {
        todo();
    }
}