function[marg_likely] = marginal_likelihood_fminsearch(theta)
%%% X is the predictors. If they are of dimension p and there are n of
%%%%% them, then X \in \mathbb{R}^{p\times n}
%%% Y is the target values
%%%%% KERNEL_TYPE may be specified as 1, 2, ... check make_kernel_mat fxn
%%% THETA is a vector of hyperparameters for the kernel matrix, often
%%%%% depending on the dimension of the datapoints p
%%% IS_MMF is a binary variable indicating whether or not K is already an
%%%%% MMF object
load wind_data.mat
X = TRAIN_DATA(:,1:(end-1));
T = TRAIN_DATA(:,end)';
K = make_rbf(X',theta');
is_MMF=0;
n=size(X,2);

if is_MMF
    params.k=2;
    params.ndensestages=1;
    params.fraction=0.9;
    fprintf('Computing MMF factorization\n')
    K_mmf = MMF(K,params);
    %D = K.determinant(); % once this is fixed I can take out the next two slow steps.
    fprintf('Computing MMF full form\n')
    F = K_mmf.fullForm();
    D = det(F{end});
    K_mmf.invert();
    alpha = K_mmf.hit(T);
    alpha(isnan(alpha)) =0;
    marg_likely = 0.5*T*alpha+0.5*log(D)+0.5*n*log(2*pi)/2 + sum(theta<0.001)*10e30...
        +sum(theta>200)*10e30;
    if isnan(marg_likely)
        keyboard;
    end
else
    marg_likely = 0.5*T*(K\T')+0.5*log(det(K))+0.5*n*log(2*pi) + sum(theta<0.001)*10e30...
        +sum(theta>200)*10e30;
end

