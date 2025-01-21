#ifndef RECORD
#define RECORD

typedef struct Array Array;
void deleteArray(Array *array);

typedef struct record {
  char *code;
  char *text;
  Array *array;
} record;

void freeRecord(record *);

/* Aloca e retorna um registro e inicia code e text com os parametros
 * fornecidos
 */
record *createRecordOpt(char *, char *);
record *createRecord(char *);
/* retorna um registro com os campos preenchidos com "" e "" */
record *emptyRecord();

#endif