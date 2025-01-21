#ifndef INTPRIMITIVE_H
#define INTPRIMITIVE_H

int *copyInteger(int *);
float *copyFloat(float *);
int *copyBool(int *);

int *createInt(int);
float *createFloat(float);
int *createBool(int);

float *addFloat(float *a, float *b);
int *addInt(int *a, int *b);

float *subtractFloat(float *a, float *b);
int *subtractInt(int *a, int *b);

float *exponentFloat(float *a, float *b);
int *exponentInt(int *a, int *b);

void assignFloat(float *a, float *b);
void assignInt(int *a, int *b);

float *castitof(int *i);
int *castftoi(float *f);

#endif