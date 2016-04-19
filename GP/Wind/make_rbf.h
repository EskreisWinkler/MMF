MatrixXd make_rbf1(MatrixXd X, VectorXd theta){
    double sf = theta(1);
    double sn = theta(2);
    VectorXd l = theta.segment(2,theta.rows()-2);
    MatrixXd X_use = X;
    int i;
    for (i=0; i<l.rows(); i++) {
        X_use.col(i) = X.col(i)/sqrt(l(i));
    }
    
    X_use = X_use.cwiseProduct(X_use);
    VectorXd n1sq = X_use.colwise().sum();
    VectorXd o = VectorXd::Constant(X_use.cols(),1);
    MatrixXd d = o*n1sq.transpose();
    MatrixXd D = n1sq*o.transpose() + o*n1sq.transpose() -2*X_use.transpose()*X_use;
    cout << "D is of size " << D.rows() << "X" << D.cols() << endl;
    return D;
}


MatrixXd make_rbf2(MatrixXd X, VectorXd theta, MatrixXd X2){
    double sf = theta(1);
    double sn = theta(2);
    VectorXd l = theta.segment(2,theta.rows()-2);
    MatrixXd X_use = X;
    MatrixXd X2_use= X2;
    int i;
    for (i=0; i<l.rows(); i++) {
        X_use.col(i) = X.col(i)/sqrt(l(i));
        X2_use.col(i) = X2.col(i)/sqrt(l(i));
    }
    X_use = X_use.cwiseProduct(X_use);
    X2_use = X2_use.cwiseProduct(X2_use);
    VectorXd n1sq = X_use.colwise().sum();
    VectorXd n2sq = X2_use.colwise().sum();
    VectorXd o1 = VectorXd::Constant(X_use.cols(),1);
    VectorXd o2 = VectorXd::Constant(X2_use.cols(),1);
    MatrixXd D = n1sq*o2.transpose() + o1*n2sq.transpose()  -2*X_use.transpose()*X2_use;
    cout << "D is of size " << D.rows() << "X" << D.cols() << endl;
    return X;
}