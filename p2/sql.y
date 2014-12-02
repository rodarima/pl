%{

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#define MAX_EMP	100
#define MAX_BUF	500

struct emp
{
	int id;
	char nombre[100];
	char apellidos[200];
	char puesto[100];
	char fecha[10];
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

%}

%union{
	int intval;
	double floatval;
	char *strval;
	int subtok;
}
%token SELECT ALL
/*
%token <valInt> HORA
%token <valFloat> VALOR_TEMPERATURA
%type <valFloat> temperatura medicion lista_temperaturas
*/
%start S
%%
S : SELECT  {printf("Select all\n");}
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


