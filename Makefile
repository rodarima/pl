all: p1.l
	flex p1.l
	gcc -lfl lex.yy.c -o p1

