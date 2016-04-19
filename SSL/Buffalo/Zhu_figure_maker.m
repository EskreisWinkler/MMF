%function[] = Zhu_figure_maker(sigma)
addpath('/Users/jeffreywinkler/Google_Drive/15fall/Kondor/DiffKernel/Buffalo/Data')
addpath('/phddata/eskreiswinkler/galton_home/MMF/DiffKernel/Buffalo/Data/')
addpath('/Users/jeffreywinkler/MMF_project/mmfc/v4/src/matlab/')
addpath('/phddata/eskreiswinkler/galton_home/mmfc/v4/src/matlab/')
addpath('/Users/jeffreywinkler/Google_Drive/15fall/Kondor/Code/GP_param_search/',...
    '/Users/jeffreywinkler/Google_Drive/15fall/Kondor/Code/GP_functions/')
addpath('/phddata/eskreiswinkler/galton_home/MMF/Code/GP_param_search/')
addpath('/phddata/eskreiswinkler/galton_home/MMF/Code/GP_functions/')


images = importdata('X.csv');
labels = importdata('Y.txt');
labels(labels==0) = -1;
ids = [-1 1];

% First simply copy the Lafferty plot

n_obs = 10;
observed_grid = round(linspace(2,97, n_obs));
n_classes = length(unique(labels));
n_draws = 5;
sigma=380;
n_fracs = 6;
frac_grid = linspace(0,0.5,n_fracs);
frac_grid=frac_grid(1:2);

EM_store = zeros(n_draws, n_obs);
KM_store = zeros(n_draws, n_obs);
EM_store_mmf = cell(n_fracs,1);
KM_store_mmf = cell(n_fracs,1);
for cur_frac = 1:n_fracs
    EM_store_mmf{cur_frac} = zeros(n_draws, n_obs);
    KM_store_mmf{cur_frac} = zeros(n_draws, n_obs);
end
for cur_obs = 1:length(observed_grid)
    n_observed = observed_grid(cur_obs);
    for cur_draw = 1:n_draws;
        % enter loop to select the observations
        good_draw = false;
        while good_draw == false
            observed_inds = randsample(1:length(labels),n_observed);
            good_draw = length(unique(labels(observed_inds)))==n_classes;
        end
        unobserved_inds = setdiff(1:length(labels),observed_inds);
        
        n_sample = length(labels);
        
        K = make_ker(images',n_sample,sigma);
        
        W = K - diag(diag(K));
        D = diag(sum(W,1));
        L = D-W;
        
        f_o = labels(observed_inds);
        f_u = L(unobserved_inds,unobserved_inds)\W(unobserved_inds,observed_inds)*f_o;
        % Compare to MMF
        fprintf('Computing MMF factorization\n')
        params = GP_params;
        for cur_frac = 1:length(frac_grid)
            params.fraction = frac_grid(cur_frac);
            M_inv = MMF(L(unobserved_inds,unobserved_inds),params);
            M_inv.invert();
            L_pre = W(unobserved_inds,observed_inds)*f_o;
            f_u_mmf = M_inv.hit(L_pre);
            f_u_EM_mmf = energy_minimization(f_u_mmf,f_o,unobserved_inds,L,ids);
            km = kmeans(f_u_mmf,length(ids));
            % realign indices
            [~, j] = min(f_u_mmf);
            min_lab = km(j);
            max_lab = setdiff([1:2], min_lab);
            f_u_KM_mmf = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
            EM_store_mmf{cur_frac}(cur_draw,cur_obs) = sum(f_u_EM_mmf == labels(unobserved_inds))/length(unobserved_inds);
            KM_store_mmf{cur_frac}(cur_draw,cur_obs) = sum(f_u_KM_mmf == labels(unobserved_inds))/length(unobserved_inds);
            [cur_obs, cur_draw, cur_frac]
        end
        % Use energmy minimization
        f_u_EM = energy_minimization(f_u,f_o,unobserved_inds,L,ids);
        % Use k means
        km = kmeans(f_u,length(ids));
        % realign indices
        [a j] = min(f_u);
        min_lab = km(j);
        max_lab = setdiff([1:2], min_lab);
        f_u_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
        
        EM_store(cur_draw,cur_obs) = sum(f_u_EM == labels(unobserved_inds))/length(unobserved_inds);
        KM_store(cur_draw,cur_obs) = sum(f_u_KM == labels(unobserved_inds))/length(unobserved_inds);
    end
end

% % Now investigate a ton of plots...
% plot(observed_grid,mean(KM_store,1),'LineWidth',5)
% hold on
% plot(observed_grid,mean(KM_store_mmf{1},1))
% plot(observed_grid,mean(KM_store_mmf{2},1))
% plot(observed_grid,mean(KM_store_mmf{3},1))
% plot(observed_grid,mean(KM_store_mmf{4},1))
% plot(observed_grid,mean(KM_store_mmf{5},1))
% hold off

save('Data/ZhuFigMaker_obs10_draws5_frac0102.mat','KM_store_mmf','KM_store','EM_store_mmf','EM_store')




