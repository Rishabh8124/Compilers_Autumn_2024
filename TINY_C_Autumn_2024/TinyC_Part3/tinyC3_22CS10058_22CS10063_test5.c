int global_var1, global_var2;
char global_var3 = 'a';

void foo(int a, int b);

int main() {
    float f1 = 2.3, f2 = 5,f3;
    int n1, n2 = 10, *n3;
    char c1 = 'd', c2[80],c3;
    char *str1 = "Hello World", *str2;

    n1 = n2 = f1 = f2;
    c2[22] = c1;
    c3 = c2[22]; 
    
    return 0;
}

void foo(int a, int b) {
    int i = a + b + global_var1;
    return;
}
