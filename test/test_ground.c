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

  printMap(typeMap);
  printf("\n");

  Array *types = createArray("char*", 3);
  arrayAdd(types, "Array*");
  arrayAdd(types, "Array*");
  arrayAdd(types, "int*");

  // createVarEntry("myArray", types, );

  cleanupGlobals();
  return 0;
}