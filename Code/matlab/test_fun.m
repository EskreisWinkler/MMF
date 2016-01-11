function[b] = test_fun(sigma)
x=1;y=2;z=3; v = ones(3,1);
X=[x y z];
K = kernelmatrix('rbf',X',X',sigma);
b = v'*K*v;

