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

  if (strcmp(type, "Int") == 0) {
    s = strdup("int*");
  } else if (strcmp(type, "Bool") == 0) {
    s = strdup("int*");
  } else if (strcmp(type, "Float") == 0) {
    s = strdup("float*");
  } else if (strcmp(type, "String") == 0) {
    s = strdup("String*");
  } else if (strcmp(type, "Map") == 0) {
    s = strdup("Map*");
  } else if (strcmp(type, "Array") == 0) {
    s = strdup("Array*");
  } else if (strcmp(type, "Stack") == 0) {
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

  if (strcmp(type, "Int") == 0) {
    s = cat3("createInt(", args, ")");
  } else if (strcmp(type, "Bool") == 0) {
    s = cat3("createBool(", args, ")");
  } else if (strcmp(type, "Float") == 0) {
    s = cat3("createFloat(", args, ")");
  } else if (strcmp(type, "String") == 0) {
    s = cat3("createString(", args, ")");
  } else if (strcmp(type, "Map") == 0) {
    s = cat3("createMap(", args, ")");
  } else if (strcmp(type, "Array") == 0) {
    s = cat3("createArray(", args, ")");
  } else if (strcmp(type, "Stack") == 0) {
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

// Array, Stack e Map não realizam uma comparação profunda
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
  } else if (strcmp(type, "Int") == 0) {
    printf("%d", *(int *)data);
  } else if (strcmp(type, "Float") == 0) {
    printf("%f", *(float *)data);
  } else if (strcmp(type, "String") == 0) {
    printString(data);
  } else if (strcmp(type, "char*") == 0) {
    printf("%s", data);
  } else if (strcmp(type, "Map") == 0) {
    printMap(data);
  } else if (strcmp(type, "Array") == 0) {
    printArray(data);
  } else if (strcmp(type, "Stack") == 0) {
    printStack(data);
  } else if (strcmp(type, "typeEntry") == 0) {
    printTypeEntry(data);
  } else if (strcmp(type, "varEntry") == 0) {
    printVarEntry(data);
  } else if (strcmp(type, "funcEntry") == 0) {
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

  if (strcmp(curType, "Map") == 0) {
    out->code = cat5("accessMap(", varName, ",", curAccessor->keys[0], ")");
    next = 2;
  } else if (strcmp(curType, "Array") == 0) {
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
  } else if (strcmp(type, "Map") == 0) {
    return copyMap(data);
  } else if (strcmp(type, "typeEntry") == 0) {
    return copyTypeEntry(data);
  } else if (strcmp(type, "varEntry") == 0) {
    return copyVarEntry(data);
  } else if (strcmp(type, "funcEntry") == 0) {
    return copyFuncEntry(data);
  } else {
    fprintf(stderr, "Error: type %s doesn't implement copy\n", type);
    abort();
  }
}

char *cast(char *data, char *newType, char *oldType) {
  if (strcmp(newType, "Int") == 0 && strcmp(oldType, "Float") == 0) {
    return cat3("castftoi(", data, ")");
  } else if (strcmp(newType, "Float") == 0 && strcmp(newType, "Float") == 0) {
    return cat3("castitof(", data, ")");
  } else {
    fprintf(stderr, "Error: type %s doesn't implement casting to %s\n", oldType,
            newType);
    abort();
  }
}