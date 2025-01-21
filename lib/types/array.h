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
void printArray(Array *array);
int equalsArray(Array *array1, Array *array2);

/**
 * Adds a copy of value into the array
 */
int arrayAdd(Array *array, void *element);
void *arrayGet(Array *array, size_t index);
void *accessArray(Array *array, size_t index);
/**
 * Returns an array equals array1 appended by array2
 * Doesn't modify array1 or array2
 */
Array *arrayAppend(Array *array1, Array *array2);

#endif