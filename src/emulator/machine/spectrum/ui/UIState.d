module emulator.machine.spectrum.ui.UIState;

import emulator.machine.spectrum.all;

final class UIState {
public:
    enum State {
        PAUSED,
        EXECUTING
    }
    static State state = State.PAUSED;

    static void paused() {
        state = State.PAUSED;
    }
    static void executing() {
        state = State.EXECUTING;
    }
}