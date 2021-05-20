module emulator.assembler.Lexer;

import emulator.assembler.all;
import std.string : toLower;

final class Lexer {
private:
    string text;
    Token[] tokens;
    int pos;
    int bufStart;
    int line;
    int lineStart;
public:
    this(string text) {
        this.text = text;
    }
    Token[] tokenise() {
        while(pos < text.length) {
            auto ch = peek();
            //writefln("ch = %s", ch);
            if(ch<33) {
                addToken();
                if(!handleEOL()) {
                    pos++;
                }
                bufStart = pos;
            } else switch(ch) with(Kind) {
                case ';':
                    parseLComment();
                    break;
                case ',':
                    addToken(Kind.COMMA);
                    break;
                // case ':':
                //     addToken(Kind.COLON);
                //     break;
                case '\'':
                    if(peek(-2)=='a' && peek(-1)=='f') {
                        // Z80 hack for af'
                        pos++;
                        break;
                    }
                    goto case '"';
                case '"':
                    parseString();
                    break;
                case '+':
                    addToken(Kind.PLUS);
                    break;
                case '-':
                    if(bufStart == pos && peek(1).isDigit()) {
                         pos++;
                    } else {
                        addToken(Kind.MINUS);
                    }
                    break;
                case '*':
                    addToken(Kind.MUL);
                    break;
                case '/':
                    addToken(Kind.DIV);
                    break;
                case '%':
                    addToken(Kind.MOD);
                    break;
                case '(':
                    addToken(Kind.LBRACKET);
                    break;
                case ')':
                    addToken(Kind.RBRACKET);
                    break;
                default:
                    pos++;
                    break;
            }
        }
        addToken();

        // foreach(t; tokens) {
        //     writefln("%s", t.toString(text));
        // }

        return tokens;
    }
private:
    char peek(int offset=0) {
        if(pos+offset>=text.length) return 0;
        return text[pos+offset];
    }
    void parseString() {
        addToken();
        auto q = peek();
        pos++;
        while(pos<text.length) {
            if(peek()==q) {
                if(peek(-1)!='\\') {
                    pos++;
                    addToken();
                    break;
                }
            }
            pos++;
        }
    }
    void parseLComment() {
        addToken();

        while(pos < text.length) {
            if(peek() == 10 || peek() == 13) {
                handleEOL();
                bufStart = pos;
                return;
            }
            pos++;
        }
        addToken();
    }
    bool handleEOL() {
        bool isEOL = false;
        if(peek()==13 && peek(1)==10) {
            pos += 2;
            isEOL = true;
        } else if(peek()==13) {
            pos++;
            isEOL = true;
        } else if(peek()==10) {
            pos++;
            isEOL = true;
        }
        if(isEOL) {
            line++;
            lineStart = pos;
        }
        return isEOL;
    }
    auto determineTokenKind(string t) {
        if(t[0] >= '0' && t[0] <= '9') return Kind.NUMBER;
        if(t[0]=='$' || t[0]=='&') return Kind.NUMBER;
        if(t[0]=='\'' || t[0]=='"') return Kind.NUMBER;
        return Kind.TEXT;
    }
    void doAddToken(Kind k, string text) {
        //writefln("addToken(%s, '%s', pos=%s)", k, text, pos);
        Token t = {
            start: bufStart,
            length: text.length.as!int,
            line: line,
            kind: k,
            firstColumn: bufStart == lineStart
        };
        tokens ~= t;
    }
    void addToken(Kind k = Kind.NONE) {
        if(bufStart < pos) {
            auto t = text[bufStart..pos];
            doAddToken(determineTokenKind(t), t);
            bufStart = pos;
        }
        if(k != Kind.NONE) {
            auto t = k.toString();
            doAddToken(k, t);
            pos += t.length.as!int;
            bufStart = pos;
        }
    }
}
