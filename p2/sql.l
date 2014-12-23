%option noyywrap nodefault yylineno case-insensitive

%{

#include <stdlib.h>
#include "sql.tab.h"

void yyerror(char *s, ...);
void emit(char *s, ...);

%}


%%

"SELECT"		{ return SELECT; }
"WHERE"			{ return WHERE; }
"FROM"			{ return FROM; }

"*"			{ return ALL; }
";"			{ return SEMICOLON; }
","			{ return COMMA; }
"="			{ return EQUAL; }
">"			{ return GREATER; }
"<"			{ return LESS; }

[a-zA-Z][a-zA-Z0-9]*	{ yylval.s = strdup(yytext); return STRING; }
[0-9]*			{ yylval.i = atoi(yytext); return NUMBER; }

[ \t\n] ;
. yyerror("Strange char %s", yytext);

%%
