#ifndef TYPEUTIL_H
#define TYPEUTIL_H
#include <stddef.h>

typedef struct Array {
    void* data;
    size_t size;
    size_t capacity;
} Array;

typedef struct Queue {
    void* data;
    size_t front;
    size_t rear;
    size_t size;
    size_t capacity;
} Queue;

typedef struct Deque {
    void* data;
    size_t front;
    size_t rear;
    size_t size;
    size_t capacity;
} Deque;

typedef struct Stack {
    void* data;
    size_t top;
    size_t capacity;
} Stack;

typedef struct Map {
    void* keys;
    void* values;
    size_t size;
    size_t capacity;
} Map;

typedef struct Set {
    void* data;
    size_t size;
    size_t capacity;
} Set;


char* typeWithGeneric(char*, char*);
char* typeWithGenericAndSize(char*, char*, char*);

char* typeFromToken(char*, char*, char*);

#endif