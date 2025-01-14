#include "typeUtil.h"
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>

char* typeFromToken(char* type, char* generic, char* size) {
    char* s1 = NULL;

    if (strcmp(type, "Int") == 0) {
        s1 = (char*)malloc(strlen("int") + 1);
        strcpy(s1, "int");
    }
    else if (strcmp(type, "Bool") == 0) {
        s1 = (char*)malloc(strlen("bool") + 1);
        strcpy(s1, "bool");
    }
    else if (strcmp(type, "Float") == 0) {
        s1 = (char*)malloc(strlen("float") + 1);
        strcpy(s1, "float");
    }
    else if (strcmp(type, "String") == 0) {
        s1 = (char*)malloc(strlen("char*") + 1);
        strcpy(s1, "char*");
    }
    else {
        s1 = typeWithGenericAndSize(type, generic, size);
    }

    return s1;
}

char* typeWithGeneric(char* type, char* generic) {

}

char* typeWithGenericAndSize(char* type, char* generic, char* size) {
    char* s = NULL;

    if (strcmp(type, "Array") == 0) {

    }
    else if (strcmp(type, "Queue") == 0) {
        // s = typeWithGenericAndSize(type, generic, size);
    }
    else if (strcmp(type, "Deque") == 0) {
        // s = typeWithGenericAndSize(type, generic, size);
    }
    else if (strcmp(type, "Stack") == 0) {
        // s = typeWithGenericAndSize(type, generic, size);
    }
    else if (strcmp(type, "Map") == 0) {
        // s = typeWithGenericAndSize(type, generic, size);
    }
    else if (strcmp(type, "Set") == 0) {
        // s = typeWithGenericAndSize(type, generic, size);
    }
    s = (char*)malloc(strlen("notimplemented") + 1);
    strcpy(s, "notimplemented");
    return s;
}