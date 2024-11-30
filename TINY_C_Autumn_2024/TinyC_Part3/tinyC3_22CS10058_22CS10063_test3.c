//22CS10058 22CS10063
int main(int i , int l) 
{
    int a[2];
    if(i < a[0] && a[1] > l) {
        l = a[1];
        a[0] = i;
        if(i <= l || a[0] >= a[1])
            i = l;
        else if(i == a[0] && a[1] != l)
            a[0] = a[1];
        else
            i = a[1];
    }
    return 100;
}