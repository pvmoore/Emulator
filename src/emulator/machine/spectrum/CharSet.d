module emulator.machine.spectrum.CharSet;

import emulator.machine.spectrum.all;
import emulator.util;
import std.stdio : writefln;
import std.conv : to;
import common : indexOf;
/**
 *  https://en.wikipedia.org/wiki/ZX_Spectrum_character_set
 */

struct ZXChar {
    string name;
}

enum {
    _       = ZXChar(),
    _LE     = ZXChar("<="),
    _GE     = ZXChar(">="),
    _NE     = ZXChar("<>"),
    AINK    = ZXChar("INK_ATTR"),
    APAPER  = ZXChar("PAPER_ATTR"),
    AFLASH  = ZXChar("FLASH_ATTR"),
    ABRIGHT = ZXChar("BRIGHT_ATTR"),
    AINVERSE = ZXChar("INVERSE_ATTR"),
    AAT     = ZXChar("AT_ATTR"),
    ABS     = ZXChar("ABS"),
    ACS     = ZXChar("ACS"),
    AND     = ZXChar("AND"),
    ASN     = ZXChar("ASN"),
    AT      = ZXChar("AT"),
    ATN     = ZXChar("ATN"),
    ATTR    = ZXChar("ATTR"),
    BEEP    = ZXChar("BEEP"),
    BIN     = ZXChar("BIN"),
    BKSPC   = ZXChar("BKSPC"),
    BORDER  = ZXChar("BORDER"),
    BRIGHT  = ZXChar("BRIGHT"),
    CAT     = ZXChar("CAT"),
    CHR_    = ZXChar("CHR$"),
    CIRCLE  = ZXChar("CIRCLE"),
    CLEAR   = ZXChar("CLEAR"),
    CLOSE_  = ZXChar("CLOSE #"),
    CLS     = ZXChar("CLS"),
    CODE    = ZXChar("CODE"),
    CONTINUE= ZXChar("CONTINUE"),
    COPY    = ZXChar("COPY"),
    COS     = ZXChar("COS"),
    DATA    = ZXChar("DATA"),
    DEF_FN  = ZXChar("DEF FN"),
    DIM     = ZXChar("DIM"),
    DRAW    = ZXChar("DRAW"),
    ERASE   = ZXChar("ERASE"),
    EXP     = ZXChar("EXP"),
    FLASH   = ZXChar("FLASH"),
    FN      = ZXChar("FN"),
    FOR     = ZXChar("FOR"),
    FORMAT  = ZXChar("FORMAT"),
    GOSUB   = ZXChar("GO SUB"),
    GOTO    = ZXChar("GO TO"),
    IF      = ZXChar("IF"),
    IN      = ZXChar("IN"),
    INK     = ZXChar("INK"),
    INKEY_  = ZXChar("INKEY$"),
    INPUT   = ZXChar("INPUT"),
    INT     = ZXChar("INT"),
    INVERSE = ZXChar("INVERSE"),
    LEN     = ZXChar("LEN"),
    LET     = ZXChar("LET"),
    LINE    = ZXChar("LINE"),
    LIST    = ZXChar("LIST"),
    LN      = ZXChar("LN"),
    LLIST   = ZXChar("LLIST"),
    LOAD    = ZXChar("LOAD"),
    LPRINT  = ZXChar("LPRINT"),
    MERGE   = ZXChar("MERGE"),
    MOVE    = ZXChar("MOVE"),
    NEW     = ZXChar("NEW"),
    NEXT    = ZXChar("NEXT"),
    NOT     = ZXChar("NOT"),
    OPEN_   = ZXChar("OPEN #"),
    OR      = ZXChar("OR"),
    OUT     = ZXChar("OUT"),
    OVER    = ZXChar("OVER"),
    PAPER   = ZXChar("PAPER"),
    PAUSE   = ZXChar("PAUSE"),
    PEEK    = ZXChar("PEEK"),
    PLOT    = ZXChar("PLOT"),
    POINT   = ZXChar("POINT"),
    POKE    = ZXChar("POKE"),
    PRINT   = ZXChar("PRINT"),
    PI      = ZXChar("PI"),
    RANDOMIZE = ZXChar("RANDOMIZE"),
    READ    = ZXChar("READ"),
    REM     = ZXChar("REM"),
    RESTORE = ZXChar("RESTORE"),
    RETURN  = ZXChar("RETURN"),
    RND     = ZXChar("RND"),
    RUN     = ZXChar("RUN"),
    SAVE    = ZXChar("SAVE"),
    SCREEN_ = ZXChar("SCREEN$"),
    SGN     = ZXChar("SGN"),
    SIN     = ZXChar("SIN"),
    SQR     = ZXChar("SQR"),
    STEP    = ZXChar("STEP"),
    STOP    = ZXChar("STOP"),
    STR_    = ZXChar("STR$"),
    TAB     = ZXChar("TAB"),
    TAN     = ZXChar("TAN"),
    THEN    = ZXChar("THEN"),
    TO      = ZXChar("TO"),
    USR     = ZXChar("USR"),
    VAL     = ZXChar("VAL"),
    VAL_    = ZXChar("VAL$"),
    VERIFY  = ZXChar("VERIFY"),
}

