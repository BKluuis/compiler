#include "stringUtil.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *cat2(char *s1, char *s2) { return cat5(s1, s2, "", "", ""); }

char *cat3(char *s1, char *s2, char *s3) { return cat5(s1, s2, s3, "", ""); }

char *cat4(char *s1, char *s2, char *s3, char *s4) {
  return cat5(s1, s2, s3, s4, "");
}

char *cat5(char *s1, char *s2, char *s3, char *s4, char *s5) {
  int tam;
  char *output;

  tam = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5) + 1;
  output = (char *)malloc(sizeof(char) * tam);

  if (!output) {
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }

  sprintf(output, "%s%s%s%s%s", s1, s2, s3, s4, s5);

  return output;
}

char *cat2space(char *s1, char *s2) {
  int tam;
  char *output;

  tam = strlen(s1) + strlen(s2) + 2;
  output = (char *)malloc(sizeof(char) * tam);

  if (!output) {
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }

  sprintf(output, "%s %s", s1, s2);

  return output;
}

char *cat3space(char *s1, char *s2, char *s3) {
  return cat2space(cat2space(s1, s2), s3);
}

char *cat4space(char *s1, char *s2, char *s3, char *s4) {
  return cat2space(cat2space(cat2space(s1, s2), s3), s4);
}

char *cat5space(char *s1, char *s2, char *s3, char *s4, char *s5) {
  return cat2space(cat2space(cat2space(cat2space(s1, s2), s3), s4), s5);
}