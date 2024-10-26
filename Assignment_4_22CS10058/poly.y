/*NAME - S.RISHABH*/
/*ROLL NUMBER - 22CS10058*/

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yylex();
    void yyerror(char *s);

    typedef struct node {
        char type;      /*Store the type of the node*/
        union {         /*Inherited value for T, P, M*/
            int val;
            char sign;
        } inh;
        int val;        /*Value for terminals and syn values for N, M*/

        struct node * child[3];
        
    } node;

    typedef node * tree;

    tree init_node(char type);
    tree init_node_t(char type, int val);
    void add_child(tree root, tree child, int index);
    void print_tree(tree root, int depth);

    // Global tree to be used for inh, syn value calculations and further processes
    tree parse_tree = NULL;
%}

/* int to catch integer returns from lex*/ 
/* char to store operations and variable */
/* treenode to create the nodes of the tree*/

%union {int val; char symbol; tree treenode;}

%start S

%token <symbol> PLUS MINUS EXPT V
%token <val> Z O D

%type <treenode> P T N M X

%%
S   : P         {parse_tree = init_node('S'); add_child(parse_tree, $1, 0);}
    | PLUS P    {parse_tree = init_node('S'); add_child(parse_tree, init_node('+'), 0); add_child(parse_tree, $2, 1);}
    | MINUS P   {parse_tree = init_node('S'); add_child(parse_tree, init_node('-'), 0); add_child(parse_tree, $2, 1);}
    ;

P   : T         {$$ = init_node('P'); add_child($$, $1, 0);}
    | T PLUS P  {$$ = init_node('P'); add_child($$, $1, 0); add_child($$, init_node('+'), 1); add_child($$, $3, 2);}
    | T MINUS P {$$ = init_node('P'); add_child($$, $1, 0); add_child($$, init_node('-'), 1); add_child($$, $3, 2);}
    ;

T   : O         {$$ = init_node('T'); add_child($$, init_node_t('O', $1), 0);}
    | N         {$$ = init_node('T'); add_child($$, $1, 0);}
    | X         {$$ = init_node('T'); add_child($$, $1, 0);}
    | N X       {$$ = init_node('T'); add_child($$, $1, 0); add_child($$, $2, 1);}
    ;

X   : V         {$$ = init_node('X'); add_child($$, init_node('x'), 0);}
    | V EXPT N  {$$ = init_node('X'); add_child($$, init_node('x'), 0); add_child($$, init_node('^'), 1); add_child($$, $3, 2);}
    ;

N   : D         {$$ = init_node('N'); add_child($$, init_node_t('D', $1), 0);}
    | O M       {$$ = init_node('N'); add_child($$, init_node_t('O', $1), 0); add_child($$, $2, 1);}
    | D M       {$$ = init_node('N'); add_child($$, init_node_t('D', $1), 0); add_child($$, $2, 1);}
    ;

M   : Z         {$$ = init_node('M'); add_child($$, init_node_t('Z', $1), 0);}
    | O         {$$ = init_node('M'); add_child($$, init_node_t('O', $1), 0);}
    | D         {$$ = init_node('M'); add_child($$, init_node_t('D', $1), 0);}
    | Z M       {$$ = init_node('M'); add_child($$, init_node_t('Z', $1), 0); add_child($$, $2, 1);}
    | O M       {$$ = init_node('M'); add_child($$, init_node_t('O', $1), 0); add_child($$, $2, 1);}
    | D M       {$$ = init_node('M'); add_child($$, init_node_t('D', $1), 0); add_child($$, $2, 1);}
    ;                     
%%

void yyerror(char * s) {printf("%s\n", s); return;}
