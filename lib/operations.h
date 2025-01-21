#ifndef OPERATIONS_H
#define OPERATIONS_H

/**
 * Returns the C operator code for the values
 */
char *codeFromOperator(char *a, char *op, char *b, char *type);

/**
 * Returns the C operator code for adding two values
 */
char *add(char *a, char *b, char *type);

/**
 * Returns the C operator code for subtracting two values
 */
char *subtract(char *a, char *b, char *type);

/**
 * Returns the C operator code for exponentiating two values
 */
char *exponent(char *a, char *b, char *type);

/**
 * Returns the C operator code for adding two values
 */
// TODO: Include assignment with operations: +=, -=, etc;
char *assignment(char *a, char *b, char *type);
#endif