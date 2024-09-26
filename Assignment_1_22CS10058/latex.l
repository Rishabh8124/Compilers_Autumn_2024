/*NAME - S.RISHABH*/
/*ROLL NUMBER - 22CS10058*/

%{
    #define EMPTY 1                 /*Unncessary tokens*/
    #define COMMENT 2               /*Comment line*/
    #define COMMAND 3               /*Command token*/
    #define ENV 4                   /*Environmental condition*/
    #define STRING 5                /*Alphabetical string*/
    #define DISPLAY_MATH 6          /*Display Equations*/
    #define MATH 7                  /*Math Equations*/
%}

/*REGULAR DEFINITIONS*/ 

/*Default regex*/
WORD [a-zA-Z]+
GARBAGE [^a-zA-Z]
SPACE [ \t\n]*

/*Command structures*/
SS ~
COMMAND_1 \\{WORD}
COMMAND_2 \\.

/*Equation structures*/
MATH_0 \$
MATH_1 \$\$
MATH_2_START \\\[
MATH_2_END \\\]

/*Comment structure*/
COMMENT_REGEX %.*\n

/*Environment structures*/
BEGIN_ENV \\begin
END_ENV \\end

%%
{BEGIN_ENV}     {return ENV;}
{END_ENV}       {return EMPTY;}

{MATH_0}        {return MATH;}
{MATH_1}        {return DISPLAY_MATH;}
{MATH_2_START}  {return DISPLAY_MATH;}
{MATH_2_END}    {return DISPLAY_MATH;}

{SS}            {return COMMAND;}
{COMMAND_1}     {return COMMAND;}
{COMMAND_2}     {return COMMAND;}

{COMMENT_REGEX} {return COMMENT;}

{WORD}          {return STRING;}

{SPACE}         {return EMPTY;}
{GARBAGE}       {return EMPTY;}
%%

int yywrap(void) {return 1;}