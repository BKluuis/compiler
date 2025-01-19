#include "primitives.h"
#include <stdio.h>
#include <stdlib.h>

int *copyInteger(int *i) {
  int *out = malloc(sizeof(int));
  *out = *i;
  return out;
}
float *copyFloat(float *f) {
  float *out = malloc(sizeof(float));
  *out = *f;
  return out;
}
int *copyBool(int *b) { return copyInteger(b); }

int *createInt(int i) {
  int *num = malloc(sizeof(int));
  if (!num) {
    fprintf(stderr, "Cannot create int: unable to allocate memory\n");
    exit(1);
  }
  *num = i;
  return num;
}
float *createFloat(float f) {
  float *num = malloc(sizeof(float));
  if (!num) {
    fprintf(stderr, "Cannot create float: unable to allocate memory\n");
    exit(1);
  }
  *num = f;
  return num;
}
int *createBool(int b) {
  int *num = malloc(sizeof(int));
  if (!num) {
    fprintf(stderr, "Cannot create bool: unable to allocate memory\n");
    exit(1);
  }
  *num = b == 1;
  return num;
}