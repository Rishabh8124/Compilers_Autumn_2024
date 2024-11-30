%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yylex();
    void yyerror(char *s);
    extern int yylineno; // Defined and maintained by Flex
    extern char *yytext; // Defined and maintained by Flex

    typedef struct tree_node {
        char * name;                // Name of the termainal or non terminal represented by the node
        char * val;                 // Value of the terminal if represents a terminal
        struct tree_node * next;    // The next symbol in the grammar transition of the parent (Linked list implementation to store the production of the parent)
        struct tree_node * child;   // Pointer to the child (First T/NT belonging to the transition being used)
    } tree;

    typedef tree * tree_pointer;

    tree_pointer init_node(char * name, char * val, tree_pointer child);
    void add_next(tree_pointer root, tree_pointer next);
    void print_parse_tree(tree_pointer root, int depth);
    tree_pointer parse_tree = NULL;
%}

%union {char * val; tree_pointer node;}

%nonassoc <val> RIGHT_PARANTHESIS
%nonassoc <val> ELSE

%start TRANSLATIONAL_UNIT

%token <val> AUTO
%token <val> RESTRICT
%token <val> UNSIGNED
%token <val> BREAK
%token <val> EXTERN
%token <val> RETURN
%token <val> VOID
%token <val> CASE
%token <val> FLOAT
%token <val> SHORT
%token <val> VOLATILE
%token <val> CHAR
%token <val> FOR
%token <val> SIGNED
%token <val> WHILE
%token <val> CONST
%token <val> GOTO
%token <val> SIZEOF
%token <val> BOOL
%token <val> CONTINUE
%token <val> IF
%token <val> STATIC
%token <val> COMPLEX
%token <val> DEFAULT
%token <val> INLINE
%token <val> IMAGINARY
%token <val> DO
%token <val> INT
%token <val> SWITCH
%token <val> DOUBLE
%token <val> LONG
%token <val> REGISTER
%token <val> IDENTIFIER
%token <val> STRING_LITERAL
%token <val> CONSTANT
%token <val> LESS_THAN
%token <val> LESS_THAN_EQUAL_TO
%token <val> GREATER_THAN
%token <val> GREATER_THAN_EQUAL_TO
%token <val> LEFT_SQUARE_BRACKET
%token <val> RIGHT_SQUARE_BRACKET
%token <val> LEFT_PARANTHESIS
%token <val> LEFT_CURLY_BRACKET
%token <val> RIGHT_CURLY_BRACKET
%token <val> DOT
%token <val> POINTER_ACCESS
%token <val> INCREMENT_OPERATOR
%token <val> DECREMENT_OPERATOR
%token <val> DIVIDE_OPERATOR
%token <val> REMAINDER_OPERATOR
%token <val> SHIFT_LEFT_OPERATOR
%token <val> SHIFT_RIGHT_OPERATOR
%token <val> EQUALITY_OPERATOR
%token <val> NON_EQUALITY_OPERATOR
%token <val> XOR_OPERATOR
%token <val> BITWISE_OR_OPERATOR
%token <val> BITWISE_AND_OPERATOR
%token <val> LOGICAL_AND_OPERATOR
%token <val> LOGICAL_OR_OPERATOR
%token <val> TERNARY_OPERATOR
%token <val> TERNARY_SEPERATOR
%token <val> SEMI_COLON
%token <val> COMMA
%token <val> TRIPLE_DOT
%token <val> ADDITION_OPERATOR
%token <val> MULTIPLICATION_OPERATOR
%token <val> SUBTRACTION_OPERATOR
%token <val> NOT_OPERATOR
%token <val> NEGATION_OPERATOR
%token <val> EQUAL_OPERATOR
%token <val> ASSIGNMENT_OPERATORS

%token <val> ENUM
%token <val> STRUCT
%token <val> TYPEDEF
%token <val> UNION
%token <val> ESCAPE_OPERATOR
%token <val> MACRO_OPERATOR

%type <node> ARGUMENT_EXPRESSION_LIST_OPT
%type <node> EXPRESSION
%type <node> CONSTANT_EXPRESSION
%type <node> PRIMARY_EXPRESSION
%type <node> POSTFIX_EXPRESSION
%type <node> ARGUMENT_EXPRESSION_LIST
%type <node> ASSIGNMENT_EXPRESSION
%type <node> UNARY_EXPRESSION
%type <node> CAST_EXPRESSION
%type <node> TYPE_NAME
%type <node> UNARY_OPEARATOR
%type <node> MULTIPLICATIVE_EXPRESSION
%type <node> ADDITIVE_EXPRESSION
%type <node> SHIFT_EXPRESSION
%type <node> RELATIONAL_EXPRESSION
%type <node> EQUALITY_EXPRESSION
%type <node> AND_EXPRESSION
%type <node> EXCLUSIVE_OR_EXPRESSION
%type <node> INCLUSIVE_OR_EXPRESSION
%type <node> LOGICAL_AND_EXPRESSION
%type <node> LOGICAL_OR_EXPRESSION
%type <node> CONDITIONAL_EXPRESSION
%type <node> ASSIGNMENT_OPERATOR
%type <node> TRANSLATIONAL_UNIT

%type <node> DECLARATION
%type <node> DECLARATION_SPECIFIERS
%type <node> INIT_DECLARATOR_LIST
%type <node> INIT_DECLARATOR
%type <node> STORAGE_CLASS_SPECIFIER
%type <node> TYPE_SPECIFIER
%type <node> SPECIFIER_QUALIFIER_LIST
%type <node> TYPE_QUALIFIER
%type <node> FUNCTION_SPECIFIER
%type <node> DECLARATOR
%type <node> DIRECT_DECLARATOR
%type <node> POINTER
%type <node> TYPE_QUALIFIER_LIST
%type <node> PARAMETER_TYPE_LIST
%type <node> PARAMETER_LIST
%type <node> PARAMETER_DECLARATION
%type <node> IDENTIFIER_LIST

%type <node> INITIALIZER
%type <node> INITIALIZER_LIST
%type <node> DESIGNATION
%type <node> DESIGNATOR_LIST
%type <node> DESIGNATOR