const ZXChar[256] CHARSET = [
/*                          6 */
/* 0 */ _,_,_,_,_,_,{"\t"},_,
        BKSPC,_,_,_,_,_,_,_,
/* 1 */ AINK,APAPER,AFLASH,ABRIGHT,AINVERSE,OVER,AAT,TAB,
        _,_,_,_,_,_,_,_,
/* 2 */ {" "},{"!"},{"\""},{"#"},{"$"},{"#"},{"&"},{"'"},
        {"("},{")"},{"*"},{"+"},{","},{"-"},{"."},{"/"},
/* 3 */ {"0"},{"1"},{"2"},{"3"},{"4"},{"5"},{"6"},{"7"},
        {"8"},{"9"},{":"},{";"},{"<"},{"="},{">"},{"?"},
/* 4 */ {"@"},{"A"},{"B"},{"C"},{"D"},{"E"},{"F"},{"G"},
        {"H"},{"I"},{"J"},{"K"},{"L"},{"M"},{"N"},{"O"},
/* 5 */ {"P"},{"Q"},{"R"},{"S"},{"T"},{"U"},{"V"},{"W"},
        {"X"},{"Y"},{"Z"},{"["},{"\\"},{"]"},{"↑"},{"_"},
/* 6 */ {"£"},{"a"},{"b"},{"c"},{"d"},{"e"},{"f"},{"g"},
        {"h"},{"i"},{"j"},{"k"},{"l"},{"m"},{"n"},{"o"},
/* 7 */ {"p"},{"q"},{"r"},{"s"},{"t"},{"u"},{"v"},{"w"},
        {"x"},{"y"},{"z"},{"{"},{"|"},{"}"},{"~"},{"©"},
/* 8 */ {"█"},{"▙"},{"▟"},{"▄"},{"▛"},{"▌"},{"▞"},{"▖"},
        {"▜"},{"▚"},{"▐"},{"▗"},{"▀"},{"▘"},{"▝"},{"▁"},
/* 9 */ {"Ⓐ"},{"Ⓑ"},{"Ⓒ"},{"Ⓓ"},{"Ⓔ"},{"Ⓕ"},{"Ⓖ"},{"Ⓗ"},
        {"Ⓘ"},{"Ⓙ"},{"Ⓚ"},{"Ⓛ"},{"Ⓜ"},{"Ⓝ"},{"Ⓞ"},{"Ⓟ"},
/* a */ {"Ⓠ"},{"Ⓡ"},{"Ⓢ"},{"Ⓣ"},{"Ⓤ"},RND,INKEY_,PI,
        FN,POINT,SCREEN_,ATTR,AT,TAB,VAL_,CODE,
/* b */ VAL,LEN,SIN,COS,TAN,ASN,ACS,ATN,
        LN,EXP,INT,SQR,SGN,ABS,PEEK,IN,
/* c */ USR,STR_,CHR_,NOT,BIN,OR,AND,_LE,
        _GE,_NE,LINE,THEN,TO,STEP,DEF_FN,CAT,
/* d */ FORMAT,MOVE,ERASE,OPEN_,CLOSE_,MERGE,VERIFY,BEEP,
        CIRCLE,INK,PAPER,FLASH,BRIGHT,INVERSE,OVER,OUT,
/* e */ LPRINT,LLIST,STOP,READ,DATA,RESTORE,NEW,BORDER,
        CONTINUE,DIM,REM,FOR,GOTO,GOSUB,INPUT,LOAD,
/* f */ LIST,LET,PAUSE,NEXT,POKE,PRINT,PLOT,RUN,
        SAVE,RANDOMIZE,IF,CLS,DRAW,CLEAR,RETURN,COPY
];

/**
 * Decodes BASIC instructions stored in RAM to human readable.
 *
 * Lines are stored as:
 *      - ushort(big-endian) line number
 *      - ushort line length
 *      - characters
 *      - 0x0d
 *
 * Numbers are stored as:
 *      - ascii values eg. '123' followed by
 *      - 0x0e followed by 5 numbers
 */
string decodeBASIC(ubyte[] ram) {
    //writefln("ram length = %s", ram.length);
    //writefln("%s", toHexStringArray(ram));
    string buf;
    int i = 0;
    while(i<ram.length) {
        if(i>0) buf ~= "\n";
        //writefln("i=%s [%02x]", i, ram[i]);
        auto lineNumber = (ram[i++]<<8) | ram[i++];
        //writefln("line = %s", lineNumber);
        buf ~= to!string(lineNumber) ~ " ";
        int len = (ram[i++] | (ram[i++]<<8));

        int start = i;
        //writefln("start = %s, len = %s", start, len);
        ZXChar prev;
        while(i < (start+len)) {
            if(i>=ram.length) {
                buf ~= "--!!BROKEN!!";
                break;
            }
            auto v = ram[i++];
            if(v==14) {
                // number
                i += 5;
            } else {
                auto ch = CHARSET[v];
                if(ch.name) {
                    if(prev.name.length>1) buf ~= " ";
                    buf ~= ch.name;
                    if(ch.name.length>1) buf ~= " ";
                }
                prev = ch;
            }
        }
    }
    return buf;
}