/* CRIAR A TABELA DE SIMBOLOS, CRIAR PILHA */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../lib/stringUtil.h"
#include "../lib/typeUtil.h"
#include "../lib/record.h"

char* outcode;
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
%token <text> INT_LIT FLOAT_LIT STRING_LIT BOOL_LIT
%token FUNC CONST MAIN
%token <text> TYPE ID 
%token SWITCH CASE DEFAULT
%token WHILE FOR BREAK CONTINUE DO
%token BEGIN_TOK VAR SEMICOLON PAREN_LEFT PAREN_RIGHT SQUARE_LEFT SQUARE_RIGHT CURLY_LEFT CURLY_RIGHT COMMA
%token IF ELIF ELSE
%token ENDWHILE ENDFOR ENDFUNC ENDMAIN ENDVAR ENDIF ENDSWITCH END
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

%type <rec> prog variables_block variables declaration initialization assignment assignments subprogs subprog parameters main commands command if elif_condition else_condition switch cases for while dowhile  return expression  call 
%type <text> literal collection_access declared

%start prog

%%
prog    : BEGIN_TOK variables_block subprogs main END {
                fprintf(yyout, cat3($2->code, $3->code, $4->code));
                freeRecord($2);
                freeRecord($3);
                freeRecord($4);
        }
        ;

variables_block :                      {$$ = createRecord("");}
                | VAR variables ENDVAR {
                        $$ = createRecord($2->code);
                        freeRecord($2);
                }
                ;

variables       :                                     {$$ = emptyRecord();}
                | declaration SEMICOLON variables     {
                        $$ =  createRecord(cat3($1->code, ";", $3->code));
                        freeRecord($1);
                        freeRecord($3);
                }
                | initialization SEMICOLON variables     {
                        $$ =  createRecord(cat3($1->code, ";", $3->code));
                        freeRecord($1);
                        freeRecord($3);
                }
                ;

/* Define a variável sem iniciar */
declaration     : TYPE array_op ID array_size_op        { 
                        char* type = typeFromToken($1);
                        $$ = createRecord(cat2space(type, $3));
                        free(type);
                }
                | CONST TYPE array_op ID array_size_op  {}
                ;

/* Define a variável e inicia */
initialization  : TYPE array_op ID ASSIGNMENT expression {
                        char* type = typeFromToken($1);
                        $$ = createRecord(cat4space(type, $3, "=", $5->code));
                        freeRecord($5);
                        free(type);
                }
                ;

array_op :                                 {}
         | LESS_THAN TYPE MORE_THAN        {}
         ;

array_size_op:                                          {}
             | SQUARE_LEFT expression SQUARE_RIGHT      {}
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
subprogs :                  {$$ = emptyRecord();}
         | subprog subprogs {$$ = createRecord(cat2($1->code, $2->code));} 
         ;

subprog : FUNC ID PAREN_LEFT parameters PAREN_RIGHT TYPE variables_block commands ENDFUNC {
                char * code = cat5space(typeFromToken($6), $2, "(", $4->code, "){");
                code = cat4space(code, $7->code, $8->code, "}");
                $$ = createRecord(code);
                free(code);
        }
        | FUNC ID PAREN_LEFT parameters PAREN_RIGHT variables_block commands ENDFUNC {
                char * code = cat5space("void", $2, "(", $4->code, "){");
                code = cat4space(code, $6->code, $7->code, "}");
                $$ = createRecord(code);
                free(code);
        }
        ;

/* Uma lista de declarações separadas por vírgula potencialmente vazia  */
parameters :                                    {$$ = emptyRecord();}
           | declaration                        {$$ = $1;}
           | declaration COMMA parameters       {$$ = createRecord(cat3($1->code, ", ", $3->code));}
           ;

main : MAIN commands ENDMAIN {$$ = createRecord(cat3("int main() {", $2->code, "return 0;};"));}
     ;

commands : command           {$$ = createRecord($1->code);}
         | command commands  {$$ = createRecord(cat2($1->code, $2->code));}
         ;

command : assignments                   {$$ = createRecord("assignments");}
        | call SEMICOLON                {$$ = createRecord("call SEMICOLON");}
        | if                            {$$ = $1;}
        | switch                        {$$ = createRecord("switch");}
        | for                           {$$ = createRecord("for");}
        | while                         {$$ = createRecord("while");}
        | dowhile                       {$$ = createRecord("dowhile");}
        | BREAK SEMICOLON               {$$ = createRecord("BREAK SEMICOLON");}
        | CONTINUE SEMICOLON            {$$ = createRecord("CONTINUE SEMICOLON");}
        | return                        {$$ = createRecord("return");}
        ;          

/* Checar o retorno */
if : IF PAREN_LEFT expression PAREN_RIGHT commands elif_condition else_condition ENDIF {
                char* code = cat4("if (", $3->code, ") {", $5->code);
                freeRecord($3);

                // if (strcmp($6->code, "") != 0) {
                //         code = cat2(code, $6->code);
                //         freeRecord($6);
                // }
                // if (strcmp($7->code, "") != 0){
                //         code = cat2(code, $6->code);
                //         freeRecord($7);
                // }
                code = cat2(code, "}");
                $$ = createRecord(code);
                free(code);
        }
   ;

elif_condition :                                                                {}
               | ELIF PAREN_LEFT expression PAREN_RIGHT commands elif_condition {}
               ;

else_condition :                        {}
               | ELSE commands          {}
               ;

switch : SWITCH PAREN_LEFT ID PAREN_RIGHT cases ENDSWITCH {}
       ;

cases :                                                         {}
      | CASE PAREN_LEFT literal PAREN_RIGHT commands cases      {}
      | DEFAULT commands cases                                  {}
      ;

for : FOR PAREN_LEFT initialization SEMICOLON expression SEMICOLON expression PAREN_RIGHT commands ENDFOR {}
    | FOR PAREN_LEFT assignment SEMICOLON expression SEMICOLON expression PAREN_RIGHT commands ENDFOR {}
    ;

while : WHILE PAREN_LEFT expression PAREN_RIGHT commands ENDWHILE {}
      ;

dowhile : DO commands WHILE PAREN_LEFT expression PAREN_RIGHT ENDWHILE{}
        ;

return : RETURN SEMICOLON               {}
       | RETURN expression SEMICOLON    {}
       ;

/* Uma expressão, um valor */           
expression : declared                                {$$ = createRecord($1);}
           | literal                                 {$$ = createRecord($1);}
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
           | MINUS expression %prec UMINUS           {}
           | PAREN_LEFT expression PAREN_RIGHT       {}
           | call                                    {}
           ;

/* Variáveis já declaradas */
declared : ID                   {$$ = $1;}
           /* Checar: tipo de expressão para a coleção, dimensão da coleção */
         | ID collection_access {$$ = $1;} 
         ; 

literal : INT_LIT     {$$ = $1;}
        | FLOAT_LIT   {$$ = $1;}
        | BOOL_LIT    {$$ = $1;}
        | STRING_LIT  {$$ = $1;}
        ;

/* Acessores de coleções */
/* Associar: tipo da expressão de acesso */
collection_access : SQUARE_LEFT expression SQUARE_RIGHT                         {$$ = cat3("[", "<exp>", "]");}
                  | collection_access SQUARE_LEFT expression SQUARE_RIGHT       {$$ = cat4($1,"[", "<exp>", "]");}
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