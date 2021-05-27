
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

