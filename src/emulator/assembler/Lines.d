module emulator.assembler.Lines;

import emulator.assembler.all;

final class Lines {
    uint[uint] addressToIndex;
public:
    Line[] lines;

    uint length() {
        return lines.length.as!uint;
    }
    Line* first() {
        return lines.length == 0 ? null : &lines[0];
    }
    Line* last() {
        return lines.length == 0 ? null : &lines[$-1];
    }

    this(Line[] lines) {
        this.lines = lines;
    }

    ref Line opIndex(uint i) {
        assert(i<lines.length);
        return lines[i];
    }
    // foreach(a; array)
	int opApply(scope int delegate(ref Line) dg) {
        int result = 0;

        for(int i = 0; i < lines.length; i++) {
            result = dg(lines[i]);
            if(result) break;
        }
        return result;
	}
    // foreach(i, a; array)
    int opApply(scope int delegate(ulong n, ref Line) dg) {
        int result = 0;

        for(ulong i = 0; i < lines.length; i++) {
            result = dg(i, lines[i]);
            if(result) break;
        }
        return result;
    }

    Line* getLineAtAddress(uint address) {
        if(addressToIndex.length != lines.length) {
            foreach(i, ref l; lines) {
                addressToIndex[l.address] = i.as!int;
            }
        }
        auto p = address in addressToIndex;
        if(p) return &lines[*p];
        return null;
    }
    ubyte[] extractCode() {
        ubyte[] code;
        foreach(l; lines) {
            code ~= l.code;
        }
        return code;
    }
    void _dump() {
        foreach(l; lines) {
            writefln("\t%s", l);
        }
    }
    void merge(Lines other) {
        if(other is null || other.length==0) return;

        addressToIndex.clear();

        if(this.lines.length==0) {
            this.lines ~= other.lines.dup;
            return;
        }

        auto left = 0;
        auto right = 0;
        Line[] temp;

        while(left<this.lines.length && right<other.lines.length) {
            Line a = this.lines[left];
            Line b = other.lines[right];

            if(a.address < b.address) {
                // select left
                temp ~= a;
                left++;
            } else {
                // select right
                temp ~= b;
                right++;
            }
        }

        // Copy the remainder if any
        while(left<this.lines.length) {
            temp ~= this.lines[left++];
        }
        while(right<other.lines.length) {
            temp ~= other.lines[right++];
        }

        this.lines = temp;
    }
}