#include "dhry.h"

#ifdef USE_MYSTDLIB
extern char *malloc();
#else
#include <stdlib.h>
#include <string.h>
#endif

/* Global Variables: */

Rec_Pointer Ptr_Glob,
    Next_Ptr_Glob;
int Int_Glob;
Boolean Bool_Glob;
char Ch_1_Glob,
    Ch_2_Glob;
int Arr_1_Glob[50];
int Arr_2_Glob[50][50];

Enumeration Func_1();
/* forward declaration necessary since Enumeration may not simply be int */

#ifndef REG
Boolean Reg = false;
#define REG
/* REG becomes defined as empty */
/* i.e. no register variables   */
#else
Boolean Reg = true;
#endif

/* Procedure for the assignment of structures,          */
/* if the C compiler doesn't support this feature       */
#ifdef NOSTRUCTASSIGN
memcpy(d, s, l) register char *d;
register char *s;
register int l;
{
  while (l--)
    *d++ = *s++;
}
#endif

#ifndef REG
#define REG
/* REG becomes defined as empty */
/* i.e. no register variables   */
#endif

extern int Int_Glob;
extern char Ch_1_Glob;

Proc_1(Ptr_Val_Par)
REG Rec_Pointer Ptr_Val_Par;
{
  REG Rec_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;
  /* == Ptr_Glob_Next */
  /* Local variable, initialized with Ptr_Val_Par->Ptr_Comp,    */
  /* corresponds to "rename" in Ada, "with" in Pascal           */

  structassign(*Ptr_Val_Par->Ptr_Comp, *Ptr_Glob);
  Ptr_Val_Par->variant.var_1.Int_Comp = 5;
  Next_Record->variant.var_1.Int_Comp = Ptr_Val_Par->variant.var_1.Int_Comp;
  Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
  Proc_3(&Next_Record->Ptr_Comp);
  /* Ptr_Val_Par->Ptr_Comp->Ptr_Comp
                      == Ptr_Glob->Ptr_Comp */
  if (Next_Record->Discr == Ident_1)
  /* then, executed */
  {
    Next_Record->variant.var_1.Int_Comp = 6;
    Proc_6(Ptr_Val_Par->variant.var_1.Enum_Comp,
           &Next_Record->variant.var_1.Enum_Comp);
    Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
    Proc_7(Next_Record->variant.var_1.Int_Comp, 10,
           &Next_Record->variant.var_1.Int_Comp);
  }
  else /* not executed */
    structassign(*Ptr_Val_Par, *Ptr_Val_Par->Ptr_Comp);
}

Proc_2(Int_Par_Ref)
One_Fifty *Int_Par_Ref;
{
  One_Fifty Int_Loc;
  Enumeration Enum_Loc;

  Int_Loc = *Int_Par_Ref + 10;
  do /* executed once */
    if (Ch_1_Glob == 'A')
    /* then, executed */
    {
      Int_Loc -= 1;
      *Int_Par_Ref = Int_Loc - Int_Glob;
      Enum_Loc = Ident_1;
    } /* if */
  while (Enum_Loc != Ident_1); /* true */
}

Proc_3(Ptr_Ref_Par)
Rec_Pointer *Ptr_Ref_Par;
{
  if (Ptr_Glob != Null)
    /* then, executed */
    *Ptr_Ref_Par = Ptr_Glob->Ptr_Comp;
  Proc_7(10, Int_Glob, &Ptr_Glob->variant.var_1.Int_Comp);
}

Proc_4() {
  Boolean Bool_Loc;

  Bool_Loc = Ch_1_Glob == 'A';
  Bool_Glob = Bool_Loc | Bool_Glob;
  Ch_2_Glob = 'B';
} /* Proc_4 */

Proc_5() {
  Ch_1_Glob = 'A';
  Bool_Glob = false;
}



Proc_6(Enum_Val_Par, Enum_Ref_Par)
Enumeration Enum_Val_Par;
Enumeration *Enum_Ref_Par;
{
  *Enum_Ref_Par = Enum_Val_Par;
  if (!Func_3(Enum_Val_Par))
    /* then, not executed */
    *Enum_Ref_Par = Ident_4;
  switch (Enum_Val_Par)
  {
  case Ident_1:
    *Enum_Ref_Par = Ident_1;
    break;
  case Ident_2:
    if (Int_Glob > 100)
      /* then */
      *Enum_Ref_Par = Ident_1;
    else
      *Enum_Ref_Par = Ident_4;
    break;
  case Ident_3: /* executed */
    *Enum_Ref_Par = Ident_2;
    break;
  case Ident_4:
    break;
  case Ident_5:
    *Enum_Ref_Par = Ident_3;
    break;
  } /* switch */
}

Proc_7(Int_1_Par_Val, Int_2_Par_Val, Int_Par_Ref)
One_Fifty Int_1_Par_Val;
One_Fifty Int_2_Par_Val;
One_Fifty *Int_Par_Ref;
{
  One_Fifty Int_Loc;

  Int_Loc = Int_1_Par_Val + 2;
  *Int_Par_Ref = Int_2_Par_Val + Int_Loc;
}

