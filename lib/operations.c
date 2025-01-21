#include "operations.h"
#include "stringUtil.h"
#include "typeUtil.h"
#include <stdio.h>

char *codeFromOperator(char *a, char *op, char *b, char *type) {
  if (equals(op, "+", "char*")) {
    return add(a, b, type);
  } else if (equals(op, "-", "char*")) {
    return subtract(a, b, type);
  } else if (equals(op, "^", "char*")) {
    return exponent(a, b, type);
  } else if (equals(op, "=", "char*")) {
    return assignment(a, b, type);
  } else {
    fprintf(
        stderr,
        "Error while performing operation: operation \"%s\" doesn't exists\n",
        op);
    abort();
  }
}

char *add(char *a, char *b, char *type) {
  if (equals(type, "Float", "char*")) {
    return cat5space("addFloat(", a, ",", b, ")");
  } else if (equals(type, "Int", "char*")) {
    return cat5space("addInt(", a, ",", b, ")");
  } else {
    fprintf(stderr, "Error while adding: type %s doesn't implement add\n",
            type);
    abort();
  }
}

char *subtract(char *a, char *b, char *type) {
  if (equals(type, "Float", "char*")) {
    return cat5space("subtractFloat(", a, ",", b, ")");
  } else if (equals(type, "Int", "char*")) {
    return cat5space("subtractInt(", a, ",", b, ")");
  } else {
    fprintf(stderr,
            "Error while subtracting: type %s doesn't implement subtract\n",
            type);
    abort();
  }
}

char *exponent(char *a, char *b, char *type) {
  if (equals(type, "Float", "char*")) {
    return cat5space("exponentFloat(", a, ",", b, ")");
  } else if (equals(type, "Int", "char*")) {
    return cat5space("exponentInt(", a, ",", b, ")");
  } else {
    fprintf(stderr,
            "Error while exponentiating: type %s doesn't implement exponent\n",
            type);
    abort();
  }
}

char *assignment(char *leftSide, char *rightSide, char *type) {
  if (equals(type, "Float", "char*")) {
    return cat4space(leftSide, "= copy(", rightSide, ", \"Int\")");
  } else if (equals(type, "Int", "char*")) {
    return cat4space(leftSide, "= copy(", rightSide, ", \"Float\")");
  } else {
    fprintf(stderr,
            "Error while assigning: type %s doesn't implement assigment\n",
            type);
    abort();
  }
}