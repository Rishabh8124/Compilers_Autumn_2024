int g() 
{
    float f1 = 4.55, f2 = 8.0, f3 = 3.5;
    int n1 = 5, n2 = 4, n3 = 6, n4 = 9;
    
    n2 = n1 >> 2;
    n4 = n4 << 2;
    f2 = -f1 + (n2 - n3) * f1/f3;
// comment testing here ---------------------------------
    n1 = n2 ^ n3;
    n2 = (n1 & n2) | n3;
    n3 = n1 & (n2 | n3);
    
    return 13;
}