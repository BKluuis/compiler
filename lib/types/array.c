#include "array.h"
#include "../globals.h"
#include "string.h"
#include <stdio.h>
#include <string.h>

Array *createArray(char *type, size_t capacity) {
  if (!typeMap) {
    printf("Bad code: call initGlobals() before using any internal data "
           "structure\n");
    exit(2);
  }

  Array *array = (Array *)malloc(sizeof(Array));
  if (array == NULL) {
    printf("Cannot create array: unable to allocate memory for the array\n");
    exit(1);
  }

  typeEntry *t1 = (typeEntry *)mapGet(typeMap, type);
  if (t1 == NULL) {
    printf("Cannot create array: type %s doesn't exists\n", type);
  }
  int tam = t1->size;

  array->type = *t1;
  array->size = 0;
  array->capacity = capacity;

  array->data = malloc(capacity * tam);
  if (array->data == NULL) {
    printf("Cannot create array: unable to allocate memory for capacity\n");
    free(array);
    exit(1);
  }

  return array;
}

/* implementar abstração que copia o valor de qualquer variavel */
Array *copyArray(Array *a) {
  Array *out = createArray(a->type.name, a->capacity);
  for (int i = 0; i < a->size; i++) {
    void *element = copy(arrayGet(a, i), a->type.name);
    arrayAdd(out, element);
  }
  return out;
}

Array *clearArray(Array *array) {
  if (array) {
    for (int i = 0; i < array->size; i++) {
      if (array->data[i]) {
        free(array->data[i]);
      }
    }
    array->capacity = 10;
    array->size = 0;
  }
}

void deleteArray(Array *array) {
  if (array) {
    for (int i = 0; i < array->size; i++) {
      if (array->data[i]) {
        delete (array->data[i], array->type.name);
      }
    }
    free(array);
    array = NULL;
  }
}

int arrayAdd(Array *array, void *element) {
  if (array->size >= array->capacity) {
    size_t newCapacity = array->capacity * 2;
    void *newData = realloc(array->data, array->type.size * newCapacity);
    if (!newData)
      return -1;

    array->data = newData;
    array->capacity = newCapacity;
  }

  array->data[array->size] = copy(element, array->type.name);

  array->size++;
  return 0;
}

void *arrayGet(Array *array, size_t index) {
  if (index >= array->size) {
    printf("Cannot get array item: index out of bounds\n");
    exit(1);
  }

  return copy(array->data[index], array->type.name);
}

void printArray(Array *array) {
  printf("[");
  if (array) {
    for (size_t i = 0; i < array->size; i++) {
      print(array->data[i], array->type.name);
      if (i != array->size - 1) {
        printf(", ");
      }
    }
  } else {
    printf("null");
  }
  printf("]");
}

Array *arrayAppend(Array *array1, Array *array2) {
  if (!equals(&array1->type, &array2->type, "typeEntry")) {
    fprintf(stderr,
            "Error appending array: array1 is of type %s while array2 is of "
            "type %s\n",
            array1->type.name, array2->type.name);
    exit(1);
  }

  Array *newArray = copyArray(array1);

  for (int i = 0; i < array2->size; i++) {
    void *element = arrayGet(array2, i);
    if (element) {
      arrayAdd(newArray, element);
    }
  }

  return newArray;
}

int equalsArray(Array *array1, Array *array2) {
  if (!equals(&array1->type, &array2->type, "typeEntry")) {
    return 0;
  }
  if (array1->size != array2->size) {
    printf("Arrays are different because size is different\n");
    return 0;
  }
  for (int i = 0; i < array1->size; i++) {
    void *elem1 = arrayGet(array1, i);
    void *elem2 = arrayGet(array2, i);
    if (!equals(elem1, elem2, array1->type.name)) {
      return 0;
    }
  }

  return 1;
}

void *accessArray(Array *array, size_t index) {
  if (index >= array->size) {
    printf("Cannot get array item: index out of bounds\n");
    exit(1);
  }

  return array->data[index];
}