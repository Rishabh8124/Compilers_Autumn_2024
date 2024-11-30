%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <iostream>
    #include <vector>
    #include <iomanip>
    #include "tinyC3_22CS10058_22CS10063.h"

    using namespace std;

    int yylex();
    void yyerror(string s);
    extern int yylineno; // Defined and maintained by Flex
    extern char *yytext; // Defined and maintained by Flex

    SymbolTable * global_table = new SymbolTable("global", NULL);
    SymbolTable * current_table = global_table;
    QuadArray three_address_code;
    int temporary_count, table_count;
%}

%union {
    int ln;
    char * val;
    char * op;
    Array * array; 
    SymbolType * declaration_type;
    Expression * expr;
    Symbol * current_symbol;
    vector<string> * params;
    vector<Symbol *> * symbol_list;
    vector<int> * nextlist;
    int param_count;
}

/*
ln is used for M to store the line number
array is used to calculate the array indexing
declaration_type is used to store the type of the declaration
expr is used to store the expression along with the temporary variable
current_symbol is used to store the current symbol being generated without data type
params is used to store the parameters used for function call
symbol_list is used to store the list of symbols which are to be initialised with given data type
nextlist is used to store the list of line numbers which are to be updated with the current line number
param_count is used to store the number of parameters in the function call
*/

%right THEN ELSE

%start TRANSLATIONAL_UNIT

/*
    val is a char* type attribute which is basically string
*/
%token <val> IDENTIFIER   
%token <val> ASSIGNMENT_OPERATORS
%token <val> STRING_LITERAL
%token <val> INTEGER_CONSTANT
%token <val> FLOATING_CONSTANT
%token <val> CHARACTER_CONSTANT

%token AUTO
%token RESTRICT
%token UNSIGNED
%token BREAK
%token EXTERN
%token RETURN
%token VOID
%token CASE
%token FLOAT
%token SHORT
%token VOLATILE
%token CHAR
%token FOR
%token SIGNED
%token WHILE
%token CONST
%token GOTO
%token SIZEOF
%token BOOL
%token CONTINUE
%token IF
%token STATIC
%token COMPLEX
%token DEFAULT
%token INLINE
%token IMAGINARY
%token DO
%token INT
%token SWITCH
%token DOUBLE
%token LONG
%token REGISTER
%token LESS_THAN
%token LESS_THAN_EQUAL_TO
%token GREATER_THAN
%token GREATER_THAN_EQUAL_TO
%token LEFT_SQUARE_BRACKET
%token RIGHT_SQUARE_BRACKET
%token LEFT_PARANTHESIS
%token RIGHT_PARANTHESIS
%token LEFT_CURLY_BRACKET
%token RIGHT_CURLY_BRACKET
%token DOT
%token POINTER_ACCESS
%token INCREMENT_OPERATOR
%token DECREMENT_OPERATOR
%token DIVIDE_OPERATOR
%token REMAINDER_OPERATOR
%token SHIFT_LEFT_OPERATOR
%token SHIFT_RIGHT_OPERATOR
%token EQUALITY_OPERATOR
%token NON_EQUALITY_OPERATOR
%token XOR_OPERATOR
%token BITWISE_OR_OPERATOR
%token BITWISE_AND_OPERATOR
%token LOGICAL_AND_OPERATOR
%token LOGICAL_OR_OPERATOR
%token TERNARY_OPERATOR
%token TERNARY_SEPERATOR
%token SEMI_COLON
%token COMMA
%token TRIPLE_DOT
%token ADDITION_OPERATOR
%token MULTIPLICATION_OPERATOR
%token SUBTRACTION_OPERATOR
%token NOT_OPERATOR
%token NEGATION_OPERATOR
%token EQUAL_OPERATOR

%type <ln> M

%type <array> POSTFIX_EXPRESSION
%type <array> UNARY_EXPRESSION
%type <array> CAST_EXPRESSION

%type <expr> PRIMARY_EXPRESSION
%type <expr> ASSIGNMENT_EXPRESSION
%type <expr> ASSIGNMENT_EXPRESSION_OPT
%type <expr> CONDITIONAL_EXPRESSION
%type <expr> LOGICAL_OR_EXPRESSION
%type <expr> LOGICAL_AND_EXPRESSION
%type <expr> INCLUSIVE_OR_EXPRESSION
%type <expr> EXCLUSIVE_OR_EXPRESSION
%type <expr> AND_EXPRESSION
%type <expr> EQUALITY_EXPRESSION
%type <expr> MULTIPLICATIVE_EXPRESSION
%type <expr> ADDITIVE_EXPRESSION
%type <expr> SHIFT_EXPRESSION
%type <expr> RELATIONAL_EXPRESSION
%type <expr> EXPRESSION
%type <expr> EXPRESSION_OPT
%type <expr> INITIALIZER
%type <expr> CONSTANT_EXPRESSION

%type <param_count> ARGUMENT_EXPRESSION_LIST_OPT

%type <params> ARGUMENT_EXPRESSION_LIST

%type <op> UNARY_OPEARATOR
%type <op> ASSIGNMENT_OPERATOR

%type <symbol_list> INIT_DECLARATOR_LIST
%type <symbol_list> INIT_DECLARATOR_LIST_OPT
%type <symbol_list> PARAMETER_LIST
%type <symbol_list> PARAMETER_TYPE_LIST

%type <declaration_type> DECLARATION_SPECIFIERS
%type <declaration_type> TYPE_SPECIFIER
%type <declaration_type> SPECIFIER_QUALIFIER_LIST
%type <declaration_type> SPECIFIER_QUALIFIER_LIST_OPT
%type <declaration_type> POINTER
%type <declaration_type> POINTER_OPT
%type <declaration_type> TYPE_NAME

%type <current_symbol> DECLARATOR
%type <current_symbol> INIT_DECLARATOR
%type <current_symbol> DIRECT_DECLARATOR
%type <current_symbol> PARAMETER_DECLARATION

%type <nextlist> STATEMENT
%type <nextlist> SELECTION_STATEMENT
%type <nextlist> N
%type <nextlist> ITERATION_STATEMENT
%type <nextlist> COMPOUND_STATEMENT
%type <nextlist> BLOCK_ITEM
%type <nextlist> BLOCK_ITEM_LIST
%type <nextlist> BLOCK_ITEM_LIST_OPT

%type IDENTIFIER_LIST
%type IDENTIFIER_LIST_OPT
%type DECLARATION
%type TRANSLATIONAL_UNIT

%type STORAGE_CLASS_SPECIFIER
%type TYPE_QUALIFIER
%type FUNCTION_SPECIFIER
%type TYPE_QUALIFIER_LIST

%type INITIALIZER_LIST
%type DESIGNATION
%type DESIGNATOR_LIST
%type DESIGNATOR

%type LABELED_STATEMENT
%type EXPRESSION_STATEMENT
%type JUMP_STATEMENT
%type EXTERNAL_DECLARATION
%type FUNCTION_DEFINITION
%type DECLARATION_LIST
%type DECLARATION_LIST_OPT
%type DECLARATION_SPECIFIERS_OPT
%type TYPE_QUALIFIER_LIST_OPT
%type DESIGNATION_OPT

%%

