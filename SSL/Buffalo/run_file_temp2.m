
addpath('/Users/jeffreywinkler/Google_Drive/15fall/Kondor/DiffKernel/Buffalo/Data')
addpath('/Users/jeffreywinkler/MMF_project/mmfc/v4/src/matlab/')
addpath('/Users/jeffreywinkler/Google_Drive/15fall/Kondor/Code/GP_param_search/',...
    '/Users/jeffreywinkler/Google_Drive/15fall/Kondor/Code/GP_functions/')

images = importdata('X.csv');
labels = importdata('Y.txt');
labels(labels==0) = 2;
% Use only zeros and ones  -- this is a relic of a larger dataset
select = (labels==1) + (labels == 2);
images = images(logical(select),:);
labels = labels(logical(select));

n = length(labels);

num_sampled = n;
sample = randsample(n,min([n,num_sampled]),0);
data = images(sample,:);
response = labels(sample);
sigma = 1000;
n_sample = length(response);

num_observed = 100;
observed = randsample(n_sample,min(n_sample,num_observed),0);
unobserved = setdiff(1:n_sample,observed);
figure(2)
histogram(response(unobserved))

K = make_ker(data',n_sample,sigma);

hist(K(1,K(1,:)>0.0001),100)

% Look at a small sample of the data
figure(5)
num_view = 10;
for i=1:num_view
    subplot(1,num_view,i);
    image_viewer(data(i,:));
end

K(1:num_view,1:num_view)

% This is a weight matrix for the graph. Now we compute the degree and
% adjacency matrices.


%E_inv = V'*diag(exp(-1*beta*diag(P)))*V;
E_inv = V'*diag(log(diag(P)))*V;

D = diag(sum(K-diag(diag(K)),1));
W = K - diag(diag(K));
M = D(unobserved,unobserved)-W(unobserved,unobserved);
M=D-W;
M2 = D-W;
D2 = sqrt(D);
M2 = diag(1./diag(D2))*M2*diag(1./diag(D2));
[V P] = eig(M2);
beta = 1;
P_exp = diag(exp(beta*diag(P)));
E = V*P_exp*V';

hist(diag(P_exp))
f_o = response(observed);
f_u1 = E(unobserved,unobserved)\W(unobserved,observed)*f_o;
f_u2 = E_inv(unobserved,unobserved)*W(unobserved,observed)*f_o;

f_u3 = M(unobserved,unobserved)\W(unobserved,observed)*f_o;
figure(1)
subplot(1,5,1)
plot(f_u1,f_u3,'o')
subplot(1,5,2)
hist(f_u1,30)
subplot(1,5,3)
plot(f_u1,response(unobserved),'o')
subplot(1,5,4)
hist(f_u3,30)
subplot(1,5,5)
plot(f_u3,response(unobserved),'o')
% now try with MMF;
params = GP_params;

%see_mmf_effects

fprintf('Computing MMF factorization\n')
M_inv = MMF(M,params);
M_inv.invert();
L_pre = W(unobserved,observed);
L = zeros(size(W(unobserved,observed)));
for i = 1:size(L,2)
    L(:,i) = M_inv.hit(L_pre(:,i));
end
f_u_mmf = L*f_o;
    


f_u=f_u3;
figure(7)
subplot(2,2,1)
histogram(f_u,40)
title('Standard')
subplot(2,2,2)
plot(f_u, response(unobserved),'o')
subplot(2,2,3)
histogram(f_u_mmf,40)
title('MMF')
subplot(2,2,4)
plot(f_u_mmf, response(unobserved),'o')



% measure error:
labs = unique(response);
f_hat = energy_minimization(f_u,f_o,unobserved,D,W,labs);
f_u_hat = f_hat(unobserved);
f_hat_mmf = energy_minimization(f_u_mmf,f_o,unobserved,D,W,labs);
f_u_hat_mmf = f_hat_mmf(unobserved);
% mistakes = (f_u_hat-1)~=response(not_observed);
% mistakes_mmf = (f_u_hat_mmf-1)~=response(not_observed);
% err_rate = sum(mistakes)/length(f_u_hat);
% err_rate_mmf = sum(mistakes_mmf)/length(f_u_hat_mmf);
% err_rate
% err_rate_mmf
