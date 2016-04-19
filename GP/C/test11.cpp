#include <iostream>
#include <sstream>
#include <string>
#include <fstream>
#include </usr/local/Eigen/Dense>

using namespace std;
using Eigen::MatrixXd;

int main(){
    
    string address = "/Users/jeffreywinkler/Google_Drive/15fall/Kondor/Code/Wind/Data/TRAIN_5p.csv";
    
    int num_r = 0;
    ifstream infile(address);
    string line = "";
    while (getline(infile, line)){
        num_r++;
    }
    cout << "Number of rows is:"<< num_r <<"\n";
    int num_c = 0;
    ifstream infile2(address);
    string line2 = "";
    getline(infile2, line2);
    string word = "";
    stringstream strstr(line2);

    while (getline(strstr,word, ',')){
        num_c ++;
    }
    cout << "Number of columns is:"<< num_c <<"\n";
    cin.get();
    MatrixXd m(num_r,num_c);
    int l,c=0;
    l=l-1;
    float number;
    ifstream infile3(address);
    //while (getline(infile3, line)){
    //    stringstream strstr(line);
    //    string word = "";
    //    l++;
    //    c = 0;
    //    while (getline(strstr,word, ',')){
    //        number = stof(word);
    //        m(l,c) = number;
    //        c ++;
    //    }
    //}
    
}

