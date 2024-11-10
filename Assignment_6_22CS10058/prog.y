/*NAME - S.RISHABH*/
/*ROLL NUMBER - 22CS10058*/

%{
    #include <iostream>
    #include <vector>
    #include <map>
    #include <fstream>

    using namespace std;

    int yylex();
    extern int yylineno;
    void yyerror(string);

    class Symbol {
        public:
            string id;
            int current_register;
            int latest;

            Symbol(string = "", int = -1);
    };

    class Symbol_table {
        public:
            vector<Symbol *> symbols;

            Symbol_table();
            string gentemp();
            Symbol * lookup(string);
    };

    class Quad {
        public:
            string op;
            string arg1;
            string arg2;
            string res;
            int bl;

            Quad(string = "", string = "", string = "", string = "");
    };

    void emit(Quad *);

    char * string_to_char(string);

    string int_to_string(int);

    Symbol_table global_table;

    vector<Quad *> quads;
    vector<Quad *> target_code;

    int instr_line = 0;
    int temp_count = 1;
    int target_code_number = 0;
%}

%union {int num; char * id; char * op; char * var; int next; }

%start PROG

%token <num> NUM
%token <id> IDEN
%token <op> OPER
%token <op> RELN
%token LP
%token RP
%token SET
%token WHEN
%token WHILE
%token LOOP_TERM

%type LIST

%type <var> ATOM
%type <var> EXPR

%type <next> N
%type <next> BOOL
%type <next> STMT
%type <next> ASGN
%type <next> COND
%type <next> LOOP

%type <num> M

%%
PROG    : LIST                                  { 
                                                    emit(new Quad("end"));
                                                    quads[0]->bl = 1;
                                                    quads[instr_line-1]->bl = 1; 
                                                }

LIST    : STMT M                                { if ($1 != -1) quads[$1]->res = int_to_string($2+1); }
        | STMT M LIST                           { 
                                                    if ($1 != -1) {
                                                        quads[$2]->bl = 1;
                                                        quads[$1]->res = int_to_string($2+1);
                                                    }
                                                }
        ;

STMT    : ASGN                                  { $$ = $1; }
        | COND                                  { $$ = $1; }
        | LOOP                                  { $$ = $1; }
        ;

ASGN    : LP SET IDEN ATOM RP                   {
                                                    $$ = -1;
                                                    emit(new Quad(":=", $4, "", $3));
                                                }
        ;

COND    : LP WHEN BOOL M LIST RP                { 
                                                    $$ = $3;
                                                    quads[$4]->bl = 1;
                                                }
        ;

LOOP    : LP LOOP_TERM WHILE M BOOL M LIST N RP {
                                                    $$ = $5;
                                                    quads[$8]->res = int_to_string($4+1);
                                                    quads[$4]->bl = 1;
                                                    quads[$6]->bl = 1;
                                                }
        ;

EXPR    : LP OPER ATOM ATOM RP                  {
                                                    $$ = string_to_char(global_table.gentemp());
                                                    emit(new Quad($2, $3, $4, $$));
                                                }
        ;

BOOL    : LP RELN ATOM ATOM RP                  {
                                                    $$ = instr_line;
                                                    emit(new Quad($2, $3, $4));
                                                }
        ;

ATOM    : IDEN                                  { $$ = $1; }
        | NUM                                   { $$ = string_to_char(int_to_string($1)); }
        | EXPR                                  { $$ = $1; }
        ;

M       :                                       { $$ = instr_line; }
        ;

N       :                                       { 
                                                    $$ = instr_line;
                                                    emit(new Quad("goto")); 
                                                }
        ;       
%%


void yyerror (string error) {
    cout << error << endl;
}