%type <node> STATEMENT
%type <node> LABELED_STATEMENT
%type <node> COMPOUND_STATEMENT
%type <node> BLOCK_ITEM_LIST
%type <node> BLOCK_ITEM
%type <node> EXPRESSION_STATEMENT
%type <node> SELECTION_STATEMENT
%type <node> ITERATION_STATEMENT
%type <node> JUMP_STATEMENT
%type <node> EXTERNAL_DECLARATION
%type <node> FUNCTION_DEFINITION
%type <node> DECLARATION_LIST
%type <node> DECLARATION_LIST_OPT
%type <node> INIT_DECLARATOR_LIST_OPT
%type <node> DECLARATION_SPECIFIERS_OPT
%type <node> SPECIFIER_QUALIFIER_LIST_OPT
%type <node> POINTER_OPT
%type <node> TYPE_QUALIFIER_LIST_OPT
%type <node> ASSIGNMENT_EXPRESSION_OPT
%type <node> IDENTIFIER_LIST_OPT
%type <node> DESIGNATION_OPT
%type <node> EXPRESSION_OPT
%type <node> BLOCK_ITEM_LIST_OPT

%%

// Expressions
PRIMARY_EXPRESSION              : IDENTIFIER                                    {   $$ = init_node("PRIMARY_EXPRESSION", "", init_node("IDENTIFIER", $1, NULL));}
                                | CONSTANT                                      {   $$ = init_node("PRIMARY_EXPRESSION", "", init_node("CONSTANT", $1, NULL));}
                                | STRING_LITERAL                                {   $$ = init_node("PRIMARY_EXPRESSION", "", init_node("STRING_LITERAL", $1, NULL));}
                                | LEFT_PARANTHESIS EXPRESSION RIGHT_PARANTHESIS {
                                                                                    tree_pointer temp = init_node($1, "", NULL); 
                                                                                    $$ = init_node("PRIMARY_EXPRESSION", "", temp);
                                                                                    add_next(temp, $2);
                                                                                    add_next(temp, init_node($3, "", NULL));
                                                                                }
                                ;

POSTFIX_EXPRESSION              : PRIMARY_EXPRESSION                                                                                            {   $$ = init_node("POSTFIX_EXPRESSION", "", $1);}
                                | POSTFIX_EXPRESSION LEFT_SQUARE_BRACKET EXPRESSION RIGHT_SQUARE_BRACKET                                        {
                                                                                                                                                    $$ = init_node("POSTFIX_EXPRESSION", "", $1);
                                                                                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                                                                                    add_next($1, $3);
                                                                                                                                                    add_next($1, init_node($4, "", NULL));
                                                                                                                                                }
                                | POSTFIX_EXPRESSION LEFT_PARANTHESIS ARGUMENT_EXPRESSION_LIST_OPT RIGHT_PARANTHESIS                            {
                                                                                                                                                    $$ = init_node("POSTFIX_EXPRESSION", "", $1);
                                                                                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                                                                                    add_next($1, $3);
                                                                                                                                                    add_next($1, init_node($4, "", NULL));
                                                                                                                                                }
                                | POSTFIX_EXPRESSION DOT IDENTIFIER                                                                             {
                                                                                                                                                    $$ = init_node("POSTFIX_EXPRESSION", "", $1);
                                                                                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                                                                                    add_next($1, init_node("IDENTIFIER", $3, NULL));
                                                                                                                                                }
                                | POSTFIX_EXPRESSION POINTER_ACCESS IDENTIFIER                                                                  {
                                                                                                                                                    $$ = init_node("POSTFIX_EXPRESSION", "", $1);
                                                                                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                                                                                    add_next($1, init_node("IDENTIFIER", $3, NULL));
                                                                                                                                                }
                                | POSTFIX_EXPRESSION INCREMENT_OPERATOR                                                                         {
                                                                                                                                                    $$ = init_node("POSTFIX_EXPRESSION", "", $1);
                                                                                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                                                                                }
                                | POSTFIX_EXPRESSION DECREMENT_OPERATOR                                                                         {
                                                                                                                                                    $$ = init_node("POSTFIX_EXPRESSION", "", $1);
                                                                                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                                                                                }                   
                                | LEFT_PARANTHESIS TYPE_NAME RIGHT_PARANTHESIS LEFT_CURLY_BRACKET INITIALIZER_LIST RIGHT_CURLY_BRACKET          {
                                                                                                                                                    tree_pointer temp = init_node($1, "", NULL); 
                                                                                                                                                    $$ = init_node("POSTFIX_EXPRESSION", "", temp);
                                                                                                                                                    add_next(temp, $2);
                                                                                                                                                    add_next(temp, init_node($3, "", NULL));
                                                                                                                                                    add_next(temp, init_node($4, "", NULL));
                                                                                                                                                    add_next(temp, $5);
                                                                                                                                                    add_next(temp, init_node($6, "", NULL));
                                                                                                                                                }
                                | LEFT_PARANTHESIS TYPE_NAME RIGHT_PARANTHESIS LEFT_CURLY_BRACKET INITIALIZER_LIST COMMA RIGHT_CURLY_BRACKET    {
                                                                                                                                                    tree_pointer temp = init_node($1, "", NULL); 
                                                                                                                                                    $$ = init_node("POSTFIX_EXPRESSION", "", temp);
                                                                                                                                                    add_next(temp, $2);
                                                                                                                                                    add_next(temp, init_node($3, "", NULL));
                                                                                                                                                    add_next(temp, init_node($4, "", NULL));
                                                                                                                                                    add_next(temp, $5);
                                                                                                                                                    add_next(temp, init_node($6, "", NULL));
                                                                                                                                                }
                                ;                   

ARGUMENT_EXPRESSION_LIST        : ASSIGNMENT_EXPRESSION                                 {$$ = init_node("ARGUMENT_EXPRESSION_LIST", "", $1);}
                                | ARGUMENT_EXPRESSION_LIST COMMA ASSIGNMENT_EXPRESSION  {
                                                                                            $$ = init_node("ARGUMENT_EXPRESSION_LIST", "", $1);
                                                                                            add_next($1, init_node($2, "", NULL));
                                                                                            add_next($1, $3);
                                                                                        }
                                ;

ARGUMENT_EXPRESSION_LIST_OPT    : ARGUMENT_EXPRESSION_LIST  {$$ = init_node("ARGUMENT_EXPRESSION_LIST_OPT", "", $1);}
                                |                           {$$ = init_node("ARGUMENT_EXPRESSION_LIST_OPT", "", init_node("<empty>", "", NULL));}
                                ;

