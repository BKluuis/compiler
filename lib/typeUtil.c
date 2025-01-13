#include "typeUtil.h"
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>

char* typeFromToken(char* tokenString) {
    char* s1 = NULL;

    if (strcmp(tokenString, "Int") == 0) {
        s1 = (char*)malloc(strlen("int") + 1);
        strcpy(s1, "int");
    }
    else if (strcmp(tokenString, "Bool") == 0) {
        s1 = (char*)malloc(strlen("bool") + 1);
        strcpy(s1, "bool");
    }
    else if (strcmp(tokenString, "Float") == 0) {
        s1 = (char*)malloc(strlen("float") + 1);
        strcpy(s1, "float");
    }
    else if (strcmp(tokenString, "String") == 0) {
        s1 = (char*)malloc(strlen("char*") + 1);
        strcpy(s1, "char*");
    }
    else if (strcmp(tokenString, "Array") == 0) {
        s1 = (char*)malloc(strlen("notimplemented") + 1);
        strcpy(s1, "notimplemented");
    }
    else if (strcmp(tokenString, "Queue") == 0) {
        s1 = (char*)malloc(strlen("notimplemented") + 1);
        strcpy(s1, "notimplemented");
    }
    else if (strcmp(tokenString, "Deque") == 0) {
        s1 = (char*)malloc(strlen("notimplemented") + 1);
        strcpy(s1, "notimplemented");
    }
    else if (strcmp(tokenString, "Stack") == 0) {
        s1 = (char*)malloc(strlen("notimplemented") + 1);
        strcpy(s1, "notimplemented");
    }
    else if (strcmp(tokenString, "Map") == 0) {
        s1 = (char*)malloc(strlen("notimplemented") + 1);
        strcpy(s1, "notimplemented");
    }
    else if (strcmp(tokenString, "Set") == 0) {
        s1 = (char*)malloc(strlen("notimplemented") + 1);
        strcpy(s1, "notimplemented");
    }

    return s1;
}