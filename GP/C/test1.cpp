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
    cin.ignore();
    cout<<"This is the thing you entered:\n"<< user_input << "\nIs that correct? \n";
	cin.get();
}
