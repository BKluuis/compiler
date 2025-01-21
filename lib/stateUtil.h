#ifndef STATEUTIL_H
#define STATEUTIL_H
#include <stdlib.h>

typedef struct Array Array;
void printArray(Array *);
void deleteArray(Array *);
Array *copyArray(Array *);

typedef struct typeEntry {
  char *name;
  size_t size;
} typeEntry;

typeEntry *createTypeEntry(char *name, size_t size);
void printTypeEntry(typeEntry *type);
void deleteTypeEntry(typeEntry *entry);
typeEntry *copyTypeEntry(typeEntry *);
int equalsTypeEntry(typeEntry *, typeEntry *);

typedef struct funcEntry {
  char *name;
  char *id; // Equivalente ao scope no varEntry
  Array *returnType;
} funcEntry;

funcEntry *createFuncEntry(char *name, char *id, Array *returnType);
void deleteFuncEntry(funcEntry *entry);
funcEntry *copyFuncEntry(funcEntry *);
void printFuncEntry(funcEntry *var);

typedef struct varEntry {
  char *name;
  char *scope;
  Array *types;
} varEntry;

varEntry *createVarEntry(char *name, Array *types, char *scope);
varEntry *varEntryExists(char *name, char *scope);
void deleteVarEntry(varEntry *entry);
void printVarEntry(varEntry *var);
varEntry *copyVarEntry(varEntry *);

char *generateName(char *, char *);

#endif