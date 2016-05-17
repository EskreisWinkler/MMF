function[] = MMF_comparisons_secstr(perc_data,run)
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

make_plots = 0;
ids = unique(y);
num.pts = length(y);
num.classes = length(ids);
num.obs = 10;

grid.observed = round(linspace(num.classes,round(0.02*num.pts), num.obs));
num.draws = 3;
num.fracs = 10;
grid.fracs = linspace(0.01,0.99,num.fracs);
num.nn = 50;

KM_store = zeros(num.draws, num.obs);
time_store = zeros(num.draws, num.obs);
KM_store_mmf = cell(num.fracs,1);
time_store_mmf = cell(num.fracs,1);

for cur_frac = 1:num.fracs
    KM_store_mmf{cur_frac}=zeros(num.draws, num.obs);
    time_store_mmf{cur_frac} = zeros(num.draws, num.obs);
end

Wnn = Knn - diag(diag(Knn));
Dnn = diag(sum(Wnn,2));

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
        
        Lnn_u = Dnn(unobserved_inds,unobserved_inds)-Wnn(unobserved_inds,unobserved_inds);
        
        f_o = y(observed_inds);
        
        v = Wnn(unobserved_inds,observed_inds)*f_o;
        
        tic();
        f_u = Lnn_u\v;
        time_store(cur_draw,cur_obs) = toc();
        %q = sum(f_o)+1; % the unnormalized class proportion estimate from labeled data, with Laplace smoothing
        %f_u_CMN = f_u .* repmat(q./sum(f_u), num.pts-num.observed, 1);
        %[V, D] = eig(L(unobserved_inds,unobserved_inds));
        %f_u = V*diag(1./diag(D))*V'*W(unobserved_inds,observed_inds)*f_o;
        %f_u_DK = V*diag(exp(-1.6*diag(D)))*V'*W(unobserved_inds,observed_inds)*f_o;
%         if make_plots == 1
%             figure(1)
%             subplot(1,3,1)
%             plot(f_u,f_u_mmf,'o')
%             subplot(1,3,2)
%             hist(f_u,30)
%             subplot(1,3,3)
%             hist(f_u_mmf,50)
%         end
        % Compare to MMF
        fprintf('Computing MMF factorization\n')
        params = GP_params;
        for cur_frac = 1:num.fracs
            fprintf('Obs inds: %d (%d), Draw: %d (%d), Fraction: %d (%d)\n',cur_obs,length(grid.observed),cur_draw,num.draws,cur_frac,num.fracs)
            
            params.dcore = round((1-grid.fracs(cur_frac))*num.pts);
            params.nsparsestages = max(1,ceil((log(params.dcore) - log(num.pts))/log(1-params.fraction)));
            params.nclusters = -ceil(num.pts/params.maxclustersize);
            
            tic();
            Mnn = MMF(Lnn_u,params);
            b = toc();
            
            v = Wnn(unobserved_inds,observed_inds)*f_o;
            
            tic();
            f_u_mmf = Mnn.solve(v);
            time_store_mmf{cur_frac}(cur_draw,cur_obs) = toc()+b;
            
%             km = kmeans(f_u_nn_mmf_s,num.classes);
%             % realign indices
%             [~, j] = min(f_u_nn_mmf);
%             min_lab = km(j);
%             max_lab = setdiff(1:num.classes, min_lab);
%             f_u_nn_KM_mmf_s = repmat(ids(1),length(km),1).*(km==min_lab) + ...
%                 repmat(ids(2),length(km),1).*(km==max_lab);
            th = prctile(f_u_mmf,p*100);
            f_u_KM_mmf = ids(1).*(f_u_mmf<=th)+ ids(2).*(f_u_mmf>th);
            KM_store_mmf{cur_frac}(cur_draw,cur_obs) = ...
                sum(f_u_KM_mmf == y(unobserved_inds))/(num.pts-num.observed);
        end
%         % Use k means
%         km = kmeans(f_u_nn,num.classes);
%         % realign indices
%         [~, j] = min(f_u_nn);
%         min_lab = km(j);
%         max_lab = setdiff(1:num.classes, min_lab);
%         
%         f_u_nn_KM = repmat(ids(1),length(km),1).*(km==min_lab)+ ...
%             repmat(ids(2),length(km),1).*(km==max_lab);
        th = prctile(f_u,p*100);
        f_u_KM = ids(1).*(f_u<=th)+ ids(2).*(f_u>th);
            
        KM_store(cur_draw,cur_obs) = sum(f_u_KM == y(unobserved_inds))/(num.pts-num.observed);
    end
end

save(sprintf('Data/%s_percData%d_obs%d_draws%d_frac%d_%d.mat',dataset_name, perc_data, num.obs,num.draws, num.fracs,run),...
    'KM_store','KM_store_mmf','time_nn_store','time_nn_store_mmf')
