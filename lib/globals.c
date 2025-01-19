#include "globals.h"
#include "types/array.h"
#include "types/string.h"
#include <stdio.h>
#include <stdlib.h>

Map *typeMap = NULL;
Map *varMap = NULL;
Map *funcMap = NULL;
Stack *scopeStack = NULL;

void initStandardTypes() {
  if (typeMap != NULL) {
    typeEntry *intType = createTypeEntry("Int", sizeof(int *));
    typeEntry *floatType = createTypeEntry("Float", sizeof(float *));
    typeEntry *mapType = createTypeEntry("Map", sizeof(Map *));
    typeEntry *stringType = createTypeEntry("String", sizeof(String *));
    typeEntry *arrayType = createTypeEntry("Array", sizeof(Array *));
    typeEntry *stackType = createTypeEntry("Stack", sizeof(Stack *));
    typeEntry *zeroStringType = createTypeEntry("char*", sizeof(char *));

    mapPut(typeMap, "Int", intType);
    mapPut(typeMap, "Float", floatType);
    mapPut(typeMap, "Map", mapType);
    mapPut(typeMap, "String", stringType);
    mapPut(typeMap, "Array", arrayType);
    mapPut(typeMap, "Stack", stackType);
    mapPut(typeMap, "char*", zeroStringType);
  } else {
    fprintf(stderr, "Cannot initiate types: typeMap not initialized\n");
  }
}

void initGlobals() {
  if (typeMap == NULL) {
    typeMap = createInternalMap("char*", sizeof(char *), "typeEntry",
                                sizeof(typeEntry *));
    initStandardTypes();
    printf("Types map created\n");
  }
  if (varMap == NULL) {
    varMap = createInternalMap("char*", sizeof(char *), "varEntry",
                               sizeof(varEntry *));
    printf("Variables map created\n");
  }
  if (funcMap == NULL) {
    funcMap = createInternalMap("char*", sizeof(char *), "funcEntry",
                                sizeof(funcEntry *));
    printf("Functions map created\n");
  }
  if (scopeStack == NULL) {
    scopeStack = createStack("char*", 5);
    printf("Scope stack created\n");
  }
}

void cleanupGlobals() {
  if (typeMap != NULL) {
    deleteMap(typeMap);
    typeMap = NULL;
    printf("Types map deleted\n");
  }
  if (varMap != NULL) {
    deleteMap(varMap);
    varMap = NULL;
    printf("Variables map deleted\n");
  }
  if (funcMap != NULL) {
    deleteMap(funcMap);
    funcMap = NULL;
    printf("Functions map deleted\n");
  }
  if (scopeStack != NULL) {
    deleteStack(scopeStack);
    scopeStack = NULL;
    printf("Scope stack deleted\n");
  }
}