#include <iostream>
#include <sstream>
#include <string>
#include <fstream>
#include </usr/local/Eigen/Dense>

using Eigen::MatrixXd;
using Eigen::VectorXd;
using namespace std;
#include "read_csv.h"
#include "make_rbf.h"

int main(){
    string address = "/Users/jeffreywinkler/Google_Drive/15fall/Kondor/Code/Wind/Data/TRAIN_5p.csv";
    MatrixXd m = read_csv(address);
    cout << "Import address is: "<< address<< endl;
    cout << "Matrix is of size " << m.rows() <<" x " << m.cols() << endl;
    VectorXd theta = VectorXd::Constant(m.cols()-1+2,1);
    theta(3) = 3;
    
    // First I am going to just make a not great Kernel matrix out of this jawn and then measure a likelihood function.
    MatrixXd data;
    MatrixXd response;
    data = m.leftCols(m.cols()-1);
    response = m.rightCols(1);
    MatrixXd K = make_rbf1(data.transpose(),theta);
    
    
}
