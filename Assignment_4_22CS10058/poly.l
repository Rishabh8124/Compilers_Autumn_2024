/*NAME - S.RISHABH*/
/*ROLL NUMBER - 22CS10058*/

%{
    #include "y.tab.h"
    int yylex();
    void yyerror(char * s);
%}

/* V -> terminal to catch x */
/* Declarations */
V                   "x"
PLUS                "+"
MINUS               "-"
EXPONENT            "^"
Z                   "0"
O                   "1"
D                   [2-9]
WHITE_SPACE         [ \t\n]*

%%
{Z}                 { yylval.val = atoi(yytext); return Z; }
{O}                 { yylval.val = atoi(yytext); return O; }
{D}                 { yylval.val = atoi(yytext); return D; }
{V}                 { yylval.symbol = yytext[0]; return V; }
{PLUS}              { yylval.symbol = yytext[0]; return PLUS; }
{MINUS}             { yylval.symbol = yytext[0]; return MINUS; }
{EXPONENT}          { yylval.symbol = yytext[0]; return EXPT; }
{WHITE_SPACE}       { }
.                   { yyerror("Invalid symbol"); }
%%

int yywrap(void) {return 1;}