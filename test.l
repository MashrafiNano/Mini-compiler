%{
#include "test.tab.h"
#include <string.h> 
%}
%%
mytype              { return MYTYPE; }
show                { return SHOW; }
input               {return INPUT;}
if                  {return IF;}
else                {return ELSE;}
symbols             {return SYMBOLS;}
[a-zA-Z_][a-zA-Z0-9_]+ { yylval.str = strdup(yytext); return IDENTIFIER; }
[0-9]+              { yylval.num = atoi(yytext); return NUMBER; }

">="                { return GE; }
"<="                { return LE; }
"=="                { return EQ; }
"!="                { return NE; }
">"                 { return GT; }
"<"                 { return LT; }

"+"                 { return PLUS; }
"-"                 { return MINUS; }
"*"                 { return TIMES; }
"/"    -             { return DIVIDE; }
"="                 { return '='; }
";"                 { return ';'; }
"("                 { return '('; }
")"                 { return ')'; }
[ \t\n]+            { /* Ignore whitespace */ }
.                   { return yytext[0]; }


%%

int yywrap(void) {
    return 1; 
}
