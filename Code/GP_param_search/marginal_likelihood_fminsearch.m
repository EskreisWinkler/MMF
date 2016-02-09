function[marg_likely] = marginal_likelihood_fminsearch(theta)
%%% X is the predictors. If they are of dimension p and there are n of
%%%%% them, then X \in \mathbb{R}^{p\times n}
%%% Y is the target values
%%%%% KERNEL_TYPE may be specified as 1, 2, ... check make_kernel_mat fxn
%%% THETA is a vector of hyperparameters for the kernel matrix, often
%%%%% depending on the dimension of the datapoints p
%%% IS_MMF is a binary variable indicating whether or not K is already an
%%%%% MMF object
load full_wind_data.mat
X = TRAIN_DATA(:,1:(end-1));
T = TRAIN_DATA(:,end);
n = size(X,1);
inds = randperm(n);
perc = 0.005;
sample = inds(1:round(perc*n));
X = X(sample,:);
T= T(sample);

if size(X,2)<size(X,1)
    X=X';
end
if size(theta,2)>size(theta,1)
    theta=theta';
end
K = make_rbf(X,theta);
is_MMF=1;
n=size(X,2);
if is_MMF
    params = GP_params();
    fprintf('Computing MMF factorization\n')
    K_mmf = MMF(K,params);
    D = K_mmf.determinant(); % once this is fixed I can take out the next two slow steps.
    K_mmf.invert();
    alpha = K_mmf.hit(T);
    alpha(isnan(alpha)) =0;
    marg_likely = 0.5*T'*alpha+0.5*log(D)+0.5*n*log(2*pi)/2 + sum(theta<0.001)*10e30...
        +sum(theta>200)*10e30;
    if isnan(marg_likely)
        marg_likely = Inf;
    end
else
    marg_likely = 0.5*T'*(K\T)+0.5*log(det(K))+0.5*n*log(2*pi) + sum(theta<0.001)*10e30...
        +sum(theta>200)*10e30;
end

