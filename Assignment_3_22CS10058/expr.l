/*NAME - S.RISHABH*/
/*ROLL NUMBER - 22CS10058*/

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
%}

NUMBER              [+-]?[1-9][0-9]*|0
IDENTIFIER          [_a-zA-Z][_a-zA-Z0-9]*
SET                 "set"
EXPT                "**"
WHITE_SPACE         [ \t\n]*

%%
{NUMBER}                        {yylval.num = atoi(yytext); return NUM;}
{SET}                           {return SET;}
{EXPT}                          {yylval.op = strdup(yytext); return EXPT;}
"+"                             {yylval.op = strdup(yytext); return PLUS;}
"-"                             {yylval.op = strdup(yytext); return SUB;}
"*"                             {yylval.op = strdup(yytext); return MUL;}
"/"                             {yylval.op = strdup(yytext); return DIV;}
"%"                             {yylval.op = strdup(yytext); return REM;}
"("                             {yylval.op = strdup(yytext); return LP;}
")"                             {yylval.op = strdup(yytext); return RP;}
{IDENTIFIER}                    {yylval.id = strdup(yytext); return ID;}

{WHITE_SPACE}                   { }

.                               {yyerror("Invalid character found\n");}
%%

int yywrap(void) {return 1;}

void yyerror(char * s) {
    printf("\nError: %s\n", s);

    exit(0);
    return;
}