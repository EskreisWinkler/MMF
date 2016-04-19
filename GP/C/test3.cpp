#include <iostream>

using namespace std;
//int x;
//char letter;
//float f,g;

int main()
{
    int user_input;
    
    cout<<"I will count to the number you give me: ";
    cin>> user_input;
    for (int x = 1; x<=user_input; x++) {
        cout << x;
        cout << "\n";
    }
    cin.ignore();
    cin.get();
}
