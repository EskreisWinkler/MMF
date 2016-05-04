on_galton = 0;

if on_galton == 0
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Buffalo')
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Benchmarks')
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_param_search/',...
        '/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_functions/')
    addpath('/Users/jeskreiswinkler/mmfc/v4/src/matlab')
    cd /Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Benchmarks/
elseif on_galton == 1;
    
    addpath('/net/wallace/ga/eskreiswinkler/MMF/SSL/Buffalo')
    addpath('/net/wallace/ga/eskreiswinkler/MMF/SSL/Benchmarks')
    addpath('/net/wallace/ga/eskreiswinkler/MMF/GP/GP_param_search/',...
        '/net/wallace/ga/eskreiswinkler/MMF/GP/GP_functions/')
    addpath('/net/wallace/ga/eskreiswinkler/mmfc/v4/src/matlab')
end

dataset_ind = 1;

switch dataset_ind
    case 1
        dataset_name = 'digit1';
        eval(sprintf('load Data/%s.mat',dataset_name))
        sigma = 756;
        %sigma = 4; % this parameter spreads out the kernel vals a bit...
    case 2
        dataset_name = 'coil';
        eval(sprintf('load Data/%s.mat',dataset_name))
        sigma = 93;
        y2 = -1*(y<=2)+1*(y>=3);
        y = y2;
        clear y2;
    case 3
        dataset_name = 'usps';
        eval(sprintf('load Data/%s.mat',dataset_name))
        sigma = 733;
    case 4
        dataset_name = 'text';
        eval(sprintf('load Data/%s.mat',dataset_name))
        sigma = 6772;
    case 5
        dataset_name = 'secstr';
        eval(sprintf('load Data/%s.mat',dataset_name))
        sigma = 6;
        % if we want to only look at a subsample because of the austere
        % size;
        s = randsample(size(T,1),5000,0);
        X=double(T(s,:));
        y2 = -1*(y(s)<1)+y(s);
        y=y2;
        clear y2;
    otherwise
        fprintf('This jawn is messed up\n')
end

make_plots = 1;
ids = unique(y);
num.pts = length(y);
num.classes = length(ids);
num.observed = 20;
num.frac = 0.01;

good_draw = false;
while good_draw == false
    observed_inds = randsample(1:num.pts,num.observed);
    good_draw = length(unique(y(observed_inds)))==num.classes;
end
unobserved_inds = setdiff(1:length(y),observed_inds);
if make_plots
    hist(y(observed_inds))
end

K = make_ker(X',length(y),sigma);

% define a NN version
K_nn_rbf = diag(diag(K));
K_nn = K_nn_rbf;
nn = 50;
for row  = 1:num.pts
    % first find the lower bound:
    m = K(row,:);
    c = sort(K(row,:));
    c = c(length(c)-nn-1);
    K_nn_rbf(row,m>c) = m(m>c);
    K_nn(row,m>c) = 1;
end

W = K - diag(diag(K));
W_nn = K_nn-diag(diag(K_nn));
D = diag(sum(W,1));
D_nn = diag(sum(W_nn,1));
L_u = D(unobserved_inds,unobserved_inds)-W(unobserved_inds,unobserved_inds);
L_u_nn = D_nn(unobserved_inds,unobserved_inds)-W_nn(unobserved_inds,unobserved_inds);
L_u_inv = inv(L_u);
L_u_nn_inv = inv(L_u_nn);

f_o = y(observed_inds);
f_u = L_u_inv*W(unobserved_inds,observed_inds)*f_o;
f_u_nn = L_u_nn_inv*W_nn(unobserved_inds,observed_inds)*f_o;
q = sum(f_o)+1; % the unnormalized class proportion estimate from labeled data, with Laplace smoothing
f_u_CMN = f_u .* repmat(q./sum(f_u), num.pts-num.observed, 1);

km = kmeans(f_u,length(ids));
% realign indices
[~, j] = min(f_u);
min_lab = km(j);
max_lab = setdiff(1:length(ids), min_lab);
f_u_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);

km = kmeans(f_u_nn,length(ids));
% realign indices
[~, j] = min(f_u_nn);
min_lab = km(j);
max_lab = setdiff(1:length(ids), min_lab);
f_u_nn_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
sum(f_u_KM == y(unobserved_inds))/length(unobserved_inds)
sum(f_u_nn_KM == y(unobserved_inds))/length(unobserved_inds)


