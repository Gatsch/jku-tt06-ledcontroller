<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This tinytapeout projects implements i2c to drive ws2812b individual addressable LEDs. The IC can be addressed with the address 0x4A. The register addresss corrosponds with the 

|address | data   |
|--------|--------|
|  0x00  | green0 |
|  0x01  | red0   |
|  0x02  | blue0  |
|  0x03  | green1 |
|  0x04  | red1   |
|  0x05  | blue1  |
|  0x06  | green2 |
| ...    | ...    |

## How to test

Connect 

## External hardware

Microntroller/computer (e.g. STM32, Arduino, Raspberry Pi, ...), ws2812b LED (strip, matrix, ...), external pullup resistors for i2c
