#ifndef RECORD
#define RECORD

struct record
{
	char* code; /* field for storing the output code */
	char* opt1; /* field for another purpose */
};

typedef struct record record;

void freeRecord(record*);
/* aloca e retorna um registro e inicia code e opt1 com os parametros fornecidos*/
record* createRecordOpt(char*, char*);
record* createRecord(char*);
/* retorna um registro com os campos preenchidos com "" e "" */
record* emptyRecord();

#endif