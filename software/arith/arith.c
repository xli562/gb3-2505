#include "devscc.h"
#include "sf-types.h"
#include "sh7708.h"

#include "e-types.h"

volatile unsigned int a = 40;
volatile signed   int b = -10;
volatile unsigned int c = 42;
int add(int m, int n) {
  return m + n;
}

int main(void) {
  volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;
  *gDebugLedsMemoryMappedRegister = 0b00000010;

  // Standard arithmetic
  int bit15, bit13, bit12, bit10, newBit;
  int seed = 0x5876;
  for (int i = 0; i < 200; i ++) {
    a = b + a;          // ADD
    b = a + 5;          // ADDI
    a = c - a;          // SUB; dependancy
    c = b - 2;          // SUBI; dependancy
    a = a ^ i;
    c = a | c;          // OR
    c = c & 0x0000FFFF; // ANDI
    b = b & c;          // AND
    a = a | 0x1101;     // ORI
    a = a ^ b;          // XOR
    b = c ^ 0xBEEF;     // XORI
    a = a << b;         // SLL
    b = a + c;          // ADD; create dependancy
    c = i ^ b;
    b = a << 3;         // SLLI
    c = i & (a & 0b1111) | 0b10;
    b = b >> a;         // SRA
    b = b - 5000;
    b = b >> 2;         // SRAI
    a = c >> a;         // SRL
    c = a >> 3;         // SRLI
    a = b > i;          // SLT
    a = add(1, -i);     // JAL, JALR
    a = a > c;          // SLTU
    a = b < -1;         // SLTI
    a = a >= i;         // SLTUI
    
    if (a >= 2) {       // BGEU
      b = a ^ i ^ 5000;
    } else if (b > -5) {// BLT
      c = a ^ i ^ 4000;
    } else if (i != 8) {// BNE
      a = a ^ i ^ 3000;
    } else if (i < 40) {
      goto SHUFFLE;     // JAL
    }
    switch (b) {
      case 5:           // BEQ
        b ^= i;
        break;
      case 6:           // BEQ
        c ^= i;
        break;
    }
    SHUFFLE:
    // Shuffling (linear feedback shift register random number generator)
    bit15 = (seed >> 15) & 1;
    bit13 = (seed >> 13) & 1;
    bit12 = (seed >> 12) & 1;
    bit10 = (seed >> 10) & 1;
    newBit= bit15 ^ bit13 ^ bit12 ^ bit10;
    seed = (seed >> 1) | (newBit << 15);
    a = seed;
  }

  // Bubblesort
  uchar bsort_input[] = {
    0x2e, 0x2e, 0x2e, 0x53, 0x69, 0x6e, 0x67, 0x20, 0x74, 0x6f, 0x20, 0x6d, 0x65, 0x20, 0x6f, 0x66, 0x20, 0x74, 0x68, 0x65, 0x20, 0x6d, 0x61, 0x6e, 0x2c, 0x20, 0x4d, 0x75, 0x73, 0x65, 0x2c, 0x20, 0x74, 0x68, 0x65, 0x20, 0x6d, 0x61, 0x6e, 0x20, 0x6f, 0x66, 0x20, 0x74, 0x77, 0x69, 0x73, 0x74, 0x73, 0x20, 0x61, 0x6e, 0x64, 0x20, 0x74, 0x75, 0x72, 0x6e, 0x73, 0x2e, 0x2e, 0x2e, 0x53, 0x69, 0x6e, 0x67, 0x20, 0x74, 0x6f, 0x20, 0x6d, 0x65, 0x20, 0x6f, 0x66, 0x20, 0x74, 0x68, 0x65, 0x20, 0x6d, 0x61, 0x6e, 0x2c, 0x20, 0x4d, 0x75, 0x73, 0x65, 0x2c, 0x20, 0x74, 0x68, 0x65, 0x20, 0x6d, 0x61, 0x6e, 0x11, 0xee
  };
  const int bsort_input_len = 100;
  int i;
  int maxindex = bsort_input_len - 1;
  while (maxindex > 0) {
    for (i = 0; i < maxindex; i++) {
      if (bsort_input[i] > bsort_input[i + 1]) {
        /*		swap		*/
        bsort_input[i] ^= bsort_input[i + 1];
        bsort_input[i + 1] ^= bsort_input[i];
        bsort_input[i] ^= bsort_input[i + 1];
      }
    }
    maxindex--;
  }

  *gDebugLedsMemoryMappedRegister = 0b00000001;
  return 0;
}
