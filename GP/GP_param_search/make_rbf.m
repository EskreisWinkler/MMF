function [ K ] = make_rbf(X,theta,X2)
% X \in \mathbb{R}^{p\times n}
% theta = [sigma_f^2 sigma_m^2 l_1,...l_p] \in \mathbb{R}^{p+2\times 1}
% X2 (if exists) \in \mathbb{R}^{m \times p}
keyboard
sigma_f_sq = theta(1);
sigma_n_sq = theta(2);
l = theta(3:end);
n=size(X,2);
X_use = bsxfun(@rdivide,X,l);
n1sq = sum(X_use.^2,1);
if ~exist('X2','var')
    D = (ones(n,1)*n1sq)' + ones(n,1)*n1sq -2*(X_use')*X_use;
    K = sigma_f_sq*exp(-D/2)+sigma_n_sq*eye(n);
else
    X2_use = bsxfun(@rdivide,X2,l);
    n2sq = sum(X2_use.^2,1);
    n2 = size(X2_use,2);
    D = (ones(n2,1)*n1sq)' + ones(n,1)*n2sq -2*X_use'*X2_use;
    K = sigma_f_sq*exp(-D/2);
end

