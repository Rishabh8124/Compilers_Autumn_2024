/*NAME - S.RISHABH*/
/*ROLL NUMBER - 22CS10058*/

%{
    #include "y.tab.h"
%}

%option yylineno

NUMBER              [+-]?(0|[1-9][0-9]*)
IDENTIFIER          [_a-zA-Z][_a-zA-Z0-9]*
SET                 "set"
EXPT                "**"
WHITE_SPACE         [ \t\n]*

%%
{NUMBER}                        { yylval.num = atoi(yytext); return NUM; }
{SET}                           { return SET; }
{EXPT}                          { yylval.op = '^'; return EXPT; }
"+"                             { yylval.op = yytext[0]; return PLUS; }
"-"                             { yylval.op = yytext[0]; return SUB; }
"*"                             { yylval.op = yytext[0]; return MUL; }
"/"                             { yylval.op = yytext[0]; return DIV; }
"%"                             { yylval.op = yytext[0]; return REM; }
"("|")"                         { return yytext[0]; }
{IDENTIFIER}                    { yylval.id = strdup(yytext); return ID; }
{WHITE_SPACE}                   { }
%%

int yywrap(void) {return 1;}