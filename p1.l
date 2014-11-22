%{
#include <stdlib.h>

%}
%option yylineno

%x START
%x P1_TITULO
%x P1_CURSO_SEP
%x P1_CURSO
%x P1_LINEA
%x IGNORE

digit		[0-9]
text		[^ \t\n]+
space		[ ]
tab		[\t]
new		[\n]
all		[.*]
NIF		{digit}{8}-[A-Z]
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

%%

	BEGIN(START);

<START>{TITULO} {
	printf(" TITULO = %s\n", yytext);
	BEGIN(P1_TITULO);
}

<P1_TITULO>{CURSO_SEP} {
	printf(" CURSO_SEP\n");
	BEGIN(P1_CURSO_SEP);
}

<P1_CURSO_SEP>{CURSO} {
	printf(" CURSO = %s\n", yytext);
	BEGIN(P1_CURSO);
}
<P1_CURSO>\n {
	BEGIN(P1_LINEA);
}

<START,P1_TITULO,P1_CURSO_SEP,P1_CURSO>. {
	printf("CABECERA INCORRECTA (%s)\n", yytext);
	BEGIN(IGNORE);
}

<IGNORE>.*\n { BEGIN(START); }

<*>.|\n {
	printf("¿%c?", yytext[0]);
}

%%
