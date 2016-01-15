function[LL] = LL_calc(theta,x,y, is_MMF, params)
% theta:    a vector of parameters for the kernel matrix
% x:        the data. There should be as many rows of x as there are of y
% y:        the response.
n=length(x);
K = make_rbf(x,theta);

if is_MMF
    K_mmf = MMF(K,params);
    d = K_mmf.determinant();
    K_mmf.invert();
    LL = 0.5*y*(K_mmf.hit(y'))+0.5*log(d)+0.5*n*log(2*pi)+1e10*(sum(theta<0)>0);
else
    LL = 0.5*y*(K\y')+0.5*log(det(K))+0.5*n*log(2*pi)+1e8*(sum(theta<0)>0);
end

