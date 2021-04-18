# Zilog Z80 information

## User Manual

https://zany80.github.io/documentation/Z80/UserManual.html

## Instructions

http://z80-heaven.wikidot.com/opcode-reference-chart
https://clrhome.org/table/
http://map.grauw.nl/resources/z80instr.php
http://www.z80.info/z80-op.txt
https://wikiti.brandonw.net/index.php?title=Z80_Instruction_Set
http://z80-heaven.wikidot.com/instructions-set

### Undocumented Instructions

http://www.z80.info/z80undoc.htm

## Memory Layout

0000 - Entry point

## Registers

**8 bit registers**

A   - Accumulator
B   - Counter
C   - Often used for interfacinf with hardware ports
D   - Mostly used in DE 16 bit form
E   - Mostly used in DE 16 bit form
F   - Flags
H   - Mostly used in DE 16 bit form
L   - Mostly used in DE 16 bit form

**16 bit versions of above**

AF  - Not normally used
BC  - Counter
DE  - Often used to hold destination address
HL  - Often used to hold source address

**16 bit registers**

IX  - Index (slower than HL)
IY  - Index
SP  - Stack pointer
PC  - Instruction pointer

**Other**

I - Interrupt register (hi byte of interrupt vector table - mode 2)
R - Refresh register (inc every time an instruction is fetched)

**Shadow Registers**

A'
B'
C'
D'
E'
F'
H'
L'