UNARY_EXPRESSION                : POSTFIX_EXPRESSION                                    {$$ = init_node("UNARY_EXPRESSION", "", $1);}
                                | INCREMENT_OPERATOR UNARY_EXPRESSION                   {
                                                                                            tree_pointer temp = init_node($1, "", NULL);
                                                                                            $$ = init_node("UNARY_EXPRESSION", "", temp);
                                                                                            add_next(temp, $2);
                                                                                        }
                                | DECREMENT_OPERATOR UNARY_EXPRESSION                   {
                                                                                            tree_pointer temp = init_node($1, "", NULL);
                                                                                            $$ = init_node("UNARY_EXPRESSION", "", temp);
                                                                                            add_next(temp, $2);
                                                                                        }
                                | UNARY_OPEARATOR CAST_EXPRESSION                       {
                                                                                            $$ = init_node("UNARY_EXPRESSION", "", $1);
                                                                                            add_next($1, $2);
                                                                                        }
                                | SIZEOF UNARY_EXPRESSION                               {
                                                                                            tree_pointer temp = init_node($1, "", NULL);
                                                                                            $$ = init_node("UNARY_EXPRESSION", "", temp);
                                                                                            add_next(temp, $2);
                                                                                        }
                                | SIZEOF LEFT_PARANTHESIS TYPE_NAME RIGHT_PARANTHESIS   {
                                                                                            tree_pointer temp = init_node($1, "", NULL);
                                                                                            $$ = init_node("UNARY_EXPRESSION", "", temp);
                                                                                            add_next(temp, init_node($2, "", NULL));
                                                                                            add_next(temp, $3);
                                                                                            add_next(temp, init_node($4, "", NULL));
                                                                                        }
                                ;

UNARY_OPEARATOR                 : ADDITION_OPERATOR         {$$ = init_node("UNARY_OPERATOR", $1, NULL);}
                                | SUBTRACTION_OPERATOR      {$$ = init_node("UNARY_OPERATOR", $1, NULL);}
                                | MULTIPLICATION_OPERATOR   {$$ = init_node("UNARY_OPERATOR", $1, NULL);}
                                | BITWISE_AND_OPERATOR      {$$ = init_node("UNARY_OPERATOR", $1, NULL);}
                                | NEGATION_OPERATOR         {$$ = init_node("UNARY_OPERATOR", $1, NULL);}
                                | NOT_OPERATOR              {$$ = init_node("UNARY_OPERATOR", $1, NULL);}
                                ;

CAST_EXPRESSION                 : UNARY_EXPRESSION                                              {$$ = init_node("CAST_EXPRESSION", "", $1);}
                                | LEFT_PARANTHESIS TYPE_NAME RIGHT_PARANTHESIS CAST_EXPRESSION  {
                                                                                                    tree_pointer temp = init_node($1, "", NULL);
                                                                                                    $$ = init_node("CAST_EXPRESSION", "", temp);
                                                                                                    add_next(temp, $2);
                                                                                                    add_next(temp, init_node($3, "", NULL));
                                                                                                    add_next(temp, $4);
                                                                                                }
                                ;

MULTIPLICATIVE_EXPRESSION       : CAST_EXPRESSION                                                   {$$ = init_node("MULTIPLICATIVE_EXPRESSION", "", $1);}
                                | MULTIPLICATIVE_EXPRESSION MULTIPLICATION_OPERATOR CAST_EXPRESSION {
                                                                                                        $$ = init_node("MULTIPLICATIVE_EXPRESSION", "", $1);
                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                        add_next($1, $3);
                                                                                                    }
                                | MULTIPLICATIVE_EXPRESSION DIVIDE_OPERATOR CAST_EXPRESSION         {
                                                                                                        $$ = init_node("MULTIPLICATIVE_EXPRESSION", "", $1);
                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                        add_next($1, $3);
                                                                                                    } 
                                | MULTIPLICATIVE_EXPRESSION REMAINDER_OPERATOR CAST_EXPRESSION      {
                                                                                                        $$ = init_node("MULTIPLICATIVE_EXPRESSION", "", $1);
                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                        add_next($1, $3);
                                                                                                    }
                                ;

ADDITIVE_EXPRESSION             : MULTIPLICATIVE_EXPRESSION                                             {$$ = init_node("ADDITIVE_EXPRESSION", "", $1);} 
                                | ADDITIVE_EXPRESSION ADDITION_OPERATOR MULTIPLICATIVE_EXPRESSION       {
                                                                                                            $$ = init_node("ADDITIVE_EXPRESSION", "", $1);
                                                                                                            add_next($1, init_node($2, "", NULL));
                                                                                                            add_next($1, $3);
                                                                                                        }
                                | ADDITIVE_EXPRESSION SUBTRACTION_OPERATOR MULTIPLICATIVE_EXPRESSION    {
                                                                                                            $$ = init_node("ADDITIVE_EXPRESSION", "", $1);
                                                                                                            add_next($1, init_node($2, "", NULL));
                                                                                                            add_next($1, $3);
                                                                                                        }
                                ;

SHIFT_EXPRESSION                : ADDITIVE_EXPRESSION                                       {   $$ = init_node("SHIFT_EXPRESSION", "", $1);} 
                                | SHIFT_EXPRESSION SHIFT_LEFT_OPERATOR ADDITIVE_EXPRESSION  {
                                                                                                $$ = init_node("SHIFT_EXPRESSION", "", $1);
                                                                                                add_next($1, init_node($2, "", NULL));
                                                                                                add_next($1, $3);
                                                                                            } 
                                | SHIFT_EXPRESSION SHIFT_RIGHT_OPERATOR ADDITIVE_EXPRESSION {
                                                                                                $$ = init_node("SHIFT_EXPRESSION", "", $1);
                                                                                                add_next($1, init_node($2, "", NULL));
                                                                                                add_next($1, $3);
                                                                                            } 
                                ;

RELATIONAL_EXPRESSION           : SHIFT_EXPRESSION                                              {   $$ = init_node("RELATIONAL_EXPRESSION", "", $1);} 
                                | RELATIONAL_EXPRESSION LESS_THAN SHIFT_EXPRESSION              {
                                                                                                    $$ = init_node("RELATIONAL_EXPRESSION", "", $1);
                                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                                    add_next($1, $3);
                                                                                                }
                                | RELATIONAL_EXPRESSION GREATER_THAN SHIFT_EXPRESSION           {
                                                                                                    $$ = init_node("RELATIONAL_EXPRESSION", "", $1);
                                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                                    add_next($1, $3);
                                                                                                }
                                | RELATIONAL_EXPRESSION LESS_THAN_EQUAL_TO SHIFT_EXPRESSION     {
                                                                                                    $$ = init_node("RELATIONAL_EXPRESSION", "", $1);
                                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                                    add_next($1, $3);
                                                                                                } 
                                | RELATIONAL_EXPRESSION GREATER_THAN_EQUAL_TO SHIFT_EXPRESSION  {
                                                                                                    $$ = init_node("RELATIONAL_EXPRESSION", "", $1);
                                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                                    add_next($1, $3);
                                                                                                } 
                                ;

