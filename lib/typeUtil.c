#include "typeUtil.h"
#include "types/array.h"
#include "types/map.h"
#include "types/primitives.h"
#include "types/string.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *typeFromToken(char *type, char *generic, char *size) {
  char *s = NULL;

  if (strcmp(type, "Int") == 0) {
    s = strdup("int*");
  } else if (strcmp(type, "Bool") == 0) {
    s = strdup("int*");
  } else if (strcmp(type, "Float") == 0) {
    s = strdup("float*");
  } else if (strcmp(type, "String") == 0) {
    s = strdup("char*");
  } else {
    s = typeWithGenericAndSize(type, generic, size);
  }

  return s;
}

char *typeWithGeneric(char *type, char *generic) {}

/* alterar a saida desse método, deve retornar uma entrada  */
char *typeWithGenericAndSize(char *type, char *generic, char *size) {
  char *var = NULL;

  if (strcmp(type, "Array") == 0) {
    // var = createVarEntry(NULL, type, NULL, NULL, NULL);
  } else if (strcmp(type, "Queue") == 0) {
    // s = typeWithGenericAndSize(type, generic, size);
  } else if (strcmp(type, "Deque") == 0) {
    // s = typeWithGenericAndSize(type, generic, size);
  } else if (strcmp(type, "Stack") == 0) {
    // s = typeWithGenericAndSize(type, generic, size);
  } else if (strcmp(type, "Map") == 0) {
    // s = typeWithGenericAndSize(type, generic, size);
  } else if (strcmp(type, "Set") == 0) {
    // s = typeWithGenericAndSize(type, generic, size);
  }
  var = (char *)malloc(strlen("notimplemented") + 1);
  strcpy(var, "notimplemented");
  return var;
}

int compare(void *a, void *b, char *type) {
  if (strcmp(type, "Int") == 0) {
    return *(int *)a == *(int *)b;
  } else if (strcmp(type, "Float") == 0) {
    return *(float *)a == *(float *)b;
  } else if (strcmp(type, "char*") == 0) {
    return strcmp(a, b) == 0;
  } else if (strcmp(type, "String") == 0) {
    return equalsString(a, b);
  } else {
    printf("Warning comparing values: %s doesn't implements comparation, "
           "comparing addresses\n",
           type);
    return a == b;
  }
}

void print(void *data, char *type) {
  if (!data) {
    printf("null");
  } else if (strcmp(type, "Int") == 0) {
    printf("%d", *(int *)data);
  } else if (strcmp(type, "Float") == 0) {
    printf("%f", *(float *)data);
  } else if (strcmp(type, "String") == 0) {
    printString(data);
  } else if (strcmp(type, "Map") == 0) {
    printMap(data);
  } else if (strcmp(type, "Array") == 0) {
    printArray(data);
  } else if (strcmp(type, "typeEntry") == 0) {
    printTypeEntry(data);
  } else if (strcmp(type, "varEntry") == 0) {
    printVarEntry(data);
  } else {
    printf("%s", type);
  }
}

void delete(void *data, char *type) {
  if (!data) {
    return;
  } else if (strcmp(type, "Int") == 0) {
    free(data);
  } else if (strcmp(type, "Float") == 0) {
    free(data);
  } else if (strcmp(type, "String") == 0) {
    deleteString(data);
  } else if (strcmp(type, "Map") == 0) {
    deleteMap(data);
  } else if (strcmp(type, "Array") == 0) {
    deleteArray(data);
  } else if (strcmp(type, "typeEntry") == 0) {
    deleteTypeEntry(data);
  } else if (strcmp(type, "varEntry") == 0) {
    deleteVarEntry(data);
  } else if (strcmp(type, "funcEntry") == 0) {
    deleteFuncEntry(data);
  } else if (strcmp(type, "char*") == 0) {
    free(data);
  } else {
    fprintf(stderr, "Error: type %s doesn't implement delete\n", type);
    abort();
  }
  data = NULL;
}

void *copy(void *data, char *type) {
  if (strcmp(type, "Int") == 0) {
    return copyInteger(data);
  } else if (strcmp(type, "Float") == 0) {
    return copyFloat(data);
  } else if (strcmp(type, "char*") == 0) {
    return strdup(data);
  } else if (strcmp(type, "String") == 0) {
    copyString(data);
  } else if (strcmp(type, "Array") == 0) {
    return copyArray(data);
  } else if (strcmp(type, "typeEntry") == 0) {
    return copyTypeEntry(data);
  } else {
    fprintf(stderr, "Error: type %s doesn't implement copy\n", type);
    abort();
  }
}