Proc_8(Arr_1_Par_Ref, Arr_2_Par_Ref, Int_1_Par_Val, Int_2_Par_Val)
Arr_1_Dim Arr_1_Par_Ref;
Arr_2_Dim Arr_2_Par_Ref;
int Int_1_Par_Val;
int Int_2_Par_Val;
{
  REG One_Fifty Int_Index;
  REG One_Fifty Int_Loc;

  Int_Loc = Int_1_Par_Val + 5;
  Arr_1_Par_Ref[Int_Loc] = Int_2_Par_Val;
  Arr_1_Par_Ref[Int_Loc + 1] = Arr_1_Par_Ref[Int_Loc];
  Arr_1_Par_Ref[Int_Loc + 30] = Int_Loc;
  for (Int_Index = Int_Loc; Int_Index <= Int_Loc + 1; ++Int_Index)
    Arr_2_Par_Ref[Int_Loc][Int_Index] = Int_Loc;
  Arr_2_Par_Ref[Int_Loc][Int_Loc - 1] += 1;
  Arr_2_Par_Ref[Int_Loc + 20][Int_Loc] = Arr_1_Par_Ref[Int_Loc];
  Int_Glob = 5;
}

Enumeration Func_1(Ch_1_Par_Val, Ch_2_Par_Val)
Capital_Letter Ch_1_Par_Val;
Capital_Letter Ch_2_Par_Val;
{
  Capital_Letter Ch_1_Loc;
  Capital_Letter Ch_2_Loc;

  Ch_1_Loc = Ch_1_Par_Val;
  Ch_2_Loc = Ch_1_Loc;
  if (Ch_2_Loc != Ch_2_Par_Val)
    /* then, executed */
    return (Ident_1);
  else /* not executed */
  {
    Ch_1_Glob = Ch_1_Loc;
    return (Ident_2);
  }
}

Boolean Func_2(Str_1_Par_Ref, Str_2_Par_Ref)
Str_30 Str_1_Par_Ref;
Str_30 Str_2_Par_Ref;
{
  REG One_Thirty Int_Loc;
  Capital_Letter Ch_Loc;

  Int_Loc = 2;
  while (Int_Loc <= 2) /* loop body executed once */
    if (Func_1(Str_1_Par_Ref[Int_Loc],
               Str_2_Par_Ref[Int_Loc + 1]) == Ident_1)
    /* then, executed */
    {
      Ch_Loc = 'A';
      Int_Loc += 1;
    } /* if, while */
  if (Ch_Loc >= 'W' && Ch_Loc < 'Z')
    /* then, not executed */
    Int_Loc = 7;
  if (Ch_Loc == 'R')
    /* then, not executed */
    return (true);
  else /* executed */
  {
    if (strcmp(Str_1_Par_Ref, Str_2_Par_Ref) > 0)
    /* then, not executed */
    {
      Int_Loc += 7;
      Int_Glob = Int_Loc;
      return (true);
    }
    else /* executed */
      return (false);
  } /* if Ch_Loc */
}

Boolean Func_3(Enum_Par_Val)
Enumeration Enum_Par_Val;
{
  Enumeration Enum_Loc;

  Enum_Loc = Enum_Par_Val;
  if (Enum_Loc == Ident_3)
    /* then, executed */
    return (true);
  else /* not executed */
    return (false);
}


