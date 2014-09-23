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

space	[ ]
digit	[0-9]
text	[^ \t\n]+
DNI	{digit}{8}-[A-Z]
NAME	{text}{space}{text},{space}{text}
SEP	"\t"
MARK	([0-9]\.[0-9]{2}|10.00)
LINE	{DNI}{SEP}{NAME}	

%%

{LINE}	{printf("--%s\n", yytext);}

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