// Expressions
PRIMARY_EXPRESSION              : IDENTIFIER                                    {
                                                                                    $$ = new Expression();
                                                                                    $$->symbol = current_table->lookup($1);
                                                                                    $$->type = 0;
                                                                                }
                                | INTEGER_CONSTANT                              { 
                                                                                    $$ = new Expression();
                                                                                    $$->symbol = current_table->gentemp(SymbolType::TYPE_INT);
                                                                                    $$->symbol->init_val = $1;
                                                                                    $$->type = 0;
                                                                                    three_address_code.emit(*(new Quad("=", $1, "", $$->symbol->name)));
                                                                                    current_table->update();
                                                                                }
                                | FLOATING_CONSTANT                             { 
                                                                                    $$ = new Expression();
                                                                                    $$->symbol = current_table->gentemp(SymbolType::TYPE_FLOAT);
                                                                                    $$->symbol->init_val = $1;
                                                                                    $$->type = 0;
                                                                                    three_address_code.emit(*(new Quad("=", $1, "", $$->symbol->name)));
                                                                                    current_table->update();
                                                                                }
                                | CHARACTER_CONSTANT                            { 
                                                                                    $$ = new Expression();
                                                                                    $$->symbol = current_table->gentemp(SymbolType::TYPE_CHAR);
                                                                                    $$->symbol->init_val = $1;
                                                                                    $$->type = 0;
                                                                                    three_address_code.emit(*(new Quad("=", $1, "", $$->symbol->name)));
                                                                                    current_table->update();
                                                                                }
                                | STRING_LITERAL                                { 
                                                                                    $$ = new Expression();
                                                                                    $$->symbol = current_table->gentemp(SymbolType::TYPE_STRING_LITERAL, (int) (sizeof($1)+1));
                                                                                    $$->symbol->init_val = $1;
                                                                                    $$->type = 0;
                                                                                    three_address_code.emit(*(new Quad("=", $1, "", $$->symbol->name)));
                                                                                    current_table->update();
                                                                                }
                                | LEFT_PARANTHESIS EXPRESSION RIGHT_PARANTHESIS { $$ = $2; }
                                ;

POSTFIX_EXPRESSION              : PRIMARY_EXPRESSION                                                                                            {
                                                                                                                                                    $$ = new Array($1->symbol, NULL, $1->symbol->type);
                                                                                                                                                }
                                | POSTFIX_EXPRESSION LEFT_SQUARE_BRACKET EXPRESSION RIGHT_SQUARE_BRACKET                                        { 
                                                                                                                                                    if ($1->temp == NULL) {
                                                                                                                                                        $$ = new Array($1->symbol, current_table->gentemp(SymbolType::TYPE_INT), $1->elem->array_elem_type);
                                                                                                                                                        three_address_code.emit(*(new Quad("*", $3->symbol->name, int_to_string($1->elem->array_elem_type->width), $$->temp->name)));
                                                                                                                                                        current_table->update();
                                                                                                                                                    } else {
                                                                                                                                                        Symbol * temp = current_table->gentemp(SymbolType::TYPE_INT);
                                                                                                                                                        three_address_code.emit(*(new Quad("*", $3->symbol->name, int_to_string($1->elem->array_elem_type->width), temp->name)));
                                                                                                                                                        $$ = new Array($1->symbol, current_table->gentemp(SymbolType::TYPE_INT), $1->elem->array_elem_type);
                                                                                                                                                        three_address_code.emit(*(new Quad("+", $1->temp->name, temp->name, $$->temp->name)));
                                                                                                                                                        current_table->update();
                                                                                                                                                    }
                                                                                                                                                }
                                | POSTFIX_EXPRESSION LEFT_PARANTHESIS ARGUMENT_EXPRESSION_LIST_OPT RIGHT_PARANTHESIS                            { 
                                                                                                                                                    $$ = new Array();
                                                                                                                                                    $$->symbol = current_table->gentemp($1->symbol->type->name);
                                                                                                                                                    three_address_code.emit(*(new Quad("call", $1->symbol->name, int_to_string($3), $$->symbol->name)));
                                                                                                                                                    current_table->update();
                                                                                                                                                }
                                | POSTFIX_EXPRESSION DOT IDENTIFIER                                                                             { /*IGNORED*/ }
                                | POSTFIX_EXPRESSION POINTER_ACCESS IDENTIFIER                                                                  { /*IGNORED*/ }
                                | POSTFIX_EXPRESSION INCREMENT_OPERATOR                                                                         {
                                                                                                                                                    $$ = new Array(current_table->gentemp($1->symbol->type->name));
                                                                                                                                                    three_address_code.emit(*(new Quad("=", $1->symbol->name, "", $$->symbol->name)));
                                                                                                                                                    three_address_code.emit(*(new Quad("+", $1->symbol->name, "1", $1->symbol->name)));
                                                                                                                                                    current_table->update();
                                                                                                                                                }
                                | POSTFIX_EXPRESSION DECREMENT_OPERATOR                                                                         {
                                                                                                                                                    $$ = new Array(current_table->gentemp($1->symbol->type->name));
                                                                                                                                                    three_address_code.emit(*(new Quad("=", $1->symbol->name, "", $$->symbol->name)));
                                                                                                                                                    three_address_code.emit(*(new Quad("-", $1->symbol->name, "1", $1->symbol->name)));
                                                                                                                                                    current_table->update();
                                                                                                                                                }
                                | LEFT_PARANTHESIS TYPE_NAME RIGHT_PARANTHESIS LEFT_CURLY_BRACKET INITIALIZER_LIST RIGHT_CURLY_BRACKET          { /*IGNORED*/ }
                                | LEFT_PARANTHESIS TYPE_NAME RIGHT_PARANTHESIS LEFT_CURLY_BRACKET INITIALIZER_LIST COMMA RIGHT_CURLY_BRACKET    { /*IGNORED*/ }
                                ;

ARGUMENT_EXPRESSION_LIST        : ASSIGNMENT_EXPRESSION                                 { $$ = new vector<string>; $$->push_back($1->symbol->name); }
                                | ARGUMENT_EXPRESSION_LIST COMMA ASSIGNMENT_EXPRESSION  { $$ = $1; $$->push_back($3->symbol->name); }
                                ;

ARGUMENT_EXPRESSION_LIST_OPT    : ARGUMENT_EXPRESSION_LIST  {
                                                                $$ = 0;
                                                                for (auto param_name: *($1)) {
                                                                    $$++;
                                                                    three_address_code.emit(*(new Quad("param", "", "", param_name)));
                                                                }
                                                            }
                                |                           { $$ = 0; }
                                ;

UNARY_EXPRESSION                : POSTFIX_EXPRESSION                                    { $$ = $1; }
                                | INCREMENT_OPERATOR UNARY_EXPRESSION                   {
                                                                                            $$ = new Array(current_table->gentemp($2->symbol->type->name));
                                                                                            three_address_code.emit(*(new Quad("+", $2->symbol->name, "1", $2->symbol->name)));
                                                                                            three_address_code.emit(*(new Quad("=", $2->symbol->name, "", $$->symbol->name)));
                                                                                            current_table->update();
                                                                                        }
                                | DECREMENT_OPERATOR UNARY_EXPRESSION                   {
                                                                                            $$ = new Array(current_table->gentemp($2->symbol->type->name));
                                                                                            three_address_code.emit(*(new Quad("-", $2->symbol->name, "1", $2->symbol->name)));
                                                                                            three_address_code.emit(*(new Quad("=", $2->symbol->name, "", $$->symbol->name)));
                                                                                            current_table->update();
                                                                                        }
                                | UNARY_OPEARATOR CAST_EXPRESSION                       {
                                                                                            if ($1 == "=&") {
                                                                                                $$ = new Array(current_table->gentemp(SymbolType::TYPE_POINTER));
                                                                                                $$->elem = $$->symbol->type;
                                                                                                $$->elem->array_elem_type = $2->elem;
                                                                                                three_address_code.emit(*(new Quad("&", $2->symbol->name, "", $$->symbol->name)));
                                                                                                current_table->update();
                                                                                            } else if ($1 == "=+") {
                                                                                                $$ = $2;
                                                                                            } else if ($1 == "=*") {
                                                                                                if ($2->elem->array_elem_type->name == SymbolType::TYPE_POINTER) {
                                                                                                    $$ = new Array(current_table->gentemp($2->elem->array_elem_type->name));
                                                                                                    $$->symbol->type = $2->elem->array_elem_type;
                                                                                                    $$->elem = $$->symbol->type;
                                                                                                    three_address_code.emit(*(new Quad("=*", $2->symbol->name, "", $$->symbol->name)));
                                                                                                    current_table->update();
                                                                                                } else {
                                                                                                    $$ = $2;
                                                                                                }
                                                                                            } else {
                                                                                                $$ = new Array(current_table->gentemp($2->symbol->type->name));
                                                                                                three_address_code.emit(*(new Quad($1, $2->symbol->name, "", $$->symbol->name)));
                                                                                                current_table->update();
                                                                                            }
                                                                                        }
                                | SIZEOF UNARY_EXPRESSION                               { /*IGNORED*/ }
                                | SIZEOF LEFT_PARANTHESIS TYPE_NAME RIGHT_PARANTHESIS   { /*IGNORED*/ }
                                ;

