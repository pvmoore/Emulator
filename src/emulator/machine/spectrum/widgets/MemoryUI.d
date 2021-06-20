module emulator.machine.spectrum.widgets.MemoryUI;

import vulkan.gui;
import emulator.machine.spectrum.all;

/**
 *
 *
 *
 */
final class MemoryUI : Widget {
private:
    Spectrum spectrum;
    RoundRectangles roundRectangles;
    Lines lines;
    Text text;
    Set!UUID ids;
    UUID[] valueIds;
    UUID[] sideLabelIds;
    UUID[] hoverIds;
    ToggleGroup hiGrp, loGrp;
    ToggleButton[] buttons;
    uint offset;
public:

    void setAddress(uint addr) {
        this.offset = addr & 0xffff;
        update();
        setToggles();
    }

    this(Spectrum spectrum) {
        this.spectrum = spectrum;
        this.ids = new Set!UUID;

        import std;
        foreach(i; 0..65536) {
            spectrum.getMemory().write(i, (uniform01()*255.0).as!ubyte);
        }
    }
    override void destroy() {

    }
    override void onAddedToStage(Stage stage) {
        this.roundRectangles = stage.getRoundRectangles(layer);
        this.text = stage.getTextRenderer("dejavusansmono-bold", layer);
        this.lines = stage.getLines(layer);

        this.relPos = int2(5,450);
        setSize(uint2(600, 360));

        // background
        auto c = WHITE*0.4;
        auto c2 = c+0.05;
        this.ids.add(roundRectangles.add(relPos.to!float, size.to!float, c, c, c*0.75, c*0.75, 10))
                .add(roundRectangles.add(relPos.to!float + 4, size.to!float-8, c2, c2, c2*0.75, c2*0.75, 10));

        // memory rows and columns
        auto mem = spectrum.getMemory();
        auto p = getAbsPos();
        auto i = 0;
        ubyte value;

        text.setSize(16)
            .setColour(RGBA(0.6, 0.7, 0.5, 1));
        // top labels
        foreach(x; 0..16) {
            text.appendText("%02x".format(x), p.x + 8+50+42 + x*25, p.y+8);
        }

        // side labels
        foreach(y; 0..16) {
            sideLabelIds ~= text.appendText("%04x".format(offset + y*16), p.x + 8+46, p.y+8+20 + y*20);
        }

        // lines
        lines.fromColour(WHITE)
             .toColour(WHITE)
             .add(float2(p.x + 8+90, p.y+28), float2(p.x + 8+90+16*25, p.y+8+20));
        lines.add(float2(p.x + 8+90, p.y+28), float2(p.x + 8+90,       p.y+28+16*20));

        // values
        text.setColour(WHITE*RGBA(0.9, 0.9, 1, 1));
        foreach(y; 0..16) {
            foreach(x; 0..16) {
                mem.read((offset+i++)&0xffff, value);
                valueIds ~= text.appendText("%02x".format(value), p.x + 100 + x*25, p.y + 28 + y*20);
            }
        }

        // hover values
        text.setColour(WHITE);
        hoverIds ~= text.appendText("0000",   p.x + 125 + 16*25, p.y + 28);
        text.setColour((YELLOW+RED)/2);
        hoverIds ~= text.appendText("00",   p.x + 125 + 16*25, p.y + 28 + 20);
        hoverIds ~= text.appendText("00",   p.x + 125 + 16*25, p.y + 28 + 40);
        hoverIds ~= text.appendText("0000",   p.x + 125 + 16*25, p.y + 28 + 60);
        hoverIds ~= text.appendText("000000", p.x + 125 + 16*25, p.y + 28 + 80);

        // hi buttons
        hiGrp = new ToggleGroup();
        foreach(y; 0..16) {
            auto s = "%x".format(y);
            auto b = new ToggleButton(s, s);
            b.setSize(uint2(18,18));
            b.setRelPos(int2(8, 8+20 + y*20));
            b.props.setFontName("dejavusansmono-bold")
                   .setFontSize(15);
            add(b);
            hiGrp.add(b);
            buttons ~= b;
        }
        // lo buttons
        loGrp = new ToggleGroup();
        foreach(y; 0..16) {
            auto s = "%x".format(y);
            auto b = new ToggleButton(s, s);
            b.setSize(uint2(18,18));
            b.setRelPos(int2(8+20, 8+20 + y*20));
            b.props.setFontName("dejavusansmono-bold")
                   .setFontSize(15);
            add(b);
            loGrp.add(b);
            buttons ~= b;
        }
        hiGrp.onToggle((t) {
            auto i = t.getText().to!int(16);
            offset = (offset&0x0fff) | (i<<12);
            update();
        });
        loGrp.onToggle((t) {
            auto i = t.getText().to!int(16);
            offset = (offset&0xf0ff) | (i<<8);
            update();
        });
        setToggles();
    }
    override void update(Frame frame) {
        foreach(e; frameEvents) {
            switch(e.type) with(GUIFrameEventType) {
                case MOUSEMOVE:
                    auto p = e.relMousePos();
                    auto a = int2(100, 28);
                    auto b = a+int2(16*25, 16*20);
                    if(p.allGTE(a) && p.allLT(b)) {
                        auto c = (p-a) / int2(25, 20);
                        updateHover(c);
                    }
                    break;
                case MOUSEBUTTON:
                    //log("mouse button abs:%s rel:%s btn:%s isPress:%s mods:%s",
                    //    e.absMousePos(), e.relMousePos(), e.button(), e.isPress(), e.keyMods());
                    break;
                case MOUSEWHEEL:
                    //log("wheel %s, %s", e.wheelX(), e.wheelY());
                    break;
                case KEYPRESS:
                    // if(e.keyAction()==KeyAction.PRESS) {
                    //     log("press %s mods:%s", e.keyCode(), e.keyMods());
                    // } else {
                    //     log("release %s mods:%s", e.keyCode(), e.keyMods());
                    // }
                    break;
                case ICONIFY:
                    //log("iconified %s", e.isIconified());
                    break;
                case FOCUS:
                    //log("focussed %s", e.isFocussed());
                    break;
                case MOUSEENTER:
                    // if(e.isEnter()) {
                    //     log("enter");
                    // } else {
                    //     log("leave");
                    // }
                    break;
                default:
                    log("event %s", e.type);
                    break;
            }
        }
    }
private:
    void update() {
        if(!isOnStage()) return;
        log("offset = %04x", offset);

        // Update side labels
        foreach(x; 0..16) {
            text.replaceText(sideLabelIds[x], "%04x".format(offset + x*16));
        }

        // Update values
        ubyte value;
        auto mem = spectrum.getMemory();
        foreach(y; 0..16) {
            foreach(x; 0..16) {
                mem.read((offset+x+y*16)&0xffff, value);
                text.replaceText(valueIds[x + y*16], "%02x".format(value));
            }
        }
    }
    void updateHover(int2 p) {
        ubyte b1;
        ubyte b2;
        auto o = offset + p.x + p.y*16;
        spectrum.getMemory().read(o, b1);
        spectrum.getMemory().read((o+1)&0xffff, b2);
        ushort s = (b2<<8) | b1;
        // address
        text.replaceText(hoverIds[0], "%04x".format(o));
        // hex byte
        text.replaceText(hoverIds[1], "%02x".format(b1));
        // decimal byte
        text.replaceText(hoverIds[2], "%d".format(b1));
        // hex word
        text.replaceText(hoverIds[3], "%04x".format(s));
        // deciaml word
        text.replaceText(hoverIds[4], "%s".format(s));
    }
    void setToggles() {
        if(!isOnStage()) return;
        assert(buttons.length == 32);

        auto hi = (offset>>>4)&0xf;
        auto lo = offset&0xf;

        // buttons[0..15] = hiGrp
        // buttons[16.31] = loGrp

        loGrp.setToggled(buttons[lo+16]);
        hiGrp.setToggled(buttons[hi]);
    }
}