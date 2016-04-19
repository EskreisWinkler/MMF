#include <fstream>
#include <iostream>

using namespace std;

int n=17;

int main()
{
    char str[n];
    
    ofstream a_file ( "data2.txt", ios::app );
    a_file << "insert this text?";
    a_file.close();
    
    ifstream b_file ("data2.txt");
    b_file >> str;
    cout<< str << "\n";
    cout<< b_file.is_open() << "\n";
    b_file.close();
    cin.get();
}