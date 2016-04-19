% First choose a dataset
addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Buffalo')
addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Benchmarks')
addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_param_search/',...
    '/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_functions/')
dataset_name = 'digit1';
eval(sprintf('load %s.mat',dataset_name))

sigma = 756;
make_plots = 0;
ids = unique(y);


% First simply copy the Lafferty plot
n_obs = 10;
observed_grid = round(linspace(2,97, n_obs));
n = length(y);
n_classes = length(ids);
n_draws = 5;
n_fracs = 1;
frac_grid = linspace(0.1,0.5,n_fracs);

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
            plot(f_u,f_u_DK,'o')
            subplot(1,3,2)
            hist(f_u,30)
            subplot(1,3,3)
            hist(f_u_DK,50)
        end
        % Compare to MMF
        fprintf('Computing MMF factorization\n')
        params = GP_params;
        for cur_frac = 1:n_fracs
            fprintf('Obs inds: %0.2f, Draw: %0.2f, Fraction: %0.2f\n',cur_obs/length(observed_grid),cur_draw/n_draws,cur_frac/n_fracs)
            
            params.fraction = frac_grid(cur_frac);
            
            M_inv = MMF(L_u,params);
            M_inv.invert();
            L_pre = W(unobserved_inds,observed_inds)*f_o;
            f_u_mmf = M_inv.hit(L_pre);
            km = kmeans(f_u_mmf,length(ids));
            % realign indices
            [~, j] = min(f_u_mmf);
            min_lab = km(j);
            max_lab = setdiff([1:2], min_lab);
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

save(sprintf('%s_obs10_draws5_frac5.mat',dataset_name),'KM_store_mmf','KM_store')


