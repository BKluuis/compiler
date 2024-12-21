all: compilador

compilador: lex.yy.c y.tab.c 
	gcc .\build\lex.yy.c .\build\y.tab.c .\lib\record.c -o compiler

lex.yy.c: scanner.l
	win_flex -o .\build\lex.yy.c -d scanner.l

y.tab.c: parser.y  
	win_bison parser.y -d -v -t -o .\build\y.tab.c

clean:
	del .\build\* /Q
	del compiler.exe

redo: clean compilador