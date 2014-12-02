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

[ \t\n] ;
. yyerror("Strange char %s", yytext);

%%
