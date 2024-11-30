%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
    int yylex();
    void yyerror(string s);
    extern int yylineno;
%}

%option yylineno

/*REGULAR DEFINITIONS*/
/* REGEX FOR MULTI LINE COMMENT */
/*     <--[^\*\/]--             */
/*  -> S ---*---> A --/--> E    */
/*    |_^        |_^            */
/*   [^\*]        *             */

MULTI_LINE_COMMENT      \/\*[^\*]*(\*+[^\*\/][^\*]*)*[\*]+\/
SINGLE_LINE_COMMENT     \/\/.*(\n)?

/*keywords*/
AUTO                    "auto"
RESTRICT                "restrict"
UNSIGNED                "unsigned"
BREAK                   "break"
EXTERN                  "extern"
RETURN                  "return"
VOID                    "void"
CASE                    "case"
FLOAT                   "float"
SHORT                   "short"
VOLATILE                "volatile"
CHAR                    "char"
FOR                     "for"
SIGNED                  "signed"
WHILE                   "while"
CONST                   "const"
GOTO                    "goto"
SIZEOF                  "sizeof"
BOOL                    "_Bool"
CONTINUE                "continue"
IF                      "if"
STATIC                  "static"
COMPLEX                 "_Complex"
DEFAULT                 "default"
INLINE                  "inline"
IMAGINARY               "_Imaginary"
DO                      "do"
INT                     "int"
SWITCH                  "switch"
DOUBLE                  "double"
LONG                    "long"
ELSE                    "else"
REGISTER                "register"

/*identifiers*/
digit                   [0-9]
identifier_nondigit     [_a-zA-Z]

IDENTIFIER              {identifier_nondigit}({digit}|{identifier_nondigit})*

