#include "../lib/globals.h"
#include "../lib/stateUtil.h"
#include "../lib/stringUtil.h"
#include "../lib/typeUtil.h"
#include "../lib/types/array.h"
#include "../lib/types/map.h"
#include "../lib/types/primitives.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int *swap(int *a, int *b) {
  int *temp = malloc(sizeof(int));

  *temp = *a;
  *a = *b;
  *b = *temp;
  return temp;
}

void *createArray2(char *type, int size) {
  // typeEntry t = mapGet(typesMap, type);
  // int tam = t.size;
  void *arr = malloc(sizeof(int) * size);
  if (arr == NULL) {
    printf("Não foi possível iniciar Array");
    exit(2);
  }
  return arr;
}

int main() {
  initGlobals();

  Array *myArray = createArray("Array", 10);
  Array *myInnerArray = createArray("Int", 3);

  int *t1 = createInt(1);
  arrayAdd(myInnerArray, t1);
  delete (t1, "Int");

  int *t2 = createInt(2);
  arrayAdd(myInnerArray, t2);
  delete (t2, "Int");

  int *t3 = createInt(3);
  arrayAdd(myInnerArray, t3);
  delete (t3, "Int");

  arrayAdd(myArray, myInnerArray);
  arrayAdd(myArray, myInnerArray);
  arrayAdd(myArray, myInnerArray);

  delete (myInnerArray, "Array");

  print(myArray, "Array");

  cleanupGlobals();
  return 0;
}