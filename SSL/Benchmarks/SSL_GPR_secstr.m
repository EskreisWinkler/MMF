function[] = SSL_GPR_secstr(perc_data,run)
% First choose a dataset
rng('shuffle')
server = 2;
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

dataset_name    = 'secstr';
c = sprintf('load Data/%s_kmat_p%d.mat',dataset_name,perc_data);
eval(c);

% make_plots = 0;
ids = unique(y);
num.pts = length(y);
num.classes = length(ids);
num.obs = 10;

grid.observed = round(linspace(num.classes,round(0.02*num.pts), num.obs));
num.draws = 3;
grid.fracs = [0.6 0.8 0.99];
num.fracs = length(grid.fracs);
% num.fracs = 10;
% grid.fracs = linspace(0.01,0.99,num.fracs);

KM_store = zeros(num.draws, num.obs);
time_store = zeros(num.draws, num.obs);
KM_store_mmf = cell(num.fracs,1);
time_store_mmf = cell(num.fracs,1);

for cur_frac = 1:num.fracs
    KM_store_mmf{cur_frac}=zeros(num.draws, num.obs);
    time_store_mmf{cur_frac} = zeros(num.draws, num.obs);
end

W_Lap = Knn - diag(diag(Knn));
D_Lap = diag(sum(W_Lap,2));
Lap = D_Lap - W_Lap;
clear D_Lap W_Lap;

for cur_obs = 1:length(grid.observed)
    num.observed = grid.observed(cur_obs);
    for cur_draw = 1:num.draws;
        % enter loop to select the observations
        good_draw = false;
        while good_draw == false
            observed_inds = randsample(1:num.pts,num.observed);
            good_draw = length(unique(y(observed_inds)))==num.classes;
        end
        unobserved_inds = setdiff(1:num.pts,observed_inds);
        p = sum(y(unobserved_inds)==ids(1))/length(y(unobserved_inds));
        
        f_o = y(observed_inds);
        
        tic();
        K_star = zeros(num.pts,length(observed_inds));
        e = zeros(num.pts,1);
        for i = 1:length(observed_inds)
            e = e*0;
            e(observed_inds(i)) = 1;
            K_star(:,i) = Lap\e;
        end
        f_u = K_star(unobserved_inds,:)*(K_star(observed_inds,:)\f_o);
        time_store(cur_draw,cur_obs) = toc();
        th = prctile(f_u,p*100);
        f_u_KM = ids(1).*(f_u<=th)+ ids(2).*(f_u>th);
            
        KM_store(cur_draw,cur_obs) = sum(f_u_KM == y(unobserved_inds))/(num.pts-num.observed);

        % Compare to MMF
        fprintf('Computing MMF factorization\n')
        params = GP_params;
        for cur_frac = 1:num.fracs
            fprintf('Obs inds: %d (%d), Draw: %d (%d), Fraction: %d (%d)\n',cur_obs,length(grid.observed),cur_draw,num.draws,cur_frac,num.fracs)
            
            params.dcore = round((1-grid.fracs(cur_frac))*num.pts);
            params.nsparsestages = max(1,ceil((log(params.dcore) - log(num.pts))/log(1-params.fraction)));
            params.nclusters = -ceil(num.pts/params.maxclustersize);
            
            tic();
            K = MMF(Lap,params);
            
            K_star = zeros(num.pts,length(observed_inds));
            e = zeros(num.pts,1);
            for i = 1:length(observed_inds)
                e = e*0;
                e(observed_inds(i))=1;
                K_star(:,i) = K.solve(e);
            end
            
            f_u_mmf = K_star(unobserved_inds,:)*(K_star(observed_inds,:)\f_o);
            
            time_store_mmf{cur_frac}(cur_draw,cur_obs) = toc();
            
            th = prctile(f_u_mmf,p*100);
            f_u_KM_mmf = ids(1).*(f_u_mmf<=th)+ ids(2).*(f_u_mmf>th);
            KM_store_mmf{cur_frac}(cur_draw,cur_obs) = ...
                sum(f_u_KM_mmf == y(unobserved_inds))/(num.pts-num.observed);
        end
    end
end

save(sprintf('Data/GPR_%s_percData%d_obs%d_draws%d_frac%d_%d.mat',dataset_name, perc_data, num.obs,num.draws, num.fracs,run),...
    'KM_store','KM_store_mmf','time_store','time_store_mmf')
