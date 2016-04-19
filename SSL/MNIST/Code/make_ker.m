function[K] = make_ker(data,n,sigma)

% We want to use an arbitrary kernel to turn the matrix of iamges into a
% set of edge-weights.

% Default for now is RBF kernel with only one length scale.
% Data is n X p

n1sq = sum(data.^2,1);
D = (ones(n,1)*n1sq)' + ones(n,1)*n1sq -2*(data')*data;
K = exp(-D/(2*sigma));


