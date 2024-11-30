int main() {
    int a, b, c, d, n;
    float *x, **y;
    x = *y;
    **y = *x;
    y = &x;
    *x = **y;
    b++;
    ++a;
/*   22CS10058 22CS10063   */
    c = +b;
    d = ~b;
    n = -b;
    return 0;
}