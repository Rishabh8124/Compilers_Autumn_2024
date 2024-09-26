/*NAME - S.RISHABH*/
/*ROLL NUMBER - 22CS10058*/

%{
    #define KEYWORD 1
    #define IDENTIFIER 2
    #define INTEGER_CONSTANT 3
    #define FLOATING_CONSTANT 4
    #define CHARACTER_CONSTANT 5
    #define STRING_LITERAL 6
    #define PUNCTUATOR 7
    #define MULTI_LINE_COMMENT 8
    #define SINGLE_LINE_COMMENT 9
    #define GARBAGE 10
    #define SPACE 11
    
%}

/*REGULAR DEFINITIONS*/ 

/* REGEX FOR MULTI LINE COMMENT */
/*     <--[^\*\/]--             */
/*  -> S ---*---> A --/--> E    */
/*    |_^        |_^            */
/*   [^\*]        *             */
MULTI_LINE_COMMENT \/\*[^\*]*(\*+[^\*\/][^\*]*)*[\*]+\/
SINGLE_LINE_COMMENT \/\/.*\n

/*keywords*/
KEYWORD "auto"|"enum"|"restrict"|"unsigned"|"break"|"extern"|"return"|"void"|"case"|"float"|"short"|"volatile"|"char"|"for"|"signed"|"while"|"const"|"goto"|"sizeof"|"_Bool"|"continue"|"if"|"static"|"_Complex"|"default"|"inline"|"struct"|"_Imaginary"|"do"|"int"|"switch"|"double"|"long"|"typedef"|"else"|"register"|"union"

/*identifiers*/

digit [0-9]
identifier_nondigit [_a-zA-Z]

IDENTIFIER {identifier_nondigit}({digit}|{identifier_nondigit})*

/*constants*/
sign [+-]
escape_sequence "\\\'"|"\\\""|"\\\?"|"\\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"
c_char [^\'\\\n]|{escape_sequence}
c_char_sequence {c_char}+
digit_sequence {digit}*|\'{c_char_sequence}\'
exponent_part [eE]{sign}?{digit_sequence}
fractional_constant ({digit_sequence}\.)|({digit_sequence}?\.{digit_sequence})

INTEGER_CONSTANT [1-9]{digit}*|0
FLOATING_CONSTANT {fractional_constant}{exponent_part}?|{digit_sequence}{exponent_part}
CHARACTER_CONSTANT \'{c_char_sequence}\'

/*string literals*/
s_char [^\'\\\n]|{escape_sequence}
s_char_sequence {s_char}+
STRING_LITERAL \"{s_char_sequence}?\"

PUNCTUATOR "<"|">"|"\\"|"\["|"\]"|"\("|"\)"|"\{"|"\}"|"."|"\->"|"\+\+"|"\-\-"|"&"|"\*"|"\+"|"\-"|"~"|"!"|"\/"|"%"|"<<"|">>"|"<="|">="|"=="|"!="|"\^"|"\|"|"&&"|"\|\|"|"\?"|":"|";"|"..."|"="|"\*="|"\/="|"%="|"\+="|"\-="|"<<="|">>="|"&="|"\^="|"\|="|","|"#"
WHITE_SPACE [ \n\t]

%%
{MULTI_LINE_COMMENT}    {return MULTI_LINE_COMMENT;}
{SINGLE_LINE_COMMENT}   {return SINGLE_LINE_COMMENT;}

{KEYWORD}               {return KEYWORD;}
{IDENTIFIER}            {return IDENTIFIER;}
{STRING_LITERAL}        {return STRING_LITERAL;}
{PUNCTUATOR}            {return PUNCTUATOR;}

{INTEGER_CONSTANT}      {return INTEGER_CONSTANT;}
{FLOATING_CONSTANT}     {return FLOATING_CONSTANT;}
{CHARACTER_CONSTANT}    {return CHARACTER_CONSTANT;}

{WHITE_SPACE}           { }
.                       {return GARBAGE;}
%%

int yywrap(void) {return 1;}