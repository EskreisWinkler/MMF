function[] = SSL_GPR(run)
% First choose a dataset
rng('shuffle')
server = 0;
if server == 0
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Buffalo')
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Benchmarks')
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_param_search/',...
        '/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_functions/')
    addpath('/Users/jeskreiswinkler/mmfc/v4/src/matlab')
elseif server == 1;
    addpath('/net/wallace/ga/eskreiswinkler/MMF/SSL/Buffalo')
    addpath('/net/wallace/ga/eskreiswinkler/MMF/SSL/Benchmarks')
    addpath('/net/wallace/ga/eskreiswinkler/MMF/GP/GP_param_search/',...
        '/net/wallace/ga/eskreiswinkler/MMF/GP/GP_functions/')
    addpath('/net/wallace/ga/eskreiswinkler/mmfc/v4/src/matlab')
elseif server==2
    addpath('/home/eskreiswinkler/MMF/SSL/Buffalo')
    addpath('/home/eskreiswinkler/MMF/SSL/Benchmarks')
    addpath('/home/eskreiswinkler/MMF/GP/GP_param_search/',...
        '/home/eskreiswinkler/MMF/GP/GP_functions/')
    addpath('/home/eskreiswinkler/mmfc/v4/src/matlab')
end

dataset_name = 'magic';

eval(sprintf('load Data/%s.mat',dataset_name))
sigma = 20;

% make_plots = 0;
ids = unique(y);
num.pts = length(y);
num.classes = length(ids);
num.obs = 10;
grid.observed = round(linspace(2,97, num.obs));
grid.observed = grid.observed(end);
num.obs = length(grid.observed);
num.draws = 3;
grid.fracs = [0.66 0.99];
num.fracs = length(grid.fracs);
% num.fracs = 10;
% grid.fracs = linspace(0.01,0.99,num.fracs);
num.nn = 50;
num.beta = 0.01;

res_store = zeros(num.draws, num.obs);
time_store = zeros(num.draws, num.obs);
res_store_mmf = cell(num.fracs,1);
time_store_mmf = cell(num.fracs,1);
for cur_frac = 1:num.fracs
    res_store_mmf{cur_frac} = zeros(num.draws, num.obs);
    time_store_mmf{cur_frac} = zeros(num.draws, num.obs);
end

W = make_ker(X',num.pts,sigma);
% Knn = sparse(zeros(size(K)));
Wnn = zeros(size(W));


for pt  = 1:num.pts
    % first find the lower bound:
    m = W(pt,:);
    c = sort(m);
    c = c(length(c)-num.nn);
    Wnn(pt,m>c) = 1;
    Wnn(m>c,pt) = 1;
end
W_Lap = Wnn - diag(diag(Wnn));
D_Lap = diag(sum(W_Lap,2));
Lap = D_Lap - W_Lap;
clear D_Lap W_Lap;
% reg_type = 'inv'; will uncomment this when we can generalize code a bit

% assign conditions
conditions = cell(num.draws,1);
for cur_draw = 1:num.draws
    conditions{cur_draw} = cell(length(grid.observed),1);
    for cur_obs = 1:length(grid.observed)
        num.observed = grid.observed(cur_obs);
        good_draw = false;
        while good_draw == false
            observed_inds = randsample(1:num.pts,num.observed);
            good_draw = length(unique(y(observed_inds)))==num.classes;
        end
        conditions{cur_draw}{cur_obs} = observed_inds;
    end
end

% first do MMF runs and then compare it to the baseline
params = GP_params;
for cur_frac = 1:num.fracs
    % assume for now we are just doing an inverse regularization
    
    params.dcore = round((1-grid.fracs(cur_frac))*num.pts);
    params.nsparsestages = max(1,ceil((log(params.dcore) - log(num.pts))/log(1-params.fraction)));
    params.nclusters = -ceil(num.pts/params.maxclustersize);
    params.verbosity = 0;
    tic();
    K = MMF(Lap,params);
    K.invert();
            
    mmf_compute = toc();
    
    for cur_draw = 1:num.draws
        for cur_obs = 1:num.obs
            observed_inds = conditions{cur_draw}{cur_obs};
            unobserved_inds = setdiff(1:num.pts,observed_inds);
            p = sum(y(unobserved_inds)==ids(1))/length(y(unobserved_inds));
            
            f_o = y(observed_inds);
            
            tic();

            K_star = zeros(num.pts,length(observed_inds));
            for i = 1:length(observed_inds)
                e = zeros(num.pts,1); e(observed_inds(i))=1;
                K_star(:,i) = K.hit(e);
            end
            
            f_u_mmf = K_star(unobserved_inds,:)*(K_star(observed_inds,:)\f_o);
            
            th = prctile(f_u_mmf,p*100);
            f_u_hat_mmf = ids(1)*(f_u_mmf<=th)+ ids(2)*(f_u_mmf>th);
            time_store_mmf{cur_frac}(cur_draw,cur_obs) = mmf_compute + toc();
            
            res_store_mmf{cur_frac}(cur_draw,cur_obs) = ...
                sum(f_u_hat_mmf == y(unobserved_inds))/(num.pts-num.observed);
        end
    end
end

tic();
K = inv(Lap);
inv_comp = toc();

for cur_draw = 1:num.draws
    for cur_obs = 1:num.obs
        observed_inds = conditions{cur_draw}{cur_obs};
        num.observed = length(observed_inds);
        unobserved_inds = setdiff(1:num.pts,observed_inds);
        p = sum(y(unobserved_inds)==ids(1))/length(y(unobserved_inds));
        
        f_o = y(observed_inds);
        
        tic()
        
        K_star = zeros(num.pts,length(observed_inds));
            for i = 1:length(observed_inds)
                e = zeros(num.pts,1); e(observed_inds(i))=1;
                K_star(:,i) = K*e;
            end
        f_u = K_star(unobserved_inds,:)*(K(observed_inds,:)\f_o);
        
        th = prctile(f_u,p*100);
        f_u_hat = ids(1).*(f_u<=th)+ ids(2).*(f_u>th);
        time_store(cur_draw,cur_obs) = toc()+inv_comp;
        
        res_store(cur_draw,cur_obs) = ...
            sum(f_u_hat == y(unobserved_inds))/(num.pts-num.observed);
    end
end



save(sprintf('Data/GPR_%s_obs%d_draws%d_frac%d_%d.mat',dataset_name, num.obs,num.draws, num.fracs,run),...
    'res_store','res_store_mmf','time_store','time_store_mmf')