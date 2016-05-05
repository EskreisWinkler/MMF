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
KM_nn_store = zeros(num.draws, num.obs);
time_nn_store = zeros(num.draws, num.obs);
KM_store_mmf = cell(num.fracs,1);
time_store_mmf = cell(num.fracs,1);
KM_nn_store_mmf = cell(num.fracs,1);
time_nn_store_mmf = cell(num.fracs,1);

for cur_frac = 1:num.fracs
    KM_store_mmf{cur_frac} = zeros(num.draws, num.obs);
    time_store_mmf{cur_frac} = zeros(num.draws, num.obs);
    KM_nn_store_mmf{cur_frac} = zeros(num.draws, num.obs);
    time_nn_store_mmf{cur_frac} = zeros(num.draws, num.obs);
end

K = make_ker(X',num.pts,sigma);
K_nn = zeros(size(K));

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
        
        for row  = 1:num.pts
            % first find the lower bound:
            m = K(row,:);
            c = sort(K(row,:));
            c = c(length(c)-num.nn-1);
            K_nn(row,m>c) = 1;
        end
        
        W = K - diag(diag(K));
        W_nn = K_nn - diag(diag(K_nn));
        
        D = diag(sum(W,2));
        D_nn = diag(sum(W_nn,2));
        
        L_u = D(unobserved_inds,unobserved_inds)-W(unobserved_inds,unobserved_inds);
        L_u_nn = D_nn(unobserved_inds,unobserved_inds)-W_nn(unobserved_inds,unobserved_inds);
        
        f_o = y(observed_inds);
        tic();
        f_u = L_u\W(unobserved_inds,observed_inds)*f_o;
        time_store(cur_draw,cur_obs) = toc();
        tic();
        f_u_nn = L_u_nn\W_nn(unobserved_inds,observed_inds)*f_o;
        time_nn_store(cur_draw,cur_obs) = toc();
        q = sum(f_o)+1; % the unnormalized class proportion estimate from labeled data, with Laplace smoothing
        %f_u_CMN = f_u .* repmat(q./sum(f_u), num.pts-num.observed, 1);
        %[V, D] = eig(L(unobserved_inds,unobserved_inds));
        %f_u = V*diag(1./diag(D))*V'*W(unobserved_inds,observed_inds)*f_o;
        %f_u_DK = V*diag(exp(-1.6*diag(D)))*V'*W(unobserved_inds,observed_inds)*f_o;
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
            M_inv = MMF(L_u,params);
            M_inv.invert();
            f_u_mmf = M_inv.hit(W(unobserved_inds,observed_inds)*f_o);
            time_store_mmf{cur_frac}(cur_draw,cur_obs)=toc();
            
            tic();
            M_nn_inv = MMF(L_u_nn,params);
            M_nn_inv.invert();
            f_u_nn_mmf = M_nn_inv.hit(W_nn(unobserved_inds,observed_inds)*f_o);
            time_nn_store_mmf{cur_frac}(cur_draw,cur_obs)=toc();
            
            %f_u_mmf_CMN = f_u_mmf .* repmat(q./sum(f_u), num.pts-num.observed, 1);
            km = kmeans(f_u_mmf,num.classes);
            % realign indices
            [~, j] = min(f_u_mmf);
            min_lab = km(j);
            max_lab = setdiff(1:num.classes, min_lab);
            f_u_KM_mmf = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
            
            km = kmeans(f_u_nn_mmf,num.classes);
            % realign indices
            [~, j] = min(f_u_nn_mmf);
            min_lab = km(j);
            max_lab = setdiff(1:num.classes, min_lab);
            f_u_nn_KM_mmf = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
            KM_store_mmf{cur_frac}(cur_draw,cur_obs) = sum(f_u_KM_mmf == y(unobserved_inds))/(num.pts-num.observed);
            KM_nn_store_mmf{cur_frac}(cur_draw,cur_obs) = sum(f_u_nn_KM_mmf == y(unobserved_inds))/(num.pts-num.observed);
        end
        % Use k means
        km = kmeans(f_u,num.classes);
        % realign indices
        [~, j] = min(f_u);
        min_lab = km(j);
        max_lab = setdiff(1:num.classes, min_lab);
        f_u_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
        
        km = kmeans(f_u_nn,num.classes);
        % realign indices
        [~, j] = min(f_u_nn);
        min_lab = km(j);
        max_lab = setdiff(1:num.classes, min_lab);
        f_u_nn_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
        
        KM_store(cur_draw,cur_obs) = sum(f_u_KM == y(unobserved_inds))/(num.pts-num.observed);
        KM_nn_store(cur_draw,cur_obs) = sum(f_u_nn_KM == y(unobserved_inds))/(num.pts-num.observed);
    end
end

save(sprintf('Data/%s_obs%d_draws%d_frac%d_%d.mat',dataset_name, num.obs, ...
    num.draws, num.fracs,run),'KM_store_mmf','KM_nn_store_mmf','KM_store',...
    'KM_nn_store','time_store','time_nn_store','time_store_mmf','time_nn_store_mmf')