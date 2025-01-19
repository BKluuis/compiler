#include "stateUtil.h"
#include "stringUtil.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static long namesCount = 0;

char *generateName(char *prefix, char *suffix) {
  int id_tam = snprintf(NULL, 0, "%ld", namesCount);
  char *id = (char *)malloc(id_tam + 1);
  sprintf(id, "%ld", namesCount);

  char *name = "";

  if (prefix) {
    name = cat2(prefix, name);
  }
  name = cat2(name, id);
  if (suffix) {
    name = cat2(name, prefix);
  }

  namesCount++;
  return name;
}

/*TODO: pegar as entries de tipo existentes*/
funcEntry *createFuncEntry(char *name, char *id, char *returnType) {
  funcEntry *entry = (funcEntry *)malloc(sizeof(funcEntry));
  if (entry == NULL) {
    return NULL;
  }

  if (name) {
    entry->name = strdup(name);
  } else {
    entry->name = NULL;
  }
  if (id) {
    entry->id = strdup(id);
  } else {
    entry->id = NULL;
  }
  // if (returnType) {
  //   entry->returnType = strdup(returnType);
  // } else {
  //   entry->returnType = NULL;
  // }

  return entry;
}

/*TODO: pegar as entries de tipo existentes*/
varEntry *createVarEntry(char *name, Array *types, char *scope) {
  varEntry *entry = (varEntry *)malloc(sizeof(varEntry));
  if (entry == NULL) {
    fprintf(stderr, "Could not create varEntry: unnable to allocate memory\n");
    exit(1);
  }

  entry->name = strdup(name);
  entry->types = copyArray(types);
  entry->scope = strdup(scope);

  return entry;
}

typeEntry *createTypeEntry(char *name, size_t size) {
  typeEntry *entry = malloc(sizeof(typeEntry));
  if (entry == NULL) {
    fprintf(stderr, "Could not create typeEntry: unnable to allocate memory\n");
    exit(1);
  }

  if (name == NULL) {
    printf("Não é possível gerar um tipo sem nome\n");
  }
  if (size == 0) {
    printf("Não é possível gerar um tipo sem tamanho\n");
  }

  entry->name = strdup(name);
  entry->size = size;
}

void deleteFuncEntry(funcEntry *entry) {
  if (entry) {
    free(entry->name);
    free(entry->id);
    free(entry->returnType.name);
    free(entry);
  }
}

void deleteVarEntry(varEntry *entry) {
  if (entry) {
    free(entry->name);
    free(entry->scope);
    deleteArray(entry->types);
    free(entry);
  }
}
void deleteTypeEntry(typeEntry *entry) {
  if (entry) {
    free(entry->name);
    free(entry);
  }
}

typeEntry *copyTypeEntry(typeEntry *other) {
  typeEntry *out = malloc(sizeof(typeEntry));
  if (!out) {
    fprintf(stderr, "Cannot copy typeEntry: unnable to allocate memory\n");
    exit(1);
  }
  out->name = strdup(other->name);
  out->size = other->size;
  return out;
}

void printVarEntry(varEntry *var) {
  printf("{%s, %s, ", var->name, var->scope);
  printArray(var->types);
  printf("}");
}
void printTypeEntry(typeEntry *type) {
  printf("{%s, %d}", type->name, type->size);
}
