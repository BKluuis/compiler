#ifndef ARRAY_H
#define ARRAY_H

#include "../typeUtil.h"
#include "map.h"
#include <stdlib.h>

typedef struct Array {
  void **data;
  typeEntry type;
  size_t size;
  size_t capacity;
} Array;

Array *createArray(char *type, size_t capacity);
Array *clearArray(Array *array);
Array *copyArray(Array *array);
void deleteArray(Array *array);

/**
 * Adds a copy of value into the array
 */
int arrayAdd(Array *array, void *element);
void *arrayGet(Array *array, size_t index);
void printArray(Array *array);

#endif