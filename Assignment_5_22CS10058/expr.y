/*NAME - S.RISHABH*/
/*ROLL NUMBER - 22CS10058*/

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yylex();
    int yylineno;
    void yyerror();

    typedef struct mem_location {                       // To pass the location of where the temporary variables are being stored
        char * loc;
        int pos;
        int type;                                       // To tell if the argument was reduced from expr or other grammar symbols
    } mem_loc;

    typedef struct identifier_node {                    // Symbol table node to store the name and index
        char * name;
        int offset;
        struct identifier_node * next;
    } symbol_table;

    typedef symbol_table * T;

    char * int_to_str (int value);                      // To ease convertion of integer to string when passing through grammar symbols

    int add_id(T * root, char * id, int * mem_count);   // Adding a new variable to symbol table, which returns the offset 
    int get_id(T root, char * id);                      // Returns the offset of the variable name

    T symbols = NULL;
    int temp, temp1;
    int temp_count = 2, mem_count = 0;                  // Registers 0 and 1 are purely for fetching and R0 is used for computing temp value if there is a overflow and the calculated value is stored in the next free memory

    FILE * fptr;                                        // Printing the code directly in file (intcodegen.c should create intcode.c)
%}

%union {int num; char * id; char op; mem_loc mem;}
%start PROGRAM
%token SET 
%token <id> ID
%token <num> NUM 
%token <op> EXPT PLUS SUB MUL REM DIV

%type STMT EXPRSTMT
%type <num> SETSTMT
%type <op> OP
%type <mem> ARG EXPR

%%
PROGRAM     :   STMT PROGRAM            { }
            |   STMT                    { }
            |   error                   { temp_count = 2; }     /* Catching error and skipping it to execute further statements*/
                PROGRAM                 { yyerrok; }
            ;
STMT        :   SETSTMT                 { fprintf(fptr, "\n\tmprn(MEM, %d);\n\n", $1); temp_count = 2; }
            |   EXPRSTMT                { }
            ;
SETSTMT     :   '(' SET ID NUM ')'      {
                    temp = add_id(&symbols, $3, &mem_count);
                    fprintf(fptr, "\tMEM[%d] = %d;\n", temp, $4);
                    $$ = temp;
                }
            |   '(' SET ID ID ')'       {
                    temp = get_id(symbols, $4);
                    if (temp == -1) fprintf(fptr, "\tprintf(\"\\n--- WARNING: %s not initialized. Initializing to 0\\n\\n\");\n\n", $4);

                    temp1 = add_id(&symbols, $4, &mem_count);
                    temp = add_id(&symbols, $3, &mem_count);

                    fprintf(fptr, "\tR[0] = MEM[%d];\n", temp1);
                    fprintf(fptr, "\tMEM[%d] = R[0];\n", temp);
                    $$ = temp;
                }
            |   '(' SET ID EXPR ')'     {
                                            temp = add_id(&symbols, $3, &mem_count);
                                            fprintf(fptr, "\tMEM[%d] = R[%d];\n", temp, ($4).pos);
                                            $$ = temp;
                                        }
            ;
EXPRSTMT    :   EXPR                    { fprintf(fptr, "\n\teprn(%s, %d);\n\n", ($1).loc, ($1).pos); temp_count = 2; }
            ;
