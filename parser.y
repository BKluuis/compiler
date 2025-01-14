/* CRIAR A TABELA DE SIMBOLOS, CRIAR PILHA */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../lib/stringUtil.h"
#include "../lib/typeUtil.h"
#include "../lib/operationsUtil.h"
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

%type <rec> prog variables_block variables declaration initialization assignment assignments subprogs subprog parameters main commands command if elif_condition else_condition switch cases for while dowhile  return expression call call_parameters
%type <text> literal collection_access declared collection_size_op generic_type_op

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
/* Alguns tipos precisam de um generic especificado */
/* Se não especificado um tamanho, iniciar com um padrão */
declaration     : TYPE generic_type_op ID collection_size_op        { 
                        char* type = typeFromToken($1, $2, $4);
                        $$ = createRecord(cat2space(type, $3));
                        free(type);
                }
                | CONST TYPE generic_type_op ID collection_size_op  {}
                ;

/* Define a variável e inicia */
initialization  : TYPE generic_type_op ID ASSIGNMENT expression {
                        char* type = typeFromToken($1, $2, NULL);
                        $$ = createRecord(cat4space(type, $3, "=", $5->code));
                        freeRecord($5);
                        free(type);
                }
                ;

/* */
generic_type_op :                               {$$ = NULL;}
                | LESS_THAN TYPE MORE_THAN      {$$ = $2;}
                ;

/* type_list       : TYPE                  {}
                | TYPE COMMA type_list  {} */

collection_size_op      :                                          {$$ = NULL;}
                        | SQUARE_LEFT expression SQUARE_RIGHT      {$$ = $2->code;}
                        ;

/* Muda o valor de uma variável, checar se variavel existe */
assignments : assignment SEMICOLON                      {$$ = createRecord(cat2($1->code, ";"));}
            | assignment SEMICOLON assignments          {$$ = createRecord(cat3($1->code, ";", $3->code));}
            ;

assignment : declared PLUS_ASSIGNMENT expression       {$$ = createRecord(cat3($1, "+=", $3->code));}
           | declared MINUS_ASSIGNMENT expression      {$$ = createRecord(cat3($1, "-=", $3->code));}
           | declared MULT_ASSIGNMENT expression       {$$ = createRecord(cat3($1, "*=", $3->code));}
           | declared DIVIDE_ASSIGNMENT expression     {$$ = createRecord(cat3($1, "/=", $3->code));}
           | declared ASSIGNMENT expression            {$$ = createRecord(cat3($1, "=", $3->code));}
           ;

/* Será necessário mudar para que as funções recebam parâmetros por referência
   adicionar * aos tipos dos parametros, 
   todo acesso à esses parametros devem ser feitos por dereferênciamento (*variavel)
*/
subprogs :                  {$$ = emptyRecord();}
         | subprog subprogs {$$ = createRecord(cat2($1->code, $2->code));} 
         ;

