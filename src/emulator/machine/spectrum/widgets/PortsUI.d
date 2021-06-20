module emulator.machine.spectrum.widgets.PortsUI;

import vulkan.gui;
import emulator.machine.spectrum.all;

final class PortsUI : Widget {
private:
    RoundRectangles roundRectangles;
    Set!UUID ids;
public:
    this(Spectrum spectrum) {
        this.ids = new Set!UUID;
    }
    override void destroy() {

    }
    override void onAddedToStage(Stage stage) {
        this.roundRectangles = stage.getRoundRectangles(layer);

        this.relPos = int2(620,450);
        setSize(uint2(50, 340));

        auto c = WHITE*0.4;
        auto c2 = c+0.05;
        this.ids.add(roundRectangles.add(relPos.to!float, size.to!float, c, c, c*0.75, c*0.75, 10))
                .add(roundRectangles.add(relPos.to!float + 4, size.to!float-8, c2, c2, c2*0.75, c2*0.75, 10));
    }
}