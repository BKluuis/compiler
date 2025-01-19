#ifndef STATEUTIL_H
#define STATEUTIL_H
#include <stdlib.h>

typedef struct Array Array;

typedef struct typeEntry {
  char *name;
  size_t size;
} typeEntry;

typeEntry *createTypeEntry(char *name, size_t size);
void printTypeEntry(typeEntry *type);
void deleteTypeEntry(typeEntry *entry);
typeEntry *copyTypeEntry(typeEntry *);

typedef struct funcEntry {
  char *name;
  char *id; // Equivalente ao scope no varEntry
  typeEntry returnType;
} funcEntry;

funcEntry *createFuncEntry(char *name, char *id, char *returnType);
void deleteFuncEntry(funcEntry *entry);

typedef struct varEntry {
  char *name;
  char *scope;
  Array *types;
} varEntry;

varEntry *createVarEntry(char *name, Array *types, char *scope);
void deleteVarEntry(varEntry *entry);
void printVarEntry(varEntry *var);

char *generateName(char *, char *);

#endif