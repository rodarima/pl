%{
#include <stdlib.h>
#include <bsd/string.h>

#define MAXLINE	512

struct sg
{
	char titulo[MAXLINE];
	char curso[MAXLINE];
	char *errores;
	char *suspensos;
	char *aprobados;
	char nombre[MAXLINE];
	char nota[MAXLINE];
	char nif[MAXLINE];
	char tmpstr[MAXLINE];
	int yyline;
} g;

void init_global();
void line_error(char *str);
void line_ok(char *nif, char *name, char *mark);
void add_line(char *str, char **lines);

%}
%option yylineno

%x START
%x P1_TITULO
%x P1_CURSO_SEP
%x P1_CURSO
%x P1_COMPLETA
%x P1_IGNORE

%x P2_SEPARADOR
%x P2_COMPLETA
%x P2_IGNORE

%x P3_NIF
%x P3_NIF_COMPLETO
%x P3_NOMBRE
%x P3_NOMBRE_COMPLETO
%x P3_NOTA
%x P3_IGNORE

digit		[0-9]
text		[^ \t\n]+
space		[ ]
tab		[\t]
new		[\n]
all		[.*]
NAME		{text}{space}{text},{space}{text}
MARK		([0-9]\.[0-9]{1,2}|10\.0{1,2})
LINE		{NIF}[\t]{NAME}[\t]{MARK}
CABECERA_S	[^-]+
CABECERA_C	"- Curso "
CABECERA_Y	{digit}{4}"/"{digit}{4}
CABECERA2	"NIF\tApellido1 Apellido2, Nombre\tNota"
CABECERA	{CABECERA1}"\n"{CABECERA2}

TITULO		[^-\n]+
CURSO_SEP	"- Curso "
CURSO		{digit}{4}"/"{digit}{4}

SEPARADOR	"NIF\tApellido1 Apellido2, Nombre\tNota"

TABULADOR	\t
NIF		{digit}{8}-[A-Z]
NOMBRE		{text}{space}{text},{space}{text}
NOTA		([0-9]\.[0-9]{1,2}|10\.0{1,2})

%%

	BEGIN(START);

 /* ====================== Cabecera ===================== */

<START>{TITULO} {
	//printf(" · TITULO = %s\n", yytext);
	strlcpy(g.titulo, yytext, MAXLINE);
	BEGIN(P1_TITULO);
}

<P1_TITULO>{CURSO_SEP} {
	//printf(" · CURSO_SEP\n");
	BEGIN(P1_CURSO_SEP);
}

<P1_CURSO_SEP>{CURSO} {
	//printf(" · CURSO = %s\n", yytext);
	strlcpy(g.curso, yytext, MAXLINE);
	BEGIN(P1_CURSO);
}

<P1_CURSO>\n {
	//printf(" · CABECERA COMPLETA!\n");
	BEGIN(P1_COMPLETA);
	g.yyline++;
}

<START,P1_TITULO,P1_CURSO_SEP,P1_CURSO>. {
	line_error("No se ha reconocido la cabecera");
	//printf("CABECERA INCORRECTA (%s)\n", yytext);
	BEGIN(P1_IGNORE);
}

<START,P1_TITULO,P1_CURSO_SEP,P1_CURSO>\n {
	line_error("No se ha reconocido la cabecera");
	//printf("CABECERA INCORRECTA (%s)\n", yytext);
	BEGIN(START);
	g.yyline++;
}

<P1_IGNORE>.*\n {
	//printf("Ignorando (%s)\n", yytext);
	BEGIN(START);
	g.yyline++;
}

 /* ==================== Fin cabecera =================== */

 /* ===================== Separador ===================== */

<P1_COMPLETA>{SEPARADOR} {
	BEGIN(P2_SEPARADOR);
}

<P2_SEPARADOR>\n {
	//printf(" · SEPARADOR COMPLETO!\n");
	BEGIN(P2_COMPLETA);
	g.yyline++;
}

<P2_SEPARADOR>. {
	line_error("No se ha reconocido la cabecera de la tabla");
	//printf(" · SEPARADOR COMPLETO!\n");
	BEGIN(P2_IGNORE);
}

<P1_COMPLETA>. {
	line_error("No se ha reconocido la cabecera de la tabla");
	//printf("CABECERA INCORRECTA (%s)\n", yytext);
	BEGIN(P2_IGNORE);
}

<P1_COMPLETA>\n {
	line_error("No se ha reconocido la cabecera de la tabla");
	//printf("CABECERA INCORRECTA (%s)\n", yytext);
	g.yyline++;
}

