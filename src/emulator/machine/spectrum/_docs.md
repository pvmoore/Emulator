
# Sinclair Spectrum

## Memory Map

https://skoolkid.github.io/rom/

| Start | End | Description             |
-----------------------------------------
| 0000 | 3fff | ROM                     |
| 4000 | 57ff | Screen Pixel Memory     |
| 5800 | 5aff | Screen attribute Memory |
| 5b00 | 5bff | Printer Buffer          |
| 5c00 | 5cbf | System Variables        |
| 5cc0 | 5cca | Reserved                |
| 5ccb | ff57 | Available               |

5b00 -> Can be used but the only way out is to reset.

5c48 - border colour

### Video Memory

32x24 bytes
256x192 pixels


- 6144 bytes at [0x4000 - 0x57ff]
    - 192 lines of 32 bytes per line
- 768 bytes at [0x5800 - 0x5aff]

## Assembly Language

http://www.retro8bitcomputers.co.uk/Content/downloads/books/SpectrumMachineLanguageForTheAbsoluteBeginner.pdf

## Interrupts

http://www.breakintoprogram.co.uk/computers/zx-spectrum/interrupts

IM 0 - Not used on Spectrum
IM 1 - Triggers 50 times a second - during vertical refresh - Jumps to address 0x0038
       Mainly used for scanning the keyboard
IM 2 - Interrupt vector table

Spectrum normally uses IM 1.

IM 2 - Triggers 50 times a second on vertical blank.
       128 word vector table (on a page - 256 byte - boundary). This table is located at (I<<8)
       ie. I = 0x20, table is at 0x2000

## Ports

https://worldofspectrum.org/faq/reference/48kreference.htm#PortFE

### 0xfe is the ULA port

Write:

- Bits 0,1,2  = border colour
- Bit  3      = MIC
- Bit  4      = EAR

Read:

- 0xfefe SHIFT,Z,X,C,V keys (bits 0-4)
etc...

### Channels

https://sinclair.wiki.zxnet.co.uk/wiki/Channels_and_streams

- K Keyboard (0, 1)
- S Screen (2)
- P Printer (3)
- R Edit buffer