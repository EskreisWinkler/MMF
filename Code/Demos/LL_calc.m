function[LL] = LL_calc(theta)
global x;
global y;

n=length(x);
K = make_rbf(x,theta);

LL = 0.5*y*(K\y')+0.5*log(det(K))+0.5*n*log(2*pi)+1000*(sum(theta<0)>0);