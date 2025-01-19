#ifndef SET_H
#define SET_H

#include <stddef.h>

typedef struct Set {
  void *data;
  size_t size;
  size_t capacity;
} Set;

#endif