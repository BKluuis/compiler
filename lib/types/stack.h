#ifndef STACK_H
#define STACK_H

#include "../typeUtil.h"
#include <stdio.h>
#include <stdlib.h>

typedef struct Stack {
  void **data;
  typeEntry type;
  size_t size;
  size_t capacity;
} Stack;

Stack *createStack(char *type, size_t capacity);
void deleteStack(Stack *stack);
void printStack(Stack *stack);
int stackPush(Stack *stack, void *element);
void *stackPop(Stack *stack);
void *stackPeek(Stack *stack);
int isStackEmpty(Stack *stack);

#endif
