module emulator.chips.z80.Z80Pins;

import emulator.chips.z80.all;

final class Z80Pins : Pins {
private:
    bool[string] namedPins;
    bool[8] d0_d7;
    bool[16] a0_a15;
    bool ioreq;
    bool mreq;
public:
    this() {
        namedPins["CLK"] = false;
        namedPins["INT"] = false;       // Maskable Interrupt Request
        namedPins["NMI"] = false;       // Non-Maskable Interrupt Request
        namedPins["WAIT"] = false;      // Wait state
        namedPins["RESET"] = false;     // Reset the CPU
        namedPins["HALT"] = false;      // halt instruction executed
        namedPins["MREQ"] = true;       // Memory Request
        namedPins["IOREQ"] = false;     // IO Request
        namedPins["RD"] = false;        // Read
        namedPins["WR"] = false;        // Write
        namedPins["BUSRQ"] = false;     // Bus Request
        namedPins["BUSACK"] = false;    // Bus Acknowledge
        namedPins["M1"] = false;        // Machine Cycle 1
        namedPins["RFSH"] = false;      // Memory Refresh
        mreq = true;
    }

    bool isIOReq() { return ioreq; }
    bool isMReq() { return mreq; }

    void setIOReq(bool f) {
        this.ioreq = f;
        this.mreq = !f;
    }
    void setMReq(bool f) {
        this.mreq = f;
        this.ioreq = !f;
    }

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