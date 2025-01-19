#include "../lib/globals.h"
#include "../lib/stateUtil.h"
#include "../lib/types/array.h"
#include "../lib/types/map.h"
#include "../lib/types/primitives.h"
#include "../lib/types/string.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
  printf("===== TESTE: Criando Mapa de Tipos =====\n");
  initGlobals();

  typeEntry *intType = (typeEntry *)mapGet(typeMap, "Int");
  typeEntry *arrayType = (typeEntry *)mapGet(typeMap, "Array");

  printf("Mapa de tipos criado com sucesso!\n");

  printf("\n===== TESTE: Criando Mapa de Inteiros =====\n");
  Map *intMap = createMap("Int", "Int", 3);

  int *key1 = createInt(1);
  int *key2 = createInt(2);
  int *key3 = createInt(3);

  int *val1 = createInt(100);
  int *val2 = createInt(200);
  int *val3 = createInt(300);

  mapPut(intMap, key1, val1);
  mapPut(intMap, key2, val2);
  mapPut(intMap, key3, val3);

  printf("Mapa de inteiros criado e preenchido com sucesso!\n");

  printf("\n===== TESTE: Recuperando Valores =====\n");
  int *res1 = (int *)mapGet(intMap, key1);
  int *res2 = (int *)mapGet(intMap, key2);
  int *res3 = (int *)mapGet(intMap, key3);

  printf("Chave 0 ->");
  print(res1, intType->name);
  printf("(Esperado: 100)\n");
  printf("Chave 1 ->");
  print(res2, intType->name);
  printf("(Esperado: 200)\n");
  printf("Chave 2 ->");
  print(res3, intType->name);
  printf("(Esperado: 300)\n");

  printf("\n===== TESTE: Atualizando Valor Existente =====\n");
  int *val4 = createInt(400);
  mapPut(intMap, key1, val4);

  res1 = (int *)mapGet(intMap, key1);
  printf("Chave 1 ->");
  print(res1, intType->name);
  printf("(Esperado: 400)\n");

  printf("\n===== TESTE: Redimensionamento do Mapa =====\n");
  for (int i = 4; i <= 10; i++) {
    int *newKey = createInt(i);
    int *newVal = createInt(i * 100);
    mapPut(intMap, newKey, newVal);
  }

  for (int i = 1; i <= 10; i++) {
    int *searchKey = createInt(i);
    int *res = (int *)mapGet(intMap, searchKey);
    printf("key%d -> %d (Esperado: %d)\n", i, res ? *res : -1, i * 100);
  }

  printf("\n===== TESTE: Chave Inexistente =====\n");
  int missingKey = 999;
  int *missingVal = (int *)mapGet(intMap, &missingKey);
  printf("missingKey -> %d (Esperado: -1)\n", missingVal ? *missingVal : -1);

  printf("\n===== TESTE: Mapa com Ponteiros para Ponteiros =====\n");
  Map *ptrMap = createMap("String", "Array", 3);

  String *ptrKey1 = createString("ptr1");
  String *ptrKey2 = createString("ptr2");
  Array *arrVal1 = createArray(intType->name, 3);
  Array *arrVal2 = createArray(intType->name, 3);

  arrayAdd(arrVal1, createInt(1000));
  arrayAdd(arrVal1, createInt(2000));
  arrayAdd(arrVal2, createInt(3000));
  arrayAdd(arrVal2, createInt(4000));

  mapPut(ptrMap, ptrKey1, arrVal1);
  mapPut(ptrMap, ptrKey2, arrVal2);

  deleteArray(arrVal1);
  deleteArray(arrVal2);

  Array *resPtr1 = (Array *)mapGet(ptrMap, ptrKey1);
  Array *resPtr2 = (Array *)mapGet(ptrMap, ptrKey2);

  printf("ptrKey1 ->");
  print(resPtr1, arrayType->name);
  printf("(Esperado: 1000)\n");
  printf("ptrKey2 ->");
  print(resPtr2, arrayType->name);
  printf("(Esperado: 2000)\n");

  printf("\n===== TESTE: Deletando Mapas =====\n");
  deleteMap(intMap);
  printf("intMap deletado\n");
  deleteMap(ptrMap);
  printf("ptrMap deletado\n");

  cleanupGlobals();

  printf("Mapas deletados com sucesso!\n");

  return 0;
}
