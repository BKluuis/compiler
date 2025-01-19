#ifndef MAP_H
#define MAP_H

#include "../stateUtil.h"
#include <stdlib.h>

/* Uma estrutura de mapa genérica. Muito cuidado, os tipos DEVEM passados devem
 * ser ponteiros */
typedef struct Map {
  void **keys;
  void **values;
  typeEntry keyType;
  typeEntry valueType;
  size_t size;
  size_t capacity;
} Map;

Map *createInternalMap(char *keyType, size_t keySize, char *valueType,
                       size_t valueSize);
Map *createMap(char *, char *, size_t);
void deleteMap(Map *);

/**
 * Puts a copy of value into key (or a copy of key if key doesn't exists)
 */
void mapPut(Map *, void *, void *);
void *mapGet(Map *, void *);
void printMap(Map *);
int compareMap(Map *, Map *);

#endif