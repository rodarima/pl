%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#define MAX_EMP	100
#define MAX_BUF	500
#define N_COLS	5
#define TABLE_NAME	"Empleado"
#define COL_SPACE 2

struct
{
	/* Input table */
	int nlines;		/* Number of lines */

	/* Select vars */
	int scolumns;		/* Bitfield of selected columns */

	/* Where vars */
	int cmp;		/* Type of comparation */
	int op;			/* Expected comparation result */
	char *wsval1, *wsval2;	/* String value from user */
	int wnval1, wnval2;	/* Number value from user */
	int wcol1, wcol2;	/* Column selected */
} g;

char *col_names[5] = 
{
	"idEmpleado", "nombre", "apellidos", "puesto", "anho"
};

struct emp
{
	int id;
	char nombre[100];
	char apellidos[200];
	char puesto[100];
	char fecha[10];

	void *cols[5];
};

struct emp emps[MAX_EMP];

void yyerror(char *s, ...)
{
	extern yylineno;
	va_list ap;
	va_start(ap, s);
	fprintf(stderr, "Error en la línea %d: ", yylineno);
	vfprintf(stderr, s, ap);
	fprintf(stderr, "\n");
}

void err(char *s, ...)
{
	extern yylineno;
	va_list ap;
	va_start(ap, s);
	fprintf(stderr, "Error en la línea %d: ", yylineno);
	vfprintf(stderr, s, ap);
	fprintf(stderr, "\n");
	exit(1);
}

void add_column(int col)
{
	g.scolumns |= (0x01 << col);
}

/*
int strlen_utf8(char *s)
{
	int i = 0, j = 0;

	while(s[i])
	{
		if ((s[i] & 0xc0) != 0x80) j++;
		
		i++;
	}
	return j;
}
*/
int strlen_utf8(const char *str)
{
	int c,i,ix,q;
	for (q=0, i=0, ix=strlen(str); i < ix; i++, q++)
	{
		c = (unsigned char) str[i];
		if      (c>=0   && c<=127) i+=0;
		else if ((c & 0xE0) == 0xC0) i+=1;
		else if ((c & 0xF0) == 0xE0) i+=2;
		else if ((c & 0xF8) == 0xF0) i+=3;
		//else if (($c & 0xFC) == 0xF8) i+=4; // 111110bb //byte 5, unnecessary in 4 byte UTF-8
		//else if (($c & 0xFE) == 0xFC) i+=5; // 1111110b //byte 6, unnecessary in 4 byte UTF-8
		else return 0;//invalid utf8
	}
	return q;
}

void print_col(int max, char *col)
{
	printf("%s", col);
	
	int i;
	for(i = strlen_utf8(col); i<max; i++)
	{
		putchar(' ');
	}
}

void clear_select()
{
	g.scolumns = 0;
}

void do_select()
{
	//printf("CMP = %d\n", g.cmp);

	int max_chars[N_COLS];
	int max_line = 0;
	int i,j;

	if(g.scolumns & 1)
	{
		max_chars[0] = strlen_utf8(col_names[0]) + COL_SPACE;
		max_line = max_chars[0];
	}
	for(j = 1; j < 5; j++)
	{
		max_chars[j] = strlen_utf8(col_names[j]);
		if(!(g.scolumns & (0x01 << j))) continue;
		for(i = 0; i < g.nlines; i++)
		{
			if(!where(i)) continue;
			
			if(max_chars[j] < strlen_utf8(emps[i].cols[j]))
				max_chars[j] = strlen_utf8(emps[i].cols[j]);
		}
		max_chars[j] += COL_SPACE;
		max_line += max_chars[j];
		//printf("%d, ", max_chars[j]);
	}
	for(i=0; i<max_line; i++)
	{
		putchar('-');
	}
	printf("\n");
	
	for(j = 0; j<5; j++)
	{
		if(g.scolumns & (0x01 << j))
		{
			printf("%-*s", max_chars[j], col_names[j]);
		}
	}
	printf("\n");
	for(i=0; i<max_line; i++)
	{
		putchar('-');
	}
	printf("\n");
	
	for(i=0; i < g.nlines; i++)
	{
		if(!where(i)) continue;
		if(g.scolumns & 1)
		{
			printf("%-*d", max_chars[0], emps[i].id);
		}
		for(j=1; j<5; j++)
		{
			if(g.scolumns & (0x01 << j))
			{
				print_col(max_chars[j], emps[i].cols[j]);
			}
		}
		printf("\n");
	}
	
	clear_select();
}

char *get_table(char *str)
{
	if(strcmp(str, TABLE_NAME))
	{
		printf("Tabla no encontrada: %s\n", str);
		exit(1);
	}
	return str;
}

#define CMP_ALL		0
#define CMP_STR_STR	1
#define CMP_STR_COL	2
#define CMP_COL_STR	3
#define CMP_SCOL_SCOL	4

#define CMP_NUM_NUM	5
#define CMP_NUM_COL	6
#define CMP_COL_NUM	7
#define CMP_NCOL_NCOL	8

char *op_str1, *op_str2;

int string_cmp(char *a, char *b)
{
	int r = strcmp(a, b);
	
	if(r == 0) return 0;
	else if(r < 0) return -1;
	else return 1;
}

int num_cmp(int *a, int *b)
{
	if((*a) == (*b)) return 0;
	else if((*a) < (*b)) return -1;
	else return 1;
}


