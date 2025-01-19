#include "string.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

String *createString(const char *s) {
  String *out = malloc(sizeof(String));

  if (out == NULL) {
    printf("Cannot create String: unable to allocate memory for the String\n");
    exit(1);
  }

  if (s == NULL) {
    printf("Cannot create String: source string is null\n");
    exit(1);
  }

  int tam = strlen(s);

  out->size = tam;
  out->data = malloc(tam);
  strncpy(out->data, s, tam);

  return out;
}

String *copyString(String *s) {
  char *data = stringToCString(s);
  String *out = createString(data);
  free(data);
  return out;
}

void deleteString(String *s) {
  if (s) {
    if (s->data) {
      free(s->data);
    }
    free(s);
    s->data = NULL;
    s = NULL;
  }
}

void printString(String *s) {
  if (!s || !s->data) {
    printf("Cannot print empty String\n");
    exit(1);
  }
  char *out = stringToCString(s);
  printf("%s", out);
}
char *stringToCString(String *s) {
  int size = s->size + 1;
  char *out = malloc(size);

  if (out == NULL) {
    printf("Cannot convert String to C_string: unable to allocate memory for "
           "the C_String\n");
    return NULL;
  }

  strncpy(out, s->data, s->size);
  out[s->size] = '\0';

  return out;
}

int equalsString(String *a, String *b) {
  if (!a || !a->data) {
    printf("Cannot compare Strings: first string isn't allocated\n");
    exit(1);
  }
  if (!b || !b->data) {
    printf("Cannot compare Strings: second string isn't allocated\n");
    exit(1);
  }
  if (a->size != b->size) {
    return 0;
  }
  return strncmp(a->data, b->data, a->size) == 0;
}