/*constants*/
sign                    [+-]
escape_sequence         "\\\'"|"\\\""|"\\\?"|"\\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"
c_char                  [^\'\\\n]|{escape_sequence}
c_char_sequence         {c_char}+
digit_sequence          {digit}*
exponent_part           [eE]{sign}?{digit_sequence}
fractional_constant     ({digit_sequence}\.)|({digit_sequence}?\.{digit_sequence})

INTEGER_CONSTANT        [1-9]{digit}*|0
FLOATING_CONSTANT       {fractional_constant}{exponent_part}?|{digit_sequence}{exponent_part}
CHARACTER_CONSTANT      \'{c_char_sequence}\'

/*string literals*/
s_char                  [^\'\\\n]|{escape_sequence}
s_char_sequence         {s_char}+
STRING_LITERAL          \"{s_char_sequence}?\"

/*punctuators*/
LESS_THAN               "<"
LESS_THAN_EQUAL_TO      "<="
GREATER_THAN            ">"
GREATER_THAN_EQUAL_TO   ">="
LEFT_SQUARE_BRACKET     "["
RIGHT_SQUARE_BRACKET    "]"
LEFT_PARANTHESIS        "("
RIGHT_PARANTHESIS       ")"
LEFT_CURLY_BRACKET      "{"
RIGHT_CURLY_BRACKET     "}"
DOT                     "."
POINTER_ACCESS          "->"
INCREMENT_OPERATOR      "++"
DECREMENT_OPERATOR      "--"
DIVIDE_OPERATOR         "/"
REMAINDER_OPERATOR      "%"
SHIFT_LEFT_OPERATOR     "<<"
SHIFT_RIGHT_OPERATOR    ">>"
EQUALITY_OPERATOR       "=="
NON_EQUALITY_OPERATOR   "!="
XOR_OPERATOR            "^"
BITWISE_OR_OPERATOR     "|"
BITWISE_AND_OPERATOR    "&"
LOGICAL_AND_OPERATOR    "&&"
LOGICAL_OR_OPERATOR     "||"
TERNARY_OPERATOR        "?"
TERNARY_SEPERATOR       ":"
SEMI_COLON              ";"
COMMA                   ","
TRIPLE_DOT              "..."

WHITE_SPACE [ \n\t]

EQUAL_OPERATOR          "="
ASSIGNMENT_OPERATORS    "*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="

ADDITION_OPERATOR       "+"
MULTIPLICATION_OPERATOR "*"
SUBTRACTION_OPERATOR    "-"
NOT_OPERATOR            "!"
NEGATION_OPERATOR       "~"

%%
{MULTI_LINE_COMMENT}        { }
{SINGLE_LINE_COMMENT}       { }

{AUTO}                      { return AUTO;}
{RESTRICT}                  { return RESTRICT;}  
{UNSIGNED}                  { return UNSIGNED; }
{BREAK}                     { return BREAK; }
{EXTERN}                    { return EXTERN; }
{RETURN}                    { return RETURN;}  
{VOID}                      { return VOID; }
{CASE}                      { return CASE; }
{FLOAT}                     { return FLOAT; }
{SHORT}                     { return SHORT; }
{VOLATILE}                  { return VOLATILE; }
{CHAR}                      { return CHAR; }
{FOR}                       { return FOR; }
{SIGNED}                    { return SIGNED; }
{WHILE}                     { return WHILE; }
{CONST}                     { return CONST; }
{GOTO}                      { return GOTO; }
{SIZEOF}                    { return SIZEOF; }
{BOOL}                      { return BOOL; }
{CONTINUE}                  { return CONTINUE; }
{IF}                        { return IF; }
{STATIC}                    { return STATIC; }
{COMPLEX}                   { return COMPLEX; }
{DEFAULT}                   { return DEFAULT; }
{INLINE}                    { return INLINE; }
{IMAGINARY}                 { return IMAGINARY; }
{DO}                        { return DO; }
{INT}                       { return INT; }
{SWITCH}                    { return SWITCH; }
{DOUBLE}                    { return DOUBLE; }
{LONG}                      { return LONG; }
{ELSE}                      { return ELSE; }
{REGISTER}                  { return REGISTER; }

{IDENTIFIER}                {yylval.val = strdup(yytext); return IDENTIFIER;}
{STRING_LITERAL}            {yylval.val = strdup(yytext); return STRING_LITERAL;}

{LESS_THAN}                 { return LESS_THAN; }
{LESS_THAN_EQUAL_TO}        { return LESS_THAN_EQUAL_TO; }
{GREATER_THAN}              { return GREATER_THAN; }
{GREATER_THAN_EQUAL_TO}     { return GREATER_THAN_EQUAL_TO; }
{LEFT_SQUARE_BRACKET}       { return LEFT_SQUARE_BRACKET; }
{RIGHT_SQUARE_BRACKET}      { return RIGHT_SQUARE_BRACKET; }
{LEFT_PARANTHESIS}          { return LEFT_PARANTHESIS; }
{RIGHT_PARANTHESIS}         { return RIGHT_PARANTHESIS; }
{LEFT_CURLY_BRACKET}        { return LEFT_CURLY_BRACKET; }
{RIGHT_CURLY_BRACKET}       { return RIGHT_CURLY_BRACKET; }

{DOT}                       { return DOT; }

{INTEGER_CONSTANT}          {yylval.val = strdup(yytext); return INTEGER_CONSTANT;}
{FLOATING_CONSTANT}         {yylval.val = strdup(yytext); return FLOATING_CONSTANT;}
{CHARACTER_CONSTANT}        {yylval.val = strdup(yytext); return CHARACTER_CONSTANT;}

{POINTER_ACCESS}            { return POINTER_ACCESS; }
{INCREMENT_OPERATOR}        { return INCREMENT_OPERATOR; }
{DECREMENT_OPERATOR}        { return DECREMENT_OPERATOR; }
{DIVIDE_OPERATOR}           { return DIVIDE_OPERATOR; }
{REMAINDER_OPERATOR}        { return REMAINDER_OPERATOR; }
{SHIFT_LEFT_OPERATOR}       { return SHIFT_LEFT_OPERATOR; }
{SHIFT_RIGHT_OPERATOR}      { return SHIFT_RIGHT_OPERATOR; }
{EQUALITY_OPERATOR}         { return EQUALITY_OPERATOR; }
{NON_EQUALITY_OPERATOR}     { return NON_EQUALITY_OPERATOR; }
{XOR_OPERATOR}              { return XOR_OPERATOR; }
{BITWISE_OR_OPERATOR}       { return BITWISE_OR_OPERATOR; }
{BITWISE_AND_OPERATOR}      { return BITWISE_AND_OPERATOR; }
{LOGICAL_AND_OPERATOR}      { return LOGICAL_AND_OPERATOR; }
{LOGICAL_OR_OPERATOR}       { return LOGICAL_OR_OPERATOR; }
{TERNARY_OPERATOR}          { return TERNARY_OPERATOR; }
{TERNARY_SEPERATOR}         { return TERNARY_SEPERATOR; }
{SEMI_COLON}                { return SEMI_COLON; }
{COMMA}                     { return COMMA; }
{TRIPLE_DOT}                { return TRIPLE_DOT; }
{ADDITION_OPERATOR}         { return ADDITION_OPERATOR; }
{MULTIPLICATION_OPERATOR}   { return MULTIPLICATION_OPERATOR; }
{SUBTRACTION_OPERATOR}      { return SUBTRACTION_OPERATOR; }
{NOT_OPERATOR}              { return NOT_OPERATOR; }     
{NEGATION_OPERATOR}         { return NEGATION_OPERATOR; }  
{EQUAL_OPERATOR}            { return EQUAL_OPERATOR; }

{ASSIGNMENT_OPERATORS}      {yylval.val = strdup(yytext); return ASSIGNMENT_OPERATORS;}

{WHITE_SPACE}               { }
.                           {yyerror("Invalid character found\n");}
%%

int yywrap(void) {return 1;}