UNARY_OPEARATOR                 : ADDITION_OPERATOR         { $$ = (char *) "=+"; }
                                | SUBTRACTION_OPERATOR      { $$ = (char *) "=-"; }
                                | MULTIPLICATION_OPERATOR   { $$ = (char *) "=*"; }
                                | BITWISE_AND_OPERATOR      { $$ = (char *) "=&"; }
                                | NEGATION_OPERATOR         { $$ = (char *) "~"; }
                                | NOT_OPERATOR              { $$ = (char *) "!"; }
                                ;

CAST_EXPRESSION                 : UNARY_EXPRESSION                                              { $$ = $1; }
                                | LEFT_PARANTHESIS TYPE_NAME RIGHT_PARANTHESIS CAST_EXPRESSION  {
                                                                                                    if ($4->elem->name == $2->name) $$ = $4;
                                                                                                    else {
                                                                                                        $$ = new Array(current_table->gentemp($2->name), NULL, $2);
                                                                                                        if ($4->elem->name == SymbolType::TYPE_INT) {
                                                                                                            if ($2->name == SymbolType::TYPE_FLOAT) three_address_code.emit(*(new Quad("=", "INT_TO_FLOAT("+$4->symbol->name+")", "", $$->symbol->name)));
                                                                                                            else if ($2->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "INT_TO_CHAR("+$4->symbol->name+")", "", $$->symbol->name)));
                                                                                                        } else if ($4->elem->name == SymbolType::TYPE_FLOAT) {
                                                                                                            if ($2->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "FLOAT_TO_INT("+$4->symbol->name+")", "", $$->symbol->name)));
                                                                                                            else if ($2->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "FLOAT_TO_CHAR("+$4->symbol->name+")", "", $$->symbol->name)));
                                                                                                        } else if ($4->elem->name == SymbolType::TYPE_CHAR) {
                                                                                                            if ($2->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "CHAR_TO_INT("+$4->symbol->name+")", "", $$->symbol->name)));
                                                                                                            else if ($2->name == SymbolType::TYPE_FLOAT) three_address_code.emit(*(new Quad("=", "CHAR_TO_FLOAT("+$4->symbol->name+")", "", $$->symbol->name)));
                                                                                                        }
                                                                                                    }
                                                                                                }
                                ;