int where(int i)
{
	switch(g.cmp)
	{
	case CMP_STR_STR:
		return string_cmp(g.wsval1, g.wsval2) == g.op;
	
	case CMP_STR_COL:
		return string_cmp(g.wsval1, emps[i].cols[g.wcol2]) == g.op;
	
	case CMP_COL_STR:
		return string_cmp(emps[i].cols[g.wcol1], g.wsval2) == g.op;
	
	case CMP_SCOL_SCOL:
		return string_cmp(emps[i].cols[g.wcol1],
			emps[i].cols[g.wcol2]) == g.op;



	case CMP_NUM_NUM:
		return num_cmp(&g.wnval1, &g.wnval2) == g.op;
	
	case CMP_NUM_COL:
		return num_cmp(&g.wnval1, emps[i].cols[g.wcol2]) == g.op;
	
	case CMP_COL_NUM:
		return num_cmp(emps[i].cols[g.wcol1], &g.wnval2) == g.op;

	case CMP_NCOL_NCOL:
		return num_cmp(emps[i].cols[g.wcol1],
			emps[i].cols[g.wcol2]) == g.op;

	case CMP_ALL:
		return 1;
	
	}
}

%}

%union{
	int i;
	double d;
	char *s;
}
%token SELECT ALL NUMBER STRING FROM SEMICOLON COMMA EQUAL GREATER LESS WHERE NUM_COLUMN STR_COLUMN

%type <i> NUMBER
%type <s> STRING

%type <i> NUM_COLUMN
%type <i> STR_COLUMN

%type <i> column_name
%type <i> operator

/*
%token <valInt> HORA
%token <valFloat> VALOR_TEMPERATURA
%type <valFloat> temperatura medicion lista_temperaturas
*/
%start S
%%

S
	: queries {}

queries
	: query SEMICOLON | query SEMICOLON queries {}

query
	: select {}

select
	: SELECT columns from where 	{ do_select(); }
	| SELECT ALL from where 	{ g.scolumns = 31; do_select();}
	| SELECT columns		{ err("Falta indicar la tabla FROM"); }
	| SELECT ALL			{ err("Falta indicar la tabla FROM"); }
	| SELECT  			{ err("Falta indicar la tabla FROM"); }

where
	:						{ g.cmp = CMP_ALL; }

	| WHERE NUMBER operator NUMBER			{ g.cmp = CMP_NUM_NUM; g.op = $3; g.wnval1 = $2; g.wnval2 = $4;}
	| WHERE NUMBER operator NUM_COLUMN		{ g.cmp = CMP_NUM_COL; g.op = $3; g.wnval1 = $2; g.wcol2  = $4;}
	| WHERE NUMBER operator STRING			{ err("Comparando número con texto"); }
	| WHERE NUMBER operator STR_COLUMN		{ err("Comparando número con columna de texto"); }

	| WHERE NUM_COLUMN operator NUMBER		{ g.cmp = CMP_COL_NUM; g.op = $3; g.wcol1  = $2; g.wnval2 = $4;}
	| WHERE NUM_COLUMN operator NUM_COLUMN		{ g.cmp = CMP_NCOL_NCOL; g.op = $3; g.wcol1  = $2; g.wcol2  = $4;}
	| WHERE NUM_COLUMN operator STRING		{ err("Comparando columna numérica con texto"); }
	| WHERE NUM_COLUMN operator STR_COLUMN		{ err("Comparando columna numérica con columna de texto"); }

	| WHERE STR_COLUMN operator STRING		{ g.cmp = CMP_COL_STR; g.op = $3; g.wcol1  = $2; g.wsval2 = $4;}
	| WHERE STR_COLUMN operator STR_COLUMN		{ g.cmp = CMP_SCOL_SCOL; g.op = $3; g.wcol1  = $2; g.wcol2  = $4;}
	| WHERE STR_COLUMN operator NUMBER		{ err("Comparando columna de texto con número"); }
	| WHERE STR_COLUMN operator NUM_COLUMN		{ err("Comparando columna de texto con columna numérica"); }

	| WHERE STRING operator STR_COLUMN		{ g.cmp = CMP_STR_COL; g.op = $3; g.wsval1 = $2; g.wcol2  = $4;}
	| WHERE STRING operator STRING			{ g.cmp = CMP_STR_STR; g.op = $3; g.wsval1 = $2; g.wsval2 = $4;}
	| WHERE STRING operator NUMBER			{ err("Comparando texto con número"); }
	| WHERE STRING operator NUM_COLUMN		{ err("Comparando texto con columna numérica"); }

column_name
	: STR_COLUMN			{ $$ = $1; }
	| NUM_COLUMN			{ $$ = $1; }

operator
	: EQUAL				{ $$ = 0; }
	| GREATER			{ $$ = 1; }
	| LESS				{ $$ = -1;}

from
	: FROM table {}

table
	: STRING			{ get_table($1); }

columns
	: column_name			{ add_column($1); }
	| column_name COMMA columns	{ add_column($1); }

%%

int read_input(char *file)
{
	int i;
	char buf[MAX_BUF];
	struct emp *e;
	FILE *f;

	f = fopen(file, "r");
	if(f == NULL)
	{
		perror("fopen");
		exit(1);
	}

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

		e->cols[0] = &(e->id);
		e->cols[1] = &(e->nombre);
		e->cols[2] = &(e->apellidos);
		e->cols[3] = &(e->puesto);
		e->cols[4] = &(e->fecha);

		/*
		printf("%d, %s, %s, %s, %s\n", 
			e->id, e->nombre, e->apellidos, e->puesto, e->fecha);
		*/
		
		g.nlines++;
	}

	fclose(f);
}

int main(int argc, char *argv[])
{
	if(argc != 2)
	{
		printf("Indique el fichero que contiene la tabla como argumento.\n");
		exit(1);
	}
	read_input(argv[1]);
	yyparse();
	return 0;
}
//void yyerror (char const *message) { fprintf (stderr, "%s\n", message);}