int main() {
/*****/

/* main program, corresponds to procedures        */
/* Main and Proc_0 in the Ada version             */

  volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0xF1ED;
  *gDebugLedsMemoryMappedRegister = 0b00000001; // Raise 'started' flag

  One_Fifty Int_1_Loc;
  REG One_Fifty Int_2_Loc;
  One_Fifty Int_3_Loc;
  REG char Ch_Index;
  Enumeration Enum_Loc;
  Str_30 Str_1_Loc;
  Str_30 Str_2_Loc;
  REG int Run_Index;
  REG int Number_Of_Runs;

  /* Initializations */

  Next_Ptr_Glob = (Rec_Pointer)malloc(sizeof(Rec_Type));
  Ptr_Glob = (Rec_Pointer)malloc(sizeof(Rec_Type));

  Ptr_Glob->Ptr_Comp = Next_Ptr_Glob;
  Ptr_Glob->Discr = Ident_1;
  Ptr_Glob->variant.var_1.Enum_Comp = Ident_3;
  Ptr_Glob->variant.var_1.Int_Comp = 40;
  strcpy(Ptr_Glob->variant.var_1.Str_Comp,
         "DHRYSTONE PROGRAM, SOME STRING");
  strcpy(Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING");

  Arr_2_Glob[8][7] = 10;
  /* Was missing in published program. Without this statement,    */
  /* Arr_2_Glob [8][7] would have an undefined value.             */
  /* Warning: With 16-Bit processors and Number_Of_Runs > 32000,  */
  /* overflow may occur for this array element.                   */

  Number_Of_Runs = 5;

  /***************/
  /* Start timer */
  /***************/

  for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index)
  {

    Proc_5();
    Proc_4();
    /* Ch_1_Glob == 'A', Ch_2_Glob == 'B', Bool_Glob == true */
    Int_1_Loc = 2;
    Int_2_Loc = 3;
    strcpy(Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
    Enum_Loc = Ident_2;
    Bool_Glob = !Func_2(Str_1_Loc, Str_2_Loc);
    /* Bool_Glob == 1 */
    while (Int_1_Loc < Int_2_Loc) /* loop body executed once */
    {
      Int_3_Loc = 5 * Int_1_Loc - Int_2_Loc;
      /* Int_3_Loc == 7 */
      Proc_7(Int_1_Loc, Int_2_Loc, &Int_3_Loc);
      /* Int_3_Loc == 7 */
      Int_1_Loc += 1;
    } /* while */
    /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Proc_8(Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);
    /* Int_Glob == 5 */
    Proc_1(Ptr_Glob);
    for (Ch_Index = 'A'; Ch_Index <= Ch_2_Glob; ++Ch_Index)
    /* loop body executed twice */
    {
      if (Enum_Loc == Func_1(Ch_Index, 'C'))
      /* then, not executed */
      {
        Proc_6(Ident_1, &Enum_Loc);
        strcpy(Str_2_Loc, "DHRYSTONE PROGRAM, 3'RD STRING");
        Int_2_Loc = Run_Index;
        Int_Glob = Run_Index;
      }
    }
    /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Int_2_Loc = Int_2_Loc * Int_1_Loc;
    Int_1_Loc = Int_2_Loc / Int_3_Loc;
    Int_2_Loc = 7 * (Int_2_Loc - Int_3_Loc) - Int_1_Loc;
    /* Int_1_Loc == 1, Int_2_Loc == 13, Int_3_Loc == 7 */
    Proc_2(&Int_1_Loc);
    /* Int_1_Loc == 5 */

  } /* loop "for Run_Index" */

  /**************/
  /* Stop timer */
  /**************/

  // printf("Execution ends\n");
  // printf("\n");
  // printf("Final values of the variables used in the benchmark:\n");
  // printf("\n");
  // printf("Int_Glob:            %d\n", Int_Glob);
  // printf("        should be:   %d\n", 5);
  // printf("Bool_Glob:           %d\n", Bool_Glob);
  // printf("        should be:   %d\n", 1);
  // printf("Ch_1_Glob:           %c\n", Ch_1_Glob);
  // printf("        should be:   %c\n", 'A');
  // printf("Ch_2_Glob:           %c\n", Ch_2_Glob);
  // printf("        should be:   %c\n", 'B');
  // printf("Arr_1_Glob[8]:       %d\n", Arr_1_Glob[8]);
  // printf("        should be:   %d\n", 7);
  // printf("Arr_2_Glob[8][7]:    %d\n", Arr_2_Glob[8][7]);
  // printf("        should be:   Number_Of_Runs + 10\n");
  // printf("Ptr_Glob->\n");
  // printf("  Discr:             %d\n", Ptr_Glob->Discr);
  // printf("        should be:   %d\n", 0);
  // printf("  Enum_Comp:         %d\n", Ptr_Glob->variant.var_1.Enum_Comp);
  // printf("        should be:   %d\n", 2);
  // printf("  Int_Comp:          %d\n", Ptr_Glob->variant.var_1.Int_Comp);
  // printf("        should be:   %d\n", 17);
  // printf("  Str_Comp:          %s\n", Ptr_Glob->variant.var_1.Str_Comp);
  // printf("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  // printf("Next_Ptr_Glob->\n");
  // printf("  Ptr_Comp:          %d\n", (int)Next_Ptr_Glob->Ptr_Comp);
  // printf("        should be:   (implementation-dependent), same as above\n");
  // printf("  Discr:             %d\n", Next_Ptr_Glob->Discr);
  // printf("        should be:   %d\n", 0);
  // printf("  Enum_Comp:         %d\n", Next_Ptr_Glob->variant.var_1.Enum_Comp);
  // printf("        should be:   %d\n", 1);
  // printf("  Int_Comp:          %d\n", Next_Ptr_Glob->variant.var_1.Int_Comp);
  // printf("        should be:   %d\n", 18);
  // printf("  Str_Comp:          %s\n",
  //        Next_Ptr_Glob->variant.var_1.Str_Comp);
  // printf("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  // printf("Int_1_Loc:           %d\n", Int_1_Loc);
  // printf("        should be:   %d\n", 5);
  // printf("Int_2_Loc:           %d\n", Int_2_Loc);
  // printf("        should be:   %d\n", 13);
  // printf("Int_3_Loc:           %d\n", Int_3_Loc);
  // printf("        should be:   %d\n", 7);
  // printf("Enum_Loc:            %d\n", Enum_Loc);
  // printf("        should be:   %d\n", 1);
  // printf("Str_1_Loc:           %s\n", Str_1_Loc);
  // printf("        should be:   DHRYSTONE PROGRAM, 1'ST STRING\n");
  // printf("Str_2_Loc:           %s\n", Str_2_Loc);
  // printf("        should be:   DHRYSTONE PROGRAM, 2'ND STRING\n");
  // printf("\n");

  *gDebugLedsMemoryMappedRegister = 0b00000111; // Raise 'finished' flag
  return 0;
}