MULTIPLICATIVE_EXPRESSION       : CAST_EXPRESSION                                                   {
                                                                                                        $$ = new Expression($1->symbol);
                                                                                                        $$->type = 0;
                                                                                                        if ($1->symbol->type->name == SymbolType::TYPE_ARRAY) {
                                                                                                            SymbolType * base = $1->elem;
                                                                                                            while(base->array_elem_type != NULL) base = base->array_elem_type;
                                                                                                            Symbol * temp = current_table->gentemp(base->name);
                                                                                                            $$->symbol = temp;
                                                                                                            three_address_code.emit(*(new Quad("=[]", $1->symbol->name, $1->temp->name, $$->symbol->name)));
                                                                                                        } else if ($1->symbol->type->name == SymbolType::TYPE_POINTER) {
                                                                                                            SymbolType * base = $1->elem;
                                                                                                            while(base->array_elem_type != NULL) base = base->array_elem_type;
                                                                                                            Symbol * temp = current_table->gentemp(base->name);
                                                                                                            $$->symbol = temp;
                                                                                                            three_address_code.emit(*(new Quad("=*", $1->symbol->name, "", $$->symbol->name)));
                                                                                                        }

                                                                                                        current_table->update();
                                                                                                    }
                                | MULTIPLICATIVE_EXPRESSION MULTIPLICATION_OPERATOR CAST_EXPRESSION { 
                                                                                                        Symbol * temp1, *temp2;
                                                                                                        if ($1->symbol->type->name == $3->symbol->type->name) {
                                                                                                            temp1 = $1->symbol;
                                                                                                            temp2 = $3->symbol;
                                                                                                        } else if ($1->symbol->type->name == SymbolType::TYPE_FLOAT) {
                                                                                                            temp1 = $1->symbol;
                                                                                                            temp2 = current_table->gentemp($1->symbol->type->name);
                                                                                                            if ($3->symbol->type->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "INT_TO_FLOAT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                            else if ($3->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_FLOAT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                        } else if ($3->symbol->type->name == SymbolType::TYPE_FLOAT) {
                                                                                                            temp2 = $3->symbol;
                                                                                                            temp1 = current_table->gentemp($3->symbol->type->name);
                                                                                                            if ($1->symbol->type->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "INT_TO_FLOAT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                            else if ($1->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_FLOAT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                        } else if ($1->symbol->type->name == SymbolType::TYPE_INT) {
                                                                                                            temp1 = $1->symbol;
                                                                                                            temp2 = current_table->gentemp($1->symbol->type->name);
                                                                                                            if ($3->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_INT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                        } else if ($3->symbol->type->name == SymbolType::TYPE_INT) {
                                                                                                            temp2 = $3->symbol;
                                                                                                            temp1 = current_table->gentemp($3->symbol->type->name);
                                                                                                            if ($1->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_INT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                        } 

                                                                                                        $$ = new Expression(current_table->gentemp($1->symbol->type->name));
                                                                                                        $$->type = 0;
                                                                                                        three_address_code.emit(*(new Quad("*", temp1->name, temp2->name, $$->symbol->name)));
                                                                                                        current_table->update();
                                                                                                    }
                                | MULTIPLICATIVE_EXPRESSION DIVIDE_OPERATOR CAST_EXPRESSION         { 
                                                                                                        Symbol * temp1, *temp2;
                                                                                                        if ($1->symbol->type->name == $3->symbol->type->name) {
                                                                                                            temp1 = $1->symbol;
                                                                                                            temp2 = $3->symbol;
                                                                                                        } else if ($1->symbol->type->name == SymbolType::TYPE_FLOAT) {
                                                                                                            temp1 = $1->symbol;
                                                                                                            temp2 = current_table->gentemp($1->symbol->type->name);
                                                                                                            if ($3->symbol->type->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "INT_TO_FLOAT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                            else if ($3->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_FLOAT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                        } else if ($3->symbol->type->name == SymbolType::TYPE_FLOAT) {
                                                                                                            temp2 = $3->symbol;
                                                                                                            temp1 = current_table->gentemp($3->symbol->type->name);
                                                                                                            if ($1->symbol->type->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "INT_TO_FLOAT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                            else if ($1->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_FLOAT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                        } else if ($1->symbol->type->name == SymbolType::TYPE_INT) {
                                                                                                            temp1 = $1->symbol;
                                                                                                            temp2 = current_table->gentemp($1->symbol->type->name);
                                                                                                            if ($3->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_INT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                        } else if ($3->symbol->type->name == SymbolType::TYPE_INT) {
                                                                                                            temp2 = $3->symbol;
                                                                                                            temp1 = current_table->gentemp($3->symbol->type->name);
                                                                                                            if ($1->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_INT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                        } 

                                                                                                        $$ = new Expression(current_table->gentemp($1->symbol->type->name));
                                                                                                        $$->type = 0;
                                                                                                        three_address_code.emit(*(new Quad("/", temp1->name, temp2->name, $$->symbol->name)));
                                                                                                        current_table->update();
                                                                                                    }
                                | MULTIPLICATIVE_EXPRESSION REMAINDER_OPERATOR CAST_EXPRESSION      { 
                                                                                                        Symbol * temp1, *temp2;
                                                                                                        if ($1->symbol->type->name == $3->symbol->type->name) {
                                                                                                            temp1 = $1->symbol;
                                                                                                            temp2 = $3->symbol;
                                                                                                        } else if ($1->symbol->type->name == SymbolType::TYPE_FLOAT) {
                                                                                                            temp1 = $1->symbol;
                                                                                                            temp2 = current_table->gentemp($1->symbol->type->name);
                                                                                                            if ($3->symbol->type->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "INT_TO_FLOAT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                            else if ($3->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_FLOAT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                        } else if ($3->symbol->type->name == SymbolType::TYPE_FLOAT) {
                                                                                                            temp2 = $3->symbol;
                                                                                                            temp1 = current_table->gentemp($3->symbol->type->name);
                                                                                                            if ($1->symbol->type->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "INT_TO_FLOAT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                            else if ($1->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_FLOAT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                        } else if ($1->symbol->type->name == SymbolType::TYPE_INT) {
                                                                                                            temp1 = $1->symbol;
                                                                                                            temp2 = current_table->gentemp($1->symbol->type->name);
                                                                                                            if ($3->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_INT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                        } else if ($3->symbol->type->name == SymbolType::TYPE_INT) {
                                                                                                            temp2 = $3->symbol;
                                                                                                            temp1 = current_table->gentemp($3->symbol->type->name);
                                                                                                            if ($1->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_INT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                        } 

                                                                                                        $$ = new Expression(current_table->gentemp($1->symbol->type->name));
                                                                                                        $$->type = 0;
                                                                                                        three_address_code.emit(*(new Quad("%", temp1->name, temp2->name, $$->symbol->name)));
                                                                                                        current_table->update();
                                                                                                    }
                                ;

ADDITIVE_EXPRESSION             : MULTIPLICATIVE_EXPRESSION                                             { $$ = $1; }
                                | ADDITIVE_EXPRESSION ADDITION_OPERATOR MULTIPLICATIVE_EXPRESSION       { 
                                                                                                            Symbol * temp1, *temp2;
                                                                                                            if ($1->symbol->type->name == $3->symbol->type->name) {
                                                                                                                temp1 = $1->symbol;
                                                                                                                temp2 = $3->symbol;
                                                                                                            } else if ($1->symbol->type->name == SymbolType::TYPE_FLOAT) {
                                                                                                                temp1 = $1->symbol;
                                                                                                                temp2 = current_table->gentemp($1->symbol->type->name);
                                                                                                                if ($3->symbol->type->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "INT_TO_FLOAT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                                else if ($3->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_FLOAT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                            } else if ($3->symbol->type->name == SymbolType::TYPE_FLOAT) {
                                                                                                                temp2 = $3->symbol;
                                                                                                                temp1 = current_table->gentemp($3->symbol->type->name);
                                                                                                                if ($1->symbol->type->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "INT_TO_FLOAT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                                else if ($1->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_FLOAT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                            } else if ($1->symbol->type->name == SymbolType::TYPE_INT) {
                                                                                                                temp1 = $1->symbol;
                                                                                                                temp2 = current_table->gentemp($1->symbol->type->name);
                                                                                                                if ($3->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_INT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                            } else if ($3->symbol->type->name == SymbolType::TYPE_INT) {
                                                                                                                temp2 = $3->symbol;
                                                                                                                temp1 = current_table->gentemp($3->symbol->type->name);
                                                                                                                if ($1->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_INT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                            } 

                                                                                                            $$ = new Expression(current_table->gentemp($1->symbol->type->name));
                                                                                                            $$->type = 0;
                                                                                                            three_address_code.emit(*(new Quad("+", temp1->name, temp2->name, $$->symbol->name)));
                                                                                                            current_table->update();
                                                                                                        }
                                | ADDITIVE_EXPRESSION SUBTRACTION_OPERATOR MULTIPLICATIVE_EXPRESSION    { 
                                                                                                            Symbol * temp1, *temp2;
                                                                                                            if ($1->symbol->type->name == $3->symbol->type->name) {
                                                                                                                temp1 = $1->symbol;
                                                                                                                temp2 = $3->symbol;
                                                                                                            } else if ($1->symbol->type->name == SymbolType::TYPE_FLOAT) {
                                                                                                                temp1 = $1->symbol;
                                                                                                                temp2 = current_table->gentemp($1->symbol->type->name);
                                                                                                                if ($3->symbol->type->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "INT_TO_FLOAT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                                else if ($3->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_FLOAT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                            } else if ($3->symbol->type->name == SymbolType::TYPE_FLOAT) {
                                                                                                                temp2 = $3->symbol;
                                                                                                                temp1 = current_table->gentemp($3->symbol->type->name);
                                                                                                                if ($1->symbol->type->name == SymbolType::TYPE_INT) three_address_code.emit(*(new Quad("=", "INT_TO_FLOAT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                                else if ($1->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_FLOAT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                            } else if ($1->symbol->type->name == SymbolType::TYPE_INT) {
                                                                                                                temp1 = $1->symbol;
                                                                                                                temp2 = current_table->gentemp($1->symbol->type->name);
                                                                                                                if ($3->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_INT("+$3->symbol->name+")", "", temp2->name)));
                                                                                                            } else if ($3->symbol->type->name == SymbolType::TYPE_INT) {
                                                                                                                temp2 = $3->symbol;
                                                                                                                temp1 = current_table->gentemp($3->symbol->type->name);
                                                                                                                if ($1->symbol->type->name == SymbolType::TYPE_CHAR) three_address_code.emit(*(new Quad("=", "CHAR_TO_INT("+$1->symbol->name+")", "", temp1->name)));
                                                                                                            } 

                                                                                                            $$ = new Expression(current_table->gentemp($1->symbol->type->name));
                                                                                                            $$->type = 0;
                                                                                                            three_address_code.emit(*(new Quad("-", temp1->name, temp2->name, $$->symbol->name)));
                                                                                                            current_table->update();
                                                                                                        }
                                ;

SHIFT_EXPRESSION                : ADDITIVE_EXPRESSION                                       { $$ = $1; }
                                | SHIFT_EXPRESSION SHIFT_LEFT_OPERATOR ADDITIVE_EXPRESSION  {
                                                                                                $$ = new Expression();
                                                                                                $$->type = 0;
                                                                                                $$->symbol = current_table->gentemp($1->symbol->type->name);
                                                                                                three_address_code.emit(*(new Quad("<<", $1->symbol->name, $3->symbol->name, $$->symbol->name)));
                                                                                                current_table->update();
                                                                                            }
                                | SHIFT_EXPRESSION SHIFT_RIGHT_OPERATOR ADDITIVE_EXPRESSION {
                                                                                                $$ = new Expression();
                                                                                                $$->type = 0;
                                                                                                $$->symbol = current_table->gentemp($1->symbol->type->name);
                                                                                                three_address_code.emit(*(new Quad(">>", $1->symbol->name, $3->symbol->name, $$->symbol->name)));
                                                                                                current_table->update();
                                                                                            }
                                ;

RELATIONAL_EXPRESSION           : SHIFT_EXPRESSION                                              { $$ = $1; }
                                | RELATIONAL_EXPRESSION LESS_THAN SHIFT_EXPRESSION              {
                                                                                                    $$ = new Expression();
                                                                                                    $$->symbol = NULL;
                                                                                                    $$->type = 1;

                                                                                                    $$->truelist = makelist(getlineno());
                                                                                                    three_address_code.emit(*(new Quad("<", $1->symbol->name, $3->symbol->name, "")));
                                                                                                    $$->falselist = merge($1->falselist, makelist(getlineno()));
                                                                                                    three_address_code.emit(*(new Quad("goto")));
                                                                                                    current_table->update();
                                                                                                }
                                | RELATIONAL_EXPRESSION GREATER_THAN SHIFT_EXPRESSION           {
                                                                                                    $$ = new Expression();
                                                                                                    $$->symbol = NULL;
                                                                                                    $$->type = 1;

                                                                                                    $$->truelist = makelist(getlineno());
                                                                                                    three_address_code.emit(*(new Quad(">", $1->symbol->name, $3->symbol->name, "")));
                                                                                                    $$->falselist = merge($1->falselist, makelist(getlineno()));
                                                                                                    three_address_code.emit(*(new Quad("goto")));
                                                                                                    current_table->update();
                                                                                                }
                                | RELATIONAL_EXPRESSION LESS_THAN_EQUAL_TO SHIFT_EXPRESSION     {
                                                                                                    $$ = new Expression();
                                                                                                    $$->symbol = NULL;
                                                                                                    $$->type = 1;

                                                                                                    $$->truelist = makelist(getlineno());
                                                                                                    three_address_code.emit(*(new Quad("<=", $1->symbol->name, $3->symbol->name, "")));
                                                                                                    $$->falselist = merge($1->falselist, makelist(getlineno()));
                                                                                                    three_address_code.emit(*(new Quad("goto")));
                                                                                                    current_table->update();
                                                                                                }
                                | RELATIONAL_EXPRESSION GREATER_THAN_EQUAL_TO SHIFT_EXPRESSION  {
                                                                                                    $$ = new Expression();
                                                                                                    $$->symbol = NULL;
                                                                                                    $$->type = 1;

                                                                                                    $$->truelist = makelist(getlineno());
                                                                                                    three_address_code.emit(*(new Quad(">=", $1->symbol->name, $3->symbol->name, "")));
                                                                                                    $$->falselist = merge($1->falselist, makelist(getlineno()));
                                                                                                    three_address_code.emit(*(new Quad("goto")));
                                                                                                    current_table->update();
                                                                                                }
                                ;

EQUALITY_EXPRESSION             : RELATIONAL_EXPRESSION                                             { $$ = $1; }
                                | EQUALITY_EXPRESSION EQUALITY_OPERATOR RELATIONAL_EXPRESSION       {
                                                                                                        $$ = new Expression();
                                                                                                        $$->symbol = NULL;
                                                                                                        $$->type = 1;

                                                                                                        $$->truelist = makelist(getlineno());
                                                                                                        three_address_code.emit(*(new Quad(">=", $1->symbol->name, $3->symbol->name, "")));
                                                                                                        $$->falselist = merge($1->falselist, makelist(getlineno()));
                                                                                                        three_address_code.emit(*(new Quad("goto")));
                                                                                                        current_table->update();
                                                                                                    }
                                | EQUALITY_EXPRESSION NON_EQUALITY_OPERATOR RELATIONAL_EXPRESSION   {
                                                                                                        $$ = new Expression();
                                                                                                        $$->symbol = NULL;
                                                                                                        $$->type = 1;

                                                                                                        $$->truelist = makelist(getlineno());
                                                                                                        three_address_code.emit(*(new Quad(">=", $1->symbol->name, $3->symbol->name, "")));
                                                                                                        $$->falselist = merge($1->falselist, makelist(getlineno()));
                                                                                                        three_address_code.emit(*(new Quad("goto")));
                                                                                                        current_table->update();
                                                                                                    }
                                ;

AND_EXPRESSION                  : EQUALITY_EXPRESSION                                       { $$ = $1; }
                                | AND_EXPRESSION BITWISE_AND_OPERATOR EQUALITY_EXPRESSION   { 
                                                                                                $$ = new Expression(current_table->gentemp($1->symbol->type->name), 0);
                                                                                                $1->convert_to_int();
                                                                                                $3->convert_to_int();
                                                                                                three_address_code.emit(*(new Quad("&", $1->symbol->name, $3->symbol->name, $$->symbol->name)));
                                                                                                current_table->update();
                                                                                            }
                                ;

EXCLUSIVE_OR_EXPRESSION         : AND_EXPRESSION                                        { $$ = $1; }
                                | EXCLUSIVE_OR_EXPRESSION XOR_OPERATOR AND_EXPRESSION   { 
                                                                                            $$ = new Expression(current_table->gentemp($1->symbol->type->name, 0));
                                                                                            $1->convert_to_int();
                                                                                            $3->convert_to_int();
                                                                                            three_address_code.emit(*(new Quad("^", $1->symbol->name, $3->symbol->name, $$->symbol->name)));
                                                                                            current_table->update();
                                                                                        }
                                ;

INCLUSIVE_OR_EXPRESSION         : EXCLUSIVE_OR_EXPRESSION                                               { $$ = $1; }
                                | INCLUSIVE_OR_EXPRESSION BITWISE_OR_OPERATOR EXCLUSIVE_OR_EXPRESSION   { 
                                                                                                            $$ = new Expression(current_table->gentemp($1->symbol->type->name, 0));
                                                                                                            $1->convert_to_int();
                                                                                                            $3->convert_to_int();
                                                                                                            three_address_code.emit(*(new Quad("|", $1->symbol->name, $3->symbol->name, $$->symbol->name)));
                                                                                                            current_table->update();
                                                                                                        }
                                ;

/*
M -> epsilon
        To get the next instruction number which is to be used for backpatching

N -> epsilon
        To create a goto quad and execute the logical and and logical or and ternary operators

Augnmented rules include rules of Non terminals
    -> LOGICAL_AND_EXPRESSION
    -> LOGICAL_OR_EXPRESSION
    -> CONDITIONAL_EXPRESSION
*/

LOGICAL_AND_EXPRESSION          : INCLUSIVE_OR_EXPRESSION                                               { $$ = $1; }
                                | LOGICAL_AND_EXPRESSION LOGICAL_AND_OPERATOR M INCLUSIVE_OR_EXPRESSION {
                                                                                                            $$ = new Expression();
                                                                                                            int y = $3+2*($1->type==0);

                                                                                                            $1->convert_to_bool();                                                                                                            
                                                                                                            $4->convert_to_bool();

                                                                                                            $$->symbol = NULL;
                                                                                                            $$->type = 1;

                                                                                                            backpatch($1->truelist, y);
                                                                                                            $$->truelist = $4->truelist;
                                                                                                            $$->falselist = merge($1->falselist, $4->falselist);
                                                                                                            current_table->update();
                                                                                                        }
                                ;

LOGICAL_OR_EXPRESSION           : LOGICAL_AND_EXPRESSION                                            { $$ = $1; }
                                | LOGICAL_OR_EXPRESSION LOGICAL_OR_OPERATOR M LOGICAL_AND_EXPRESSION    {
                                                                                                            $$ = new Expression();
                                                                                                            int y = $3;

                                                                                                            $1->convert_to_bool();
                                                                                                            $4->convert_to_bool();

                                                                                                            $$->symbol = NULL;
                                                                                                            $$->type = 1;

                                                                                                            backpatch($1->falselist, y);
                                                                                                            $$->falselist = $4->falselist;
                                                                                                            $$->truelist = merge($1->truelist, $4->truelist);
                                                                                                            current_table->update();
                                                                                                        }
                                ;

CONDITIONAL_EXPRESSION          : LOGICAL_OR_EXPRESSION                                                                                 { $$ = $1; }
                                | LOGICAL_OR_EXPRESSION TERNARY_OPERATOR M EXPRESSION N TERNARY_SEPERATOR M CONDITIONAL_EXPRESSION      {
                                                                                                                                            $$ = new Expression();
                                                                                                                                            $1->convert_to_bool();
                                                                                                                                            $$->symbol = current_table->gentemp($1->symbol->type->name);
                                                                                                                                            backpatch($1->truelist, $3);
                                                                                                                                            backpatch($1->falselist, $7);
                                                                                                                                            three_address_code.emit(*(new Quad("=", $8->symbol->name, "", $$->symbol->name)));
                                                                                                                                            three_address_code.emit(*(new Quad("goto", "", "", int_to_string(getlineno()+3))));
                                                                                                                                            backpatch($5, getlineno());
                                                                                                                                            three_address_code.emit(*(new Quad("=", $4->symbol->name, "", $$->symbol->name)));
                                                                                                                                            three_address_code.emit(*(new Quad("goto", "", "", int_to_string(getlineno()+1))));
                                                                                                                                            current_table->update();
                                                                                                                                        }
                                ;

ASSIGNMENT_EXPRESSION           : CONDITIONAL_EXPRESSION                                        { $$ = $1; }
                                | UNARY_EXPRESSION ASSIGNMENT_OPERATOR ASSIGNMENT_EXPRESSION    {
                                                                                                    $$ = new Expression($1->symbol);
                                                                                                    Symbol * temp;
                                                                                                    if ($3->symbol->type->name == SymbolType::TYPE_POINTER) {
                                                                                                        Symbol * temp = current_table->gentemp($3->symbol->type->array_elem_type->name);
                                                                                                        three_address_code.emit(*(new Quad("=*", $3->symbol->name, "", temp->name)));
                                                                                                    } else {
                                                                                                        temp = $3->symbol;
                                                                                                    }

                                                                                                    if ($2 == "=") {
                                                                                                        if ($1->symbol->type->name == SymbolType::TYPE_ARRAY) three_address_code.emit(*(new Quad("[]=", temp->name, $1->temp->name, $1->symbol->name)));
                                                                                                        else if ($1->symbol->type->name == SymbolType::TYPE_POINTER) three_address_code.emit(*(new Quad("*=", temp->name, "", $1->symbol->name)));
                                                                                                        else three_address_code.emit(*(new Quad("=", temp->name, "", $1->symbol->name)));
                                                                                                    } else {
                                                                                                        char sym = $2[0];
                                                                                                        string oper = " ";
                                                                                                        oper[0] = sym;
                                                                                                        three_address_code.emit(*(new Quad(oper, temp->name, $1->symbol->name, $1->symbol->name)));
                                                                                                    }
                                                                                                    current_table->update();
                                                                                                }
                                ;

ASSIGNMENT_OPERATOR             : EQUAL_OPERATOR        { $$ = (char *) "="; }
                                | ASSIGNMENT_OPERATORS  { $$ = $1; }
                                ;

EXPRESSION                      : ASSIGNMENT_EXPRESSION                     { $$ = $1; }
                                | EXPRESSION COMMA ASSIGNMENT_EXPRESSION    { $$ = $3; }
                                ;

CONSTANT_EXPRESSION             : CONDITIONAL_EXPRESSION    { $$ = $1; }
                                ;

/*Declarations*/

DECLARATION                     : DECLARATION_SPECIFIERS INIT_DECLARATOR_LIST_OPT SEMI_COLON    {
                                                                                                    SymbolType * temp;
                                                                                                    for (auto symbol: *($2)) {
                                                                                                        current_table->symbols.push_back(symbol);
                                                                                                        current_table->symbol_instance[symbol->name] = symbol;
                                                                                                        temp = symbol->type;
                                                                                                        if (temp == NULL) symbol->type = $1;
                                                                                                        else {
                                                                                                            while(temp->array_elem_type != NULL) temp = temp->array_elem_type;
                                                                                                            temp->array_elem_type = $1;
                                                                                                        }
                                                                                                    }
                                                                                                    current_table->update();
                                                                                                }
                                ;

INIT_DECLARATOR_LIST_OPT        : INIT_DECLARATOR_LIST { $$ = $1; } 
                                |                      { /*No semantics*/ } 
                                ;

DECLARATION_SPECIFIERS          :   STORAGE_CLASS_SPECIFIER DECLARATION_SPECIFIERS_OPT  { /*IGNORED*/ }
                                |   TYPE_SPECIFIER DECLARATION_SPECIFIERS_OPT           { $$ = $1; }
                                |   TYPE_QUALIFIER DECLARATION_SPECIFIERS_OPT           { /*IGNORED*/ }
                                |   FUNCTION_SPECIFIER DECLARATION_SPECIFIERS_OPT       { /*IGNORED*/ }
                                ;

DECLARATION_SPECIFIERS_OPT      :   DECLARATION_SPECIFIERS  { /*IGNORED*/ } 
                                |                           { /*IGNORED*/ } 
                                ;                            

INIT_DECLARATOR_LIST            :   INIT_DECLARATOR { $$ = new vector<Symbol *>; $$->push_back($1); } 
                                |   INIT_DECLARATOR_LIST COMMA INIT_DECLARATOR { $$ = $1; $$->push_back($3); } 
                                ;

INIT_DECLARATOR                 :   DECLARATOR { $$ = $1; } 
                                |   DECLARATOR EQUAL_OPERATOR INITIALIZER   {
                                                                                $$ = $1;
                                                                                $1->init_val = $3->symbol->init_val;
                                                                                three_address_code.emit(*(new Quad("=", $3->symbol->name, "", $1->name)));
                                                                            } 
                                ;

STORAGE_CLASS_SPECIFIER         :   EXTERN      { /*IGNORED*/ } 
                                |   STATIC      { /*IGNORED*/ } 
                                |   AUTO        { /*IGNORED*/ } 
                                |   REGISTER    { /*IGNORED*/ } 
                                ;

TYPE_SPECIFIER                  :   VOID        { $$ = new SymbolType(SymbolType::TYPE_VOID); } 
                                |   CHAR        { $$ = new SymbolType(SymbolType::TYPE_CHAR); } 
                                |   SHORT       { /*IGNORED*/ } 
                                |   INT         { $$ = new SymbolType(SymbolType::TYPE_INT); } 
                                |   LONG        { /*IGNORED*/ } 
                                |   FLOAT       { $$ = new SymbolType(SymbolType::TYPE_FLOAT); } 
                                |   DOUBLE      { /*IGNORED*/ } 
                                |   SIGNED      { /*IGNORED*/ } 
                                |   UNSIGNED    { /*IGNORED*/ } 
                                |   BOOL        { /*IGNORED*/ } 
                                |   COMPLEX     { /*IGNORED*/ } 
                                |   IMAGINARY   { /*IGNORED*/ } 
                                ;

SPECIFIER_QUALIFIER_LIST        :   TYPE_SPECIFIER SPECIFIER_QUALIFIER_LIST_OPT { $$ = $1; } 
                                |   TYPE_QUALIFIER SPECIFIER_QUALIFIER_LIST_OPT { /*IGNORED*/ } 
                                ;

SPECIFIER_QUALIFIER_LIST_OPT    :   SPECIFIER_QUALIFIER_LIST { $$ = $1; } 
                                |                            { $$ = NULL; } 
                                ;

TYPE_QUALIFIER                  :   CONST       { /*IGNORED*/ } 
                                |   RESTRICT    { /*IGNORED*/ } 
                                |   VOLATILE    { /*IGNORED*/ } 
                                ;

FUNCTION_SPECIFIER              :   INLINE      { /*IGNORED*/ } 
                                ;

DECLARATOR                      :   POINTER_OPT DIRECT_DECLARATOR   {
                                                                        $$ = $2;
                                                                        if ($1 != NULL) {
                                                                            SymbolType * temp = $1;
                                                                            while(temp->array_elem_type != NULL) temp = temp->array_elem_type;
                                                                            temp->array_elem_type = $2->type;
                                                                            $2->type = $1;
                                                                        }
                                                                    } 
                                ;

POINTER_OPT                     :   POINTER { $$ = $1; } 
                                |           { $$ = NULL; } 
                                ;

DIRECT_DECLARATOR               :   IDENTIFIER { $$ = new Symbol($1); } 
                                |   LEFT_PARANTHESIS DECLARATOR RIGHT_PARANTHESIS { $$ = $2; } 
                                |   DIRECT_DECLARATOR LEFT_SQUARE_BRACKET TYPE_QUALIFIER_LIST_OPT ASSIGNMENT_EXPRESSION_OPT RIGHT_SQUARE_BRACKET    { 
                                                                                                                                                        SymbolType * temp = new SymbolType(SymbolType::TYPE_ARRAY, string_to_int($4->symbol->init_val));
                                                                                                                                                        $$ = $1;
                                                                                                                                                        if ($$->type == NULL) $$->type = temp;
                                                                                                                                                        else {
                                                                                                                                                            SymbolType * t = $$->type;
                                                                                                                                                            while(t->array_elem_type != NULL) t = t->array_elem_type;
                                                                                                                                                            t->array_elem_type = temp;
                                                                                                                                                        }
                                                                                                                                                    } 
                                |   DIRECT_DECLARATOR LEFT_SQUARE_BRACKET STATIC TYPE_QUALIFIER_LIST_OPT ASSIGNMENT_EXPRESSION RIGHT_SQUARE_BRACKET { /*IGNORED*/ } 
                                |   DIRECT_DECLARATOR LEFT_SQUARE_BRACKET TYPE_QUALIFIER_LIST STATIC ASSIGNMENT_EXPRESSION RIGHT_SQUARE_BRACKET { /*IGNORED*/ } 
                                |   DIRECT_DECLARATOR LEFT_SQUARE_BRACKET TYPE_QUALIFIER_LIST_OPT MULTIPLICATION_OPERATOR RIGHT_SQUARE_BRACKET { /*IGNORED*/ } 
                                |   DIRECT_DECLARATOR LEFT_PARANTHESIS PARAMETER_TYPE_LIST RIGHT_PARANTHESIS    { 
                                                                                                                    $$ = $1;
                                                                                                                    SymbolTable * func_table = new SymbolTable($1->name, current_table);
                                                                                                                    $1->nested = func_table;

                                                                                                                    for(auto symbol: *($3)) {
                                                                                                                        func_table->symbols.push_back(symbol);
                                                                                                                        func_table->symbol_instance[symbol->name] = symbol;
                                                                                                                    }

                                                                                                                    func_table->update();
                                                                                                                } 
                                |   DIRECT_DECLARATOR LEFT_PARANTHESIS IDENTIFIER_LIST_OPT RIGHT_PARANTHESIS    { 
                                                                                                                    $$ = $1;
                                                                                                                    SymbolTable * func_table = new SymbolTable($1->name, current_table);
                                                                                                                    $1->nested = func_table;

                                                                                                                    func_table->update();
                                                                                                                }
                                ;

ASSIGNMENT_EXPRESSION_OPT       :   ASSIGNMENT_EXPRESSION { $$ = $1; } 
                                |   { $$ = NULL; } 
                                ;

POINTER                         :   MULTIPLICATION_OPERATOR TYPE_QUALIFIER_LIST_OPT { $$ = new SymbolType(SymbolType::TYPE_POINTER); } 
                                |   MULTIPLICATION_OPERATOR TYPE_QUALIFIER_LIST_OPT POINTER { $$ = new SymbolType(SymbolType::TYPE_POINTER, POINTER_SIZE, $3); } 
                                ;

TYPE_QUALIFIER_LIST             :   TYPE_QUALIFIER { /*IGNORED*/ } 
                                |   TYPE_QUALIFIER_LIST TYPE_QUALIFIER { /*IGNORED*/ } 
                                ;

TYPE_QUALIFIER_LIST_OPT         :   TYPE_QUALIFIER_LIST { /*IGNORED*/ } 
                                |   { /*IGNORED*/ } 
                                ;

PARAMETER_TYPE_LIST             :   PARAMETER_LIST { $$ = $1; }                  
                                |   PARAMETER_LIST COMMA TRIPLE_DOT { /*IGNORED*/ } 
                                ;

PARAMETER_LIST                  :   PARAMETER_DECLARATION { $$ = new vector<Symbol *>; $$->push_back($1); }                       
                                |   PARAMETER_LIST COMMA PARAMETER_DECLARATION { $$=$1; $$->push_back($3); } 
                                ;

PARAMETER_DECLARATION           :   DECLARATION_SPECIFIERS DECLARATOR   { 
                                                                            $$ = $2;
                                                                            if ($$->type == NULL) $$->type = $1;
                                                                            else {
                                                                                SymbolType * temp = $$->type;
                                                                                while(temp->array_elem_type != NULL)  temp = temp->array_elem_type;
                                                                                temp->array_elem_type = $1;
                                                                            }
                                                                        }           
                                |   DECLARATION_SPECIFIERS { /*IGNORED*/ } 
                                ;

IDENTIFIER_LIST                 :   IDENTIFIER { /*IGNORED*/ }                                  
                                |   IDENTIFIER_LIST COMMA IDENTIFIER { /*IGNORED*/ } 
                                ;

IDENTIFIER_LIST_OPT             :   IDENTIFIER_LIST { /*IGNORED*/ }     
                                |   { /*IGNORED*/ } 
                                ;

TYPE_NAME                       :   SPECIFIER_QUALIFIER_LIST { $$ = $1; }                    
                                ;

INITIALIZER                     :   ASSIGNMENT_EXPRESSION { $$ = $1; }                       
                                |   LEFT_CURLY_BRACKET INITIALIZER_LIST RIGHT_CURLY_BRACKET { /*IGNORED*/ } 
                                |   LEFT_CURLY_BRACKET INITIALIZER_LIST COMMA RIGHT_CURLY_BRACKET { /*IGNORED*/ } 
                                ;

INITIALIZER_LIST                :   DESIGNATION_OPT INITIALIZER { /*IGNORED*/ }    
                                |   INITIALIZER_LIST COMMA DESIGNATION_OPT INITIALIZER { /*IGNORED*/ } 
                                ;

DESIGNATION                     :   DESIGNATOR_LIST EQUAL_OPERATOR { /*IGNORED*/ }  
                                ;

DESIGNATION_OPT                 :   DESIGNATION { /*IGNORED*/ }  
                                |   { /*IGNORED*/ } 
                                ;

DESIGNATOR_LIST                 :   DESIGNATOR { /*IGNORED*/ }                                  
                                |   DESIGNATOR_LIST DESIGNATOR { /*IGNORED*/ } 
                                ;

DESIGNATOR                      :   LEFT_SQUARE_BRACKET CONSTANT_EXPRESSION RIGHT_SQUARE_BRACKET { /*IGNORED*/ }  
                                |   DOT IDENTIFIER { /*IGNORED*/ }      
                                ;

              
// statements
STATEMENT                       : LABELED_STATEMENT    { /*IGNORED*/ } 
                                |   { 
                                        current_table = new SymbolTable(current_table->name+int_to_string(table_count++), current_table); 
                                        three_address_code.emit(*(new Quad("label", "", "", current_table->name)));
                                        
                                    } COMPOUND_STATEMENT   { 
                                        current_table->update(); 
                                        Symbol * temp = new Symbol(current_table->name, new SymbolType(SymbolType::TYPE_VOID));
                                        temp->nested = current_table;
                                        current_table->parent->symbols.push_back(temp);
                                        current_table = current_table->parent; 
                                        current_table->update();
                                        $$ = $2; 
                                    } 
                                | EXPRESSION_STATEMENT { $$ = NULL; } 
                                | SELECTION_STATEMENT  { $$ = $1; } 
                                | ITERATION_STATEMENT  { $$ = $1; } 
                                | JUMP_STATEMENT       { $$ = NULL; } 
                                ;

LABELED_STATEMENT               : IDENTIFIER TERNARY_SEPERATOR STATEMENT  { /*IGNORED*/ } 
                                | CASE CONSTANT_EXPRESSION TERNARY_SEPERATOR STATEMENT { /*IGNORED*/ } 
                                | DEFAULT TERNARY_SEPERATOR STATEMENT { /*IGNORED*/ } 
                                ;

COMPOUND_STATEMENT              : LEFT_CURLY_BRACKET BLOCK_ITEM_LIST_OPT RIGHT_CURLY_BRACKET { $$ = $2; } 
                                ;

BLOCK_ITEM_LIST                 : BLOCK_ITEM                 { $$ = $1; } 
                                | BLOCK_ITEM_LIST M BLOCK_ITEM { $$ = $3; backpatch($1, $2); }
                                ;

BLOCK_ITEM                      : DECLARATION { $$ = NULL; } 
                                | STATEMENT   { $$ = $1; } 
                                ;

EXPRESSION_STATEMENT            : EXPRESSION_OPT SEMI_COLON { /*NO SEMANTICS*/ } 
                                ;

SELECTION_STATEMENT             : IF LEFT_PARANTHESIS EXPRESSION RIGHT_PARANTHESIS M STATEMENT N %prec THEN {
                                                                                                                backpatch($3->truelist, $5);
                                                                                                                $$ = merge($6, $7);
                                                                                                                $$ = merge($3->falselist, $$);
                                                                                                            } 
                                | IF LEFT_PARANTHESIS EXPRESSION RIGHT_PARANTHESIS M STATEMENT N ELSE M STATEMENT   { 
                                                                                                                        backpatch($3->truelist, $5);
                                                                                                                        backpatch($3->falselist, $9);
                                                                                                                        $$ = merge(merge($6, $7), $10);
                                                                                                                    } 
                                | SWITCH LEFT_PARANTHESIS EXPRESSION RIGHT_PARANTHESIS STATEMENT { /*IGNORED*/ }
                                ;

ITERATION_STATEMENT             : WHILE LEFT_PARANTHESIS M EXPRESSION RIGHT_PARANTHESIS M STATEMENT   {
                                                                                                        $$ = $4->falselist;
                                                                                                        backpatch($7, $3);
                                                                                                        backpatch($4->truelist, $6);
                                                                                                        three_address_code.emit(*(new Quad("goto", "", "", int_to_string($3))));
                                                                                                    } 
                                | DO M STATEMENT WHILE LEFT_PARANTHESIS M EXPRESSION RIGHT_PARANTHESIS SEMI_COLON   {
                                                                                                                        $$ = $7->falselist;
                                                                                                                        backpatch($3, $6);
                                                                                                                        backpatch($7->truelist, $2);
                                                                                                                    } 
                                | FOR LEFT_PARANTHESIS EXPRESSION_OPT SEMI_COLON M EXPRESSION_OPT SEMI_COLON M EXPRESSION_OPT N RIGHT_PARANTHESIS M STATEMENT   {
                                                                                                                                                                    $$ = $6->falselist;
                                                                                                                                                                    backpatch($6->truelist, $12);
                                                                                                                                                                    backpatch($13, $8);
                                                                                                                                                                    backpatch($10, $5);
                                                                                                                                                                } 
                                | FOR LEFT_PARANTHESIS DECLARATION EXPRESSION_OPT SEMI_COLON EXPRESSION_OPT RIGHT_PARANTHESIS STATEMENT { /*IGNORED*/ } 
                                ;

JUMP_STATEMENT                  : GOTO IDENTIFIER SEMI_COLON { /*IGNORED*/ } 
                                | CONTINUE SEMI_COLON        { /*IGNORED*/ } 
                                | BREAK SEMI_COLON            { /*IGNORED*/ } 
                                | RETURN EXPRESSION_OPT SEMI_COLON  {
                                                                        if ($2 == NULL) three_address_code.emit(*(new Quad("return", "", "", "")));
                                                                        else three_address_code.emit(*(new Quad("return", "", "", $2->symbol->name)));
                                                                    }   
                                ;

M                               : { $$ = getlineno(); }
                                ;

N                               : { $$ = makelist(getlineno()); three_address_code.emit(*(new Quad("goto"))); }
                                ;

// Optional non-terminals
BLOCK_ITEM_LIST_OPT             : BLOCK_ITEM_LIST { $$ = $1; } 
                                | /* empty */     { $$ = NULL; } 
                                ;

EXPRESSION_OPT                  : EXPRESSION  { $$ = $1; } 
                                | /* empty */ { $$ = NULL; } 
                                ;

/* External definitions */

TRANSLATIONAL_UNIT              : EXTERNAL_DECLARATION                                                      { /*NO SEMANTICS*/ }
                                | TRANSLATIONAL_UNIT EXTERNAL_DECLARATION                                   { /*NO SEMANTICS*/ }
                                ;

EXTERNAL_DECLARATION            : FUNCTION_DEFINITION                                                       { /*NO SEMANTICS*/ }
                                | DECLARATION                                                               { /*NO SEMANTICS*/ }
                                ;

FUNCTION_DEFINITION             : DECLARATION_SPECIFIERS DECLARATOR DECLARATION_LIST_OPT    {   

                                                                                                current_table->symbols.push_back($2);
                                                                                                $2->type = $1;
                                                                                                current_table->symbol_instance[$2->name] = $2;
                                                                                                current_table->update();
                                                                                                current_table = $2->nested;
                                                                                                
                                                                                                three_address_code.emit(*(new Quad("label", "", "", current_table->name)));
                                                                                            } 
                                                                                            
                                                                                            COMPOUND_STATEMENT { current_table->update(); current_table = current_table->parent; }
                                ;

DECLARATION_LIST                : DECLARATION                                                               { }                                             
                                | DECLARATION_LIST DECLARATION                                              { }
                                ;

DECLARATION_LIST_OPT            : DECLARATION_LIST                                                          { }
                                |                                                                           { }
                                ;                        
%%

void yyerror(string s) {
    cout << s << endl;
}