subprog : FUNC ID PAREN_LEFT parameters PAREN_RIGHT TYPE generic_type_op variables_block commands ENDFUNC {
                char * code = cat5space(typeFromToken($6, $7, NULL), $2, "(", $4->code, "){");
                code = cat4space(code, $8->code, $9->code, "}");
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

main : MAIN commands ENDMAIN {$$ = createRecord(cat3("int main() {", $2->code, "};"));}
     ;

commands : command           {$$ = createRecord($1->code);}
         | command commands  {$$ = createRecord(cat2($1->code, $2->code));}
         ;

command : assignments                   {$$ = $1;}
        | call SEMICOLON                {$$ = createRecord(cat2($1->code, ";"));}
        | if                            {$$ = $1;}
        | switch                        {$$ = createRecord("switch_comamnd");}
        | for                           {$$ = $1;}
        | while                         {$$ = $1;}
        | dowhile                       {$$ = createRecord("dowhile_comamnd");}
        | BREAK SEMICOLON               {$$ = createRecord("break;");}
        | CONTINUE SEMICOLON            {$$ = createRecord("continue;");}
        | return                        {$$ = $1;}
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

/*checar se a expressao 1 é do tipo booleano*/
for     : FOR PAREN_LEFT initialization SEMICOLON expression SEMICOLON assignment PAREN_RIGHT commands ENDFOR       {
                char* code = cat5("for(", $3->code, ";", $5->code, ";");
                code = cat5(code, $7->code, "){", $9->code, "}");
                $$ = createRecord(code);
                free(code);
        }
        | FOR PAREN_LEFT assignment SEMICOLON expression SEMICOLON assignment PAREN_RIGHT commands ENDFOR           {
                char* code = cat5("for(", $3->code, ";", $5->code, ";");
                code = cat5(code, $7->code, "){", $9->code, "}");
                $$ = createRecord(code);
                free(code);
        }
        ;

while : WHILE PAREN_LEFT expression PAREN_RIGHT commands ENDWHILE {$$ = createRecord(cat5("while(", $3->code, "){", $5->code, "}"));}
      ;

dowhile : DO commands WHILE PAREN_LEFT expression PAREN_RIGHT ENDWHILE{}
        ;

return : RETURN SEMICOLON               {$$ = createRecord("return;");}
       | RETURN expression SEMICOLON    {$$ = createRecord(cat3space("return", $2->code, ";"));}
       ;

/* Uma expressão, um valor */           
expression : declared                                {$$ = createRecord($1);}
           | literal                                 {$$ = createRecord($1);}
           | expression OR expression                {$$ = createRecord(cat3space($1->code, "||", $3->code));}
           | expression AND expression               {$$ = createRecord(cat3space($1->code, "&&", $3->code));}
           | expression EQUALS expression            {$$ = createRecord(cat3space($1->code, "==", $3->code));}
           | expression NOT_EQUAL expression         {$$ = createRecord(cat3space($1->code, "!=", $3->code));}
           | expression LESS_THAN expression         {$$ = createRecord(cat3space($1->code, "<", $3->code));}
           | expression MORE_THAN expression         {$$ = createRecord(cat3space($1->code, ">", $3->code));}
           | expression LESS_OR_EQUAL expression     {$$ = createRecord(cat3space($1->code, "<=", $3->code));}
           | expression MORE_OR_EQUAL expression     {$$ = createRecord(cat3space($1->code, ">=", $3->code));}
           | expression ADD expression               {$$ = createRecord(cat3space($1->code, "+", $3->code));}
           | expression MINUS expression             {$$ = createRecord(cat3space($1->code, "-", $3->code));}
           | expression MULT expression              {$$ = createRecord(cat3space($1->code, "*", $3->code));}
           | expression DIV expression               {$$ = createRecord(cat3space($1->code, "/", $3->code));}
           | expression DIV_QUOTIENT expression      {$$ = createRecord(cat3space($1->code, "quotient", $3->code));}
           | expression DIV_REMAINDER expression     {$$ = createRecord(cat3space($1->code, "remainder", $3->code));}
           | expression EXP expression               {$$ = createRecord(cat5("exponentf(", $1->code , "," , $3->code, ")"));}
           | NOT expression                          {$$ = createRecord(cat2("!", $2->code));}
           | MINUS expression %prec UMINUS           {$$ = createRecord(cat2("-", $2->code));}
           | PAREN_LEFT expression PAREN_RIGHT       {$$ = createRecord(cat3("(", $2->code, ")"));}
           | call                                    {$$ = $1;}
           ;

/* Variáveis já declaradas */
declared : ID                   {$$ = $1;}
           /* Checar: tipo de expressão para a coleção, dimensão da coleção */
         | ID collection_access {$$ = cat2($1, $2);} 
         ; 

literal : INT_LIT     {$$ = $1;}
        | FLOAT_LIT   {$$ = $1;}
        | BOOL_LIT    {$$ = $1;}
        | STRING_LIT  {$$ = $1;}
        ;

/* Acessores de coleções */
/* Associar: tipo da expressão de acesso */
collection_access : SQUARE_LEFT expression SQUARE_RIGHT                         {$$ = cat3("[", $2->code, "]");}
                  | collection_access SQUARE_LEFT expression SQUARE_RIGHT       {$$ = cat4($1,"[", $3->code, "]");}
                  ;

/* Seguindo a mudança dos subprogs, o call_parameters deve ter & adicionado aos parâmetros
*/
call : ID PAREN_LEFT call_parameters PAREN_RIGHT {$$ = createRecord(cat4space($1, "(", $3->code, ")"));}    
     ;  

call_parameters :                                       {$$ = emptyRecord();}
                | expression                            {$$ = $1;}
                | call_parameters COMMA expression      {$$ = createRecord(cat3($1->code, ",", $3->code));}
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