module emulator.machine.spectrum.ui.UIEvents;

import emulator.all;
import emulator.machine.spectrum.all;

enum Evt : uint {
    CODE_LINE_CHANGED       = 1<<0,
    EXECUTE_STATE_CHANGED   = 1<<1,
    INSTRUCTION_CLICKED     = 1<<2,
    WATCH_ADDED             = 1<<3,
    WATCH_REMOVED           = 1<<4,
    WATCH_TRIGGERED         = 1<<5,
}

enum ExecuteState {
    PAUSED,
    EXECUTING
}

void fireCodeLineChange(Line* line) {
     getEvents().fire(EventMsg(Evt.CODE_LINE_CHANGED, line));
}
void fireExecuteStateChange(ExecuteState state) {
    getEvents().fire(EventMsg(Evt.EXECUTE_STATE_CHANGED, state));
}
void fireInstructionClicked(Line* line) {
    getEvents().fire(EventMsg(Evt.INSTRUCTION_CLICKED, line));
}
void fireAddWatch(WatchRange range) {
    getEvents().fire(EventMsg(Evt.WATCH_ADDED, range.toUlong()));
}
void fireRemoveWatch(WatchRange range) {
    getEvents().fire(EventMsg(Evt.WATCH_REMOVED, range.toUlong()));
}
void fireWatchTriggered(uint addr) {
    getEvents().fire(EventMsg(Evt.WATCH_TRIGGERED, addr));
}