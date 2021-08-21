module emulator.machine.spectrum.ui.FileDialog;

import emulator.machine.spectrum.all;
import core.sys.windows.windows;
import std.string : toStringz, fromStringz;
import vulkan;

pragma(lib, "Comdlg32.lib");

final class FileDialog {
private:
    @Borrowed VulkanContext context;
public:
    this(VulkanContext context) {
        this.context = context;
    }
    /**
     *  @param filter - eg. "All\0*.*\0*.txt\0"
     */
    string open(string directory = null, string filter = "*.*") {
        // auto window = context.vk.getGLFWWindow();
        // auto hwnd = glfwGetWin32Window(window);

        char[] filename = new char[1024];
        filename[0] = '\0';

        OPENFILENAMEA data = {
            lStructSize: OPENFILENAMEA.sizeof,
            hwndOwner: null,
            lpstrFilter: toStringz(filter),
            nFilterIndex: 1,

            lpstrFile: filename.ptr,
            nMaxFile: filename.length.as!int,

            lpstrInitialDir: toStringz(directory),

            lpstrTitle: null,

            Flags: OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST
        };
        auto okClicked = GetOpenFileNameA(&data);

        if(okClicked) {
            return cast(string)fromStringz(filename.ptr);
        }
        return null;
    }
    string save(string directory = null) {

        char[] filename = new char[1024];
        filename[0] = '\0';

        OPENFILENAMEA data = {
            lStructSize: OPENFILENAMEA.sizeof,
            hwndOwner: null,

            lpstrFile: filename.ptr,
            nMaxFile: filename.length.as!int,

            lpstrInitialDir: toStringz(directory),

            lpstrTitle: null,

            Flags: OFN_OVERWRITEPROMPT
        };

        auto okClicked = GetSaveFileNameA(&data);
        if(okClicked) {
            return cast(string)fromStringz(filename.ptr);
        }
        return null;
    }
}