EXPR        :   '(' OP ARG ARG ')'      {
                                            char * pos1, * pos2;
                                            int expr_count = 0;
                                            int fetch_reg = 0;

                                            /* Calculating the register to be used for the current expr evaluation. */
                                            /* If the children that is the production of arg gave expr, the registers used for that production is currently free and can be used */

                                            if (($3).loc == NULL) pos1 = int_to_str(($3).pos);
                                            else if (strcmp(($3).loc, "MEM") == 0) {
                                                fprintf(fptr, "\tR[%d] = MEM[%d];\n", fetch_reg++,($3).pos);    // Fetching from memory and storing it in R[0]
                                                pos1 = (char *) malloc (3);
                                                pos1 = strdup("R[");
                                                strcat(pos1, int_to_str(fetch_reg-1));
                                                strcat(pos1, "]");
                                            } else {
                                                pos1 = (char *) malloc (3);
                                                pos1 = strdup("R[");
                                                strcat(pos1, int_to_str(($3).pos));
                                                strcat(pos1, strdup("]"));
                                            }

                                            expr_count += (($3).type);

                                            if (($4).loc == NULL) pos2 = int_to_str(($4).pos);
                                            else if (strcmp(($4).loc, "MEM") == 0) {
                                                fprintf(fptr, "\tR[%d] = MEM[%d];\n", fetch_reg++,($4).pos);
                                                pos2 = (char *) malloc (3);
                                                pos2 = strdup("R[");
                                                strcat(pos2, int_to_str(fetch_reg-1));
                                                strcat(pos2, "]");
                                            } else {
                                                pos2 = (char *) malloc (3);
                                                pos2 = strdup("R[");
                                                strcat(pos2, int_to_str(($4).pos));
                                                strcat(pos2, strdup("]"));
                                            }

                                            expr_count += (($4).type);

                                            temp_count -= expr_count;
                                            
                                            if (temp_count > 11) {
                                                if ($2 != '^') fprintf(fptr, "\tR[0] = %s %c %s;\n", pos1, $2, pos2);
                                                else fprintf(fptr, "\tR[0] = pwr(%s, %s);\n", pos1, pos2);

                                                fprintf(fptr, "\tMEM[%d] = R[0];\n", mem_count);
                                                temp_count++;
                                                $$.loc = (char *) malloc (4);
                                                $$.loc[0] = 'M';
                                                $$.loc[1] = 'E';
                                                $$.loc[2] = 'M';
                                                $$.loc[3] = '\0';
                                                $$.pos = mem_count;
                                                $$.type = 1;

                                                char * var_name = (char *) malloc (2);
                                                var_name[0] = '$';
                                                var_name[1] = '\0';
                                                strcat(var_name, int_to_str(mem_count));
                                                add_id(&symbols, var_name, &mem_count);
                                            } else {
                                                if ($2 != '^') fprintf(fptr, "\tR[%d] = %s %c %s;\n", temp_count, pos1, $2, pos2);
                                                else fprintf(fptr, "\tR[%d] = pwr(%s, %s);\n", temp_count, pos1, pos2);
                                                temp_count++;
                                                $$.loc = (char *) malloc (2);
                                                $$.loc[0] = 'R';
                                                $$.loc[1] = '\0';
                                                $$.pos = temp_count-1;
                                                $$.type = 1;
                                            }                       
                                        }
            ;
OP          :   PLUS                    { $$ = $1; }
            |   SUB                     { $$ = $1; }
            |   MUL                     { $$ = $1; }
            |   DIV                     { $$ = $1; }
            |   REM                     { $$ = $1; }
            |   EXPT                    { $$ = $1; }
            ;
ARG         :   ID                      { 
                                            temp = get_id(symbols, $1);
                                            if (temp == -1) {
                                                fprintf(fptr, "\tprintf(\"\\n--- WARNING: %s not initialized. Initializing to 0\\n\\n\");\n\n", $1);
                                            }
                                            temp = add_id(&symbols, $1, &mem_count);
                                            $$.loc = "MEM";
                                            $$.pos = temp;
                                            $$.type = 0;
                                        }
            |   NUM                     {   
                                            $$.loc = NULL;
                                            $$.pos = $1;
                                            $$.type = 0;
                                        }
            |   EXPR                    { $$ = $1; }
            ;
%%

void yyerror(char * error) { fprintf(fptr, "\tprintf(\"\\n!!! Syntax Error at line number %d\\n\\n\");\n\n", yylineno); }
