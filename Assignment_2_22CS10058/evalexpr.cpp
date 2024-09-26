// Name - S.Rishabh
// Roll number - 22CS10058

/*
GRAMMAR -

Terminals       -   {(, ), +, -, *, /, %, id, num}
Non terminals   -   {EXPR, OP, ARG, LP, RP, ID, NUM}


EXPR    ->      LP OP ARG ARG RP
OP      ->      + | - | * | / | %
ARG     ->      ID | NUM | EXPR

LP      ->      (
ID      ->      id
NUM     ->      num
RP      ->      rp
*/

/*
PARSE TABLE -

NT\T              (                    ID              NUM                OP              )
LP              ( -> (
EXPR            EXPR->(OP ARG ARG)
OP                                                                     OP-> +|-|*|/|%
ARG             ARG->EXPR               ARG->ID         ARG->NUM              
RP                                                                                        ) -> )
ID                                       ID->id
NUM                                                     NUM->num
*/

#include <iostream>
#include <stack>
#include "lex.yy.c"

using namespace std;

// Structure for identifiers table
typedef struct identifier_node {
   string name;
   int value;
   struct identifier_node *next;

} id_node;

typedef id_node * T;

T push_identifier(T root, string s, T &address) {
    T head = root;
    while(head != NULL) {
        if (head->name == s) {
            address = head;
            return root;
        }

        head = head->next;
    }

    T new_point = (T) malloc(sizeof(id_node));
    new_point->name = s;
    new_point->next = NULL;

    address = new_point;
    head = root;
    if (head == NULL) {
        return new_point;
    } else {
        while(head->next != NULL) head = head->next;
        head->next = new_point;
    }
    
    return root;
}

// Structure for constants table
typedef struct constant_node {
   int value;
   struct constant_node *next;

   constant_node(int n1): value(n1), next(NULL) {}
} c_node;

typedef c_node * C;

C push_integer(C root, int s, C &address) {
    C head = root;
    
    while(head != NULL) {
        if (head->value == s) {
            address = head;
            return root;
        }

        head = head->next;
    }

    C new_point = (C) malloc(sizeof(c_node));
    new_point->value = s;
    new_point->next = NULL;

    address = new_point;
    head = root;
    if (head == NULL) {
        return new_point;
    } else {
        while(head->next != NULL) head = head->next;
        head->next = new_point;
    }
    
    return root;
}

// String to int conversion
int string_to_int(string s) {
    int num = 0;
    int v = 1;
    int i=0;

    if (s[0] == '-') {v = -1; i++;}
    else if (s[0] == '+') {i++;}

    while(i<s.size()) {
        num = num*10 + s[i]-'0';
        i++;
    }
    return num*v;   
}

// Structure for tree node
typedef struct tree_node {
    int type;
    union values {
        char oper;
        T id_address;
        C int_address;
    } val;
    struct tree_node * parent;
    struct tree_node * left;
    struct tree_node * right;
} tree_node;

typedef tree_node * Tree;

void init(Tree x, int t, char s) { x->type = t; x->val.oper = s; x->left=NULL; x->right=NULL; x->parent=NULL; }
void init(Tree x, int t, T s) { x->type = t; x->val.id_address = s; x->left=NULL; x->right=NULL; x->parent=NULL; }
void init(Tree x, int t, C s) { x->type = t; x->val.int_address = s; x->left=NULL; x->right=NULL; x->parent=NULL; }

// Printing and evaluating eval tree
int eval_tree(Tree t, int d) {
    for(int i=0; i<d-1; i++) {
        cout << "\t";
    }
    if (d) cout << "--> ";
    if (t->type == OP) {
        cout << "OP( " << t->val.oper << " )" << endl;
        int l = eval_tree(t->left, d+1);
        int r = eval_tree(t->right, d+1);

        if (t->val.oper == '+') return l+r;
        if (t->val.oper == '-') return l-r;
        if (t->val.oper == '*') return l*r;
        if (t->val.oper == '%') {
            if (r) return l%r;
            else {
                cout << "Divide by zero error\n" << endl;
                exit(0);
            }
        }
        if (t->val.oper == '/') {
            if (r) return l/r;
            else {
                cout << "Divide by zero error\n" << endl;
                exit(0);
            }
        }
    } else if (t->type == ID) {
        cout << "ID( " << t->val.id_address->name << " )" << endl;
        return t->val.id_address->value;
    } else {
        cout << "NUM( " << t->val.int_address->value << " )" << endl;
        return t->val.int_address->value;
    }

    return 0;
}

