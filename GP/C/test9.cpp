#include <iostream>
#include <fstream>
using namespace std;

int main() {
    ofstream file1,file2;
    file1.open ("data2.txt");
    file1 << "Write to file1. \n";
    cout << file1;
    file1.close();
    cin.get();
    file2.open ("data2.txt", ios::app);
    file2 << "Write to file2. \n";
    cout << file2;
    file2.close();
    
    cin.get();
}