if make_plots == 1
    figure(1)
    subplot(1,3,1)
    plot(f_u,f_u_nn,'o')
    subplot(1,3,2)
    hist(f_u,50)
    subplot(1,3,3)
    hist(f_u_nn,50)
end

fprintf('Computing MMF factorization\n')
params = GP_params;

params.fraction = num.frac;
L_u_mmf = MMF(L_u,params);
L_u_nn_mmf = MMF(L_u_nn,params);
L_u_mmf_inv = L_u_mmf;
L_u_nn_mmf_inv = L_u_nn_mmf;

L_u_mmf_inv.invert();
L_u_mmf_inv = L_u_mmf_inv.reconstruction();
L_u_nn_mmf_inv.invert();
L_u_nn_mmf_inv = L_u_nn_mmf_inv.reconstruction();

f_u_mmf = L_u_mmf_inv*W(unobserved_inds,observed_inds)*f_o;
f_u_mmf_CMN = f_u_mmf .* repmat(q./sum(f_u), num.pts-num.observed, 1);
f_u_nn_mmf = L_u_nn_mmf_inv*W_nn(unobserved_inds,observed_inds)*f_o;

if make_plots == 1
    figure(1)
    subplot(1,3,1)
    plot(f_u,f_u_mmf,'o')
    subplot(1,3,2)
    hist(f_u,30)
    subplot(1,3,3)
    hist(f_u_mmf,50)
end

% how well did we do?
km = kmeans(f_u_mmf,length(ids));
% realign indices
[~, j] = min(f_u_mmf);
min_lab = km(j);
max_lab = setdiff(1:length(ids), min_lab);
f_u_mmf_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
sum(f_u_mmf_KM == y(unobserved_inds))/length(unobserved_inds)

km = kmeans(f_u_nn_mmf,length(ids));
% realign indices
[~, j] = min(f_u_nn_mmf);
min_lab = km(j);
max_lab = setdiff(1:length(ids), min_lab);
f_u_nn_mmf_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
sum(f_u_nn_mmf_KM == y(unobserved_inds))/length(unobserved_inds)
% where is the error be incurred?


% (1) Check the original matrices and see if there are strong deviances

% option 1
if make_plots == 1
    k = randsample(size(L_u_mmf,1),3);
    figure(1)
    for i = 1:3
        subplot(1,3,i)
        plot(L_u(k(i),L_u(k(i),:)<1),L_u_mmf(k(i),L_u_mmf(k(i),:)<1),'o')
    end
end

% we see that a lot of the problem is coming from the fact that the MMF
% takes a lot of distinct values from the real matrix and projects them
% onto a single value. this is basically an analysis so far of the off-diagonal
% entries since these are the only ones that will be large.

% option 2
plot(diag(L_u),diag(L_u_mmf),'o')

% specifically on the diagonals we see a bit of scattering, but this
% actually looks pretty good. The problem is when we had a lot of
% information in the original matrix which is just getting thrown out.

% (2) Check the inverse of the original matrices and see if there are strong deviances
s = 5;
if make_plots == 1
    k = randsample(size(L_u_mmf_inv,1),s);
    figure(1)
    for i = 1:s
        subplot(1,s,i)
        plot(L_u_inv(k(i),L_u_inv(k(i),:)<1e-4),L_u_mmf_inv(k(i),L_u_mmf_inv(k(i),:)<1e-4),'o')
    end
end

% we find the same thing happening as before inversion

plot(diag(L_u_inv),diag(L_u_mmf_inv),'o')
% Now we have a serious problem re the inverse.


% (3) Consider a spectral comparison
[V, D] = eig(L_u);
d = (diag(D));
[V_mmf, D_mmf] = eig(L_u_mmf);
d_mmf = (diag(D_mmf));
% option 1: comparing eigenvalues
plot(d(d>40),d_mmf(d_mmf>40),'o')
s = 5;
if make_plots == 1
    k = randsample(size(L_u_mmf_inv,1),s);
    figure(1)
    for i = 1:s
        subplot(1,s,i)
        plot(V(:,k(i)),V_mmf(:,k(i)),'o')
    end
end
