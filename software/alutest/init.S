.globl _start
.align	2

_start:

init:
	nop
	li		sp, 5120		# 4096 (== 0x1000) for the code section plus another 1000 for the data section
	
	add		x5, x0, 3		# x5 = 3
	add		x6, x0, 2		# x6 = 2
	sub		x5, x6, x5		# x5 = 3 + 2 = 5
	li		x6, 64			# at address 0xa (36 / 4 = 9)
	sw		x5, 4(x6)		# store 

	j		main
