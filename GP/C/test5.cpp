# include <iostream>

using namespace std;

int main(){
    int x;
    int *p;
    p = &x;
    
    cin>> x;
    cin.ignore();
    cout<< *p <<"\n";
    cin.get();
}