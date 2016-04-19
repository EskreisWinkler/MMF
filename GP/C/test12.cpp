#include <iostream>
#include <sstream>
#include <string>
#include <fstream>
#include </usr/local/Eigen/Dense>


using namespace std;
using Eigen::MatrixXd;

#include "test12.h"

int main(){
    string address = "/Users/jeffreywinkler/Google_Drive/15fall/Kondor/Code/Wind/Data/TRAIN_5p.csv";
    cout << address<< "\n";
    MatrixXd m = read_csv(address);
   // cout << m << endl;
}