EQUALITY_EXPRESSION             : RELATIONAL_EXPRESSION                                             {   $$ = init_node("EQUALITY_EXPRESSION", "", $1);} 
                                | EQUALITY_EXPRESSION EQUALITY_OPERATOR RELATIONAL_EXPRESSION       {
                                                                                                        $$ = init_node("EQUALITY_EXPRESSION", "", $1);
                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                        add_next($1, $3);
                                                                                                    }  
                                | EQUALITY_EXPRESSION NON_EQUALITY_OPERATOR RELATIONAL_EXPRESSION   {
                                                                                                        $$ = init_node("EQUALITY_EXPRESSION", "", $1);
                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                        add_next($1, $3);
                                                                                                    } 
                                ;

AND_EXPRESSION                  : EQUALITY_EXPRESSION                                       {   $$ = init_node("AND_EXPRESSION", "", $1);} 
                                | AND_EXPRESSION BITWISE_AND_OPERATOR EQUALITY_EXPRESSION   {
                                                                                                $$ = init_node("AND_EXPRESSION", "", $1);
                                                                                                add_next($1, init_node($2, "", NULL));
                                                                                                add_next($1, $3);
                                                                                            } 
                                ;

EXCLUSIVE_OR_EXPRESSION         : AND_EXPRESSION                                        {   $$ = init_node("EXCLUSIVE_OR_EXPRESSION", "", $1);} 
                                | EXCLUSIVE_OR_EXPRESSION XOR_OPERATOR AND_EXPRESSION   {
                                                                                            $$ = init_node("EXCLUSIVE_OR_EXPRESSION", "", $1);
                                                                                            add_next($1, init_node($2, "", NULL));
                                                                                            add_next($1, $3);
                                                                                        } 
                                ;

INCLUSIVE_OR_EXPRESSION         : EXCLUSIVE_OR_EXPRESSION                                               {   $$ = init_node("INCLUSIVE_OR_EXPRESSION", "", $1);} 
                                | INCLUSIVE_OR_EXPRESSION BITWISE_OR_OPERATOR EXCLUSIVE_OR_EXPRESSION   {
                                                                                                            $$ = init_node("INCLUSIVE_OR_EXPRESSION", "", $1);
                                                                                                            add_next($1, init_node($2, "", NULL));
                                                                                                            add_next($1, $3);
                                                                                                        } 
                                ;

LOGICAL_AND_EXPRESSION          : INCLUSIVE_OR_EXPRESSION                                               {   $$ = init_node("LOGICAL_AND_EXPRESSION", "", $1);}  
                                | LOGICAL_AND_EXPRESSION LOGICAL_AND_OPERATOR INCLUSIVE_OR_EXPRESSION   {
                                                                                                            $$ = init_node("LOGICAL_AND_EXPRESSION", "", $1);
                                                                                                            add_next($1, init_node($2, "", NULL));
                                                                                                            add_next($1, $3);
                                                                                                        }  
                                ;

LOGICAL_OR_EXPRESSION           : LOGICAL_AND_EXPRESSION                                            {   $$ = init_node("LOGICAL_OR_EXPRESSION", "", $1);} 
                                | LOGICAL_OR_EXPRESSION LOGICAL_OR_OPERATOR LOGICAL_AND_EXPRESSION  {
                                                                                                        $$ = init_node("LOGICAL_OR_EXPRESSION", "", $1);
                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                        add_next($1, $3);
                                                                                                    }   
                                ;

CONDITIONAL_EXPRESSION          : LOGICAL_OR_EXPRESSION                                                                         {   $$ = init_node("CONDITIONAL_EXPRESSION", "", $1);} 
                                | LOGICAL_OR_EXPRESSION TERNARY_OPERATOR EXPRESSION TERNARY_SEPERATOR CONDITIONAL_EXPRESSION    {
                                                                                                                                    $$ = init_node("CONDITIONAL_EXPRESSION", "", $1);
                                                                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                                                                    add_next($1, $3);
                                                                                                                                    add_next($1, init_node($4, "", NULL));
                                                                                                                                    add_next($1, $5);
                                                                                                                                } 
                                ;

ASSIGNMENT_EXPRESSION           : CONDITIONAL_EXPRESSION                                        {   $$ = init_node("ASSIGNMENT_EXPRESSION", "", $1);}
                                | UNARY_EXPRESSION ASSIGNMENT_OPERATOR ASSIGNMENT_EXPRESSION    {
                                                                                                    $$ = init_node("ASSIGNMENT_EXPRESSION", "", $1);
                                                                                                    add_next($1, $2);
                                                                                                    add_next($1, $3);
                                                                                                } 
                                ;

ASSIGNMENT_OPERATOR             : EQUAL_OPERATOR        {$$ = init_node("ASSIGNMENT_OPERATOR", $1, NULL);}
                                | ASSIGNMENT_OPERATORS  {$$ = init_node("ASSIGNMENT_OPERATOR", $1, NULL);}
                                ;

EXPRESSION                      : ASSIGNMENT_EXPRESSION                     {   $$ = init_node("EXPRESSION", "", $1);}
                                | EXPRESSION COMMA ASSIGNMENT_EXPRESSION    {
                                                                                $$ = init_node("EXPRESSION", "", $1);
                                                                                add_next($1, init_node($2, "", NULL));
                                                                                add_next($1, $3);
                                                                            }
                                ;

CONSTANT_EXPRESSION             : CONDITIONAL_EXPRESSION    {   $$ = init_node("CONSTANT_EXPRESSION", "", $1);}
                                ;

/*Declarations*/

DECLARATION                     : DECLARATION_SPECIFIERS INIT_DECLARATOR_LIST_OPT SEMI_COLON    {   $$ = init_node("DECLARATION", "", $1);
                                                                                                    add_next($1, $2);
                                                                                                    add_next($1, init_node($3, "", NULL));
                                                                                                }
                                ;

INIT_DECLARATOR_LIST_OPT        : INIT_DECLARATOR_LIST  {   $$ = init_node("INIT_DECLARATOR_LIST_OPT", "", $1);}
                                |                       {   $$ = init_node("INIT_DECLARATOR_LIST_OPT", "", init_node("<empty>", "", NULL));}
                                ;

