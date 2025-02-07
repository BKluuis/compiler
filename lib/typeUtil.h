#ifndef TYPEUTIL_H
#define TYPEUTIL_H

#include "record.h"
#include "stateUtil.h"

/**
 * Returns the C type equivalent of the given token
 */
char *typeFromToken(char *token);

/**
 * Returns the C creation code of the given type
 */
char *createFromType(char *type, char *args);

/**
 * Constructs the sequence of function calls to get a value
 * Currently only Array and Map
 */
record *access(char *varName, Array *types, Array *accessors, int typeIndex,
               int accessIndex);

/*
 * equalss two different values of type specified by typeEntry
 * type MUST have an equals[typename]() to work
 */
int equals(void *a, void *b, char *type);

/*
 * Makes a copy of type specified by char*
 * type MUST have an copy[typename]() to work
 */
void *copy(void *source, char *type);

/*
 * Makes a copy of type specified by char*
 * type MUST have an print[typename]() to work
 */
void print(void *data, char *type);

/*
 * Makes a copy of type specified by char*
 * type MUST have an delete[typename]() to work
 */
void delete(void *data, char *type);

/**
 * Returns the C cast code for the given expression
 */
char *cast(char *expression, char *newTyp, char *oldType);

#endif