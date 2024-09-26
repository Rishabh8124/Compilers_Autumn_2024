/*NAME - S.RISHABH*/
/*ROLL NUMBER - 22CS10058*/

%{
    #define SPACE 10
    #define EXPR_START 1
    #define EXPR 2
    #define OP 3
    #define ARG 4
    #define EXPR_END 5

    #define ID 6         
    #define NUM 7

    #define OPER1 8
    #define GARBAGE 9
%}

/*REGULAR DEFINITIONS*/ 
ID [_a-zA-Z][_a-zA-Z0-9]*
WHITE_SPACE [ \t\n]
OPEN_PARAN \(
END_PARAN \)
INTEGER [+-]?[0-9]+
VALID_OPER [+\-*/%]

BITWISE_AND &
LOGICAL_AND &&
BITWISE_OR \|
LOGICAL_OR \|\|
BITWISE_XOR \^
RELOP [<>=]+

INVALID_OPER ({BITWISE_AND}|{BITWISE_OR}|{BITWISE_XOR}|{LOGICAL_AND}|{LOGICAL_OR}|{RELOP})

%%
{WHITE_SPACE}   {return SPACE;}
{INTEGER}       {return NUM;}
{VALID_OPER}    {return OP;}
{OPEN_PARAN}    {return EXPR_START;}
{END_PARAN}     {return EXPR_END;}
{ID}            {return ID;}
{INVALID_OPER}  {return OPER1;}
.               {return GARBAGE;}

%%

int yywrap(void) {return 1;}