/* CRIAR A TABELA DE SIMBOLOS, CRIAR PILHA */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../lib/types/map.h"
#include "../lib/types/stack.h"
#include "../lib/types/array.h"
#include "../lib/types/primitives.h"
#include "../lib/globals.h"
#include "../lib/stringUtil.h"
#include "../lib/stateUtil.h"
#include "../lib/typeUtil.h"
#include "../lib/record.h"

int yylex(void);
int yyerror(char *s);
static char* currentScope;
extern int yylineno;
extern char * yytext;
extern FILE * yyin, * yyout;
extern int yydebug;
Array* typesArray;
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

%type <rec> prog variables_block variables declaration initialization assignment subprogs subprog parameters main commands command if elif_condition else_condition switch cases for while dowhile return expression call call_parameters statement statements stms_cmds generic_type_op
%type <text> literal collection_access declared collection_size_op 

%start prog

%%
/*TODO: Adicionar os includes da linguagem no inicio*/
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
declaration     : {deleteArray(typeArray);} type ID collection_size_op        { 
                        
                        varEntry* tempVar;
                        char* code;

                        if($2){
                                if($2->opt1){
                                        tempVar = createVarEntry($3, $1, $2->code, $2->opt1, "currentscope");
                                        printf("%s - %s - %s - %s - %s\n", tempVar->name, tempVar->type, tempVar->subtype1, tempVar->subtype2, tempVar->scope);
                                } else {
                                        tempVar = createVarEntry($3, $1, $2->code, NULL, "currentscope");
                                        printf("%s - %s - %s - %s\n", tempVar->name, tempVar->type, tempVar->subtype1, tempVar->scope);
                                }
                        } else {
                                tempVar = createVarEntry($3, $1, NULL, NULL, "currentscope");
                                printf("%s - %s - %s\n", tempVar->name, tempVar->type, tempVar->scope);
                        }
                        varEntry* var = (varEntry *)mapGet(varMap, tempVar->name); 
                        if(var && strcmp(var->scope, tempVar->scope) != 0){
                                mapPut(varMap, tempVar->name, tempVar);
                        }

                        code = typeFromToken($1, NULL, NULL);
                        code = cat2space(code, $3);
                        $$ = createRecord(code);

                }
                ;

/* Define a variável e inicia */
initialization  :{deleteArray(typeArray);} type ID collection_size_op ASSIGNMENT expression { 
                        varEntry* tempVar;
                        char* code;

                        if($2){
                                if($2->opt1){
                                        tempVar = createVarEntry($3, $1, $2->code, $2->opt1, "currentscope");
                                        printf("%s - %s - %s - %s - %s\n", tempVar->name, tempVar->type, tempVar->subtype1, tempVar->subtype2, tempVar->scope);
                                } else {
                                        tempVar = createVarEntry($3, $1, $2->code, NULL, "currentscope");
                                        printf("%s - %s - %s - %s\n", tempVar->name, tempVar->type, tempVar->subtype1, tempVar->scope);
                                }
                        } else {
                                tempVar = createVarEntry($3, $1, NULL, NULL, "currentscope");
                                printf("%s - %s - %s\n", tempVar->name, tempVar->type, tempVar->scope);
                        }
                        varEntry* var = (varEntry *)mapGet(varMap, tempVar->name); 
                        if(var && strcmp(var->scope, tempVar->scope) != 0){
                                mapPut(varMap, tempVar->name, tempVar);
                        }

                        code = typeFromToken($1, NULL, NULL);
                        code = cat4space(code, $3, "=", $6->code);
                        $$ = createRecord(code);

                }
                | CONST {deleteArray(typeArray);} type ID collection_size_op ASSIGNMENT expression  {
                        /* criar registro na tabela de simbolos com as informações da variavel */
                        $$ = createRecord(cat5space("const", $2, $4, "=", $7->code));
                }
                ;

type    : TYPE                  {}
        | TYPE generic_type_op  {}
        ;

generic_type_op :                                               {$$ = NULL;}
                | LESS_THAN TYPE MORE_THAN                      {$$ = createRecord($2);}
                | LESS_THAN TYPE COMMA TYPE MORE_THAN           {$$ = createRecordOpt($2, $4);}
                ;


collection_size_op      :                                          {$$ = NULL;}
                        | SQUARE_LEFT expression SQUARE_RIGHT      {$$ = $2->code;}
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

