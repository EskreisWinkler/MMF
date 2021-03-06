% First choose a dataset
addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Buffalo')
addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Benchmarks')
addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_param_search/',...
    '/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_functions/')
load Data/secstr.mat;
k = 15;
sig_min = 1;
sig_max = 15;
make_plots = 0;

% X is data: NxP and y is response that is Nx1
% here y has many categories so I want to partition into binary, at least
% initially. If this step is not needed, rename y as y2 so that the code
% works.
%y2 = -1*(y<=2)+1*(y>=3);
%y2 = y;
% For the secstr dataset the next line is required
%s = randsample(size(T,1),3000,0);
%X=double(T(s,:));
%y2 = -1*(y(s)<1)+y(s);

% We want to run a cross validation to find the optimal sigma in defining
% an rbf kernel.

%%% define a proposed range of sigmas
%%% Some suggested ranges:
%%% digit1 : 400,1200 --------> 756
%%% coil*  : 80, 200 ---------> 93
%%% usps   : 200, 1000 -------> 733 
%%% text   : 100, 15000 ------> 6772
%%% secstr : 2, 30 -----------> 6 (suspect)

% note this was in-sample error. for a more accurate analysis we would need
% out of sample error.


n_sigmas = 10;
sigma_range = round(linspace(sig_min,sig_max,n_sigmas));
n_reps = 10;
acc_store = zeros(length(sigma_range),n_reps);

for k = 1:length(sigma_range)
    sigma = sigma_range(k);
    
    n = length(y2);
    
    n_observed = 300;
    % enter loop to select the observations
    ids = unique(y2);
    n_classes = length(ids);
    for cur_rep = 1:n_reps
        good_draw = false;
        while good_draw == false
            observed = randsample(1:length(y2),n_observed);
            good_draw = length(unique(y2(observed)))==n_classes;
        end
        
        unobserved = setdiff(1:n,observed);
        if make_plots == 1
            figure(1)
            subplot(1,2,1)
            histogram(y2(observed))
            subplot(1,2,2)
            histogram(y2(unobserved))
        end
        K = make_ker(X',n,sigma);
        
        D = diag(sum(K-diag(diag(K)),1));
        W = K - diag(diag(K));
        L = D(unobserved,unobserved)-W(unobserved,unobserved);
        f_o = y2(observed);
        f_u =  L\W(unobserved,observed)*f_o;
        
        % compute the CMN solution
        q = sum(f_o)+1; % the unnormalized class proportion estimate from labeled data, with Laplace smoothing
        f_u_CMN = f_u .* repmat(q./sum(f_u), n-n_observed, 1);
        if make_plots==1
            figure(2)
            subplot(4,1,1)
            hist(K(1,:),50)
            subplot(4,1,2)
            hist(f_u,100)
            subplot(4,1,3)
            hist(f_u_CMN,100)
            subplot(4,1,4)
            plot(f_u_CMN,y2(unobserved),'o')
        end
        
        km = kmeans(f_u,length(ids));
        [a j] = min(f_u);
        min_lab = km(j);
        max_lab = setdiff(1:2, min_lab);
        f_u_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
        accuracy =  sum(f_u_KM == y2(unobserved))/length(unobserved);
        if make_plots == 1
            figure(3)
            subplot(1,2,1)
            histogram(f_u_CMN(f_u_KM==-1));
            hold on;
            histogram(f_u_CMN(f_u_KM==1));
            hold off;
            legend('plabel = -1','plabel = 1')
            subplot(1,2,2)
            h1 = histogram(f_u_CMN(f_u_KM==-1 & y2(unobserved)==-1));
            hold on
            h2 = histogram(f_u_CMN(f_u_KM==-1 & y2(unobserved)==1));
            h3 = histogram(f_u_CMN(f_u_KM==1 & y2(unobserved)==-1));
            h4 = histogram(f_u_CMN(f_u_KM==1 & y2(unobserved)==1));
            hold off
            legend('plabel = -1, tlabel = -1','plabel = -1, tlabel = 1',...
                'plabel = 1, tlabel = -1','plabel = 1, tlabel = 1')
        end
        acc_store(k,cur_rep) = accuracy;
    end
end

plot(sigma_range,acc_store,'o')
hold on
plot(sigma_range,mean(acc_store,2),'LineWidth',3)
hold off
