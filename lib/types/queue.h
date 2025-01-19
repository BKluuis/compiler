#ifndef QUEUE_H
#define QUEUE_H

#include <stddef.h>

typedef struct Queue {
  void *data;
  char *type;
  size_t front;
  size_t rear;
  size_t size;
  size_t capacity;
} Queue;

#endif