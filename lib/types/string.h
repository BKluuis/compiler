#ifndef STRINGCOMP_H
#define STRINGCOMP_H

#include <stddef.h>

typedef struct String {
  char *data;
  size_t size;
} String;

String *createString(const char *);
String *copyString(String *);
void deleteString(String *);
void printString(String *);
int equalsString(String *, String *);
char *stringToCString(String *);

#endif