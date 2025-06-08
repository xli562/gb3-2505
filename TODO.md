# TODO

1. revert to previous working branch, run test on EVERY SMALL CHANGE
1. Write simple asm programs to test the ~10 ALU functions one-by-one. Switch between branch alu (unstable) and perf (stable).

ADD done (3 + 2 = 5)
SUB done (3 - 2 = -1)
AND done (10101101 & 11011011 = 10001001)
OR  done (10101101 & 10011011 = 10111111)
XOR done (10101101 ^ 10011011 = 00110110)
SLL done (10101101 << 5       = 1010110100000)
SRL done (11111111111 >> 5    = 111111)
SRA error(-10 >>> 2 = 00111111111111111111111111111101) (-10 == 11110110)


## Questions for Friday 30

- What is branch_enable in alu?
- Is CSRR in the RV32I ISA? Do we really need it for our single-core single-process single-thread processor? --- NO! Get rid of CSRR.
