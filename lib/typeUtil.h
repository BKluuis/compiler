#ifndef TYPEUTIL_H
#define TYPEUTIL_H

#include "stateUtil.h"

char *typeWithGeneric(char *, char *);
char *typeWithGenericAndSize(char *, char *, char *);

char *typeFromToken(char *, char *, char *);

/*
 * Compares two different values of type specified by typeEntry
 * type MUST have an compare[typename]() to work
 */
int compare(void *, void *, char *);

/*
 * Makes a copy of type specified by char*
 * type MUST have an copy[typename]() to work
 */
void *copy(void *, char *);

/*
 * Makes a copy of type specified by char*
 * type MUST have an print[typename]() to work
 */
void print(void *, char *);

/*
 * Makes a copy of type specified by char*
 * type MUST have an delete[typename]() to work
 */
void delete(void *, char *);

#endif