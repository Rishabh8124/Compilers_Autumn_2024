/*NAME - S.RISHABH*/
/*ROLL NUMBER - 22CS10058*/

%{
    #include "y.tab.h"
%}

%option yylineno

NUMBER              0|[+-]?[1-9][0-9]*
IDENTIFIER          [_a-zA-Z][_a-zA-Z0-9]*
SET                 "set"
WHEN                "when"
LOOP_TERM           "loop"
WHILE               "while"
RELN                "<"|">"|"="|">="|"<="|"/="
OPER                "+"|"-"|"*"|"/"|"%"
LP                  "("
RP                  ")"
WHITE_SPACE         [ \t\n]*

%%
{NUMBER}                        { yylval.num = atoi(yytext); return NUM; }
{SET}                           { return SET; }
{WHEN}                          { return WHEN; }
{LOOP_TERM}                     { return LOOP_TERM; }
{WHILE}                         { return WHILE; }
{RELN}                          { yylval.op = strdup(yytext); return RELN; }
{OPER}                          { yylval.op = strdup(yytext); return OPER; }
{LP}                            { return LP; }
{RP}                            { return RP; }
{IDENTIFIER}                    { yylval.id = strdup(yytext); return IDEN; }
{WHITE_SPACE}                   { }
%%

int yywrap(void) {return 1;}