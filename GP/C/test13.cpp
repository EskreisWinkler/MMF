#include <iostream>
#include </usr/local/Eigen/Dense>


using namespace Eigen;
using namespace std;
int main()
{
    int n =2;
    MatrixXd m(n,n);
    m(0,0) = 3;
    m(1,0) = 2.5;
    m(0,1) = -1;
    m(1,1) = m(1,0) + m(0,1);
    VectorXd v(n);
    v << 1, 1;
    cout << m << endl;
    cout << v << endl;
    cout <<m<<endl;
    MatrixXd m_temp = m.block<2,1>(0,0);
    cout << m_temp.transpose() * m_temp<<endl;
    cout <<m.transpose()*v <<endl;
    
}
