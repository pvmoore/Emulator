module emulator.component.BusComponent;

import emulator.all;

interface BusComponent {
    bool write(uint addr, ubyte value);
    bool read(uint addr, ref ubyte value);
}