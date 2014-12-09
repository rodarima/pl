%option noyywrap nodefault yylineno case-insensitive

%{

#include <stdlib.h>
#include "sql.tab.h"

void yyerror(char *s, ...);
void emit(char *s, ...);

%}


%%

"SELECT" { return SELECT; }
"*" { return ALL; }
"FROM" { return FROM; }
[a-zA-Z][a-zA-Z0-9]* { yylval.s = strdup(yytext); return NAME; }
[0-9]* { yylval.i = atoi(yytext); return NUMBER; }
";" {return SEMICOLON;}
"," {return COMMA;}

[ \t\n] ;
. yyerror("Strange char %s", yytext);

%%
