%{
  #include <stdio.h>
  #include "y.tab.h"
  
  extern int yyerror (char *msg);  
%}

digit [0-9]
sign -?
alphabetic [a-zA-Z]
alphanumeric ({alphabetic} | {digit})

%%

[ \t\n]                     ;
{sign}{digit}+              {yylval.text = strdup(yytext);
                              return INT_LIT;}
{sign}{digit}?+\.{digit}+    {yylval.text = strdup(yytext);
                              return FLOAT_LIT;}
\".+\"                      {yylval.text = strdup(yytext);
                              return STRING_LIT;}
"true"|"false"              { if(strcmp(yytext, "true") == 0){
                                yylval.text = strdup("1");
                              } else {
                                yylval.text = strdup("0");
                              }
                              return BOOL_LIT;
                            }
"not"|"!"                       {return NOT;}
"and"|"&&"                  {return AND;}                            
"or"|"||"                   {return OR;}
"func"                      {return FUNC;}
"const"                     {return CONST;}
"Int"                       {yylval.text = strdup("Int");
                             return TYPE;}
"Bool"                      {yylval.text = strdup("Bool");
                             return TYPE;}
"Float"                     {yylval.text = strdup("Float");
                             return TYPE;}
"String"                    {yylval.text = strdup("String");
                             return TYPE;}
"Array"                     {yylval.text = strdup("Array");
                             return TYPE;}
"Queue"                     {yylval.text = strdup("Queue");
                             return TYPE;}
"Deque"                     {yylval.text = strdup("Deque");
                             return TYPE;}
"Stack"                     {yylval.text = strdup("Stack");
                             return TYPE;}
"Map"                       {yylval.text = strdup("Map");
                             return TYPE;}
"Set"                       {yylval.text = strdup("Set");
                             return TYPE;}
"switch"                    {return SWITCH;}
"case"                      {return CASE;}
"default"                   {return DEFAULT;} 
"while"                     {return WHILE;}
"main"                      {return MAIN;}
"begin"                     {return BEGIN_TOK;}
"endfunc"                   {return ENDFUNC;}
"endvar"                    {return ENDVAR;}
"endmain"                   {return ENDMAIN;}
"endif"                     {return ENDIF;}
"endswitch"                 {return ENDSWITCH;}
"endfor"                    {return ENDFOR;}
"endwhile"                  {return ENDWHILE;}
"end"                       {return END;}
"var"                       {return VAR;}
"dowhile"                   {return DO;}
"if"                        {return IF;}
"elif"                      {return ELIF;}
"else"                      {return ELSE;}
"for"                       {return FOR;}
"break"                     {return BREAK;}
"continue"                  {return CONTINUE;}
"return"                    {return RETURN;}
";"                         {return SEMICOLON;}
"+="                        {return PLUS_ASSIGNMENT;}
"-="                        {return MINUS_ASSIGNMENT;}
"*="                        {return MULT_ASSIGNMENT;}
"/="                        {return DIVIDE_ASSIGNMENT;}
"="                         {return ASSIGNMENT;}
"^"                         {return EXP;}
"+"                         {return ADD;}
"-"                         {return MINUS;}
"/"                         {return DIV;}
"%"                         {return DIV_REMAINDER;}
"//"                        {return DIV_QUOTIENT;}
"*"                         {return MULT;}
"<"                         {return LESS_THAN;}
">"                         {return MORE_THAN;}
"=="                        {return EQUALS;}
"<="                        {return LESS_OR_EQUAL;}
">="                        {return MORE_OR_EQUAL;}
"!="                        {return NOT_EQUAL;}
"("                         {return PAREN_LEFT;}
")"                         {return PAREN_RIGHT;}
"["                         {return SQUARE_LEFT;}  
"]"                         {return SQUARE_RIGHT;}  
"{"                         {return CURLY_LEFT;}  
"}"                         {return CURLY_RIGHT;}
","                         {return COMMA;}                      
[a-zA-Z][a-zA-Z0-9]*	      {yylval.text = strdup(yytext);
                              return ID;}
\\\*.*\*\\                    {/* isso é um comentário */}
.                           {yyerror("Invalid character");}

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif