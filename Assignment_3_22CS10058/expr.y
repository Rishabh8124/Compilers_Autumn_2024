%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    int yylex();
    void yyerror(char *s);

    typedef struct identifier_node { // Structure for symbol table nodes
    char * name;                    // Identifier name (empty for constants)
    int value;                      // Value of the identifier
    int set_val;                    // Boolean to check if value is set or not
    int type;                       // Constant or identifier
    struct identifier_node *next;   // Pointer to next node
    } symbol_table;

    typedef symbol_table * T;

    T add_id(T * root, char * id, int t, int value);
    T get_id(T root, char * id, int t, int value);

    typedef struct tree_node {      // Structure for tree nodes
        int type;                   // Pointer to symbol table or operator
        union values {              // TO store the different values
            char * oper;
            T st_address;
        } val;
        struct tree_node * left;    // Left child
        struct tree_node * right;   // Right child

    } tree_node;

    typedef tree_node * expr_tree;

    expr_tree add_child (expr_tree expression_tree, T st_pointer, char * op, expr_tree parent, int type);

    expr_tree init_node_op(char * op);
    expr_tree init_node_tl(T st_pointer);

    int binary_exponentiation(int a, int b);
    int eval_expr(expr_tree current);
    void free_tree(expr_tree expression);
    void print_st(T st);

    T symbols = NULL;       // Global symbol table
    T temp, temp1;
%}
 
%union {int num; char * id; char * op; expr_tree expression;}
%start PROGRAM
%token SET 
%token <id> ID
%token <num> NUM
%token <op> PLUS SUB MUL REM DIV EXPT LP RP

%type STMT SETSTMT EXPRSTMT 
%type <expression> EXPR OP ARG

%%
PROGRAM     :   STMT PROGRAM            { }
            |   STMT                    { }
            ;
STMT        :   SETSTMT                 { }
            |   EXPRSTMT                { }
            ;
SETSTMT     :   LP SET ID NUM RP      {
                    temp = add_id(&symbols, $3, 0, 0);
                    temp->value = $4;
                    temp->set_val = 1;
                    printf("Variable %s is set to %d\n", temp->name, temp->value);
                }
            |   LP SET ID ID RP       {
                    temp1 = get_id(symbols, $4, 0, 0); 
                    if (temp1 == NULL) {yyerror("Variable not found");}
                    if (temp1->set_val == 0) {yyerror("Value not assigned to variable");}
                    else {
                        temp = add_id(&symbols, $3, 0, 0);
                        temp->value = temp1->value;
                        temp->set_val = 1;
                        printf("Variable %s is set to %d\n", temp->name, temp->value);
                    }
                }
            |   LP SET ID EXPR RP     {
                    temp = add_id(&symbols, $3, 0, 0);
                    if (symbols == NULL) symbols = temp;
                    temp->value = eval_expr($4);
                    temp->set_val = 1;
                    printf("Variable %s is set to %d\n", temp->name, temp->value);
                    free_tree($4);
                }
            ;
EXPRSTMT    :   EXPR                    {printf("Standalone expression evaluates to %d\n", eval_expr($1)); free_tree($1);}
            ;
EXPR        :   LP OP ARG ARG RP        {$$ = $2; $$->left = $3; $$->right = $4;}
            ;
OP          :   PLUS                    {$$ = init_node_op($1);}
            |   SUB                     {$$ = init_node_op($1);}
            |   MUL                     {$$ = init_node_op($1);}
            |   DIV                     {$$ = init_node_op($1);}
            |   REM                     {$$ = init_node_op($1);}
            |   EXPT                    {$$ = init_node_op($1);}
            ;
ARG         :   ID                      {temp = add_id(&symbols, $1, 0, 0); $$ = init_node_tl(temp);}
            |   NUM                     {temp = add_id(&symbols, "", 1, $1); $$ = init_node_tl(temp);}
            |   EXPR                    {$$ = $1;}
            ;
%%

void yyerror(char * s) {
    printf("\nError: %s\n", s);

    exit(0);
    return;
}
