%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
    int yylex();
    void yyerror(char * s);
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
ENUM                    "enum"
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
STRUCT                  "struct"
IMAGINARY               "_Imaginary"
DO                      "do"
INT                     "int"
SWITCH                  "switch"
DOUBLE                  "double"
LONG                    "long"
TYPEDEF                 "typedef"
ELSE                    "else"
REGISTER                "register"
UNION                   "union"

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
ESCAPE_OPERATOR         "\\"
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
MACRO_OPERATOR          "#"
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

{AUTO}                      {yylval.val = strdup(yytext); return AUTO;} 
{ENUM}                      {yylval.val = strdup(yytext); return ENUM;}
{RESTRICT}                  {yylval.val = strdup(yytext); return RESTRICT;} 
{UNSIGNED}                  {yylval.val = strdup(yytext); return UNSIGNED;}
{BREAK}                     {yylval.val = strdup(yytext); return BREAK;}
{EXTERN}                    {yylval.val = strdup(yytext); return EXTERN;}
{RETURN}                    {yylval.val = strdup(yytext); return RETURN;} 
{VOID}                      {yylval.val = strdup(yytext); return VOID;}
{CASE}                      {yylval.val = strdup(yytext); return CASE;}
{FLOAT}                     {yylval.val = strdup(yytext); return FLOAT;}
{SHORT}                     {yylval.val = strdup(yytext); return SHORT;}
{VOLATILE}                  {yylval.val = strdup(yytext); return VOLATILE;}
{CHAR}                      {yylval.val = strdup(yytext); return CHAR;}
{FOR}                       {yylval.val = strdup(yytext); return FOR;}
{SIGNED}                    {yylval.val = strdup(yytext); return SIGNED;}
{WHILE}                     {yylval.val = strdup(yytext); return WHILE;}
{CONST}                     {yylval.val = strdup(yytext); return CONST;}
{GOTO}                      {yylval.val = strdup(yytext); return GOTO;}
{SIZEOF}                    {yylval.val = strdup(yytext); return SIZEOF;}
{BOOL}                      {yylval.val = strdup(yytext); return BOOL;}
{CONTINUE}                  {yylval.val = strdup(yytext); return CONTINUE;}
{IF}                        {yylval.val = strdup(yytext); return IF;}
{STATIC}                    {yylval.val = strdup(yytext); return STATIC;}
{COMPLEX}                   {yylval.val = strdup(yytext); return COMPLEX;}
{DEFAULT}                   {yylval.val = strdup(yytext); return DEFAULT;}
{INLINE}                    {yylval.val = strdup(yytext); return INLINE;}
{STRUCT}                    {yylval.val = strdup(yytext); return STRUCT;}
{IMAGINARY}                 {yylval.val = strdup(yytext); return IMAGINARY;}
{DO}                        {yylval.val = strdup(yytext); return DO;}
{INT}                       {yylval.val = strdup(yytext); return INT;}
{SWITCH}                    {yylval.val = strdup(yytext); return SWITCH;}
{DOUBLE}                    {yylval.val = strdup(yytext); return DOUBLE;}
{LONG}                      {yylval.val = strdup(yytext); return LONG;}
{TYPEDEF}                   {yylval.val = strdup(yytext); return TYPEDEF;}
{ELSE}                      {yylval.val = strdup(yytext); return ELSE;}
{REGISTER}                  {yylval.val = strdup(yytext); return REGISTER;}
{UNION}                     {yylval.val = strdup(yytext); return UNION;}

