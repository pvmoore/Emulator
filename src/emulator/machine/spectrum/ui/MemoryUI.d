module emulator.machine.spectrum.ui.MemoryUI;

import emulator.machine.spectrum.all;
import vulkan.all;

/**
 *
 *
 *
 */
final class MemoryUI  {
private:
    enum WIDTH = 745, HEIGHT = 430;
    @Borrowed Spectrum spectrum;
    @Borrowed VulkanContext context;
    @Borrowed Memory memory;
    @Borrowed Z80 cpu;
    @Borrowed Z80Ports ports;
    @Borrowed Z80Pins pins;
    MemoryEditor ramEditor;
    MemoryEditor portsEditor;
public:

    this(VulkanContext context, Spectrum spectrum) {
        this.context = context;
        this.spectrum = spectrum;
        this.cpu = spectrum.getCpu();
        this.memory = spectrum.getMemory();
        this.ports = spectrum.getPorts();
        this.pins = cpu.pins;

        this.ramEditor = new MemoryEditor()
            .withFont(context.vk.getImguiFont(1));
        this.portsEditor = new MemoryEditor()
            .withFont(context.vk.getImguiFont(1));

        ramEditor.ReadFn = (ptr, offset, userData) {
            ubyte value;
            memory.read(offset.as!uint, value);
            return value;
        };
        portsEditor.ReadFn = (ptr, offset, userData) {
            ubyte value;
            ports.read(offset.as!uint, value);
            return value;
        };

        ramEditor.WriteFn = (ptr, offset, value, userData) {
            memory.write(offset.as!uint, value.as!ubyte);
        };
        portsEditor.WriteFn = (ptr, offset, value, userData) {
            ports.write(offset.as!uint, value.as!ubyte);
        };

        ramEditor.PreviewDataType = ImGuiDataType_U8;
        portsEditor.PreviewDataType = ImGuiDataType_U8;

        const eventMask =
            Evt.CODE_LINE_CHANGED |
            Evt.INSTRUCTION_CLICKED |
            Evt.WATCH_TRIGGERED;

        getEvents().subscribe("Memory", eventMask, &handleEvent);
    }
    void render(Frame frame) {

        igSetNextWindowPos(igGetMainViewport().WorkPos + ImVec2(10,890), ImGuiCond_Once, ImVec2(0.0, 1.0));
        igSetNextWindowSize(ImVec2(WIDTH, HEIGHT), ImGuiCond_Once);

        auto windowFlags = ImGuiWindowFlags_None
            | ImGuiWindowFlags_NoSavedSettings
            //| ImGuiWindowFlags_NoTitleBar
            //| ImGuiWindowFlags_NoCollapse
            //| ImGuiWindowFlags_NoResize
            //| ImGuiWindowFlags_NoBackground
            //| ImGuiWindowFlags_NoMove;
            ;

        if(igBegin("IO", null, windowFlags)) {

            auto options = ImGuiTabItemFlags_None
               // | ImGuiTabBarFlags_Reorderable
                ;

            if (igBeginTabBar("MyTabBar", options)) {

                auto flags = ImGuiTabItemFlags_None;
                    //ImGuiTabItemFlags_UnsavedDocument;
                    //| ImGuiTabItemFlags_SetSelected;

                if (igBeginTabItem("RAM", null, flags))
                {
                    ramEditor.DrawContents(null, 65536, 0);
                    igEndTabItem();
                }
                if (igBeginTabItem("Ports", null, ImGuiTabItemFlags_None)) {
                    pins.setIOReq(true);
                    portsEditor.DrawContents(null, 256, 0);
                    pins.setIOReq(false);
                    igEndTabItem();
                }

                igEndTabBar();
            }

        }
        igEnd();
    }
private:
    void handleEvent(EventMsg m) {
        switch(m.id) {
            case Evt.INSTRUCTION_CLICKED:
                Line* line = m.get!(Line*);
                // If there is an indirect address in these tokens then go to that address
                auto tokens = line.tokens;
                log("tokens = %s", tokens);
                auto addr = -1;
                foreach(i, t; tokens) {
                    if(t=="(") {
                        auto t2 = tokens[i+1];
                        if(t2.startsWith("$")) {
                            // indirect address literal
                            addr = t2[1..$].to!uint(16);
                            break;
                        } else if(t2=="hl") {
                            addr = cpu.state.HL;
                        } else if(t2=="ix") {
                            addr = cpu.state.IX;
                            if(tokens[i+2]=="+") {
                                addr += tokens[i+3][1..$].to!uint(16);
                            }
                        } else if(t2=="iy") {
                            addr = cpu.state.IY;
                            if(tokens[i+2]=="+") {
                                addr += tokens[i+3][1..$].to!uint(16);
                            }
                        } else {

                        }                    }
                }
                if(addr!=-1) {
                    ramEditor.scrollToAddress(addr);
                }
                break;
            case Evt.WATCH_TRIGGERED:
                ramEditor.scrollToAddress(m.get!ulong);
                break;
            default:
                break;
        }
    }
}
