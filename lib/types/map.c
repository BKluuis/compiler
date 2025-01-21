#include "map.h"
#include "../globals.h"
#include "../typeUtil.h"
#include <stdio.h>
#include <string.h>

Map *createInternalMap(char *keyType, size_t keySize, char *valueType,
                       size_t valueSize) {
  if (keyType == NULL || valueType == NULL) {
    printf("Cannot create map, one of supplied arguments are null\n");
    exit(1);
  }

  Map *map = (Map *)malloc(sizeof(Map));
  if (map == NULL) {
    return NULL;
  }
  int capacity = 10;

  map->keys = malloc(capacity * keySize);
  map->values = malloc(capacity * valueSize);
  if (map->keys == NULL || map->values == NULL) {
    free(map->keys);
    free(map->values);
    free(map);
    return NULL;
  }

  map->keyType = *createTypeEntry(keyType, keySize);
  map->valueType = *createTypeEntry(valueType, valueSize);
  map->size = 0;
  map->capacity = capacity;

  return map;
}

Map *createMap(char *keyType, char *valueType, size_t capacity) {
  if (!typeMap) {
    printf("Bad code: call initGlobals() before using any internal data "
           "structure\n");
    exit(2);
  }

  if (typeMap == NULL || keyType == NULL || valueType == NULL) {
    printf("Cannot create map: one of supplied arguments are null\n");
    exit(1);
  }

  Map *map = (Map *)malloc(sizeof(Map));
  if (map == NULL) {
    printf("Cannot create map: unable to allocate memory for the map\n");
    exit(1);
  }

  typeEntry *t1 = (typeEntry *)mapGet(typeMap, keyType);
  if (t1 == NULL) {
    printf("Cannot create map: type %s doesn't exists", keyType);
  }
  int keytam = t1->size;

  typeEntry *t2 = (typeEntry *)mapGet(typeMap, valueType);
  if (t2 == NULL) {
    printf("Cannot create map: type %s doesn't exists", valueType);
  }
  int valuetam = t2->size;

  if (capacity <= 0) {
    capacity = 5;
  }

  map->keys = malloc(capacity * keytam);
  map->values = malloc(capacity * valuetam);
  if (map->keys == NULL || map->values == NULL) {
    printf(
        "Cannot create map: unable allocate memory for the keys or values\n");
    free(map->keys);
    free(map->values);
    free(map);
    exit(1);
  }

  map->keyType = *t1;
  map->valueType = *t2;
  map->size = 0;
  map->capacity = capacity;

  return map;
}

/* Realiza um shallow delete, as variáveis ainda estão alocadas, o mapa apenas
 * não tem mais referência */
void deleteMap(Map *map) {
  if (map == NULL) {
    return;
  }

  for (size_t i = 0; i < map->size; i++) {
    if (map->keys[i]) {
      delete (map->keys[i], map->keyType.name);
    }
    if (map->values[i]) {
      delete (map->values[i], map->valueType.name);
    }
  }
  free(map);
  map = NULL;
}

void mapPut(Map *map, void *key, void *value) {
  if (map == NULL || key == NULL || value == NULL) {
    printf("Cannot put map: map, key or value is null\n");
    return;
  }

  /*Chave já existe*/
  for (size_t i = 0; i < map->size; i++) {
    void *existingKey = map->keys[i];
    if (equals(existingKey, key, map->keyType.name)) {
      map->values[i] = copy(value, map->valueType.name);
      return;
    }
  }

  /* Redimensionamento */
  if (map->size == map->capacity) {
    size_t newCapacity = map->capacity * 2;
    map->keys = realloc(map->keys, newCapacity * map->keyType.size);
    map->values = realloc(map->values, newCapacity * map->valueType.size);
    map->capacity = newCapacity;
  }

  /*Chave não existe*/
  map->keys[map->size] = copy(key, map->keyType.name);
  map->values[map->size] = copy(value, map->valueType.name);
  map->size++;
}

void *mapGet(Map *map, void *key) {
  if (map == NULL || key == NULL) {
    printf("Cannot get from map: map is null or key is null\n");
    exit(1);
  }

  for (size_t i = 0; i < map->size; i++) {
    void *existingKey = map->keys[i];
    if (equals(existingKey, key, map->keyType.name)) {
      return copy(map->values[i], map->valueType.name);
    }
  }

  return NULL;
}

void printMap(Map *map) {
  if (!map) {
    printf("Cannot print Map: not allocated\n");
    exit(1);
  }
  printf("{");
  for (size_t i = 0; i < map->size; i++) {
    print(map->keys[i], map->keyType.name);
    printf(": ");
    print(map->values[i], map->valueType.name);
    if (i != map->size - 1) {
      printf(", ");
    }
  }
  printf("}");
}

int equalsMap(Map *a, Map *b) {
  int isSameType = 1;
  int isEqual = 1;

  isSameType = isSameType && strcmp(a->keyType.name, b->keyType.name) == 0;
  isSameType = isSameType && strcmp(a->keyType.name, b->keyType.name) == 0;

  if (a->size == b->size && isSameType) {
    for (int i = 0; i < a->size; i++) {
      isEqual = isEqual && equals(mapGet(a, a->keys[i]), mapGet(b, b->keys[i]),
                                  a->keyType.name);
      isEqual = isEqual && equals(mapGet(a, a->values[i]),
                                  mapGet(b, b->values[i]), a->valueType.name);
    }
  }

  return isEqual;
}

Map *copyMap(Map *map) {
  if (map == NULL) {
    printf("Cannot copy map: map is null\n");
    return NULL;
  }

  Map *newMap =
      createMap(map->keyType.name, map->valueType.name, map->capacity);

  for (size_t i = 0; i < map->size; i++) {
    void *copiedKey = copy(map->keys[i], map->keyType.name);
    void *copiedValue = copy(map->values[i], map->valueType.name);
    mapPut(newMap, copiedKey, copiedValue);
  }

  return newMap;
}

void *accessMap(Map *map, void *key) {
  if (map == NULL || key == NULL) {
    printf("Cannot get from map: map is null or key is null\n");
    exit(1);
  }

  for (size_t i = 0; i < map->size; i++) {
    void *existingKey = map->keys[i];
    if (equals(existingKey, key, map->keyType.name)) {
      return map->values[i];
    }
  }

  printf("Cannot access map: key not found\n");
  exit(1);
}