{IDENTIFIER}                {yylval.val = strdup(yytext); return IDENTIFIER;}
{STRING_LITERAL}            {yylval.val = strdup(yytext); return STRING_LITERAL;}
{LESS_THAN}                 {yylval.val = strdup(yytext); return LESS_THAN;}
{LESS_THAN_EQUAL_TO}        {yylval.val = strdup(yytext); return LESS_THAN_EQUAL_TO;}
{GREATER_THAN}              {yylval.val = strdup(yytext); return GREATER_THAN;}
{GREATER_THAN_EQUAL_TO}     {yylval.val = strdup(yytext); return GREATER_THAN_EQUAL_TO;}
{ESCAPE_OPERATOR}           {yylval.val = strdup(yytext); return ESCAPE_OPERATOR;}
{LEFT_SQUARE_BRACKET}       {yylval.val = strdup(yytext); return LEFT_SQUARE_BRACKET;}
{RIGHT_SQUARE_BRACKET}      {yylval.val = strdup(yytext); return RIGHT_SQUARE_BRACKET;}
{LEFT_PARANTHESIS}          {yylval.val = strdup(yytext); return LEFT_PARANTHESIS;}
{RIGHT_PARANTHESIS}         {yylval.val = strdup(yytext); return RIGHT_PARANTHESIS;}
{LEFT_CURLY_BRACKET}        {yylval.val = strdup(yytext); return LEFT_CURLY_BRACKET;}
{RIGHT_CURLY_BRACKET}       {yylval.val = strdup(yytext); return RIGHT_CURLY_BRACKET;}
{DOT}                       {yylval.val = strdup(yytext); return DOT;}
{POINTER_ACCESS}            {yylval.val = strdup(yytext); return POINTER_ACCESS;}
{INCREMENT_OPERATOR}        {yylval.val = strdup(yytext); return INCREMENT_OPERATOR;}
{DECREMENT_OPERATOR}        {yylval.val = strdup(yytext); return DECREMENT_OPERATOR;}
{DIVIDE_OPERATOR}           {yylval.val = strdup(yytext); return DIVIDE_OPERATOR;}
{REMAINDER_OPERATOR}        {yylval.val = strdup(yytext); return REMAINDER_OPERATOR;}
{SHIFT_LEFT_OPERATOR}       {yylval.val = strdup(yytext); return SHIFT_LEFT_OPERATOR;}
{SHIFT_RIGHT_OPERATOR}      {yylval.val = strdup(yytext); return SHIFT_RIGHT_OPERATOR;}
{EQUALITY_OPERATOR}         {yylval.val = strdup(yytext); return EQUALITY_OPERATOR;}
{NON_EQUALITY_OPERATOR}     {yylval.val = strdup(yytext); return NON_EQUALITY_OPERATOR;}
{XOR_OPERATOR}              {yylval.val = strdup(yytext); return XOR_OPERATOR;}
{BITWISE_OR_OPERATOR}       {yylval.val = strdup(yytext); return BITWISE_OR_OPERATOR;}
{BITWISE_AND_OPERATOR}      {yylval.val = strdup(yytext); return BITWISE_AND_OPERATOR;}
{LOGICAL_AND_OPERATOR}      {yylval.val = strdup(yytext); return LOGICAL_AND_OPERATOR;}
{LOGICAL_OR_OPERATOR}       {yylval.val = strdup(yytext); return LOGICAL_OR_OPERATOR;}
{TERNARY_OPERATOR}          {yylval.val = strdup(yytext); return TERNARY_OPERATOR;}
{TERNARY_SEPERATOR}         {yylval.val = strdup(yytext); return TERNARY_SEPERATOR;}
{SEMI_COLON}                {yylval.val = strdup(yytext); return SEMI_COLON;}
{COMMA}                     {yylval.val = strdup(yytext); return COMMA;}
{MACRO_OPERATOR}            {yylval.val = strdup(yytext); return MACRO_OPERATOR;}
{TRIPLE_DOT}                {yylval.val = strdup(yytext); return TRIPLE_DOT;}

{INTEGER_CONSTANT}          {yylval.val = strdup(yytext); return CONSTANT;}
{FLOATING_CONSTANT}         {yylval.val = strdup(yytext); return CONSTANT;}
{CHARACTER_CONSTANT}        {yylval.val = strdup(yytext); return CONSTANT;}

{ASSIGNMENT_OPERATORS}      {yylval.val = strdup(yytext); return ASSIGNMENT_OPERATORS;}

{ADDITION_OPERATOR}         {yylval.val = strdup(yytext); return ADDITION_OPERATOR;}
{MULTIPLICATION_OPERATOR}   {yylval.val = strdup(yytext); return MULTIPLICATION_OPERATOR;}
{SUBTRACTION_OPERATOR}      {yylval.val = strdup(yytext); return SUBTRACTION_OPERATOR;}
{NOT_OPERATOR}              {yylval.val = strdup(yytext); return NOT_OPERATOR;}    
{NEGATION_OPERATOR}         {yylval.val = strdup(yytext); return NEGATION_OPERATOR;} 

{EQUAL_OPERATOR}            {yylval.val = strdup(yytext); return EQUAL_OPERATOR;}

{WHITE_SPACE}               { }
.                           {yyerror("Invalid character found\n");}
%%

int yywrap(void) {return 1;}