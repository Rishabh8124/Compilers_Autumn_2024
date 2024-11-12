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

    class Symbol {                  // Symbol structure to store the data of a variable being created during intermediate code generation
        public:
            string id;              // Variable name
            int current_register;   // The register in which the present value of the variable is stored
            int latest;             // If its value has been modified in the current block being processed

            Symbol(string = "", int = -1);
    };

    class Symbol_table {            // To simplify functions like lookup and gentemp
        public:
            vector<Symbol *> symbols;

            Symbol_table();
            string gentemp();
            Symbol * lookup(string);
    };

    class Quad {                    // Quad for creating intermediate code and target code
        public:
            string op;
            string arg1;
            string arg2;
            string res;
            int bl;                 // Indicates the start of new block

            Quad(string = "", string = "", string = "", string = "");
    };

    void emit(Quad *);              // Push quad into quad array

    // Additiona functions for data type conversion
    char * string_to_char(string);
    string int_to_string(int);

    // Global variables
    Symbol_table global_table;

    vector<Quad *> quads;
    vector<Quad *> target_code;

    int instr_line = 0;
    int temp_count = 1;
    int target_code_number = 0;

    int error_bool = 0;
%}

%union {int num; char * id; char * op; char * var; int next; }

/* PROG -> LIST => To capture the end of program */

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

%type <next> BOOL
%type <next> STMT
%type <next> ASGN
%type <next> COND
%type <next> LOOP

%type <next> M
%type <next> N


%%
PROG    : LIST                                  { 
                                                    emit(new Quad("end"));
                                                    quads[0]->bl = 1;               // 1st line is beginning of new block
                                                    quads[instr_line-1]->bl = 1;    // End line is beginning of new block
                                                }
        | error PROG                            { error_bool = 1; yyerrok; }
        ;

LIST    : STMT M                                { 
                                                    if ($1 != -1) quads[$1]->res = int_to_string($2+1); // Backpatching
                                                }
        | STMT M LIST                           { 
                                                    if ($1 != -1) {                             // If $1 == -1, there is no goto in STMT, hence not a new block
                                                        quads[$2]->bl = 1;                      // Beginning of new block
                                                        quads[$1]->res = int_to_string($2+1);   // Backpatching
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
                                                    $$ = $3;            // goto of BOOL is COND.next (performing iffalse to remove redundant gotos)
                                                    quads[$4]->bl = 1;  // Beginning of new block in LIST (follows a goto statement)
                                                }
        ;

LOOP    : LP LOOP_TERM WHILE M BOOL M LIST N RP {
                                                    $$ = $5;            // goto of BOOL is LOOP.next (performing iffalse to remove redundant gotos)
                                                    quads[$8]->res = int_to_string($4+1);
                                                    quads[$4]->bl = 1;  // Beginning of new block (followed by the goto in bool)
                                                    quads[$6]->bl = 1;  // Beginning of new block (followed by the goto of N [go back to start of loop])
                                                }
        ;

EXPR    : LP OPER ATOM ATOM RP                  {
                                                    $$ = string_to_char(global_table.gentemp());
                                                    emit(new Quad($2, $3, $4, $$));
                                                }
        ;

BOOL    : LP RELN ATOM ATOM RP                  {
                                                    $$ = instr_line;    // The instruction in this line has a goto, so store this line number to perform backpatch
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
    cout << error << " at line number " << yylineno << endl;
}