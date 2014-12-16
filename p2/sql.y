%{

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#define MAX_EMP	100
#define MAX_BUF	500
#define N_COLS	5

struct emp
{
	int id;
	char nombre[100];
	char apellidos[200];
	char puesto[100];
	char fecha[10];
};

int columns = 0;
int num_emp = 0;
struct col_name_s
{
	char *name;
	int flag;
};

struct emp emps[MAX_EMP];

int numMedidas = 0;

void emit(char *s, ...)
{
	extern yylineno;
	va_list ap;
	va_start(ap, s);
	printf("SqL: ");
	vfprintf(stdout, s, ap);
	printf("\n");
}

void yyerror(char *s, ...)
{
	extern yylineno;
	va_list ap;
	va_start(ap, s);
	fprintf(stderr, "%d: error: ", yylineno);
	vfprintf(stderr, s, ap);
	fprintf(stderr, "\n");
}

struct col_name_s cn[5] = {
	{"idEmpleado",	1},
	{"nombre",	2},
	{"apellidos",	4},
	{"puesto",	8},
	{"anho",	16}
};

void addcolumn(char *str)
{
	int i;
	for(i=0; i<N_COLS; i++)
	{
		if(strcmp(str, cn[i].name) == 0)
		{
			columns |= cn[i].flag;
			break;
		}
	}
	
}

void select()
{
	int i,j;
	for(i=0; i<num_emp; i++)
	{
		if(columns & 1)
		{
			printf("%d\t", emps[i].id);
		}
		if(columns & 2)
		{
			printf("%s\t", emps[i].nombre);
		}
		if(columns & 4)
		{
			printf("%s\t", emps[i].apellidos);
		}
		if(columns & 8)
		{
			printf("%s\t", emps[i].puesto);
		}
		if(columns & 16)
		{
			printf("%s\t", emps[i].fecha);
		}
		printf("\n");
	}
	columns = 0;
}

%}

%union{
	int i;
	double d;
	char *s;
}
%token SELECT ALL NUMBER NAME FROM SEMICOLON COMMA
%type <i> NUMBER
%type <s> NAME
%type <s> TABLE
/*
%token <valInt> HORA
%token <valFloat> VALOR_TEMPERATURA
%type <valFloat> temperatura medicion lista_temperaturas
*/
%start S
%%
S : SENTENCES {}
SENTENCES : SENTENCE SEMICOLON | SENTENCE SEMICOLON SENTENCES {}
SENTENCE : SEN_SELECT {}

SEN_SELECT : SELECT COLS SEN_FROM {printf("SELECT %d\n", columns);select();}
SEN_SELECT : SELECT ALL SEN_FROM {columns = 31; printf("SELECT *\n"); select();}
SEN_FROM : FROM TABLE {}

TABLE : NAME			{printf("TABLE %s\n", $1); $$ = $1;}
COLS : NAME			{addcolumn($1);}
COLS : NAME COMMA COLS		{addcolumn($1);}
%%

int read_input(char *file)
{
	int i;
	char buf[MAX_BUF];
	struct emp *e;
	FILE *f;

	f = fopen(file, "r");

	for(i = 0; i < MAX_EMP; i++)
	{
		e = &emps[i];
		if(fgets(buf, MAX_BUF, f) == NULL)
		{
			break;
		}
		e->id = atoi(strtok(buf, ",\n"));
		strcpy(e->nombre, strtok(NULL, ",\n"));
		strcpy(e->apellidos, strtok(NULL, ",\n"));
		strcpy(e->puesto, strtok(NULL, ",\n"));
		strcpy(e->fecha, strtok(NULL, ",\n"));
		printf("%d, %s, %s, %s, %s\n", 
			e->id, e->nombre, e->apellidos, e->puesto, e->fecha);
		num_emp++;
	}

	fclose(f);
}

int main(int argc, char *argv[])
{
	read_input(argv[1]);
	yyparse();
	return 0;
}
//void yyerror (char const *message) { fprintf (stderr, "%s\n", message);}


