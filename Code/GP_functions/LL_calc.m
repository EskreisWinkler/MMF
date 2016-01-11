function[LL] = LL_calc(theta,x,y)
% theta:    a vector of parameters for the kernel matrix
% x:        the data. There should be as many rows of x as there are of y
% y:        the response.


n=length(x);
K = make_rbf(x,theta);

LL = 0.5*y*(K\y')+0.5*log(det(K))+0.5*n*log(2*pi)+1000*(sum(theta<0)>0);