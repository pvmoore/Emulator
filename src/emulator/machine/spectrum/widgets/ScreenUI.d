module emulator.machine.spectrum.widgets.ScreenUI;

import vulkan.gui;
import emulator.machine.spectrum.all;

/**
 *  Display Spectrum screen
 *      Pixel data:
 *          - 32x24 bytes
 *          - 256x192 pixels
 *
 *      Attribute data:
 *          - 32x24 bytes
 *
 */
final class ScreenUI : Widget {
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

        this.relPos = int2(5,5);
        setSize(uint2(600, 430));

        auto c = WHITE*0.4;
        auto c2 = c+0.05;
        this.ids.add(roundRectangles.add(relPos.to!float, size.to!float, c, c, c*0.75, c*0.75, 10))
                .add(roundRectangles.add(relPos.to!float + 4, size.to!float-8, c2, c2, c2*0.75, c2*0.75, 10));
    }
}
