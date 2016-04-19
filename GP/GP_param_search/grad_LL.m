function [grad_theta] = grad_LL(X,T,K,theta, is_MMF)
% IS_MMF indicates that the K object is already an MMF object
%K_inv = K;
%K_inv.invert();
%alpha = K_inv.hit(T)';
alpha = K \ T';

theta_f_sq = theta(1);
theta_n_sq = theta(2);
l = theta(3:end);
%p = length(theta)-2;
n=size(X,2);

theta_SIGfSQ = [1;0;l];
D_SIGfSQ = make_rbf(X,theta_SIGfSQ);

A = (alpha*alpha'+inv(K));
grad_theta(1) = 0.5*sum(diag(A*D_SIGfSQ)*2*sqrt(theta_f_sq));
grad_theta(2) = 0.5*sum(diag(A)*2*sqrt(theta_n_sq));
for i = 1:length(l)
    cur_X = X(i,:)/(l(i)^1.5);
    n1sq = sum(X.^2,1);
    C = (ones(n,1)*n1sq)' + ones(n,1)*n1sq -2*(cur_X')*cur_X;
    D_l_i = theta_f_sq*make_rbf(X,theta).*C;
    grad_theta(i+2) = 0.5*sum(diag(A*D_l_i));
end
grad_theta = grad_theta';
