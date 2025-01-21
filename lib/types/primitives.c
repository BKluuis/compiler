#include "primitives.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

float *addFloat(float *a, float *b) { return createFloat(*a + *b); }
int *addInt(int *a, int *b) { return createInt(*a + *b); }

float *exponentf(float a, float b) { return createFloat(powf(a, b)); }
int *exponenti(int a, int b) { return createInt((int)powf((int)a, (int)b)); }

float *castitof(int i) { return createFloat((float)(i)); }
int *castftoi(float f) { return createInt((int)(f)); }