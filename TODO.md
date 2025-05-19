# TODO

## Questions for Tuesday 20

- Is it okay to use additional (also open-source) python packages for automated tests?

- Why does bubblesort do strange things after it terminates? It sorts perfectly, then goes on to flash randomly until it settles on a fixed routine of flashing every 5 seconds or so. Blinking the LED forever upon sort finish proves that sorting _does_ finish.

- Where does the 0x2000 memory address for the green LED come from?

- How to measure average CPI using the oscilloscope? Specifically, how to obtain the cycle count and the instruction count?

- How to obtain GPIO ports for debugging, e.g. clock speed measurement? I noticed that 8 LEDs are toggled in the code (0x00 to 0xFF), but only 1 flashes on the board. Are the other 7 LEDs actually memory-mapped GPIO? How to find them?

- Also, the 1Hz blink works the same when the jumper is removed from J23. This should not happen according to the dev board's manual?
