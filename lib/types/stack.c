#include "stack.h"
#include "../globals.h"
#include <string.h>

Stack *createStack(char *type, size_t capacity) {
  if (!typeMap) {
    printf("Bad code: call initGlobals() before using any internal data "
           "structure\n");
    exit(2);
  }

  Stack *stack = (Stack *)malloc(sizeof(Stack));
  if (!stack) {
    printf("Cannot create stack: unable to allocate memory\n");
    exit(1);
  }

  typeEntry *t1 = (typeEntry *)mapGet(typeMap, type);
  if (!t1) {
    printf("Cannot create stack: type %s doesn't exist\n", type);
    exit(1);
  }

  stack->type = *t1;
  stack->size = 0;
  stack->capacity = (capacity > 0) ? capacity : 10;

  stack->data = malloc(stack->capacity * sizeof(void *));
  if (!stack->data) {
    printf("Cannot create stack: unable to allocate memory for elements\n");
    free(stack);
    exit(1);
  }

  return stack;
}

void deleteStack(Stack *stack) {
  if (stack) {
    for (size_t i = 0; i < stack->size; i++) {
      delete (stack->data[i], stack->type.name);
    }
    free(stack);
    stack = NULL;
  }
}

int stackPush(Stack *stack, void *element) {
  if (stack->size >= stack->capacity) {
    size_t newCapacity = stack->capacity * 2;
    void **newData = realloc(stack->data, newCapacity * sizeof(void *));
    if (!newData)
      return -1;

    stack->data = newData;
    stack->capacity = newCapacity;
  }

  stack->data[stack->size] = copy(element, stack->type.name);
  stack->size++;
  return 0;
}

void *stackPop(Stack *stack) {
  if (stack->size == 0) {
    printf("Stack underflow: cannot pop from empty stack\n");
    exit(1);
  }

  void *element = stack->data[stack->size - 1];
  stack->size--;
  return element;
}

void *stackPeek(Stack *stack) {
  if (stack->size == 0) {
    printf("Stack is empty: cannot peek\n");
    exit(1);
  }

  return stack->data[stack->size - 1];
}

int isStackEmpty(Stack *stack) { return stack->size == 0; }

void printStack(Stack *stack) {
  printf("Stack (size: %zu, capacity: %zu): [", stack->size, stack->capacity);
  for (size_t i = 0; i < stack->size; i++) {
    print(stack->data[i], stack->type.name);
    if (i != stack->size - 1)
      printf(", ");
  }
  printf("]\n");
}
