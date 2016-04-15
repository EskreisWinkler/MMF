#include <iostream>

using namespace std;
//int x;
//char letter;
//float f,g;

int main()
{
    int user_input;
    
    cout<<"Please enter a number: ";
    cin>> user_input;
    if (user_input>=0) {
        cout<<"Your number is nonnegative\n";
    } else {
        cout<<"Your number is negative\n";
    }
    cin.ignore();
    cin.get();
}
