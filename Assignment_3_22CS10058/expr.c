#include "y.tab.c"
#include "lex.yy.c"

// Add a new variable to the symbol table
T add_id(T * root_pointer, char * id, int t, int value) { 

    T root = *root_pointer;
    T check_exist = get_id(root, id, t, value);
    if (check_exist != NULL) return check_exist;

    if (t == 0) {   // t = 0 for identifier type node
        T new_point = (T) malloc(sizeof(symbol_table));
        new_point->name = (char *)malloc((strlen(id)+1) * sizeof(char));
        strcpy(new_point->name, id);
        new_point->set_val = 0;
        new_point->type = 0;
        new_point->next = NULL;

        if (root == NULL) {
            *root_pointer = new_point;
            return new_point;
        } else {
            temp = root;
            while(temp->next != NULL) temp = temp->next;
            temp->next = new_point;
        }

        return new_point;
    } else {    // t = 1 for constant type node
        T new_point = (T) malloc(sizeof(symbol_table));
        new_point->name = "";
        new_point->value = value;
        new_point->set_val = 1;
        new_point->type = 1;
        new_point->next = NULL;

        if (root == NULL) {
            *root_pointer = new_point;
            return new_point;
        } else {
            temp = root;
            while(temp->next != NULL) temp = temp->next;
            temp->next = new_point;
        }

        return new_point;
    }
}

// Gets the location of variable or constant from the symbol table
T get_id(T root, char * id, int t, int value) { 
    if (t == 0) {
        T temp = root;
        while(temp != NULL) {
            if (strcmp(temp->name, id) == 0) return temp;

            temp = temp->next;
        }

        return NULL;
    } else {
        T temp = root;
        while(temp != NULL) {
            if (strcmp(temp->name, "") == 0 && temp->value == value) return temp;

            temp = temp->next;
        }

        return NULL;
    }
}

// Initialize operator type leaf in tree
expr_tree init_node_op (char * op) {
    expr_tree new_node = (expr_tree) malloc(sizeof(tree_node));
    new_node->left = NULL;
    new_node->right = NULL;
    new_node->type = 0;
    new_node->val.oper = strdup(op);

    return new_node;
}

// Initialize symbol table pointer type leaf in tree
expr_tree init_node_tl (T st_pointer) { 
    expr_tree new_node = (expr_tree) malloc(sizeof(tree_node));
    new_node->left = NULL;
    new_node->right = NULL;
    new_node->type = 1;
    new_node->val.st_address = st_pointer;

    return new_node;
}

// Evaluating powers using binary exponentiation
// Assumptions
//      0^0             - Undefined
//      0^(neg value)   - Equivalent to division by 0
//      (a > 1)^(neg value)   - 0 (lies between 0 and 1, approximated to 0)
//      (a < 1)^(neg value)   - 0 (if even) -1 (if odd)
int binary_exponentiation(int a, int b) { 
    if (a == -1) return 1*(b%2 == 0) + (-1)*(b%2);
    if (a == 1) return 1;
    if (a == 0) {
        if (b > 0) return 0;
        else if (b == 0) yyerror("0 power of 0 is undefined\n");
        else yyerror("Negative power of 0\n");
    }

    if ((a > 1 && b < 0) || (a < 1 && b%2 == 0)) return 0;
    if (a < 1 && b < 0) return -1;

    int ans = 1, temp = a;
    while(b) {
        if (b%2) ans *= temp;
        temp *= temp;
        b /= 2;
    }

    return ans;
}

// Evaluates the expression tree
int eval_expr(expr_tree current) {
    if (current->type == 1) {
        if (current->val.st_address->set_val == 0) {
            yyerror("Variable value not assigned\n");
        }
        return current->val.st_address->value;
    }
    else {
        if (current->left == NULL || current->right == NULL) {
            yyerror("Invalid syntax\n");
        }

        if (strcmp(current->val.oper, "+") == 0) {
            return eval_expr(current->left) + eval_expr(current->right);
        } else if (strcmp(current->val.oper, "-") == 0) {
            return eval_expr(current->left) - eval_expr(current->right);
        } else if (strcmp(current->val.oper, "*") == 0) {
            return eval_expr(current->left) * eval_expr(current->right);
        } else if (strcmp(current->val.oper, "/") == 0) {
            int temp1 = eval_expr(current->right);
            if (temp1 == 0) {
                yyerror("Division by 0\n");
            }
            return eval_expr(current->left) / temp1;
        } else if (strcmp(current->val.oper, "%") == 0) {
            int temp1 = eval_expr(current->right);
            if (temp1 == 0) {
                yyerror("Division by 0");
            }
            return eval_expr(current->left) % temp1;
        } else if (strcmp(current->val.oper, "**") == 0) {
            return binary_exponentiation(eval_expr(current->left), eval_expr(current->right));
        }
    }
}

// Free the expression tree
void free_tree(expr_tree expression) {
    if (expression == NULL) return;
    free_tree(expression->left);
    free_tree(expression->right);
    free(expression);
    return;
}

// Print symbol table
void print_st(T st) {
    T head = st;
    printf("\nSymbol Table:- \n");
    while(head != NULL) {
        if (head->set_val) {
            if (strcmp(head->name, "")) printf("%14s - %d\n", head->name, head->value);
            else printf("CONSTANT VALUE - %d\n", head->value);
        } else {
            printf("%14s - NOT SET\n", head->name);
        }
        head = head->next;
    }
}

int main() {
    yyparse();
    return 0;
}