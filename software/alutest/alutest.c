#include "devscc.h"
#include "sf-types.h"
#include "sh7708.h"

#include "e-types.h"

int a = 0;
int b = 3;
int c = 2;

int main(void) {
  volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;
  *gDebugLedsMemoryMappedRegister = 0b00000010;
  a = b + c;
  c = a + b;
  *gDebugLedsMemoryMappedRegister = 0b00000001;
  return 0;
}
