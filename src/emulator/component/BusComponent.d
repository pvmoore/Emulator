module emulator.component.BusComponent;

import emulator.all;

interface BusComponent {
    bool write(uint addr, ubyte value);
    bool writeWord(uint addr, ushort value);
    bool read(uint addr, ref ubyte value);
    bool readWord(uint addr, ref ushort value);
}