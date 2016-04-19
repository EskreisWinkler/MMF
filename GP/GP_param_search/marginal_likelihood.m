function[marg_likely] = marginal_likelihood(X,T,K,is_MMF)
%%% X is the predictors. If they are of dimension p and there are n of
%%%%% them, then X \in \mathbb{R}^{p\times n}
%%% Y is the target values
%%%%% KERNEL_TYPE may be specified as 1, 2, ... check make_kernel_mat fxn
%%% THETA is a vector of hyperparameters for the kernel matrix, often
%%%%% depending on the dimension of the datapoints p
%%% IS_MMF is a binary variable indicating whether or not K is already an
%%%%% MMF object


n=size(X,2);

if is_MMF
    D = K.determinant();
    alpha = K.hit(T);
    marg_likely = -0.5*log(D)-n*log(2*pi)/2-0.5*T'*alpha;
else
    marg_likely = -0.5*T*(K\T')-0.5*log(det(K))-0.5*n*log(2*pi);
end

