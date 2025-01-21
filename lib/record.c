#include "record.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void freeRecord(record *r) {
  if (r) {
    if (r->code != NULL)
      free(r->code);
    if (r->text != NULL)
      free(r->text);
    if (r->array != NULL)
      deleteArray(r->array);
    free(r);
  }
}

record *createRecord(char *c1) {
  record *r = (record *)malloc(sizeof(record));

  if (!r) {
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }

  r->code = strdup(c1);
  r->text = NULL;
  r->array = NULL;

  return r;
}

record *createRecordOpt(char *c1, char *c2) {
  record *r = (record *)malloc(sizeof(record));

  if (!r) {
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }

  r->code = strdup(c1);
  r->text = strdup(c2);
  r->array = NULL;

  return r;
}

record *emptyRecord() { return createRecord(""); }
