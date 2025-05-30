.globl _start
.align	2

_start:

init:
	nop

	li		sp, 5120		# 4096 (== 0x1000) for the code section plus another 1000 for the data section

	# Clear memory-mapped leds
	li		x5, 0			# Clear reg x5
	li		x6, 8192		# 8192 (= 0x2000), Memory-mapped address for LEDs
	sw		x5, 4(x6)		# Write 0x00000000 to memory-mapped LEDs

	j		main
