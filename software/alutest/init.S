.globl _start
.align	2

_start:

init:
	nop
	li		sp, 5120		# 4096 (== 0x1000) for the code section plus another 1000 for the data section
	
	add		x5, x0, 3		# x5 = 3
	add		x6, x0, 2		# x6 = 2
	add		x5, x6, x5		# x5 = 2 + 3 = 5
	li		x7, 64			# at address 0xa (36 / 4 = 9)
	sw		x5, 4(x7)		# store
	lw		x6, 4(x7)		# next-cycle read


	# j		main
