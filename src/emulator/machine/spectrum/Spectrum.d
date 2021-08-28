module emulator.machine.spectrum.Spectrum;

import emulator.all;
import emulator.machine.spectrum.all;

final class Spectrum {
private:
    Z80 cpu;
    Memory memory;
    Z80Ports ports;
    Z80Pins pins;
    Bus bus;
    bool running = true;
    Semaphore executeSemaphore;
    WatchRange[] watchList;
    Assembler assembler;
    ROM48K rom;
public:
    auto getCpu()    { return cpu; }
    auto getMemory() { return memory; }
    auto getPorts()  { return ports; }
    auto getBus()    { return bus; }
    auto getROM()    { return rom; }

    this() {
        this.cpu = new Z80();
        this.pins = cpu.pins;

        this.ports = new Z80Ports(cpu.pins);
        this.memory = new Memory(65536);

        this.bus = new Bus()
            .add(ports)
            .add(memory);

        this.rom = new ROM48K();

        cpu.addBus(bus);

        this.executeSemaphore = new Semaphore();

        this.assembler = createZ80Assembler();

        auto thread = new Thread(&run);
        thread.isDaemon(true);
        thread.name("Spectrum Executor");
        thread.start();

        getEvents().subscribe("Memory", Evt.WATCH_ADDED | Evt.WATCH_REMOVED, (EventMsg m) {
            if(m.id==Evt.WATCH_ADDED) {
                watchList ~= WatchRange.from(m.get!ulong);
            } else if(m.id==Evt.WATCH_REMOVED) {
                watchList.remove(WatchRange.from(m.get!ulong));
            }
        });
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
        writeToMemory(0, rom.getCode());
    }
    void loadTape(string filename) {
        this.log("Loading tape '%s'", filename);
        auto tap = Loader.loadTape(filename);
        this.log("======================================== %s", filename);
        this.log("autoStart line: %s", tap.getAutoStartLine());
        this.log("%s", decodeBASIC(tap.getBasicProgram()));
        this.log("Data: %s", tap.getBasicData());
        foreach(m; tap.getMemBlocks()) {
            this.log("  %s", m);
        }
    }
    void loadSnapshot(string filename) {

    }
    void saveSnapshot(string filename) {

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

        ubyte[] ramSnapshot = new ubyte[65536];

        while(running) {
            this.log("Waiting on execute Semaphore");
            executeSemaphore.wait();
            if(!running) break;
            this.log("Executing %s instructions", maxInstructionsToExecute);

            atomicStore(_isExecuting, true);
            numInstructionsExecuted = 0;

            while(maxInstructionsToExecute == 0 || numInstructionsExecuted < maxInstructionsToExecute) {
                // Save memory snapshot if we are watching data
                takeWatchListSnapshot(ramSnapshot);

                this.log("Excuting instruction @ %04x", cpu.state.PC);

                // Execute the next instruction
                auto instruction = cpu.execute();
                numInstructionsExecuted++;

                this.log("Instruction = %s", instruction.tokens);

                // Check for watch list changes
                bool watchTriggered = checkWatchList(ramSnapshot);

                // Callback after instruction
                if(afterInstruction) {
                    afterInstruction();
                }

                if(breakPoints && breakPoints.contains(cpu.state.PC)) {
                    this.log("Hit breakpoint @ address %04x", cpu.state.PC);
                    break;
                }
                if(watchTriggered) {
                    this.log("Watch triggered @ address %04x", cpu.state.PC);
                    break;
                }
            }
            // callback after all executing has finished
            if(afterExecute) afterExecute();
            atomicStore(_isExecuting, false);
        }
        this.log("Execute thread exiting");
    }
    void takeWatchListSnapshot(ref ubyte[] snapshot) {
        // This is not efficient.
        // It copies all memory regardless of the size of any WatchRanges
        if(watchList.length > 0) {
            snapshot[] = memory.data[];
        }
    }
    bool checkWatchList(ubyte[] snapshot) {
        if(watchList.length > 0) {
            foreach(range; watchList) {
                const start = range.start;
                const end = range.start+range.numBytes;

                foreach(i; start..end) {
                    if(memory.data[i] != snapshot[i]) {
                        fireWatchTriggered(i);
                        return true;
                    }
                }
            }
        }
        return false;
    }
}