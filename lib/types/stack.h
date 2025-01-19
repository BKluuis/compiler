#ifndef STACK_H
#define STACK_H

#include "../typeUtil.h"
#include <stdio.h>
#include <stdlib.h>

typedef struct Stack {
  void **data;     // Ponteiro para os elementos
  typeEntry type;  // Tipo armazenado na pilha
  size_t size;     // Quantidade de elementos na pilha
  size_t capacity; // Capacidade máxima antes de expandir
} Stack;

Stack *createStack(char *type, size_t capacity);
void deleteStack(Stack *stack);
int stackPush(Stack *stack, void *element);
void *stackPop(Stack *stack);
void *stackPeek(Stack *stack);
int isStackEmpty(Stack *stack);
void printStack(Stack *stack);

#endif