DECLARATION_SPECIFIERS          :   STORAGE_CLASS_SPECIFIER DECLARATION_SPECIFIERS_OPT  {   $$ = init_node("DECLARATION_SPECIFIERS", "", $1); add_next($1, $2);}
                                |   TYPE_SPECIFIER DECLARATION_SPECIFIERS_OPT           {   $$ = init_node("DECLARATION_SPECIFIERS", "", $1); add_next($1, $2);}
                                |   TYPE_QUALIFIER DECLARATION_SPECIFIERS_OPT           {   $$ = init_node("DECLARATION_SPECIFIERS", "", $1); add_next($1, $2);}
                                |   FUNCTION_SPECIFIER DECLARATION_SPECIFIERS_OPT       {   $$ = init_node("DECLARATION_SPECIFIERS", "", $1); add_next($1, $2);}
                                ;

DECLARATION_SPECIFIERS_OPT      :   DECLARATION_SPECIFIERS  {$$ = init_node("DECLARATION_SPECIFIERS_OPT", "", $1);}
                                |                           {$$ = init_node("DECLARATION_SPECIFIERS_OPT", "", init_node("<empty>", "", NULL));}
                                ;                            

INIT_DECLARATOR_LIST            :   INIT_DECLARATOR                             {   $$ = init_node("INIT_DECLARATOR_LIST", "", $1);}
                                |   INIT_DECLARATOR_LIST COMMA INIT_DECLARATOR  {
                                                                                    $$ = init_node("INIT_DECLARATOR_LIST", "", $1);
                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                    add_next($1, $3);
                                                                                }
                                ;

INIT_DECLARATOR                 :   DECLARATOR                              {$$ = init_node("INIT_DECLARATOR", "", $1);}
                                |   DECLARATOR EQUAL_OPERATOR INITIALIZER   {
                                                                                $$ = init_node("INIT_DECLARATOR", "", $1);
                                                                                add_next($1, init_node($2, "", NULL));
                                                                                add_next($1, $3);
                                                                            }
                                ;

STORAGE_CLASS_SPECIFIER         :   EXTERN      {$$ = init_node("STORAGE_CLASS_SPECIFIER", $1, NULL);}
                                |   STATIC      {$$ = init_node("STORAGE_CLASS_SPECIFIER", $1, NULL);}
                                |   AUTO        {$$ = init_node("STORAGE_CLASS_SPECIFIER", $1, NULL);}
                                |   REGISTER    {$$ = init_node("STORAGE_CLASS_SPECIFIER", $1, NULL);}
                                ;

