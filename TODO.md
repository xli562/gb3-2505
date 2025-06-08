# TODO

1. Write simple asm programs to test the ~10 ALU functions one-by-one. Switch between branch alu (unstable) and perf (stable).

ADD done
SUB done


1. Add reset logic for consistent behaviour

## Questions for Friday 30

- What is branch_enable in alu?
- Is CSRR in the RV32I ISA? Do we really need it for our single-core single-process single-thread processor? --- NO! Get rid of CSRR.
