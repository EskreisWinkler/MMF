#include <iostream>
#include <fstream>

using namespace std;
int n=5;


int main()
{
    cin.get();
    int x,y;
    int i_vector2[n][n];
    for (x=1; x<=n; x++) {
        for (y=1; y<=n; y++) {
            i_vector2[x][y] = x*y;
        }
    }
    cout<<"Array Indices:\n";
    for ( x = 1; x <= n;x++ ) {
        for ( y = 1; y <=n; y++ )
        cout<<"["<<x<<"]["<<y<<"]="<< i_vector2 [x][y] <<" ";
        cout<<"\n";
    }
    cin.get();
}