<P2_IGNORE>.*\n {
	//printf("Ignorando (%s)\n", yytext);
	BEGIN(P1_COMPLETA);
	g.yyline++;
}

 /* ==================== Fin Separador =================== */

 /* ===================== Notas ===================== */

 /* NIF */

<P2_COMPLETA>{NIF} {
	strlcpy(g.nif, yytext, MAXLINE);
	BEGIN(P3_NIF);
}

<P2_COMPLETA>. {
	line_error("NIF incorrecto");
	BEGIN(P3_IGNORE);
}

<P2_COMPLETA>\n {
	line_error("Línea vacía");
	BEGIN(P2_COMPLETA);
	g.yyline++;
}

 /* SEPARADOR */

<P3_NIF>{TABULADOR} {
	BEGIN(P3_NIF_COMPLETO);
}

<P3_NIF>. {
	line_error("Se esperaba tabulador después del NIF");
	BEGIN(P3_IGNORE);
}

<P3_NIF>\n {
	line_error("Falta el nombre y la nota");
	BEGIN(P2_COMPLETA);
	g.yyline++;
}

 /* NOMBRE */

<P3_NIF_COMPLETO>{NOMBRE} {
	strlcpy(g.nombre, yytext, MAXLINE);
	BEGIN(P3_NOMBRE);
}

<P3_NIF_COMPLETO>. {
	line_error("Nombre incorrecto");
	BEGIN(P3_IGNORE);
}

<P3_NIF_COMPLETO>\n {
	line_error("Falta el nombre y la nota");
	BEGIN(P2_COMPLETA);
	g.yyline++;
}

 /* SEPARADOR */

<P3_NOMBRE>{TABULADOR} {
	BEGIN(P3_NOMBRE_COMPLETO);
}

<P3_NOMBRE>. {
	line_error("Se esperaba tabulador después del nombre");
	BEGIN(P3_IGNORE);
}

<P3_NOMBRE>\n {
	line_error("Falta la nota");
	BEGIN(P2_COMPLETA);
	g.yyline++;
}

 /* NOTA */

<P3_NOMBRE_COMPLETO>{NOTA} {
	strlcpy(g.nota, yytext, MAXLINE);
	BEGIN(P3_NOTA);
}

<P3_NOMBRE_COMPLETO>. {
	line_error("Nota incorrecta");
	BEGIN(P3_IGNORE);
}

<P3_NOMBRE_COMPLETO>\n {
	line_error("Falta la nota");
	BEGIN(P2_COMPLETA);
	g.yyline++;
}

 /* FIN DE LINEA */

<P3_NOTA>\n {
	line_ok(g.nif, g.nombre, g.nota);
	BEGIN(P2_COMPLETA);
	g.yyline++;
}

<P3_NOTA>. {
	line_error("Nota incorrecta");
	BEGIN(P3_IGNORE);
}

<P3_IGNORE>.*\n {
	BEGIN(P2_COMPLETA);
	g.yyline++;
}

 /* ===================== Fin Notas ===================== */

<*>. {
	//printf("¿¿¿¿%c????", yytext[0]);
}


<*>\n {
	//printf("¿¿¿¿%c????", yytext[0]);
	g.yyline++;
}

%%

void init_global()
{
	g.errores = NULL;
	g.yyline = 1;
	add_line("- Errores:\n", &(g.errores));
	add_line("- Alumnos aprobados:\n", &(g.aprobados));
	add_line("- Alumnos suspensos:\n", &(g.suspensos));
}

void line_error(char *str)
{
	sprintf(g.tmpstr, "Línea %d: %s\n", g.yyline, str);
	add_line(g.tmpstr, &(g.errores));
}

void line_ok(char *nif, char *name, char *mark)
{
	double nota = atof(mark);
	if(nota >= 5.0)
	{
		sprintf(g.tmpstr, "%s;%s;%s\n", nif, name, mark);
		add_line(g.tmpstr, &(g.aprobados));
	}
	else
	{
		sprintf(g.tmpstr, "%s;%s\n", nif, name);
		add_line(g.tmpstr, &(g.suspensos));
	}
}

void add_line(char *str, char **lines)
{
	int len = strlen(str);
	int buflen = (*lines) ? strlen(*lines) : 0;
	(*lines) = realloc((*lines), buflen + len + 1);
	strlcpy((*lines) + buflen, str, len + 1);
}

int main(int argc, char *argv[])
{
	init_global();
	yylex();
	printf("- Asignatura: %s\n", g.titulo);
	printf("- Curso: %s\n", g.curso);
	printf("%s%s%s", g.suspensos, g.aprobados, g.errores);
	free(g.errores);
	free(g.aprobados);
	free(g.suspensos);
	return 0;
}
