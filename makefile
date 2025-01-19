all: compilador

LIB_SOURCES := $(wildcard ./lib/*.c)
LIB_SOURCES += $(wildcard ./lib/*/*.c)

compilador: lex.yy.c y.tab.c 
	gcc .\build\lex.yy.c .\build\y.tab.c $(LIB_SOURCES) -o compiler

lex.yy.c: scanner.l
	win_flex -o .\build\lex.yy.c  scanner.l

y.tab.c: parser.y  
	win_bison parser.y --report=all -d -v -t -o .\build\y.tab.c

clean:
	del .\build\* /Q
	del compiler.exe

redo: clean compilador

test: 
	gcc -g $(LIB_SOURCES) ./test/$(file).c -o test