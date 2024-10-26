// NAME - S.RISHABH
// ROLL NUMBER - 22CS10058

#include "y.tab.c"
#include "lex.yy.c"

tree init_node(char type) { // For non terminal nodes initialization of values is not required
    tree temp = (tree) malloc(sizeof(node));

    temp->child[0] = NULL;
    temp->child[1] = NULL;
    temp->child[2] = NULL;
    temp->type = type;

    return temp;
}

tree init_node_t(char type, int val) { // For terminal nodes (leaf nodes) values are initialzed based on lex return value
    
    tree temp = init_node(type);
    temp->val = val;

    return temp;
}

void add_child(tree root, tree child, int index) { // Assigning the cild node to the parent
    root->child[index] = child;
}

void print_tree(tree root, int depth) { // DFS approach to print the parse tree
    if (root == NULL) return;
    for(int i=0; i<depth; i++) printf("\t");

    if (root->type == 'M') printf("-> %c [inh = %d, val = %d]\n", root->type, root->inh.val, root->val);        // M has both inh and syn values (type: int)
    else if (root->type == 'N') printf("-> %c [val = %d]\n", root->type, root->val);                            // N has only syn values (type: int)
    else if (root->type == 'P' || root->type == 'T') printf("-> %c [inh = %c]\n", root->type, root->inh.sign);  // P, T have inh signs (type: char)
    else if (root->type != 'Z' && root->type != 'O' && root->type != 'D') printf("-> %c\n", root->type);        // Symbols and variables
    else printf("-> %c [%d]\n", root->type, root->val);                                                         // Constants

    print_tree(root->child[0], depth+1);    // Recursive DFS call
    print_tree(root->child[1], depth+1);    // Recursive DFS call
    print_tree(root->child[2], depth+1);    // Recursive DFS call
}

void setatt(tree root) {        // Recursive function to set inh and syn values
    
    // First get the inherited value from the parent and complete till last depth
    // After the inh value reaches the bottom, syn values are passed to the top

    if (root == NULL) return;

    switch(root->type) {
        case 'S': // S -> P -- inh sign +
            
            if (root->child[1] == NULL) {
                root->child[0]->inh.sign = '+';
            } else {
                root->child[1]->inh.sign = root->child[0]->type;
            }

            setatt(root->child[0]);
            setatt(root->child[1]);
            setatt(root->child[2]);
            break;
        
        case 'P':

            root->child[0]->inh.sign = root->inh.sign;
            if (root->child[2] != NULL) root->child[2]->inh.sign = root->child[1]->type;

            setatt(root->child[0]);
            setatt(root->child[1]);
            setatt(root->child[2]);
            break;

        case 'T':
            setatt(root->child[0]);
            setatt(root->child[1]);
            setatt(root->child[2]);
            break;
        
        case 'X':
            setatt(root->child[0]);
            setatt(root->child[1]);
            setatt(root->child[2]);
            break;
        
        case 'N':

            if (root->child[1] != NULL) {
                root->child[1]->inh.val = root->child[0]->val;
            }
            
            setatt(root->child[0]);
            setatt(root->child[1]);
            setatt(root->child[2]);
            
            if (root->child[1] == NULL) {
                root->val = root->child[0]->val;
            } else {
                root->val = root->child[1]->val;
            }

            break;
        
        case 'M':

            if (root->child[1] != NULL) {
                root->child[1]->inh.val = root->child[0]->val + root->inh.val*10;
            }
            
            setatt(root->child[0]);
            setatt(root->child[1]);
            setatt(root->child[2]);

            if (root->child[1] == NULL) {
                root->val = root->inh.val*10 + root->child[0]->val;
            } else {
                root->val = root->child[1]->val;
            }

            break;

        default:
            return;
    };
}

long long binpow(long long a, long long b) { // Binary exponentiation to calculate power (used in evaluation)
    long long ans = 1;
    long long temp = a;

    while(b) {
        if (b%2) ans *= temp;
        temp *= temp;
        b /= 2;
    }

    return ans;
}

long long evalpoly(tree root, long long x) { // Evaluating the expression by performing suitable calculation for each grammar rule
    if (root == NULL) return 0;

    switch(root->type) {
        case 'S':
            if (root->child[1] == NULL) return evalpoly(root->child[0], x);
            else return evalpoly(root->child[1], x);
            break;

        case 'P':
            if (root->child[1] == NULL) return evalpoly(root->child[0], x);
            else return evalpoly(root->child[0], x) + evalpoly(root->child[2], x);
            break;
        
        case 'T':
            if (root->child[1] == NULL) return ((root->inh.sign == '+') - (root->inh.sign == '-'))*evalpoly(root->child[0], x);
            else return ((root->inh.sign == '+') - (root->inh.sign == '-'))*evalpoly(root->child[0], x)*evalpoly(root->child[1], x);
            break;
        
        case 'N':
            return root->val;
        
        case 'X':
            if (root->child[2] == NULL) return x;
            else return binpow(x, evalpoly(root->child[2], x));
            break;
        
        default:
            return 1;
            break;
    };
}

void print_derivative(tree root) {

    // Printing the derivative expression (valid based on grammar rules)
    // A constant expression f(x) = 5 will not print anything as the derivative is 0 and is not an valid expression in the given grammar

    // ax^n -> n*ax^(n-1)
    // ax^2 -> 2*ax
    // ax -> a
    // a -> <empty>
    
    if (root == NULL) return;

    switch (root->type) {

        case 'S':
        
            if (root->child[1] == NULL) print_derivative(root->child[0]);
            else print_derivative(root->child[1]);
            break;
        
        case 'P':
        
            if (root->child[1] == NULL) print_derivative(root->child[0]);
            else {print_derivative(root->child[0]); print_derivative(root->child[2]);}
            break;
        
        case 'T':
        
            if (root->child[1] != NULL) { // T -> N X
                printf(" %c ", root->inh.sign);
                if (root->child[1]->child[1] == NULL) { // power 1
                    printf("%d", root->child[0]->val);
                } else {
                    if (root->child[1]->child[2]->val == 2) printf("%dx", 2*(root->child[0]->val));
                    else printf("%dx^%d", (root->child[0]->val)*(root->child[1]->child[2]->val), root->child[1]->child[2]->val-1);
                }
            } else if (root->child[1] == NULL && root->child[0]->type == 'X') { // T -> X
                printf(" %c ", root->inh.sign);
                if (root->child[0]->child[1] == NULL) { // power 1
                    printf("%d", 1);
                } else {
                    if (root->child[0]->child[2]->val > 2) printf("%dx^%d", root->child[0]->child[2]->val, root->child[0]->child[2]->val-1);
                    else printf("2x");
                }
            }
            break;
        
        default:
            break;
    };
}

int main() {
    yyparse();
    setatt(parse_tree);
    print_tree(parse_tree, 0);
    for(int i=-5; i<=5; i++) {
        printf("+++ f(%2d) =%15lld\n", i, evalpoly(parse_tree, i));
    }

    printf("\n+++ f'(x) = ");
    print_derivative(parse_tree);
    printf("\n");
    return 0;
}