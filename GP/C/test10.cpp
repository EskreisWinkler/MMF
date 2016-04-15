#include <iostream>
#include <sstream>
#include <string>
#include <fstream>
#include </usr/local/Eigen/Dense>

using namespace std;
using Eigen::MatrixXd;

int count_rows(string address) {
    int r = 0;
    ifstream infile(address);
    string line = "";
    while (getline(infile, line)){
        r++;
    }
    cout << "Number of rows is:"<< r <<"\n";
    return r;
}
int count_cols(string address) {
    int c = 0;
    ifstream infile(address);
    string line = "";
    getline(infile, line);
    string word;
    while (getline(strstr,word, ',')){
        c ++;
    }
    cout << "Number of columns is:"<< c <<"\n";
    return c;
}
float read_csv(string address,int num_r, int num_c){
    int num_r = count_rows(address);
    int num_c = count_cols(address);
    MatrixXd m(num_r,num_c);
    int l,c=0;
    l=l-1;
    
    ifstream infile(address);
    while (getline(infile, line)){
        stringstream strstr(line);
        string word = "";
        l++;
        c = 0;
        while (getline(strstr,word, ',')){
            number = stof(word);
            m(l,c) = number;
            c ++;
        }
    }
    return m;
}


int main(){

    string address = "/Users/jeffreywinkler/Google_Drive/15fall/Kondor/Code/Wind/Data/test_5p.csv";
    
    MatrixXd data = read_csv(address);
    
}

