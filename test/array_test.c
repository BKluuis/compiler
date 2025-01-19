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
  typeEntry *stringType = (typeEntry *)mapGet(typeMap, "String");
  typeEntry *arrayType = (typeEntry *)mapGet(typeMap, "Array");

  printf("Mapa de tipos criado com sucesso!\n");

  printf("\n===== TESTE: Criando Array de Inteiros =====\n");
  Array *intArray = createArray("Int", 3);
  if (intArray == NULL) {
    printf("Erro ao criar array de inteiros\n");
    return 1;
  }

  int *val1 = createInt(10);
  int *val2 = createInt(20);
  int *val3 = createInt(30);

  arrayAdd(intArray, val1);
  arrayAdd(intArray, val2);
  arrayAdd(intArray, val3);

  printf("Array de inteiros criado e preenchido com sucesso!\n");

  printf("\n===== TESTE: Recuperando Valores do Array =====\n");
  int *res1 = (int *)arrayGet(intArray, 0);
  int *res2 = (int *)arrayGet(intArray, 1);
  int *res3 = (int *)arrayGet(intArray, 2);

  printf("Índice 0 ->");
  print(res1, intType->name);
  printf("(Esperado: 10)\n");
  printf("Índice 1 ->");
  print(res2, intType->name);
  printf("(Esperado: 20)\n");
  printf("Índice 2 ->");
  print(res3, intType->name);
  printf("(Esperado: 30)\n");

  printf("\n===== TESTE: Redimensionamento do Array =====\n");
  int *val4 = createInt(40);
  int *val5 = createInt(50);

  arrayAdd(intArray, val4);
  arrayAdd(intArray, val5);

  int *res4 = (int *)arrayGet(intArray, 3);
  int *res5 = (int *)arrayGet(intArray, 4);

  printf("Índice 3 ->");
  print(res4, intType->name);
  printf("(Esperado: 40)\n");
  printf("Índice 4 ->");
  print(res5, intType->name);
  printf("(Esperado: 50)\n");

  printf("\n===== TESTE: Criando Array de Strings =====\n");
  Array *strArray = createArray("String", 2);

  if (strArray == NULL) {
    printf("Erro ao criar array de strings\n");
    return 1;
  }

  String *name1 = createString("Alice");
  String *name2 = createString("Bob");

  arrayAdd(strArray, name1);
  arrayAdd(strArray, name2);

  String *resName1 = (String *)arrayGet(strArray, 0);
  String *resName2 = (String *)arrayGet(strArray, 1);

  char *c_resname1 = stringToCString(resName1);
  char *c_resname2 = stringToCString(resName2);

  printf("Índice 0 -> %s - %d (Esperado: Alice)\n", c_resname1,
         strlen(c_resname1));
  printf("Índice 1 -> %s - %d (Esperado: Bob)\n", c_resname2,
         strlen(c_resname2));

  printf("Índice 0 -> ");
  printString(resName1);
  printf(" (Esperado: Alice)\n");

  printf("Índice 1 -> ");
  printString(resName2);
  printf(" (Esperado: Bob)\n");

  printf("\n===== TESTE: Criando Array de Array de inteiros =====\n");
  Array *inArray = createArray("Int", 5);

  arrayAdd(inArray, val1);
  arrayAdd(inArray, val2);
  arrayAdd(inArray, val3);
  arrayAdd(inArray, val4);
  arrayAdd(inArray, val5);

  Array *outArray = createArray("Array", 5);

  arrayAdd(outArray, inArray);
  arrayAdd(outArray, inArray);
  arrayAdd(outArray, inArray);
  arrayAdd(outArray, inArray);
  arrayAdd(outArray, inArray);

  printArray(outArray);

  printf("\n===== TESTE: Deletando Arrays =====\n");
  deleteArray(intArray);
  printf("intArray deletado\n");
  deleteArray(strArray);
  printf("strArray deletado\n");
  deleteArray(outArray);
  deleteArray(inArray);

  printMap(typeMap);

  printf("Todos os testes foram finalizados com sucesso!\n");

  cleanupGlobals();
  return 0;
}
