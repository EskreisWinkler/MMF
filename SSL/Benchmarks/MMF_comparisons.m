function[] = MMF_comparisons(dataset_ind,run)
% First choose a dataset
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


% First simply copy the Lafferty plot
n_obs = 10;
observed_grid = round(linspace(2,97, n_obs));
n = length(y);
n_classes = length(ids);
n_draws = 5;
n_fracs = 10;
frac_grid = linspace(0.01,0.99,n_fracs);

KM_store = zeros(n_draws, n_obs);
KM_store_mmf = cell(n_fracs,1);
for cur_frac = 1:n_fracs
    KM_store_mmf{cur_frac} = zeros(n_draws, n_obs);
end


for cur_obs = 1:length(observed_grid)
    n_observed = observed_grid(cur_obs);
    for cur_draw = 1:n_draws;
        % enter loop to select the observations
        good_draw = false;
        while good_draw == false
            observed_inds = randsample(1:length(y),n_observed);
            good_draw = length(unique(y(observed_inds)))==n_classes;
        end
        unobserved_inds = setdiff(1:length(y),observed_inds);
        
        K = make_ker(X',length(y),sigma);
        
        W = K - diag(diag(K));
        D = diag(sum(W,1));
        L_u = D(unobserved_inds,unobserved_inds)-W(unobserved_inds,unobserved_inds);
        
        f_o = y(observed_inds);
        f_u = L_u\W(unobserved_inds,observed_inds)*f_o;
        q = sum(f_o)+1; % the unnormalized class proportion estimate from labeled data, with Laplace smoothing
        f_u_CMN = f_u .* repmat(q./sum(f_u), n-n_observed, 1);
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
        for cur_frac = 1:n_fracs
            fprintf('Obs inds: %d (%d), Draw: %d (%d), Fraction: %d (%d)\n',cur_obs,length(observed_grid),cur_draw,n_draws,cur_frac,n_fracs)
            
            params.fraction = frac_grid(cur_frac);
            
            M_inv = MMF(L_u,params);
            
            M_inv.invert();
            f_u_mmf = M_inv.hit(W(unobserved_inds,observed_inds)*f_o);
            f_u_mmf_CMN = f_u_mmf .* repmat(q./sum(f_u), n-n_observed, 1);
            km = kmeans(f_u_mmf,length(ids));
            % realign indices
            [~, j] = min(f_u_mmf);
            min_lab = km(j);
            max_lab = setdiff(1:2, min_lab);
            f_u_KM_mmf = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
            KM_store_mmf{cur_frac}(cur_draw,cur_obs) = sum(f_u_KM_mmf == y(unobserved_inds))/length(unobserved_inds);
        end
        % Use k means
        km = kmeans(f_u,length(ids));
        % realign indices
        [~, j] = min(f_u);
        min_lab = km(j);
        max_lab = setdiff(1:length(ids), min_lab);
        f_u_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
        
        
        %km = kmeans(f_u_DK,length(ids));
        %[~, j] = min(f_u_DK);
        %min_lab = km(j);
        %max_lab = setdiff(1:length(ids), min_lab);
        %f_u_DK_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
        
        KM_store(cur_draw,cur_obs) = sum(f_u_KM == y(unobserved_inds))/length(unobserved_inds);
        %KM_store_DK(cur_draw,cur_obs) = sum(f_u_DK_KM ==labels(unobserved_inds))/length(unobserved_inds);
    end
end

save(sprintf('Data/%s_obs%d_draws%d_frac%d_%d.mat',dataset_name, n_obs, n_draws, n_fracs,run),'KM_store_mmf','KM_store')

if make_plots == 1
    plot(observed_grid,mean(KM_store,1))
    hold on
    plot(observed_grid,mean(KM_store_mmf{1},1))
    plot(observed_grid,mean(KM_store_mmf{2},1))
    plot(observed_grid,mean(KM_store_mmf{3},1))
    plot(observed_grid,mean(KM_store_mmf{4},1))
    hold off
end
