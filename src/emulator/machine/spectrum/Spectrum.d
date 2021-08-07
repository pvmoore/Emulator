module emulator.machine.spectrum.Spectrum;

import emulator.all;
import emulator.machine.spectrum.all;

final class Spectrum {
private:
    enum ROM48K = "resources/roms/48k.rom";
    Z80 cpu;
    Memory memory;
    Z80Ports ports;
    Z80Pins pins;
    Bus bus;
    bool running = true;
    Semaphore executeSemaphore;
public:
    auto getCpu()    { return cpu; }
    auto getMemory() { return memory; }
    auto getPorts()  { return ports; }
    auto getBus()    { return bus; }

    this() {
        this.cpu = new Z80();
        this.pins = cpu.pins;

        this.ports = new Z80Ports(cpu.pins);
        this.memory = new Memory(65536);

        this.bus = new Bus()
            .add(ports)
            .add(memory);

        cpu.addBus(bus);

        this.executeSemaphore = new Semaphore();

        auto thread = new Thread(&run);
        thread.isDaemon(true);
        thread.name("Spectrum Executor");
        thread.start();
    }
    void destroy() {
        this.running = false;
        executeSemaphore.notify();
    }

    void reset() {
        cpu.reset();
        loadROM48K();
    }
    void loadROM48K() {
        log("Loading ROM");
        auto data = cast(ubyte[])From!"std.file".read(ROM48K);
        writeToMemory(0, data);
        log("ROM loaded");
    }
    void loadTape(string filename) {

    }
    ubyte[] readFromMemory(ushort addr, ushort numBytes) {
        pins.setMReq(true);
        ubyte[] data;
        foreach(i; 0..numBytes) {
            data ~= bus.read(addr+i);
        }
        return data;
    }
    void writeToMemory(ushort addr, ubyte[] data) {
        pins.setMReq(true);
        foreach(i; 0..data.length.as!uint) {
            bus.write(addr+i, data[i]);
        }
    }
    /**
     * Execute instructions until maxInstructions or
     * one of the specified breakpoints is reached.
     */
    void execute(Set!uint breakPoints,
                 int maxInstructions,
                 void delegate() afterInstruction,
                 void delegate() afterExecute)
    {
        this.breakPoints = breakPoints;
        this.maxInstructionsToExecute = maxInstructions;
        this.afterInstruction = afterInstruction;
        this.afterExecute = afterExecute;
        executeSemaphore.notify();
    }
    bool isExecuting() {
        return running && atomicLoad(_isExecuting);
    }
private:
    void delegate() afterInstruction;
    void delegate() afterExecute;
    Set!uint breakPoints;
    uint maxInstructionsToExecute;
    uint numInstructionsExecuted;
    bool _isExecuting;

    void run() {
        this.log("Execute thread running");
        while(running) {
            this.log("Waiting on execute Semaphore");
            executeSemaphore.wait();
            if(!running) break;
            this.log("Executing %s instructions", maxInstructionsToExecute);

            atomicStore(_isExecuting, true);
            numInstructionsExecuted = 0;

            while(maxInstructionsToExecute == 0 ||
                 numInstructionsExecuted < maxInstructionsToExecute)
            {

                cpu.execute();
                numInstructionsExecuted++;

                if(afterInstruction) {
                    afterInstruction();
                }

                if(breakPoints && breakPoints.contains(cpu.state.PC)) {
                    this.log("Hit breakpoint @ address %04x", cpu.state.PC);
                    break;
                }
            }
            if(afterExecute) afterExecute();
            atomicStore(_isExecuting, false);
        }
        this.log("Execute thread existing");
    }
}