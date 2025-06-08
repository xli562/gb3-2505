# TODO

1. revert to previous working branch, run test on EVERY SMALL CHANGE
1. Write simple asm programs to test the ~10 ALU functions one-by-one. Switch between branch alu (unstable) and perf (stable).

ADD done
SUB done

## Questions for Friday 30

- What is branch_enable in alu?
- Is CSRR in the RV32I ISA? Do we really need it for our single-core single-process single-thread processor? --- NO! Get rid of CSRR.
