// NAME - S.RISHABH
// ROLL NUMBER - 22CS10058

#include <stdio.h>
#include <stdlib.h>

void mprn(int * array, int pos) {
    printf("+++ MEM[%d] set to %d\n", pos, array[pos]);
    return;
}

void eprn(int * array, int pos) {
    printf("+++ Standalone expression evaluates to %d\n", array[pos]);
    return;
}

int pwr(int a, int b) {
    if (a == -1) return 1*(b%2 == 0) + (-1)*(abs(b%2));
    if (a == 1) return 1;
    if (a == 0) {
        if (b > 0) return 0;
        else if (b == 0) {printf("\n--- WARNING: 0 power of 0 is undefined\n\n"); return 0;}
        else {printf("\n--- WARNING: Negative power of 0\n\n"); return 0;}
    }

    if ((a > 1 && b < 0) || (a < 1 && b%2 == 0 && b < 0)) return 0;
    if (a < 1 && b < 0) return -1;

    int ans = 1, temp = a;
    while(b) {
        if (b%2) ans *= temp;
        temp *= temp;
        b /= 2;
    }

    return ans;
}