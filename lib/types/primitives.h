#ifndef INTPRIMITIVE_H
#define INTPRIMITIVE_H

int *copyInteger(int *);
float *copyFloat(float *);
int *copyBool(int *);

int *createInt(int);
float *createFloat(float);
int *createBool(int);

float *intToFloat(int);

float *addFloat(float *a, float *b);
int *addInt(int *a, int *b);

float *exponentf(float a, float b);
int *exponenti(int a, int b);

float *castitof(int i);
int *castftoi(float f);

#endif