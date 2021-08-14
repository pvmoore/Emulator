module main_ui;

import core.sys.windows.windows;
import core.runtime;
import std.string : toStringz;
import std.stdio  : writefln;
import std.format : format;
import std.datetime.stopwatch : StopWatch;

import emulator.all;
import emulator.machine.spectrum;
import logging  : log, flushLog, setEagerFlushing;
import vulkan.all;

// Required for MessageBoxA etc...
pragma(lib, "user32.lib");

extern(Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow) {
	int result = 0;
	VulkanApplication app;
	try{
        Runtime.initialize();

        setEagerFlushing(true);

		auto speccy = new Spectrum();
		speccy.reset();

		speccy.writeToMemory(0x4000,
			cast(ubyte[])From!"std.file".read("C:/Temp/emulators/spectrum/scr/hobbitthe.scr"));

        app = new SpectrumUI(speccy);

		app.run();

    }catch(Throwable e) {
		log("exception: %s", e.msg);
		MessageBoxA(null, e.toString().toStringz, "Error", MB_OK | MB_ICONEXCLAMATION);
		result = -1;
    }finally{
		flushLog();
		if(app) app.destroy();
		Runtime.terminate();
	}
	flushLog();
    return result;
}