TYPE_SPECIFIER                  :   VOID        {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                |   CHAR        {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                |   SHORT       {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                |   INT         {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                |   LONG        {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                |   FLOAT       {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                |   DOUBLE      {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                |   SIGNED      {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                |   UNSIGNED    {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                |   BOOL        {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                |   COMPLEX     {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                |   IMAGINARY   {$$ = init_node("TYPE_SPECIFIER", $1, NULL);}
                                ;

SPECIFIER_QUALIFIER_LIST        :   TYPE_SPECIFIER SPECIFIER_QUALIFIER_LIST_OPT {
                                                                                    $$ = init_node("SPECIFIER_QUALIFIER_LIST", "", $1);
                                                                                    add_next($1, $2);
                                                                                }
                                |   TYPE_QUALIFIER SPECIFIER_QUALIFIER_LIST_OPT {
                                                                                    $$ = init_node("SPECIFIER_QUALIFIER_LIST", "", $1);
                                                                                    add_next($1, $2);
                                                                                }
                                ;

SPECIFIER_QUALIFIER_LIST_OPT    :   SPECIFIER_QUALIFIER_LIST    {$$ = init_node("SPECIFIER_QUALIFIER_LIST_OPT", "", $1);}
                                |                               {$$ = init_node("SPECIFIER_QUALIFIER_LIST_OPT", "", init_node("<empty>", "", NULL));}
                                ;

TYPE_QUALIFIER                  :   CONST       {$$ = init_node("TYPE_QUALIFIER", $1, NULL);}
                                |   RESTRICT    {$$ = init_node("TYPE_QUALIFIER", $1, NULL);}
                                |   VOLATILE    {$$ = init_node("TYPE_QUALIFIER", $1, NULL);}
                                ;

FUNCTION_SPECIFIER              :   INLINE      {$$ = init_node("FUNCTION_SPECIFIER", $1, NULL);}
                                ;

DECLARATOR                      :   POINTER_OPT DIRECT_DECLARATOR   {$$ = init_node("DECLARATOR", "", $1); add_next($1, $2);}
                                ;

POINTER_OPT                     :   POINTER {$$ = init_node("POINTER_OPT", "", $1);}
                                |           {$$ = init_node("POINTER_OPT", "", init_node("<empty>", "", NULL));}
                                ;

DIRECT_DECLARATOR               :   IDENTIFIER                                                                                                      {$$ = init_node("DIRECT_DECLARATOR", "", init_node("IDENTIFIER", $1, NULL));}
                                |   LEFT_PARANTHESIS DECLARATOR RIGHT_PARANTHESIS                                                                   {
                                                                                                                                                        tree_pointer temp = init_node($1, "", NULL);
                                                                                                                                                        $$ = init_node("DIRECT_DECLARATOR", "", temp);
                                                                                                                                                        add_next(temp, $2);
                                                                                                                                                        add_next(temp, init_node($3, "", NULL));
                                                                                                                                                    }
                                |   DIRECT_DECLARATOR LEFT_SQUARE_BRACKET TYPE_QUALIFIER_LIST_OPT ASSIGNMENT_EXPRESSION_OPT RIGHT_SQUARE_BRACKET    {
                                                                                                                                                        $$ = init_node("DIRECT_DECLARATOR", "", $1);
                                                                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                                                                        add_next($1, $3);
                                                                                                                                                        add_next($1, $4);
                                                                                                                                                        add_next($1, init_node($5, "", NULL));
                                                                                                                                                    }
                                |   DIRECT_DECLARATOR LEFT_SQUARE_BRACKET STATIC TYPE_QUALIFIER_LIST_OPT ASSIGNMENT_EXPRESSION RIGHT_SQUARE_BRACKET {
                                                                                                                                                        $$ = init_node("DIRECT_DECLARATOR", "", $1);
                                                                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                                                                        add_next($1, init_node($3, "", NULL));
                                                                                                                                                        add_next($1, $4);
                                                                                                                                                        add_next($1, $5);
                                                                                                                                                        add_next($1, init_node($6, "", NULL));
                                                                                                                                                    }
                                |   DIRECT_DECLARATOR LEFT_SQUARE_BRACKET TYPE_QUALIFIER_LIST STATIC ASSIGNMENT_EXPRESSION RIGHT_SQUARE_BRACKET     {
                                                                                                                                                        $$ = init_node("DIRECT_DECLARATOR", "", $1);
                                                                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                                                                        add_next($1, $3);
                                                                                                                                                        add_next($1, init_node($4, "", NULL));
                                                                                                                                                        add_next($1, $5);
                                                                                                                                                        add_next($1, init_node($6, "", NULL));
                                                                                                                                                    }
                                |   DIRECT_DECLARATOR LEFT_SQUARE_BRACKET TYPE_QUALIFIER_LIST_OPT MULTIPLICATION_OPERATOR RIGHT_SQUARE_BRACKET      {
                                                                                                                                                        $$ = init_node("DIRECT_DECLARATOR", "", $1);
                                                                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                                                                        add_next($1, $3);
                                                                                                                                                        add_next($1, init_node($4, "", NULL));
                                                                                                                                                        add_next($1, init_node($5, "", NULL));
                                                                                                                                                    }
                                |   DIRECT_DECLARATOR LEFT_PARANTHESIS PARAMETER_TYPE_LIST RIGHT_PARANTHESIS                                        {
                                                                                                                                                        $$ = init_node("DIRECT_DECLARATOR", "", $1);
                                                                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                                                                        add_next($1, $3);
                                                                                                                                                        add_next($1, init_node($4, "", NULL));
                                                                                                                                                    }
                                |   DIRECT_DECLARATOR LEFT_PARANTHESIS IDENTIFIER_LIST_OPT RIGHT_PARANTHESIS                                        {
                                                                                                                                                        $$ = init_node("DIRECT_DECLARATOR", "", $1);
                                                                                                                                                        add_next($1, init_node($2, "", NULL));
                                                                                                                                                        add_next($1, $3);
                                                                                                                                                        add_next($1, init_node($4, "", NULL));
                                                                                                                                                    }
                                ;

ASSIGNMENT_EXPRESSION_OPT       :   ASSIGNMENT_EXPRESSION   {$$ = init_node("ASSIGNMENT_EXPRESSION_OPT", "", $1);}
                                |                           {$$ = init_node("ASSIGNMENT_EXPRESSION_OPT", "", init_node("<empty>", "", NULL));}
                                ;

POINTER                         :   MULTIPLICATION_OPERATOR TYPE_QUALIFIER_LIST_OPT         {
                                                                                                tree_pointer temp = init_node($1, "", NULL);
                                                                                                $$ = init_node("POINTER", "", temp);
                                                                                                add_next(temp, $2);
                                                                                            }
                                |   MULTIPLICATION_OPERATOR TYPE_QUALIFIER_LIST_OPT POINTER {
                                                                                                tree_pointer temp = init_node($1, "", NULL);
                                                                                                $$ = init_node("POINTER", "", temp);
                                                                                                add_next(temp, $2);
                                                                                                add_next(temp, $3);
                                                                                            }
                                ;

TYPE_QUALIFIER_LIST             :   TYPE_QUALIFIER                      {$$ = init_node("TYPE_QUALIFIER_LIST", "", $1);}            
                                |   TYPE_QUALIFIER_LIST TYPE_QUALIFIER  {$$ = init_node("TYPE_QUALIFIER_LIST", "", $1); add_next($1, $2);}
                                ;

TYPE_QUALIFIER_LIST_OPT         :   TYPE_QUALIFIER_LIST                         {$$ = init_node("TYPE_QUALIFIER_LIST_OPT", "", $1);}
                                |                                               {$$ = init_node("TYPE_QUALIFIER_LIST_OPT", "", init_node("<empty>", "", NULL));}
                                ;

PARAMETER_TYPE_LIST             :   PARAMETER_LIST                  {$$ = init_node("PARAMETER_TYPE_LIST", "", $1);}
                                |   PARAMETER_LIST COMMA TRIPLE_DOT {
                                                                        $$ = init_node("PARAMETER_TYPE_LIST", "", $1);
                                                                        add_next($1, init_node($2, "", NULL));
                                                                        add_next($1, init_node($3, "", NULL));
                                                                    }
                                ;

PARAMETER_LIST                  :   PARAMETER_DECLARATION                       {$$ = init_node("PARAMETER_LIST", "", $1);}
                                |   PARAMETER_LIST COMMA PARAMETER_DECLARATION  {
                                                                                    $$ = init_node("PARAMETER_LIST", "", $1);
                                                                                    add_next($1, init_node($2, "", NULL));
                                                                                    add_next($1, $3);
                                                                                }
                                ;

PARAMETER_DECLARATION           :   DECLARATION_SPECIFIERS DECLARATOR           { $$ = init_node("PARAMETER_DECLARATION","",$1); add_next($1,$2 ); } 
                                |   DECLARATION_SPECIFIERS                      { $$ = init_node("PARAMETER_DECLARATION","",$1); }
                                ;

IDENTIFIER_LIST                 :   IDENTIFIER                                  {   $$ = init_node("IDENTIFIER_LIST","", init_node("IDENTIFIER",$1,NULL)); }
                                |   IDENTIFIER_LIST COMMA IDENTIFIER            {   $$ = init_node("IDENTIFIER_LIST","",$1);
                                                                                    add_next($1, init_node($2,"",NULL) );
                                                                                    add_next($1, init_node($3,"",NULL) );
                                                                                }
                                ;

IDENTIFIER_LIST_OPT             :   IDENTIFIER_LIST     { $$ = init_node("IDENTIFIER_LIST_OPT","",$1); }
                                |   { $$ = init_node("IDENTIFIER_LIST_OPT","",init_node("<empty>","",NULL)); }
                                ;

TYPE_NAME                       :   SPECIFIER_QUALIFIER_LIST                    { $$ = init_node("TYPE_NAME","",$1); }
                                ;

INITIALIZER                     :   ASSIGNMENT_EXPRESSION                       { $$ = init_node("INITIALIZER","",$1); }
                                |   LEFT_CURLY_BRACKET INITIALIZER_LIST RIGHT_CURLY_BRACKET    {    tree_pointer temp = init_node($1,"",NULL);
                                                                                                    $$ = init_node("INITIALIZER","",temp);
                                                                                                    add_next(temp, $2 );
                                                                                                    add_next(temp, init_node($3,"",NULL) );
                                                                                               }
                                |   LEFT_CURLY_BRACKET INITIALIZER_LIST COMMA RIGHT_CURLY_BRACKET    { }
                                ;

INITIALIZER_LIST                :   DESIGNATION_OPT INITIALIZER    {    $$ = init_node("INITIALIZER_LIST","",$1); 
                                                                        add_next($1, $2 );
                                                                   }
                                |   INITIALIZER_LIST COMMA DESIGNATION_OPT INITIALIZER  {   $$ = init_node("INITIALIZER_LIST","",$1); 
                                                                                            add_next($1, init_node($2,"",NULL) );
                                                                                            add_next($1, $3 );
                                                                                        }
                                ;

DESIGNATION                     :   DESIGNATOR_LIST EQUAL_OPERATOR  {   $$ = init_node("DESIGNATION","",$1); 
                                                                        add_next($1, init_node($2,"",NULL) );
                                                                    }
                                ;

DESIGNATION_OPT                 :   DESIGNATION  { $$ = init_node("DESIGNATION_OPT","",$1); }
                                |                { $$ = init_node("DESIGNATION_OPT","",init_node("<empty>","",NULL)); }
                                ;

DESIGNATOR_LIST                 :   DESIGNATOR                                  { $$ = init_node("DESIGNATOR_LIST","",$1); }
                                |   DESIGNATOR_LIST DESIGNATOR                  { $$ = init_node("DESIGNATOR_LIST","",$1); add_next($1,$2); }
                                ;
                        
DESIGNATOR                      :   LEFT_SQUARE_BRACKET CONSTANT_EXPRESSION RIGHT_SQUARE_BRACKET  {     tree_pointer temp = init_node($1,"",NULL);
                                                                                                        $$ = init_node("DESIGNATOR","",temp); 
                                                                                                        add_next(temp, $2 );
                                                                                                        add_next(temp, init_node($3,"",NULL) );
                                                                                                  }
                                |   DOT IDENTIFIER      {   tree_pointer temp = init_node($1,"",NULL); 
                                                            $$ = init_node("DESIGNATOR","",temp); 
                                                            add_next(temp, init_node("IDENTIFIER",$2,NULL) );
                                                        }
                                ;
              
// statements
STATEMENT                       : LABELED_STATEMENT    { $$ = init_node("STATEMENT","",$1); } 
                                | COMPOUND_STATEMENT   { $$ = init_node("STATEMENT","",$1); } 
                                | EXPRESSION_STATEMENT { $$ = init_node("STATEMENT","",$1); } 
                                | SELECTION_STATEMENT  { $$ = init_node("STATEMENT","",$1); } 
                                | ITERATION_STATEMENT  { $$ = init_node("STATEMENT","",$1); } 
                                | JUMP_STATEMENT       { $$ = init_node("STATEMENT","",$1); } 
                                ;

LABELED_STATEMENT               : IDENTIFIER TERNARY_SEPERATOR STATEMENT  {   tree_pointer temp = init_node("IDENTIFIER",$1,NULL); 
                                                                                $$ = init_node("LABELED_STATEMENT","",temp); 
                                                                                add_next(temp, init_node($2,"",NULL) );
                                                                                add_next(temp, $3 );
                                                                            } 
                                | CASE CONSTANT_EXPRESSION TERNARY_SEPERATOR STATEMENT {  tree_pointer temp = init_node($1,"",NULL); 
                                                                                            $$ = init_node("LABELED_STATEMENT","",temp); 
                                                                                            add_next(temp, $2 );
                                                                                            add_next(temp, init_node($3,"",NULL) );
                                                                                            add_next(temp, $4 );
                                                                                        } 
                                | DEFAULT TERNARY_SEPERATOR STATEMENT {   tree_pointer temp = init_node($1,"",NULL); 
                                                                            $$ = init_node("LABELED_STATEMENT","",temp); 
                                                                            add_next(temp, init_node($2,"",NULL) );
                                                                            add_next(temp, $3 );
                                                                        } 
                                ;

COMPOUND_STATEMENT              : LEFT_CURLY_BRACKET BLOCK_ITEM_LIST_OPT RIGHT_CURLY_BRACKET {   tree_pointer temp = init_node($1,"",NULL); 
                                                                                                    $$ = init_node("COMPOUND_STATEMENT","",temp); 
                                                                                                    add_next(temp, $2 );
                                                                                                    add_next(temp, init_node($3,"",NULL) );
                                                                                                } 
                                ;

BLOCK_ITEM_LIST                 : BLOCK_ITEM                 { $$ = init_node("BLOCK_ITEM_LIST","",$1);} 
                                | BLOCK_ITEM_LIST BLOCK_ITEM { $$ = init_node("BLOCK_ITEM_LIST","",$1); add_next($1,$2); } 
                                ;

BLOCK_ITEM                      : DECLARATION { $$ = init_node("BLOCK_ITEM","",$1); } 
                                | STATEMENT   { $$ = init_node("BLOCK_ITEM","",$1); } 
                                ;

EXPRESSION_STATEMENT            : EXPRESSION_OPT SEMI_COLON { $$ = init_node("EXPRESSION_STATEMENT","",$1); add_next($1,init_node($2,"",NULL)); } 
                                ;

SELECTION_STATEMENT             : IF LEFT_PARANTHESIS EXPRESSION RIGHT_PARANTHESIS STATEMENT {  tree_pointer temp = init_node($1,"",NULL); 
                                                                                                $$ = init_node("SELECTION_STATEMENT","",temp); 
                                                                                                add_next(temp, init_node($2,"",NULL) );
                                                                                                add_next(temp, $3 );
                                                                                                add_next(temp, init_node($4,"",NULL) );
                                                                                                add_next(temp, $5 );
                                                                                            } 
                                | IF LEFT_PARANTHESIS EXPRESSION RIGHT_PARANTHESIS STATEMENT ELSE STATEMENT {   tree_pointer temp = init_node($1,"",NULL); 
                                                                                                                $$ = init_node("SELECTION_STATEMENT","",temp); 
                                                                                                                add_next(temp, init_node($2,"",NULL) );
                                                                                                                add_next(temp, $3 );
                                                                                                                add_next(temp, init_node($4,"",NULL) );
                                                                                                                add_next(temp, $5 );
                                                                                                                add_next(temp, init_node($6,"",NULL) );
                                                                                                                add_next(temp, $7 );
                                                                                                            } 
                                | SWITCH LEFT_PARANTHESIS EXPRESSION RIGHT_PARANTHESIS STATEMENT {  tree_pointer temp = init_node($1,"",NULL); 
                                                                                                    $$ = init_node("SELECTION_STATEMENT","",temp); 
                                                                                                    add_next(temp, init_node($2,"",NULL) );
                                                                                                    add_next(temp, $3 );
                                                                                                    add_next(temp, init_node($4,"",NULL) );
                                                                                                    add_next(temp, $5 );
                                                                                                } 
                                ;

ITERATION_STATEMENT             : WHILE LEFT_PARANTHESIS EXPRESSION RIGHT_PARANTHESIS STATEMENT {  tree_pointer temp = init_node($1,"",NULL); 
                                                                                                    $$ = init_node("ITERATION_STATEMENT","",temp); 
                                                                                                    add_next(temp, init_node($2,"",NULL) );
                                                                                                    add_next(temp, $3 );
                                                                                                    add_next(temp, init_node($4,"",NULL) );
                                                                                                    add_next(temp, $5 );
                                                                                                } 
                                | DO STATEMENT WHILE LEFT_PARANTHESIS EXPRESSION RIGHT_PARANTHESIS SEMI_COLON {     tree_pointer temp = init_node($1,"",NULL); 
                                                                                                                    $$ = init_node("ITERATION_STATEMENT","",temp); 
                                                                                                                    add_next(temp, $2 );
                                                                                                                    add_next(temp, init_node($3,"",NULL) );
                                                                                                                    add_next(temp, init_node($4,"",NULL) );
                                                                                                                    add_next(temp, $5 );
                                                                                                                    add_next(temp, init_node($6,"",NULL) );
                                                                                                                    add_next(temp, init_node($7,"",NULL) );
                                                                                                            } 
                                | FOR LEFT_PARANTHESIS EXPRESSION_OPT SEMI_COLON EXPRESSION_OPT SEMI_COLON EXPRESSION_OPT RIGHT_PARANTHESIS STATEMENT {     tree_pointer temp = init_node($1,"",NULL); 
                                                                                                                                                            $$ = init_node("ITERATION_STATEMENT","",temp); 
                                                                                                                                                            add_next(temp, init_node($2,"",NULL) );
                                                                                                                                                            add_next(temp, $3 );
                                                                                                                                                            add_next(temp, init_node($4,"",NULL) );
                                                                                                                                                            add_next(temp, $5 );
                                                                                                                                                            add_next(temp, init_node($6,"",NULL) );
                                                                                                                                                            add_next(temp, $7 );
                                                                                                                                                            add_next(temp, init_node($8,"",NULL) );
                                                                                                                                                            add_next(temp, $9 );
                                                                                                                                                    } 
                                | FOR LEFT_PARANTHESIS DECLARATION EXPRESSION_OPT SEMI_COLON EXPRESSION_OPT RIGHT_PARANTHESIS STATEMENT {   tree_pointer temp = init_node($1,"",NULL); 
                                                                                                                                            $$ = init_node("ITERATION_STATEMENT","",temp); 
                                                                                                                                            add_next(temp, init_node($2,"",NULL) );
                                                                                                                                            add_next(temp, $3 );
                                                                                                                                            add_next(temp, $4 );
                                                                                                                                            add_next(temp, init_node($5,"",NULL) );
                                                                                                                                            add_next(temp, $6 );
                                                                                                                                            add_next(temp, init_node($7,"",NULL) );
                                                                                                                                            add_next(temp, $8 );
                                                                                                                                        } 
                                ;

JUMP_STATEMENT                  : GOTO IDENTIFIER SEMI_COLON {   tree_pointer temp = init_node($1,"",NULL);
                                                                $$ = init_node("JUMP_STATEMENT","",temp) ; 
                                                                add_next(temp,init_node($2,"",NULL)); 
                                                                add_next(temp,init_node($3,"",NULL));  
                                                            } 
                                | CONTINUE SEMI_COLON        {  tree_pointer temp = init_node($1,"",NULL);
                                                                $$ = init_node("JUMP_STATEMENT","",temp) ; 
                                                                add_next(temp,init_node($2,"",NULL));
                                                            } 
                                | BREAK SEMI_COLON            {  tree_pointer temp = init_node($1,"",NULL);
                                                                $$ = init_node("JUMP_STATEMENT","",temp) ; 
                                                                add_next(temp,init_node($2,"",NULL));
                                                            } 
                                | RETURN EXPRESSION_OPT SEMI_COLON {  tree_pointer temp = init_node($1,"",NULL);
                                                                    $$ = init_node("JUMP_STATEMENT","",temp) ; 
                                                                    add_next(temp,$2);
                                                                    add_next(temp,init_node($3,"",NULL));
                                                                } 
                                ;

// Optional non-terminals
BLOCK_ITEM_LIST_OPT             : BLOCK_ITEM_LIST { $$ = init_node("BLOCK_ITEM_LIST_OPT","",$1); } 
                                | /* empty */     { $$ = init_node("BLOCK_ITEM_LIST_OPT","",init_node("<empty>","",NULL)); } 
                                ;

EXPRESSION_OPT                  : EXPRESSION  { $$ = init_node("EXPRESSION_OPT","",$1); } 
                                | /* empty */ { $$ = init_node("EXPRESSION_OPT","",init_node("<empty>","",NULL)); } 
                                ;

/*External definitions*/

TRANSLATIONAL_UNIT              :   EXTERNAL_DECLARATION                        {   parse_tree = init_node("TRANSLATIONAL_UNIT","",$1);
                                                                                    $$=parse_tree;
                                                                                }
                                |   TRANSLATIONAL_UNIT EXTERNAL_DECLARATION     {   parse_tree = init_node("TRANSLATIONAL_UNIT","",$1);
                                                                                    add_next($1,$2);
                                                                                    $$ = parse_tree;
                                                                                }
                                ;

EXTERNAL_DECLARATION            :   FUNCTION_DEFINITION                         { $$ = init_node("EXTERNAL_DECLARATION","",$1); }
                                |   DECLARATION                                 { $$ = init_node("EXTERNAL_DECLARATION","",$1); }
                                ;

FUNCTION_DEFINITION             :   DECLARATION_SPECIFIERS DECLARATOR DECLARATION_LIST_OPT COMPOUND_STATEMENT   { $$ = init_node("FUNCTION_DEFINITION","",$1); add_next($1,$2); add_next($2,$3); add_next($3,$4); }
                                ;

DECLARATION_LIST                :   DECLARATION                                 { $$ = init_node("DECLARATION_LIST","",$1); }                                             
                                |   DECLARATION_LIST DECLARATION                { $$ = init_node("DECLARATION_LIST","",$1); add_next($1,$2); }
                                ;

DECLARATION_LIST_OPT            :   DECLARATION_LIST                            { $$ = init_node("DECLARATION_LIST_OPT","",$1); }
                                |                                               { $$ = init_node("DECLARATION_LIST_OPT","",NULL); }
                                ;                        
%%

void yyerror(char *s) {
    fprintf(stderr, "Error: %s at line %d, near '%s'\n", s, yylineno, yytext);
}