subprog : FUNC ID PAREN_LEFT parameters PAREN_RIGHT {deleteArray(typeArray);} type variables_block stms_cmds ENDFUNC {
                char * code = cat5space($6, $2, "(", $4->code, "){");
                code = cat4space(code, $8->code, $9->code, "}");
                $$ = createRecord(code);
                free(code);
        }
        | FUNC ID PAREN_LEFT parameters PAREN_RIGHT variables_block stms_cmds ENDFUNC {
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

main : MAIN stms_cmds ENDMAIN {$$ = createRecord(cat3("int main() {", $2->code, "};"));}
     ;

stms_cmds       :                               {$$ = emptyRecord();}
                | commands stms_cmds            {$$ = createRecord(cat2space($1->code, $2->code));}
                | statements stms_cmds          {$$ = createRecord(cat2space($1->code, $2->code));}
                ;

commands : command               {$$ = createRecord($1->code);}
         | command commands      {$$ = createRecord(cat2($1->code, $2->code));}
         ;

command : if                            {$$ = $1;}
        | switch                        {$$ = $1;}
        | for                           {$$ = $1;}
        | while                         {$$ = $1;}
        | dowhile                       {$$ = createRecord("dowhile_comamnd");}
        ; 

statements      : statement SEMICOLON                   {$$ = createRecord(cat2($1->code, ";"));}
                | statement SEMICOLON statements        {$$ = createRecord(cat3($1->code, ";", $3->code));}
                ;

statement       : assignment    {$$ = $1;}
                | return        {$$ = $1;}
                | call          {$$ = $1;}
                | BREAK         {$$ = createRecord("break");}
                | CONTINUE      {$$ = createRecord("continue");}
                ;


/* Checar o retorno */
if : IF PAREN_LEFT expression PAREN_RIGHT {} stms_cmds {} elif_condition else_condition ENDIF {
                char* id = generateName("outif", NULL);
                char* code = cat5("if (!(", $3->code, ")) goto ", id, "; {");
                code = cat5(code, $5->code, "}", id, ":");
                code = cat3space(code, $6->code, $7->code);

                $$ = createRecord(code);
                freeRecord($3);
                free(code);
        }
   ;

elif_condition  :                                                                       {$$ = emptyRecord();}
                | ELIF PAREN_LEFT expression PAREN_RIGHT stms_cmds elif_condition       {
                        char* id = generateName("outelif", NULL);
                        char* code = cat5("if (!(", $3->code, ")) goto ", id, "; {");
                        code = cat5(code, $5->code, "}", id, ":");
                        code = cat2space(code, $6->code);

                        $$ = createRecord(code);
                        freeRecord($3);
                        freeRecord($5);
                        freeRecord($6);
                        free(code);
                }
                ;

else_condition  :                       {$$ = emptyRecord();}
                | ELSE stms_cmds        {
                        $$ = createRecord(cat3("{", $2->code, "}"));
                        freeRecord($2);
                }
                ;

switch  : SWITCH PAREN_LEFT ID PAREN_RIGHT cases ENDSWITCH {
                // char * id = generateName("switch", NULL);
                $$ = createRecord(cat5space("switch(", $3, ") {", $5->code, "}"));
        }
        ;

cases   :                                                                 {$$ = emptyRecord();}
        | CASE PAREN_LEFT literal PAREN_RIGHT stms_cmds cases             {
                char* code = cat5space("case(",$3,"):",$5->code, "break;");
                code = cat2(code, $6->code);
                $$ = createRecord(code);
                /*dar free*/

        }
        | DEFAULT stms_cmds cases                                         {
                $$ = createRecord(cat4space("default:",$2->code,"break;",$3->code));
        }
        ;

/*checar se a expressao 1 é do tipo booleano*/
for     : FOR PAREN_LEFT initialization SEMICOLON expression SEMICOLON assignment PAREN_RIGHT stms_cmds ENDFOR       {
                char* id = generateName("for", NULL);
                char* outId = cat2(id, "out");
                char* condition = cat5("if(", $5->code, ") goto ", outId, ";");

                char* code = cat5("{", $3->code, ";", id, ":");
                code = cat2(code, condition);
                code = cat5(code, $7->code, ";", $9->code, "goto");
                code = cat5space(code, id, ";", outId, ":}");

                $$ = createRecord(code);
                freeRecord($3);
                freeRecord($5);
                freeRecord($7);
                freeRecord($9);
                free(code);
        }
        | FOR PAREN_LEFT assignment SEMICOLON expression SEMICOLON assignment PAREN_RIGHT stms_cmds ENDFOR           {
                char* id = generateName("for", NULL);
                char* outId = cat2(id, "out");
                char* condition = cat5("if(", $5->code, ") goto ", outId, ";");

                char* code = cat5("{", $3->code, ";", id, ":");
                code = cat2(code, condition);
                code = cat5(code, $7->code, ";", $9->code, "goto");
                code = cat5space(code, id, ";", outId, ":}");

                $$ = createRecord(code);
                freeRecord($3);
                freeRecord($5);
                freeRecord($7);
                freeRecord($9);
                free(code);
        }
        ;

while   : WHILE PAREN_LEFT expression PAREN_RIGHT stms_cmds ENDWHILE {
                char* id = generateName("while", NULL);
                char* outId = cat2(id, "out");
                char* condition = cat5("if(", $3->code, ") goto ", outId, ";");

                char* code = cat5("{", id, ":", condition, $5->code);
                code = cat4space(code, "goto", id, ";");
                code = cat3space(code, outId, ":}");

                $$ = createRecord(code);
                freeRecord($3);
                freeRecord($5);
                free(code);
        }
        ;

dowhile : DO stms_cmds WHILE PAREN_LEFT expression PAREN_RIGHT {
                char* id = generateName("dowhile", NULL);
                char* condition = cat5("if(", $2->code, ") goto ", id, ";");

                char* code = cat5("{", id, ":", $5->code, condition);
                code = cat2(code, "}");

                $$ = createRecord(code);
                freeRecord($2);
                freeRecord($5);
                free(code);
        }
        ;

return : RETURN               {$$ = createRecord("return");}
       | RETURN expression    {$$ = createRecord(cat2space("return", $2->code));}
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
declared : ID                   {$$ = cat2("*", $1);}
           /* Checar: tipo de expressão para a coleção, dimensão da coleção */
         | ID collection_access {$$ = cat3("*", $1, $2);} 
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

        initGlobals();
        initStandardTypes();
        
        yyin = fopen(argv[1], "r");
        yyout = fopen(argv[2], "w");

        codigo = yyparse();

        fclose(yyin);
        fclose(yyout);

        cleanupGlobals();
        return codigo;

}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}