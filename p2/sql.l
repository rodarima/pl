%option noyywrap nodefault yylineno case-insensitive

%{

#include <stdlib.h>
#include "sql.tab.h"

void yyerror(char *s, ...);
void emit(char *s, ...);

%}

%s START
%x STR_IN


%%

BEGIN(START);

"SELECT"		{ return SELECT; }
"WHERE"			{ return WHERE; }
"FROM"			{ return FROM; }

"*"			{ return ALL; }
";"			{ return SEMICOLON; }
","			{ return COMMA; }
"="			{ return EQUAL; }
">"			{ return GREATER; }
"<"			{ return LESS; }
\"			{ BEGIN(STR_IN);}
<STR_IN>[^\"]+		{ yylval.s = strdup(yytext); return STRING; }
<STR_IN>"\""		{ BEGIN(START);}

"idEmpleado"		{ yylval.i = 0; return NUM_COLUMN; }
"nombre"		{ yylval.i = 1; return STR_COLUMN; }
"apellidos"		{ yylval.i = 2; return STR_COLUMN; }
"puesto"		{ yylval.i = 3; return STR_COLUMN; }
"anho"			{ yylval.i = 4; return STR_COLUMN; }

[0-9]*			{ yylval.i = atoi(yytext); return NUMBER; }
[a-zA-Z0-9]* 		{ yylval.s = strdup(yytext); return STRING; }

[ \t\n] ;
. yyerror("Carácter no reconocido %s", yytext);

%%
