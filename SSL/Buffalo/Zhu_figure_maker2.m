%function[] = Zhu_figure_maker2(sigma)
addpath('/Users/jeffreywinkler/Google_Drive/15fall/Kondor/DiffKernel/Buffalo/Data')
addpath('/Users/jeffreywinkler/MMF_project/mmfc/v4/src/matlab/')
addpath('/Users/jeffreywinkler/Google_Drive/15fall/Kondor/Code/GP_param_search/',...
    '/Users/jeffreywinkler/Google_Drive/15fall/Kondor/Code/GP_functions/')


images = importdata('X.csv');
labels = importdata('Y.txt');
labels(labels==0) = -1;
ids = [-1 1];

% First simply copy the Lafferty plot

n_obs = 10;
observed_grid = round(linspace(2,97, n_obs));
n_classes = length(unique(labels));
n_draws = 1;
sigma=380;
n_fracs = 5;
frac_grid = linspace(0,0.5,n_fracs);

EM_store = zeros(n_draws, n_obs);
KM_store = zeros(n_draws, n_obs);
KM_store_DK = KM_store;
KM_store_mmf = cell(n_fracs,1);
for cur_frac = 1:n_fracs
    EM_store_mmf{cur_frac} = zeros(n_draws, n_obs);
    KM_store_mmf{cur_frac} = zeros(n_draws, n_obs);
end

observed_grid = observed_grid(5);

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
        [V D] = eig(L(unobserved_inds,unobserved_inds));
        f_u = V*diag(1./diag(D))*V'*W(unobserved_inds,observed_inds)*f_o;
        f_u_DK = V*diag(exp(-1.6*diag(D)))*V'*W(unobserved_inds,observed_inds)*f_o;
        figure(1)
        subplot(1,3,1)
        plot(f_u,f_u_DK,'o')
        subplot(1,3,2)
        hist(f_u,30)
        subplot(1,3,3)
        hist(f_u_DK,50)
        % Compare to MMF
%         fprintf('Computing MMF factorization\n')
%         params = GP_params;
%         for cur_frac = 1:n_fracs
%             params.fraction = frac_grid(cur_frac);
%             M_inv = MMF(L(unobserved_inds,unobserved_inds),params);
%             M_inv.invert();
%             L_pre = W(unobserved_inds,observed_inds)*f_o;
%             f_u_mmf = M_inv.hit(L_pre);
%             f_u_EM_mmf = energy_minimization(f_u_mmf,f_o,unobserved_inds,L,ids);
%             km = kmeans(f_u_mmf,length(ids));
%             % realign indices
%             [~, j] = min(f_u_mmf);
%             min_lab = km(j);
%             max_lab = setdiff([1:2], min_lab);
%             f_u_KM_mmf = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
%             EM_store_mmf{cur_frac}(cur_draw,cur_obs) = sum(f_u_EM_mmf == labels(unobserved_inds))/length(unobserved_inds);
%             KM_store_mmf{cur_frac}(cur_draw,cur_obs) = sum(f_u_KM_mmf == labels(unobserved_inds))/length(unobserved_inds);
%             [cur_obs, cur_draw, cur_frac]
%         end
        % Use k means
        km = kmeans(f_u,length(ids));
        % realign indices
        [a, j] = min(f_u);
        min_lab = km(j);
        max_lab = setdiff(1:length(ids), min_lab);
        f_u_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
        
        
        km = kmeans(f_u_DK,length(ids));
        [a, j] = min(f_u_DK);
        min_lab = km(j);
        max_lab = setdiff(1:length(ids), min_lab);
        f_u_DK_KM = ids(1)*(km==min_lab)+ ids(2)*(km==max_lab);
        f_u_DK_KM = (f_u_DK<=0.06)*-1+(f_u_DK>0.06)*1;
        
        KM_store(cur_draw,cur_obs) = sum(f_u_KM == labels(unobserved_inds))/length(unobserved_inds);
        KM_store_DK(cur_draw,cur_obs) = sum(f_u_DK_KM ==labels(unobserved_inds))/length(unobserved_inds);
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

save('ZhuFigMaker_obs10_draws5_frac5.mat','KM_store_mmf','KM_store','EM_store_mmf','EM_store')




