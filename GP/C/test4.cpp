#include <iostream>
#include <cstdlib>

using namespace std;
int a = rand();
int test_fun(int x, int y);

int main()
{
    int x,y;
    
    cout<<"I will multiply together the two numbers you give me: ";
    cin>> x>>y;
    cin.ignore();
    cout<< test_fun(x,y);
    cin.get();
}

int test_fun(int a1, int a2) {
    return a1*a2;
}
