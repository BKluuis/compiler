#ifndef GLOBALS_H
#define GLOBALS_H

#include "./types/array.h"
#include "./types/map.h"
#include "./types/stack.h"

/**
 * Map of existing types
 */
extern Map *typeMap;

/**
 * Map of existing functions
 */
extern Map *funcMap;

/**
 * Map of existing variables
 */
extern Map *varMap;

extern Stack *scopeStack;
extern Array *typesArray;

void initGlobals();
void cleanupGlobals();
void printGlobals();

#endif
