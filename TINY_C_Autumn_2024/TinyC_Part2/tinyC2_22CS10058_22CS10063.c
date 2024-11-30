#include "y.tab.c"
#include "lex.yy.c"

tree_pointer init_node(char * name, char * val, tree_pointer child) {
    tree_pointer new_tree = (tree_pointer) malloc(sizeof(tree));
    new_tree->name = strdup(name);
    new_tree->val = strdup(val);
    new_tree->next = NULL;
    new_tree->child = child;

    return new_tree;
}

void add_next(tree_pointer root, tree_pointer next) {
    tree_pointer temp = root;
    while(temp->next != NULL) temp = temp->next;

    temp->next = next;
    return;
}

void print_parse_tree(tree_pointer root, int depth) {
    if (root == NULL) return;

    for (int i=0; i<depth; i++) printf("\t");
    if (strcmp("", root->val)) printf("-> %s (%s)\n", root->name, root->val);
    else printf("-> %s\n", root->name);

    print_parse_tree(root->child, depth+1);
    print_parse_tree(root->next, depth);

    return;
}

int main() {
    yyparse();
    print_parse_tree(parse_tree,0); // parse tree initialized in bison file
    return 0;
}