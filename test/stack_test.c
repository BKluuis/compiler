#include "../lib/globals.h"
#include "../lib/stateUtil.h"
#include "../lib/types/array.h"
#include "../lib/types/map.h"
#include "../lib/types/primitives.h"
#include "../lib/types/stack.h"
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
  typeEntry *stackType = (typeEntry *)mapGet(typeMap, "Stack");

  printf("Mapa de tipos criado com sucesso!\n");

  printf("\n===== TESTE: Criando Stack de Inteiros =====\n");
  Stack *intStack = createStack("Int", 3);
  if (intStack == NULL) {
    printf("Erro ao criar stack de inteiros\n");
    return 1;
  }

  int *val1 = createInt(10);
  int *val2 = createInt(20);
  int *val3 = createInt(30);

  stackPush(intStack, val1);
  stackPush(intStack, val2);
  stackPush(intStack, val3);

  printf("Stack de inteiros criada e preenchida com sucesso!\n");

  printf("\n===== TESTE: Topo da Stack =====\n");
  int *top = (int *)stackPeek(intStack);
  printf("Topo -> ");
  print(top, intType->name);
  printf("(Esperado: 30)\n");

  printf("\n===== TESTE: Removendo Elementos (Pop) =====\n");
  int *popped1 = (int *)stackPop(intStack);
  printf("Pop -> ");
  print(popped1, intType->name);
  printf("(Esperado: 30)\n");

  int *popped2 = (int *)stackPop(intStack);
  printf("Pop -> ");
  print(popped2, intType->name);
  printf("(Esperado: 20)\n");

  int *popped3 = (int *)stackPop(intStack);
  printf("Pop -> ");
  print(popped3, intType->name);
  printf("(Esperado: 10)\n");

  printf("\n===== TESTE: Stack Vazia =====\n");
  printf("Stack vazia? -> %d (Esperado: 1)\n", isStackEmpty(intStack));

  printf("\n===== TESTE: Redimensionamento da Stack =====\n");
  for (int i = 1; i <= 10; i++) {
    int *newVal = createInt(i * 100);
    stackPush(intStack, newVal);
  }

  for (int i = 10; i >= 1; i--) {
    int *res = (int *)stackPop(intStack);
    printf("Pop -> %d (Esperado: %d)\n", res ? *res : -1, i * 100);
  }

  printf("\n===== TESTE: Criando Stack de Strings =====\n");
  Stack *strStack = createStack("String", 2);
  if (strStack == NULL) {
    printf("Erro ao criar stack de strings\n");
    return 1;
  }

  String *name1 = createString("Alice");
  String *name2 = createString("Bob");

  stackPush(strStack, name1);
  stackPush(strStack, name2);

  String *resName2 = (String *)stackPop(strStack);
  String *resName1 = (String *)stackPop(strStack);

  printf("Pop -> ");
  printString(resName2);
  printf(" (Esperado: Bob)\n");

  printf("Pop -> ");
  printString(resName1);
  printf(" (Esperado: Alice)\n");

  printf("\n===== TESTE: Criando Stack de Arrays =====\n");
  Stack *arrayStack = createStack("Array", 2);

  Array *arr1 = createArray("Int", 2);
  arrayAdd(arr1, createInt(100));
  arrayAdd(arr1, createInt(200));

  Array *arr2 = createArray("Int", 2);
  arrayAdd(arr2, createInt(300));
  arrayAdd(arr2, createInt(400));

  stackPush(arrayStack, arr1);
  stackPush(arrayStack, arr2);

  Array *resArr2 = (Array *)stackPop(arrayStack);
  Array *resArr1 = (Array *)stackPop(arrayStack);

  printf("Stack de Arrays: \n");
  printArray(resArr2);
  printf("(Esperado: [300, 400])\n");

  printArray(resArr1);
  printf("(Esperado: [100, 200])\n");

  printf("\n===== TESTE: Deletando Stacks =====\n");
  deleteStack(intStack);
  printf("intStack deletada\n");

  deleteStack(strStack);
  printf("strStack deletada\n");

  deleteStack(arrayStack);
  printf("arrayStack deletada\n");

  printMap(typeMap);

  printf("Todos os testes foram finalizados com sucesso!\n");

  cleanupGlobals();
  return 0;
}
