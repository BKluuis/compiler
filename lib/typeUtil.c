#include "typeUtil.h"
#include "stateUtil.h"
#include "stringUtil.h"
#include "types/array.h"
#include "types/map.h"
#include "types/primitives.h"
#include "types/stack.h"
#include "types/string.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *typeFromToken(char *type) {
  char *s = NULL;

  if (equals(type, "Int", "char*")) {
    s = strdup("int*");
  } else if (equals(type, "Bool", "char*")) {
    s = strdup("int*");
  } else if (equals(type, "Float", "char*")) {
    s = strdup("float*");
  } else if (equals(type, "String", "char*")) {
    s = strdup("String*");
  } else if (equals(type, "Map", "char*")) {
    s = strdup("Map*");
  } else if (equals(type, "Array", "char*")) {
    s = strdup("Array*");
  } else if (equals(type, "Stack", "char*")) {
    s = strdup("Stack*");
  } else {
    fprintf(
        stderr,
        "Error parsing: cannot convert token to type %s because it's unknown\n",
        type);
    abort();
  }

  return s;
}
char *createFromType(char *type, char *args) {
  char *s = NULL;

  if (equals(type, "Int", "char*")) {
    s = cat3("createInt(", args, ")");
  } else if (equals(type, "Bool", "char*")) {
    s = cat3("createBool(", args, ")");
  } else if (equals(type, "Float", "char*")) {
    s = cat3("createFloat(", args, ")");
  } else if (equals(type, "String", "char*")) {
    s = cat3("createString(", args, ")");
  } else if (equals(type, "Map", "char*")) {
    s = cat3("createMap(", args, ")");
  } else if (equals(type, "Array", "char*")) {
    s = cat3("createArray(", args, ")");
  } else if (equals(type, "Stack", "char*")) {
    s = cat3("createStack(", args, ")");
  } else {
    fprintf(stderr,
            "Error parsing: %s doesn't have a create function in "
            "createFromType\n",
            type);
    abort();
  }

  return s;
}

// Stack não realizam uma comparação profunda
int equals(void *a, void *b, char *type) {
  if (strcmp(type, "Int") == 0) {
    return *(int *)a == *(int *)b;
  } else if (strcmp(type, "Float") == 0) {
    return *(float *)a == *(float *)b;
  } else if (strcmp(type, "char*") == 0) {
    return strcmp(a, b) == 0;
  } else if (strcmp(type, "String") == 0) {
    return equalsString(a, b);
  } else if (strcmp(type, "Array") == 0) {
    return equalsArray(a, b);
  } else if (strcmp(type, "Map") == 0) {
    return equalsMap(a, b);
  } else if (strcmp(type, "typeEntry") == 0) {
    return equalsTypeEntry(a, b);
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
  } else if (equals(type, "Int", "char*")) {
    printf("%d", *(int *)data);
  } else if (equals(type, "Float", "char*")) {
    printf("%f", *(float *)data);
  } else if (equals(type, "String", "char*")) {
    printString(data);
  } else if (equals(type, "char*", "char*")) {
    printf("%s", data);
  } else if (equals(type, "Map", "char*")) {
    printMap(data);
  } else if (equals(type, "Array", "char*")) {
    printArray(data);
  } else if (equals(type, "Stack", "char*")) {
    printStack(data);
  } else if (equals(type, "typeEntry", "char*")) {
    printTypeEntry(data);
  } else if (equals(type, "varEntry", "char*")) {
    printVarEntry(data);
  } else if (equals(type, "funcEntry", "char*")) {
    printFuncEntry(data);
  } else {
    printf("Error while printing: no printing defined for type %s\n", type);
  }
}

record *access(char *varName, Array *types, Array *accessors, int typeIndex,
               int accessIndex) {
  record *out = emptyRecord();
  int next = 1;

  char *curType = (char *)arrayGet(types, typeIndex);
  Map *curAccessor = (Map *)arrayGet(accessors, accessIndex);

  if (equals(curType, "Map", "char*")) {
    out->code = cat5("accessMap(", varName, ",", curAccessor->keys[0], ")");
    next = 2;
  } else if (equals(curType, "Array", "char*")) {
    out->code = cat5("accessArray(", varName, ",", curAccessor->keys[0], ")");
  }

  if (typeIndex + 1 < types->size && accessIndex + 1 < accessors->size) {
    out =
        access(out->code, types, accessors, typeIndex + next, accessIndex + 1);
  }

  if (accessIndex == accessors->size - 1) {
    Array *outType = createArray("char*", 3);
    for (int i = typeIndex + next; i < types->size; i++) {
      arrayAdd(outType, arrayGet(types, i));
    }
    out->array = outType;
  }

  printf("Returning from recursion %d: %s\n", typeIndex, out->code);
  return out;
}

void delete(void *data, char *type) {
  if (!data) {
    return;
  } else if (equals(type, "Int", "char*")) {
    free(data);
  } else if (equals(type, "Float", "char*")) {
    free(data);
  } else if (equals(type, "String", "char*")) {
    deleteString(data);
  } else if (equals(type, "Map", "char*")) {
    deleteMap(data);
  } else if (equals(type, "Array", "char*")) {
    deleteArray(data);
  } else if (equals(type, "typeEntry", "char*")) {
    deleteTypeEntry(data);
  } else if (equals(type, "varEntry", "char*")) {
    deleteVarEntry(data);
  } else if (equals(type, "funcEntry", "char*")) {
    deleteFuncEntry(data);
  } else if (equals(type, "char*", "char*")) {
    free(data);
  } else {
    fprintf(stderr, "Error: type %s doesn't implement delete\n", type);
    abort();
  }
  data = NULL;
}

void *copy(void *data, char *type) {
  if (equals(type, "Int", "char*")) {
    return copyInteger(data);
  } else if (equals(type, "Float", "char*")) {
    return copyFloat(data);
  } else if (equals(type, "char*", "char*")) {
    return strdup(data);
  } else if (equals(type, "String", "char*")) {
    copyString(data);
  } else if (equals(type, "Array", "char*")) {
    return copyArray(data);
  } else if (equals(type, "Map", "char*")) {
    return copyMap(data);
  } else if (equals(type, "typeEntry", "char*")) {
    return copyTypeEntry(data);
  } else if (equals(type, "varEntry", "char*")) {
    return copyVarEntry(data);
  } else if (equals(type, "funcEntry", "char*")) {
    return copyFuncEntry(data);
  } else {
    fprintf(stderr, "Error: type %s doesn't implement copy\n", type);
    abort();
  }
}

char *cast(char *data, char *newType, char *oldType) {
  if (equals(newType, "Int", "char*") && equals(oldType, "Float", "char*")) {
    return cat3("castftoi(", data, ")");
  } else if (equals(newType, "Float", "char*") &&
             equals(newType, "Float", "char*")) {
    return cat3("castitof(", data, ")");
  } else {
    fprintf(stderr, "Error: type %s doesn't implement casting to %s\n", oldType,
            newType);
    abort();
  }
}