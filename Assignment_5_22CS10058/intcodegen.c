// NAME - S.RISHABH
// ROLL NUMBER - 22CS10058

#include "y.tab.c"
#include "lex.yy.c"

char * int_to_str (int value) {
    if (value == 0) {
        char * ans = (char *) malloc (4);
        ans[0] = '0';
        ans[1] = '\0';
        return ans;
    }
    int len = (value<0);
    int temp = value;
    if (len) temp = temp*-1;

    while(temp) {
        len++;
        temp /= 10;
    }

    char * ans = (char *) malloc(sizeof(int)*(len+1));
    ans[len] = '\0';

    if (value < 0) {
        ans[0] = '-';
        value *= -1;
    }

    while(value) {
        len--;
        ans[len] = '0'+(value%10);
        value /= 10;
    }

    return ans;
}

int add_id(T * root, char * id, int * mem_count) {
    T temp = *root;
    while(temp != NULL) {
        if (strcmp(temp->name, id) == 0) return temp->offset;

        temp = temp->next;
    }

    T new_point = (T) malloc(sizeof(symbol_table));
    new_point->name = (char *)malloc((strlen(id)+1) * sizeof(char));
    strcpy(new_point->name, id);
    new_point->offset = *mem_count;
    *mem_count = new_point->offset + 1;
    new_point->next = NULL;

    
    if (*root != NULL)  {
        temp = *root;
        while(temp->next != NULL) temp = temp->next;
        temp->next = new_point;
    } else {
        *root = new_point;
    }

    return new_point->offset;
}

int get_id(T root, char * id) {
    T temp = root;
    while(temp != NULL) {
        if (strcmp(temp->name, id) == 0) break;

        temp = temp->next;
    }

    if (temp == NULL) return -1;

    return temp->offset;
}

int main() {
    fptr = fopen("intcode.c", "w");
    fprintf(fptr, "#include <stdio.h>\n#include <stdlib.h>\n#include \"aux.c\"\n\nint main() {\n\tint R[12];\n\tint MEM[65536];\n\n");
    yyparse();
    fprintf(fptr, "\texit(0);\n}");
    fclose(fptr);
    return 0;
}