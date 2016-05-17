function[] = MMF_comparisonsTIME(dataset_ind,run)
% First choose a dataset
rng('shuffle')
on_galton = 1;
if on_galton == 0
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Buffalo')
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Benchmarks')
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_param_search/',...
        '/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_functions/')
    addpath('/Users/jeskreiswinkler/mmfc/v4/src/matlab')
elseif on_galton == 1;
    
    addpath('/net/wallace/ga/eskreiswinkler/MMF/SSL/Buffalo')
    addpath('/net/wallace/ga/eskreiswinkler/MMF/SSL/Benchmarks')
    addpath('/net/wallace/ga/eskreiswinkler/MMF/GP/GP_param_search/',...
        '/net/wallace/ga/eskreiswinkler/MMF/GP/GP_functions/')
    addpath('/net/wallace/ga/eskreiswinkler/mmfc/v4/src/matlab')
end

switch dataset_ind
    case 1
        dataset_name = 'digit1';
        eval(sprintf('load Data/%s.mat',dataset_name))
        sigma = 756;
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

make_plots = 0;
ids = unique(y);
num.pts = length(y);
num.classes = length(ids);
num.obs = 10;
grid.observed = round(linspace(2,97, num.obs));
num.draws = 3;
num.fracs = 10;
grid.fracs = linspace(0.01,0.99,num.fracs);
num.nn = 50;

KM_store = zeros(num.draws, num.obs);
time_store = zeros(num.draws, num.obs);
KM_store2 = zeros(num.draws, num.obs);
KM_store_mmf = cell(num.fracs,1);
KM_store_mmf_s = cell(num.fracs,1);
KM_store_mmf2 = cell(num.fracs,1);
KM_store_mmf_s2 = cell(num.fracs,1);
time_store_mmf = cell(num.fracs,1);
time_store_mmf_s = cell(num.fracs,1);
for cur_frac = 1:num.fracs
    KM_store_mmf{cur_frac} = zeros(num.draws, num.obs);
    KM_store_mmf_s{cur_frac} = zeros(num.draws, num.obs);
    KM_store_mmf2{cur_frac} = zeros(num.draws, num.obs);
    KM_store_mmf_s2{cur_frac} = zeros(num.draws, num.obs);
    time_store_mmf{cur_frac} = zeros(num.draws, num.obs);
    time_store_mmf_s{cur_frac} = zeros(num.draws, num.obs);
end

K = make_ker(X',num.pts,sigma);
Knn = zeros(size(K));

for row  = 1:num.pts
    % first find the lower bound:
    m = K(row,:);
    c = sort(K(row,:));
    c = c(length(c)-num.nn-1);
    Knn(row,m>c) = 1;
end

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
        
        Wnn = Knn - diag(diag(Knn));
        Dnn = diag(sum(Wnn,2));
        Lnn_u = Dnn(unobserved_inds,unobserved_inds)-Wnn(unobserved_inds,unobserved_inds);
        
        f_o = y(observed_inds);
        v = Wnn(unobserved_inds,observed_inds)*f_o;
        tic();
        f_u = Lnn_u\v;
        time_store(cur_draw,cur_obs) = toc();
        
        if make_plots == 1
            figure(1)
            subplot(1,3,1)
            plot(f_u,f_u_mmf,'o')
            subplot(1,3,2)
            hist(f_u,30)
            subplot(1,3,3)
            hist(f_u_mmf,50)
        end
        % Compare to MMF
        fprintf('Computing MMF factorization\n')
        params = GP_params;
        for cur_frac = 1:num.fracs
            fprintf('Obs inds: %d (%d), Draw: %d (%d), Fraction: %d (%d)\n',cur_obs,length(grid.observed),cur_draw,num.draws,cur_frac,num.fracs)
            params.fraction = grid.fracs(cur_frac);
            
            tic();
            Mnn = MMF(Lnn_u,params);
            b = toc();
            
            Mnn_inv = Mnn;
            tic();
            Mnn_inv.invert();
            f_u_mmf = Mnn_inv.hit(v);
            time_store_mmf{cur_frac}(cur_draw,cur_obs)=toc()+b;
            
            km = kmeans(f_u_mmf,num.classes);
            % realign indices
            [~, j] = min(f_u_mmf);
            min_lab = km(j);
            max_lab = setdiff(1:num.classes, min_lab);
            f_u_KM_mmf = repmat(ids(1),length(km),1).*(km==min_lab) + ...
                repmat(ids(2),length(km),1).*(km==max_lab);
            th = prctile(f_u_mmf,p*100);
            f_u_KM_mmf2 = ids(1)*(f_u_mmf<=th)+ ids(2)*(f_u_mmf>th);
            
            KM_store_mmf{cur_frac}(cur_draw,cur_obs) = ...
                sum(f_u_KM_mmf == y(unobserved_inds))/(num.pts-num.observed);
            KM_store_mmf2{cur_frac}(cur_draw,cur_obs) = ...
                sum(f_u_KM_mmf2 == y(unobserved_inds))/(num.pts-num.observed);
            
            tic();
            f_u_mmf_s = Mnn.solve(v);
            time_store_mmf_s{cur_frac}(cur_draw,cur_obs) = toc()+b;
            
            km = kmeans(f_u_mmf_s,num.classes);
            % realign indices
            [~, j] = min(f_u_mmf_s);
            min_lab = km(j);
            max_lab = setdiff(1:num.classes, min_lab);
            f_u_KM_mmf_s = repmat(ids(1),length(km),1).*(km==min_lab) + ...
                repmat(ids(2),length(km),1).*(km==max_lab);
            th = prctile(f_u_mmf_s,p*100);
            f_u_KM_mmf_s2 = ids(1)*(f_u_mmf_s<=th)+ ids(2)*(f_u_mmf_s>th);
            KM_store_mmf_s{cur_frac}(cur_draw,cur_obs) = ...
                sum(f_u_KM_mmf_s == y(unobserved_inds))/(num.pts-num.observed);
            KM_store_mmf_s2{cur_frac}(cur_draw,cur_obs) = ...
                sum(f_u_KM_mmf_s2 == y(unobserved_inds))/(num.pts-num.observed);
        end
        % Use k means
        km = kmeans(f_u,num.classes);
        % realign indices
        [~, j] = min(f_u);
        min_lab = km(j);
        max_lab = setdiff(1:num.classes, min_lab);
        f_u_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
        th = prctile(f_u,p*100);
        f_u_KM2 = ids(1)*(f_u<=th)+ ids(2)*(f_u>th);
        
        KM_store(cur_draw,cur_obs) = sum(f_u_KM == y(unobserved_inds))/(num.pts-num.observed);
        KM_store2(cur_draw,cur_obs) = sum(f_u_KM2 == y(unobserved_inds))/(num.pts-num.observed);
    end
end

save(sprintf('Data/%s_obs%d_draws%d_frac%d_%d.mat',dataset_name, num.obs, ...
    num.draws, num.fracs,run),'KM_store','KM_store_mmf','KM_store_mmf_s',...
    'time_store','time_store_mmf','time_store_mmf_s',...
    'KM_store2','KM_store_mmf2','KM_store_mmf_s2')