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

struct record * exponentExpression(struct record *a, struct record *b);
struct record * binaryExpression(struct record *a, char* operation, struct record *b);
int yylex(void);
int yyerror(char *s);
static char* currentScope;
extern int yylineno;
extern char * yytext;
extern FILE * yyin, * yyout;
extern int yydebug;
extern int yy_flex_debug;
%}

%debug

%union {
	char * text;  /* string value */
	struct record * rec;
        struct Array *array;
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

%type <rec> prog variables_block variables declaration initialization initialization_expression initialization_list assignment subprogs subprog parameters call_parameters_op main commands command if elif_condition else_condition switch cases for while dowhile return expression call  statement statements stms_cmds  func_declaration
literal declared casting
%type <text>  collection_size_op 
%type <array> type generic_type collection_access

%start prog

%%
/*TODO: Adicionar os includes da linguagem no inicio*/
prog    : BEGIN_TOK {stackPush(scopeStack, "global");} variables_block subprogs main END {
                char* code = "#include \"./lib/standard.h\"\n";
                if(strcmp($3->code, "") != 0){
                        code = cat2(code, $3->code);
                }
                fprintf(yyout, cat3(code, $4->code, $5->code));
                freeRecord($3);
                freeRecord($4);
                freeRecord($5);
                stackPop(scopeStack);
        }
        ;

variables_block :                      {$$ = createRecord("");}
                | VAR variables ENDVAR {
                        $$ = createRecord($2->code);
                        freeRecord($2);
                }
                ;

variables       :                                     {$$ = emptyRecord();}
                | initialization SEMICOLON variables     {
                        $$ =  createRecord(cat3($1->code, ";", $3->code));
                        freeRecord($1);
                        freeRecord($3);
                }
                | declaration SEMICOLON variables     {
                        $$ =  createRecord(cat3($1->code, ";", $3->code));
                        freeRecord($1);
                        freeRecord($3);
                }
                ;

/* Define a variável sem iniciar */
/* Retorna o código de declaração é a coleção de tipos da variavel */
declaration     : type ID collection_size_op        { 
                        varEntry* temp;
                        char* code;

                        temp = createVarEntry($2, $1, stackPeek(scopeStack));

                        varEntry* var = (varEntry *)mapGet(varMap, temp->name); 
                        if(var && equals(var->scope, temp->scope, "char*")){
                                fprintf(stderr, "Error while parsing: Variable ");
                                print(var, "varEntry");
                                fprintf(stderr, " already defined\n");
                                exit(1);
                        } else {
                                mapPut(varMap, temp->name, temp);
                        }
                        printf("Created var: "); print(temp, "varEntry"); printf("\n");

                        code = typeFromToken(arrayGet($1, 0));
                        code = cat2space(code, $2);

                        $$ = createRecord(code);
                        $$->array = copyArray($1);

                        deleteArray($1);
                        free($3);
                }
                ;

/* Define a variável e inicia */
// TODO: Se o escopo for global, permitir apenas inicialização de literais
// TODO: Checar se a expressão de inicialização condiz com o tipo da declaração
initialization  : declaration ASSIGNMENT initialization_expression {
                        $$ = binaryExpression($1, "=", $3);
                }

//TODO: Adicionar inicialização de array, mapa, stack, etc;
initialization_expression       : CURLY_LEFT initialization_list CURLY_RIGHT    {$$ = $2;}
                                | expression                                    {$$ = $1;}
                                ;

initialization_list     : expression                            {$$ = $1;}
                        | initialization_list COMMA expression  {/*TODO: gerar um monte de add/push/put dependendo do tipo*/}
                        ;

type    : TYPE                  { 
                struct Array* types = createArray("char*", 4);
                arrayAdd(types, $1);
                $$ = types;
        }
        | TYPE generic_type     { 
                struct Array* types = createArray("char*", 2);
                arrayAdd(types, $1);
                $$ = arrayAppend(types, $2);
        }
        ;

generic_type    : LESS_THAN type MORE_THAN                      {$$ = $2;}
                | LESS_THAN type COMMA type MORE_THAN           {$$ = arrayAppend($2, $4);}
                ;


collection_size_op      :                                          {$$ = NULL;}
                        | SQUARE_LEFT expression SQUARE_RIGHT      {$$ = $2->code;}
                        ;

assignment : declared PLUS_ASSIGNMENT expression       {$$ = createRecord(cat3($1->code, "+=", $3->code));}
           | declared MINUS_ASSIGNMENT expression      {$$ = createRecord(cat3($1->code, "-=", $3->code));}
           | declared MULT_ASSIGNMENT expression       {$$ = createRecord(cat3($1->code, "*=", $3->code));}
           | declared DIVIDE_ASSIGNMENT expression     {$$ = createRecord(cat3($1->code, "/=", $3->code));}
           | declared ASSIGNMENT expression            {$$ = createRecord(cat3($1->code, "=", $3->code));}
           ;

/* Será necessário mudar para que as funções recebam parâmetros por referência
   adicionar * aos tipos dos parametros, 
   todo acesso à esses parametros devem ser feitos por dereferênciamento (*variavel)
*/
subprogs :                  {$$ = emptyRecord();}
         | subprog subprogs {$$ = createRecord(cat2($1->code, $2->code));} 
         ;

/**
* Retorna o código da função e possívelmente o tipo da função, se houver, ou nulo, se não houver
* Ainda não checa o tipo a fundo, apenas o tipo inicial
*/
subprog : func_declaration type variables_block stms_cmds ENDFUNC {
                char * code = cat5space(typeFromToken(arrayGet($2, 0)), $1->code, "{", $3->code, $4->code);
                code = cat2space(code,"}");

                $$ = createRecord(code);
                $$->array = copyArray($2);

                freeRecord($1);
                freeRecord($3);
                freeRecord($4);
                deleteArray($2);
                free(code);
                stackPop(scopeStack);
        }
        | func_declaration variables_block stms_cmds ENDFUNC {
                char * code = cat5space("void", $1->code, "{", $2->code, $3->code);
                code = cat2space(code,"}");

                $$ = createRecord(code);
                freeRecord($1);
                freeRecord($2);
                freeRecord($3);
                free(code);
                stackPop(scopeStack);
        }
        ;

func_declaration        : FUNC ID PAREN_LEFT {stackPush(scopeStack, $2);} parameters PAREN_RIGHT {
                                char* id = stackPeek(scopeStack);

                                funcEntry* entry = createFuncEntry($2, id, typesArray);
                                funcEntry* var = (funcEntry *)mapGet(funcMap, entry->name); 

                                if(var && equals(var->name, entry->name, "char*")){
                                        printf("Error while parsing: function already defined ");
                                        print(var, "funcEntry");
                                        printf("\n");
                                        exit(1);
                                } else {
                                        printf("New function defined: ");
                                        print(entry, "funcEntry");
                                        printf("\n");
                                        mapPut(funcMap, entry->name, entry);
                                }

                                //text é os tipos dos parametros concatenados sem espaço
                                $$ = createRecord(cat4space($2, "(", $5->code, ")"));
                                $$->array = copyArray($5->array);
                                printf(cat4space($2, "(", $5->code, ") "));
                                print($$->array, "Array");
                                printf("\n");
                                freeRecord($5);
                        }

/* Uma lista de declarações separadas por vírgula potencialmente vazia  */
/* Retorna como text todos os tipos juntos, servirá como identificação para overloading de função  */
/* TODO: fazer com que o text junte os subtipos também s*/
parameters :                                    {$$ = emptyRecord();}
           | declaration                        {$$ = $1;}
           | declaration COMMA parameters       {$$ = createRecord(cat3($1->code, ", ", $3->code)); $$->array = copyArray($1->array);}
           ;

call_parameters_op      :                                      {$$ = emptyRecord();}
                        | expression                           {$$ = $1;}
                        | expression COMMA parameters          {$$ = createRecord(cat3($1->code, ", ", $3->code)); $$->array = copyArray($1->array);}
                        ;


main : MAIN variables_block stms_cmds ENDMAIN {$$ = createRecord(cat4("int main() {", $2->code, $3->code, "};"));}
     ;

// Add option to return
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
if      : IF PAREN_LEFT expression PAREN_RIGHT stms_cmds elif_condition else_condition ENDIF {
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
                char* code = cat5space("case(",$3->code,"):",$5->code, "break;");
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

/* Uma expressão, um valor
* Retorna como text o nome do tipo da expressão em char* 
*/           
expression      : declared                              {$$ = $1; /*$$->code = cat2("*", $$->code);*/}
                | literal                               {
                        $$ = $1; 
                        $$->array = createArray("char*", 1);
                        arrayAdd($$->array, $$->text);
                        $$->code = cat5("create",$1->text, "(", $1->code, ")");
                }
                | casting                               {$$ = $1;}
                | expression OR expression              {$$ = binaryExpression($1, "||", $3);}
                | expression AND expression             {$$ = binaryExpression($1, "&&", $3);}
                | expression EQUALS expression          {$$ = binaryExpression($1, "==", $3);}
                | expression NOT_EQUAL expression       {$$ = binaryExpression($1, "!=", $3);}
                | expression LESS_THAN expression       {$$ = binaryExpression($1, "<", $3);}
                | expression MORE_THAN expression       {$$ = binaryExpression($1, ">", $3);}
                | expression LESS_OR_EQUAL expression   {$$ = binaryExpression($1, "<=", $3);}
                | expression MORE_OR_EQUAL expression   {$$ = binaryExpression($1, ">=", $3);}
                | expression ADD expression             {$$ = binaryExpression($1, "+", $3);}
                | expression MINUS expression           {$$ = binaryExpression($1, "-", $3);}
                | expression MULT expression            {$$ = binaryExpression($1, "*", $3);}
                | expression DIV expression             {$$ = binaryExpression($1, "/", $3);}
                | expression DIV_QUOTIENT expression    {$$ = binaryExpression($1, "quotient", $3);}
                | expression DIV_REMAINDER expression   {$$ = binaryExpression($1, "remainder", $3);}
                | expression EXP expression             {$$ = exponentExpression($1, $3);}
                | NOT expression                        {$$ = createRecord(cat2("!", $2->code)); $$->array = copy($2->array, "Array");}
                | MINUS expression %prec UMINUS         {$$ = createRecord(cat2("-", $2->code)); $$->array = copy($2->array, "Array");}
                | PAREN_LEFT expression PAREN_RIGHT     {$$ = createRecord(cat3("(", $2->code, ")")); $$->array = copy($2->array, "Array");}
                | call                                  {$$ = $1;}
                ;

casting : TYPE PAREN_LEFT expression PAREN_RIGHT {
                struct Array* type = createArray("char*", 1);
                arrayAdd(type, $1);
                $$ = createRecord(cast($3->code, $1, arrayGet($3->array, 0)));
                $$->array = copy(type, "Array");
        } 

/* Variáveis já declaradas */
//TODO: Checar escopo
declared        : ID                   {
                       varEntry* var = (varEntry *)mapGet(varMap, $1); 
                        if(!var) {
                                yyerror(cat2space("Variable doesn't exists: ", $1));
                                return 1;
                        }
                        $$ = createRecord($1);
                        $$->array = copy(var->types, "Array");
                }
                /* Checar: tipo de expressão para a coleção, dimensão da coleção */
                | ID collection_access {
                        varEntry* var = (varEntry *)mapGet(varMap, $1); 
                        if(!var) {
                                yyerror(cat2space("Variable doesn't exists: ", $1));
                                return 1;
                        }

                        printf("Var: "); print(var, "varEntry"); printf("\n");
                        printf("Accessors: "); print($2, "Array");
                        $$ = access(var->name, var->types, $2, 0, 0);
                        printf("Final variable accessor: code: %s, type: ", $$->code);
                        printArray($$->array);
                        printf("\n");
                } 
                ; 

literal : INT_LIT     {$$ = createRecordOpt($1, "Int");}
        | FLOAT_LIT   {$$ = createRecordOpt(cat2($1,"f"), "Float");}
        | BOOL_LIT    {$$ = createRecordOpt($1, "Bool");}
        | STRING_LIT  {$$ = createRecordOpt($1, "String");}
        ;

/* Acessores de coleções */
/* TODO: Atualmente está comparando apenas o tipo superficial da expressão */
collection_access       : SQUARE_LEFT expression SQUARE_RIGHT                         {
                                struct Array* exps = createArray("Map",3);
                                struct Map* vars = createMap("char*", "char*", 3);

                                mapPut(vars, $2->code, arrayGet($2->array, 0));
                                arrayAdd(exps, vars);

                                // print(exps, "Array");
                                $$ = exps;
                        }
                        | collection_access SQUARE_LEFT expression SQUARE_RIGHT       {
                                $$ = $1;         
                                struct Map* vars = createMap("char*", "char*", 3);

                                mapPut(vars, $3->code, arrayGet($3->array, 0));
                                arrayAdd($$, vars);
                                // print($$, "Array");
                        }
                        ;

/* 
* Comparar func aos args
*/
call    : ID PAREN_LEFT call_parameters_op PAREN_RIGHT {
                funcEntry* func = (funcEntry *)mapGet(funcMap, $1); 
                if(!func) {
                        yyerror(cat2space("Function doesn't exists: ", $1));
                        exit(1);
                }

                if(strcmp($1, "print") == 0){
                        $3->code = cat4($3->code, ",\"", arrayGet($3->array, 0), "\"");
                }

                printf("\n");
                print(func, "funcEntry");
                printf("\n");
                $$ = createRecord(cat4space($1, "(", $3->code, ")"));
                $$->array = copy(func->returnType, "Array");
        }    
        ;  

%%

int yywrap(void){
        return 1;
}


int main (int argc, char ** argv) {
        int codigo;
        int yylineno = 0;

        if (argc < 3) {
        printf("Usage: $./compiler input.txt output.txt [-d]\nClosing application...\n");
        exit(0);
        }
        if(argc == 4 && strcmp(argv[3], "-d") == 0){
                yydebug = 1; 
                yy_flex_debug = 1;
        } else {
                yydebug = 0; 
                yy_flex_debug = 0;
        }

        initGlobals();
        
        yyin = fopen(argv[1], "r");
        yyout = fopen(argv[2], "w");

        codigo = yyparse();

        fclose(yyin);
        fclose(yyout);

        printGlobals();

        cleanupGlobals();
        return codigo;

}

int isSameType(struct record *a, struct record *b){
        return equals(a->array, b->array, "Array");
}

struct record * binaryExpression(struct record *a, char* operation, struct record *b){
        if(!equals(a->array, b->array, "Array")){
                yyerror("Error comparing expressions");
                printf("Incompatible expression type: \"%s\" is of type ", a->code); 
                print(a->array, "Array");
                printf(" and \"%s\" is of type ", b->code); 
                print(b->array, "Array");
                printf("\n"); 
                exit(1);
        }
        char* code;

printf("1");
        if(strcmp(operation, "+") == 0){
printf("2");
                if(strcmp(arrayGet(a->array, 0), "Float") == 0){
printf("3");
                        code = cat4space("addFloat(", a->code, b->code,")");
                } else {
printf("4");
                        code = cat4space("addInt(", a->code, b->code,")");
                }
        } else {
printf("5");
                code = cat3space(a->code, operation, b->code);
        }

        struct record* rec = createRecord(code);
        rec->array = copy(a->array, "Array");
        return rec;
}

struct record * exponentExpression(struct record *a, struct record *b){
        if(!equals(a->array, b->array, "Array")){
                yyerror("Error comparing expressions");
                printf("Incompatible expression type: \"%s\" is of type ", a->code); 
                print(a->array, "Array");
                printf(" and \"%s\" is of type ", b->code); 
                print(b->array, "Array");
                printf("\n"); 
                exit(1);
        }

        char* code;
        if(strcmp(arrayGet(a->array, 0), "Float") == 0){
         code = cat5space("exponentf(",a->code, ",", b->code, ")");
        } else {
         code = cat5space("exponenti(",a->code, ",", b->code, ")");
        }

        struct record* rec = createRecord(code);
        rec->array = copy(a->array, "Array");
        return rec;
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}