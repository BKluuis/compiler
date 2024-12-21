%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../lib/record.h"

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;
extern FILE * yyin, * yyout;
extern int yydebug;

char * cat(char *, char *, char *, char *, char *);

%}

%debug

%union {
	char * text;  /* string value */
	struct record * rec;
};



%token RETURN
%token INT_LIT FLOAT_LIT STRING_LIT BOOL_LIT
%token FUNC CONST MAIN
%token <text> TYPE ID 
%token SWITCH CASE DEFAULT
%token WHILE FOR BREAK CONTINUE DO
%token BEGIN_TOK END VAR SEMICOLON PAREN_LEFT PAREN_RIGHT SQUARE_LEFT SQUARE_RIGHT CURLY_LEFT CURLY_RIGHT COMMA
%token IF ELIF ELSE
%token PLUS_ASSIGNMENT MINUS_ASSIGNMENT MULT_ASSIGNMENT DIVIDE_ASSIGNMENT ASSIGNMENT

%left OR
%left AND
%right NOT

%left ADD MINUS
%left MULT DIV DIV_REMAINDER DIV_QUOTIENT
%right EXP
%nonassoc LESS_THAN MORE_THAN LESS_OR_EQUAL MORE_OR_EQUAL EQUALS NOT_EQUAL

/* %type <rec> variables_block variables declaration initialization assignment assignments subprogs subprog parameters parameter main commands command if elif_condition else_condition switch cases cases_opt for while dowhile variable_valued return expression literal call expressions  */

/* %type <node> expression literal */

%start prog

%%
prog : BEGIN_TOK  variables_block subprogs main END {}
     ;

variables_block :                       {}
                | VAR variables END VAR {}
                ;

variables :                                    {}
          | declaration SEMICOLON variables {}
          | initialization SEMICOLON variables {}
          ;

/* Define a variável sem iniciar */
declaration : TYPE ID         {}
            | CONST TYPE ID   {}
            ;

/* Define a variável e inicia */
initialization : TYPE ID ASSIGNMENT expression {}
               ;

/* Muda o valor de uma variável, checar se variavel existe */
assignments : assignment SEMICOLON {}
            | assignment SEMICOLON assignments   {}
            ;

assignment : ID PLUS_ASSIGNMENT expression       {}
           | ID MINUS_ASSIGNMENT expression      {}
           | ID MULT_ASSIGNMENT expression       {}
           | ID DIVIDE_ASSIGNMENT expression     {}
           | ID ASSIGNMENT expression            {}
           ;

/* Uma lista de subprogramas potencialmente vazia */
subprogs :                  {}
         | subprog subprogs {} 
         ;

subprog : FUNC ID PAREN_LEFT parameters PAREN_RIGHT TYPE variables_block commands END FUNC {}
        | FUNC ID PAREN_LEFT parameters PAREN_RIGHT variables_block commands END FUNC {}
        ;

/* Uma lista de declarações separadas por vírgula potencialmente vazia  */
parameters :           {}
           | parameter {}
           | parameter COMMA parameters {}
           ;

parameter : TYPE ID       {}
          | CONST TYPE ID {}
          ;

main : MAIN commands END MAIN {}
     ;

commands :                   {}
         | command commands  {}
         ;

command : assignments                 {}
        | call                        {}
        | if                         {}
        | switch                     {}
        | for                        {}
        | while                      {}
        | dowhile                    {}
        | BREAK                      {} 
        | CONTINUE                   {}
        | return                     {}
        ;          

/* Checar o retorno */
if : IF PAREN_LEFT expression PAREN_RIGHT commands elif_condition else_condition END IF {}
   ;

elif_condition :                                                     {}
               | ELIF PAREN_LEFT expression PAREN_RIGHT commands elif_condition {}
               ;

else_condition :              {}
               | ELSE commands    {}
               ;

switch : SWITCH PAREN_LEFT ID PAREN_RIGHT cases END SWITCH {}

cases :                  {}
      | cases_opt DEFAULT commands     {}
      ;

cases_opt :                                                {}
          | CASE PAREN_LEFT literal PAREN_RIGHT commands cases {}
          ;

for : FOR PAREN_LEFT variable_valued SEMICOLON expression SEMICOLON expression PAREN_RIGHT commands END FOR {}

while : WHILE PAREN_LEFT expression PAREN_RIGHT commands END WHILE {}

dowhile : DO commands WHILE PAREN_LEFT expression PAREN_RIGHT END DO WHILE{}

variable_valued : initialization {}
                | assignment      {}
                ;

return : RETURN SEMICOLON  
       | RETURN expression SEMICOLON {}
       ;

/* Uma expressão, um valor */           
expression : ID                                      {}
           | literal                                 {}
           | expression OR expression                {}
           | expression AND expression               {}
           | expression EQUALS expression            {}
           | expression NOT_EQUAL expression         {}
           | expression LESS_THAN expression         {}
           | expression MORE_THAN expression         {}
           | expression LESS_OR_EQUAL expression     {}
           | expression MORE_OR_EQUAL expression     {}
           | expression ADD expression               {}
           | expression MINUS expression             {}
           | expression MULT expression              {}
           | expression DIV expression               {}
           | expression DIV_QUOTIENT expression      {}
           | expression DIV_REMAINDER expression     {}
           | expression EXP expression               {}
           | NOT expression                          {}
           | PAREN_LEFT expression PAREN_RIGHT       {}
           | call                                    {}
           ;

literal : INT_LIT     {}
        | FLOAT_LIT   {}
        | BOOL_LIT    {}
        | STRING_LIT  {}
        ;

/* expressions : expression SEMICOLON expressions {} */

call : ID PAREN_LEFT call_parameters PAREN_RIGHT SEMICOLON {}    
     ;  

call_parameters : 
                | expression
                | call_parameters COMMA expression 
                ;

%%

int yywrap(void){
        return 1;
}

int main (int argc, char ** argv) {
        int codigo;

        if (argc < 3) {
        printf("Usage: $./compiler input.txt output.txt [-d]\nClosing application...\n");
        exit(0);
        }
        if(argc == 4 && strcmp(argv[3], "-d") == 0){
                yydebug = 1; 
        }

        yyin = fopen(argv[1], "r");
        yyout = fopen(argv[2], "w");

        codigo = yyparse();

        fclose(yyin);
        fclose(yyout);

        return codigo;
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}

char * cat(char * s1, char * s2, char * s3, char * s4, char * s5){
        int tam;
        char * output;

        tam = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5)+ 1;
        output = (char *) malloc(sizeof(char) * tam);

        if (!output){
        printf("Allocation problem. Closing application...\n");
        exit(0);
        }

        sprintf(output, "%s%s%s%s%s", s1, s2, s3, s4, s5);


        return output;
}

#define YYPRINT(file, type, value)   yyprint (file, type, value)

static void
yyprint (file, type, value)
     FILE *file;
     int type;
     YYSTYPE value;
{
  if (type == TYPE || type == ID)
    fprintf (file, " %s", value.text);
}