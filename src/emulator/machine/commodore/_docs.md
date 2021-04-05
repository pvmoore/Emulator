
# Commodore 64

CPU     - 6510
Video   - VICII
Sound   - SID

D000 to DFFF -> Interface chip RAM (I/O or Character memory)

$00 - Data Direction Register
$01 - Output Register

## VIC II - Video Interface Chip - 6567 (NTSC) 6569 (PAL)

https://en.wikipedia.org/wiki/MOS_Technology_VIC-II

40 x 25 Text resolution
320 x 200 pixels (160 x 200  in multi-colour mode)
16 colours
8 24 x 21 sprites for scanline or (12 x 21 multi-colour)
Sprite = MOB (Movable Object Block)
Character data 8 x 8 x 256 characters = 2K

D000 to D02E - Control Registers (47)
0400 to 07E7 - Screen characters (40x25) (1000 bytes)

## SID - Sound Interface Device 6581

https://en.wikipedia.org/wiki/MOS_Technology_6581


## Kernal ROM

()
0E000 - FFFF (8K)

## BASIC ROM

A000 to BFFF (8K)

https://www.atarimagazines.com/compute/issue32/112_1_COMMODORE_64_ARCHITECTURE.php

## Port $0001 Bits

5 - Cassette motor control (0 = motor on)
4 - Cassette switch sense (0 = PLAY pressed)
3 - Cassette write line
2 - CHAREN (0=Character ROM instead of I/O area)
1 - HIRAM ($E000-$FFFF)
0 - LORAM ($A000-$BFFF)

If HIRAM or LORAM is set, the I/O area is mapped to $D000-$DFFF.

$0000 should always be set to $2F 