int main(int argc, char* argv[]) {
    int parse_table[7][5][5];

    int identifier_count = 0;
    T identifiers = NULL, storing_val=NULL;
    C constants = NULL;
    Tree parse_tree = NULL, current_node;

    // Manually initializing parse table
    
    /*
    parse_table[i][j][k] > 0 -> Push in stack
    parse_table[i][j][k] == 0 -> Error
    parse_table[i][j][k] == -1 -> Terminal matching, move to next input
    parse_table[i][j][k] == -2 -> Move to next iter (not next input)

    Index based on parse table in comments at the start.
    3rd dimension to store the indices to be pushed inside the stack
    */
    
    parse_table[0][0][0] = -1;

    parse_table[1][0][0] = 5;
    parse_table[1][0][1] = 4;
    parse_table[1][0][2] = 4;
    parse_table[1][0][3] = 3;
    parse_table[1][0][4] = 1;
    
    parse_table[2][3][0] = -1;

    parse_table[3][0][0] = 2;
    parse_table[3][0][1] = -2;
    
    parse_table[3][1][0] = 6;
    parse_table[3][1][1] = -2;

    parse_table[3][2][0] = 7;
    parse_table[3][2][1] = -2;

    parse_table[4][4][0] = -1;

    parse_table[5][1][0] = -1;

    parse_table[6][2][0] = -1;

    stack<int> parsing;
    int ntoken = yylex();
    int next_input = 0;
    parsing.push(2); // Start symbol

    while(ntoken) {
        
        if (next_input) {
            ntoken = yylex();
            next_input = 0;

            if (ntoken == 0) break;
        }

        if (ntoken == 10) {next_input = 1; continue;}

        string token = yytext;

        // Expression parsing complete, taking input for variables
        if (parsing.empty()) {
            if (ntoken != NUM) {
                cout << "*** Error: Expected end of file, but found input" << endl;
                return 0;
            } else {
                int value = string_to_int(token);
                if (storing_val == NULL) {
                    cout << "*** Error: Expected end of file, but found input" << endl;
                    return 0;
                } else {
                    storing_val->value = value;
                    storing_val = storing_val->next;
                }
            }
            next_input = 1;
            continue;
        }

        // Syntax analysis from tokens returned by lexical analyser
        switch(ntoken) {
            case GARBAGE: // Unexpected inputs
                cout << "Unrecognized expression found" << endl;
                return 0;

            case OPER1: // Invalid operators like ||, &&, Relop, etc..
                cout << "Invalid operator " << token << " found" << endl;
                return 0;

            case NUM: // Constant value
                C temp; // Stores the reference address of the given value
                constants = push_integer(constants, string_to_int(token), temp);
                
                while (next_input == 0) { // Processing the stack till the NT and Terminal match
                    int stack_top = parsing.top();
                    parsing.pop();

                    for(int i=0; i<5; i++) {
                        if (parse_table[stack_top-1][2][i] == 0) {
                            if (stack_top == 1 || stack_top == 2) cout << "Expected ( but found " << token << endl;
                            if (stack_top == 5) cout << "Expected ) but found " << token << endl;
                            if (stack_top == 3) cout << "Operator expected but found " << token << endl;
                            if (stack_top == 4) cout << "ID/NUM/( expected but found " << token << endl;
                            return 0;

                        } else if (parse_table[stack_top-1][2][i] == -1) { // Update in parse tree
                            if (current_node->left == NULL) {
                                current_node->left = (Tree) malloc(sizeof(tree_node));
                                current_node->left->parent = current_node;
                                init(current_node->left, ntoken, temp);
                            } else {
                                current_node->right = (Tree) malloc(sizeof(tree_node));
                                current_node->right->parent = current_node;
                                init(current_node->right, ntoken, temp);

                                while(current_node != NULL && current_node->right != NULL) {current_node = current_node->parent;}
                            }

                            next_input = 1;
                            break;
                        } else if (parse_table[stack_top-1][2][i] == -2) {
                            break;
                        } else { // Update the stack
                            parsing.push(parse_table[stack_top-1][2][i]);
                        }
                    }
                }

                break;

            case ID: // Identifiers
                T temp1; // Stores the reference address of the variable
                identifiers = push_identifier(identifiers, token, temp1);
                storing_val = identifiers;

                while (next_input == 0) { // Processing the stack till the NT and Terminal match
                    int stack_top = parsing.top();
                    parsing.pop();               
                    for(int i=0; i<5; i++) {
                        if (parse_table[stack_top-1][1][i] == 0) {
                            if (stack_top == 1 || stack_top == 2) cout << "Expected ( but found " << token << endl;
                            if (stack_top == 5) cout << "Expected ) but found " << token << endl;
                            if (stack_top == 3) cout << "Operator expected but found " << token << endl;
                            if (stack_top == 4) cout << "ID/NUM/( expected but found " << token << endl;
                            return 0;
                        } else if (parse_table[stack_top-1][1][i] == -1) {
                            if (current_node->left == NULL) {
                                current_node->left = (Tree) malloc(sizeof(tree_node));
                                current_node->left->parent = current_node;
                                init(current_node->left, ntoken, temp1);
                            } else {
                                current_node->right = (Tree) malloc(sizeof(tree_node));
                                current_node->right->parent = current_node;
                                init(current_node->right, ntoken, temp1);

                                while(current_node != NULL && current_node->right != NULL) {current_node = current_node->parent;}
                            }
                            next_input = 1;
                            break;
                        } else if (parse_table[stack_top-1][1][i] == -2) {
                            break;
                        } else {
                            parsing.push(parse_table[stack_top-1][1][i]);
                        }
                    }
                }
                break;

            case EXPR_START: // LP "("
                while (next_input == 0) { // Processing the stack till the NT and Terminal match
                    int stack_top = parsing.top();
                    parsing.pop();
                                        
                    for(int i=0; i<5; i++) {
                        if (parse_table[stack_top-1][0][i] == 0) {
                            if (stack_top == 5) cout << "Expected ) but found " << token << endl;
                            if (stack_top == 3) cout << "Operator expected but found " << token << endl;
                            if (stack_top == 6) cout << "Expected ID but found " << token << endl;
                            if (stack_top == 7) cout << "Expected NUM but found " << token << endl;
                            return 0;
                        } else if (parse_table[stack_top-1][0][i] == -1) {
                            next_input = 1;
                            break;
                        } else if (parse_table[stack_top-1][0][i] == -2) {
                            break;
                        } else {
                            parsing.push(parse_table[stack_top-1][0][i]);
                        }
                    }
                }
                break;

            case EXPR_END:
                while (next_input == 0) { // Processing the stack till the NT and Terminal match
                    int stack_top = parsing.top();
                    parsing.pop();
                    
                    for(int i=0; i<5; i++) {
                        if (parse_table[stack_top-1][4][i] == 0) {
                            if (stack_top == 1 || stack_top == 2) cout << "Expected ( but found " << token << endl;
                            if (stack_top == 3) cout << "Operator expected but found " << token << endl;
                            if (stack_top == 4) cout << "ID/NUM/( expected but found " << token << endl;
                            if (stack_top == 6) cout << "Expected ID but found " << token << endl;
                            if (stack_top == 7) cout << "Expected NUM but found " << token << endl;
                            return 0;
                        } else if (parse_table[stack_top-1][4][i] == -1) {
                            next_input = 1;
                            break;
                        } else if (parse_table[stack_top-1][4][i] == -2) {
                            break;
                        } else {
                            parsing.push(parse_table[stack_top-1][4][i]);
                        }
                    }
                }
                break;
            
            case OP:
                while (next_input == 0) { // Processing the stack till the NT and Terminal match
                    int stack_top = parsing.top();
                    parsing.pop();
                                        
                    for(int i=0; i<5; i++) {
                        if (parse_table[stack_top-1][3][i] == 0) {
                            if (stack_top == 1 || stack_top == 2) cout << "Expected ( but found " << token << endl;
                            if (stack_top == 3) cout << "Operator expected but found " << token << endl;
                            if (stack_top == 4) cout << "ID/NUM/( expected but found " << token << endl;
                            if (stack_top == 6) cout << "Expected ID but found " << token << endl;
                            if (stack_top == 7) cout << "Expected NUM but found " << token << endl;
                            return 0;
                        } else if (parse_table[stack_top-1][3][i] == -1) {
                            if (parse_tree == NULL) {
                                parse_tree = (Tree) malloc(sizeof(tree_node));
                                current_node = parse_tree;
                                init(parse_tree, ntoken, token[0]);
                            } else {
                                if (current_node->left == NULL) {
                                    current_node->left = (Tree) malloc(sizeof(tree_node));
                                    init(current_node->left, ntoken, token[0]);
                                    current_node->left->parent = current_node;
                                    current_node = current_node->left;
                                } else {
                                    current_node->right = (Tree) malloc(sizeof(tree_node));
                                    init(current_node->right, ntoken, token[0]);
                                    current_node->right->parent = current_node;
                                    current_node = current_node->right;
                                }
                            }

                            next_input = 1;
                            break;
                        } else if (parse_table[stack_top-1][2][i] == -2) {
                            break;
                        } else {
                            parsing.push(parse_table[stack_top-1][3][i]);
                        }
                    }
                }
        }
    }

    if (storing_val != NULL) {
        cout << "Expected input for variables. None found" << endl;
        return 0;
    }

    cout << "Parsing is successful\n" << endl;
    int ans = eval_tree(parse_tree, 0);

    if (identifiers != NULL) cout << "\nVariable values read from input:\n";
    storing_val = identifiers;
    while(storing_val != NULL) {
        cout << storing_val->name << " = " << storing_val->value << endl;
        storing_val = storing_val->next;
    }

    cout << "\nThe expression evaluates to " << ans << endl;

    return 0;
}
