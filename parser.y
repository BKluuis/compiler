%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../lib/record.h"
#include "../lib/tree.h"

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
        struct Node * node;
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

%nonassoc LESS_THAN MORE_THAN LESS_OR_EQUAL MORE_OR_EQUAL EQUALS NOT_EQUAL
%left ADD MINUS
%left MULT DIV DIV_REMAINDER DIV_QUOTIENT
%right EXP
/*Esse token nunca é retornada pelo lexer, mas é usada para dar maior precedência à regra : - expression*/
%left UMINUS 

/* %type <rec> variables_block variables declaration initialization assignment assignments subprogs subprog parameters parameter main commands command if elif_condition else_condition switch cases cases_opt for while dowhile variable_valued return expression literal call expressions  */

%type <node> expression literal declared

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
declaration : TYPE array_op ID         {}
            | CONST TYPE array_op ID   {}
            ;

/* Define a variável e inicia */
initialization : TYPE array_op ID ASSIGNMENT expression {}
               ;

array_op :                                 {}
         | LESS_THAN TYPE MORE_THAN        {}
         ;

/* Muda o valor de uma variável, checar se variavel existe */
assignments : assignment SEMICOLON {}
            | assignment SEMICOLON assignments   {}
            ;

assignment : declared PLUS_ASSIGNMENT expression       {}
           | declared MINUS_ASSIGNMENT expression      {}
           | declared MULT_ASSIGNMENT expression       {}
           | declared DIVIDE_ASSIGNMENT expression     {}
           | declared ASSIGNMENT expression            {}
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
           | declaration {}
           | declaration COMMA parameters {}
           ;

main : MAIN commands END MAIN {}
     ;

commands :                   {}
         | command commands  {}
         ;

command : assignments                   {}
        | call SEMICOLON                {}
        | if                            {}
        | switch                        {}
        | for                           {}
        | while                         {}
        | dowhile                       {}
        | BREAK                         {} 
        | CONTINUE                      {}
        | return                        {}
        ;          

/* Checar o retorno */
if : IF PAREN_LEFT expression PAREN_RIGHT commands elif_condition else_condition END IF {}
   ;

elif_condition :                                                                {}
               | ELIF PAREN_LEFT expression PAREN_RIGHT commands elif_condition {}
               ;

else_condition :              {}
               | ELSE commands    {}
               ;

switch : SWITCH PAREN_LEFT ID PAREN_RIGHT cases END SWITCH {}
       ;

cases : 
      | CASE PAREN_LEFT literal PAREN_RIGHT commands cases      {}
      | DEFAULT commands cases    {}
      ;

for : FOR PAREN_LEFT initialization SEMICOLON expression SEMICOLON expression PAREN_RIGHT commands END FOR {}
    | FOR PAREN_LEFT assignment SEMICOLON expression SEMICOLON expression PAREN_RIGHT commands END FOR {}
    ;

while : WHILE PAREN_LEFT expression PAREN_RIGHT commands END WHILE {}
      ;

dowhile : DO commands WHILE PAREN_LEFT expression PAREN_RIGHT END DO WHILE{}
        ;

return : RETURN SEMICOLON  
       | RETURN expression SEMICOLON {}
       ;

/* Uma expressão, um valor */           
expression : declared                                {$$ = createNode("declared"); addChild($$, $1);}
           | literal                                 {$$ = createNode("literal"); addChild($$, $1);}
           | expression OR expression                {$$ = createNode("OR"); addChild($$, $1); addChild($$, $3);}
           | expression AND expression               {$$ = createNode("AND"); addChild($$, $1); addChild($$, $3);}
           | expression EQUALS expression            {$$ = createNode("EQUALS"); addChild($$, $1); addChild($$, $3);}
           | expression NOT_EQUAL expression         {$$ = createNode("NOT_EQUAL"); addChild($$, $1); addChild($$, $3);}
           | expression LESS_THAN expression         {$$ = createNode("LESS_THAN"); addChild($$, $1); addChild($$, $3);}
           | expression MORE_THAN expression         {$$ = createNode("MORE_THAN"); addChild($$, $1); addChild($$, $3);}
           | expression LESS_OR_EQUAL expression     {$$ = createNode("LESS_OR_EQUAL"); addChild($$, $1); addChild($$, $3);}
           | expression MORE_OR_EQUAL expression     {$$ = createNode("MORE_OR_EQUAL"); addChild($$, $1); addChild($$, $3);}
           | expression ADD expression               {$$ = createNode("ADD"); addChild($$, $1); addChild($$, $3);}
           | expression MINUS expression             {$$ = createNode("MINUS"); addChild($$, $1); addChild($$, $3);}
           | expression MULT expression              {$$ = createNode("MULT"); addChild($$, $1); addChild($$, $3);}
           | expression DIV expression               {$$ = createNode("DIV"); addChild($$, $1); addChild($$, $3);}
           | expression DIV_QUOTIENT expression      {$$ = createNode("DIV_QUOTIENT"); addChild($$, $1); addChild($$, $3);}
           | expression DIV_REMAINDER expression     {$$ = createNode("DIV_REMAINDER"); addChild($$, $1); addChild($$, $3);}
           | expression EXP expression               {$$ = createNode("EXP"); addChild($$, $1); addChild($$, $3);}
           | NOT expression                          {$$ = createNode("NOT"); addChild($$, $2);}
           | MINUS expression %prec UMINUS           {$$ = createNode("UNARY MINUS"); addChild($$, $2);}
           | PAREN_LEFT expression PAREN_RIGHT       {$$ = createNode("PARENTHESIS"); addChild($$, $2);}
           | call                                    {$$ = createNode("call");}
           ;

/* Variáveis já declaradas */
declared : ID              {$$ = createNode("ID"); addChild($$, createNode($1));}
           /* Checar: tipo de expressão para a coleção, dimensão da coleção */
         | ID collection_access {$$ = createNode("ARRAY"); addChild($$, createNode($1));} 
         ; 

literal : INT_LIT     {$$ = createNode("INT");}
        | FLOAT_LIT   {$$ = createNode("FLOAT");}
        | BOOL_LIT    {$$ = createNode("BOOL");}
        | STRING_LIT  {$$ = createNode("STRING");}
        ;

/* Acessores de coleções */
/* Associar: tipo da expressão de acesso */
collection_access : SQUARE_LEFT expression SQUARE_RIGHT              {}
                  | collection_access SQUARE_LEFT expression SQUARE_RIGHT {}
                  ;

/* Chamada para uma função */
/*  */
call : ID PAREN_LEFT call_parameters PAREN_RIGHT {}    
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