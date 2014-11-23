all: p1

p1: p1.l
	flex p1.l
	gcc -g -lbsd -lfl lex.yy.c -o p1

