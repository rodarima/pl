%{
#include <stdlib.h>

struct student_t
{
	char *NIF;
	char *name;
	double mark;
};

struct list_t
{
	struct student_t **students;
	size_t n;
};

%}

digit	[0-9]
text	[^ \t\n]+
space	[ ]
tab	[\t]
new	[\n]
all	[.*]
DNI	{digit}{8}-[A-Z]
NAME	{text}{space}{text},{space}{text}
MARK	([0-9]\.[0-9]{2}|10\.00)
LINE	{DNI}[\t]{NAME}[\t]{MARK}

%%

{LINE}		{ printf("GOTCHA!\n"); explode(yytext); }
{DNI}\t{NAME}\t.*	{ printf("BAD MARK\n"); }
{DNI}\t{NAME}.*	{ printf("TAB AFTER NAME PLS\n"); }
{DNI}\t.*	{ printf("BAD NAME\n"); }
{DNI}.*		{ printf("TAB AFTER DNI PLS\n"); }
.*		{ printf("BAD DNI\n"); }
.	{ printf("ERROR %s LINE%d\n", yytext, yylineno); exit(1); }

%%

int list_new(struct list_t *list)
{
	if(!(list->students = malloc(sizeof(struct student_t*))))
	{
		perror("malloc");
		exit(1);
	}
	list->students[0] = NULL;
	list->n = 0;
	return 0;
}

int explode(char *shit)
{
	char *p;
	p = strtok(shit, "\t\n");
	while(p != NULL)
	{
		printf("HM? %s\n", p);
		p = strtok(NULL, "\t\n");
	}
}

int insert_student(struct student_t **list, struct student_t student)
{
	return 0;
}

int main(int argc, char *argv[])
{
	struct list_t list;
	list_new(&list);
	yylex();
	return 0;
}
