function[] = SSL_magic(reg_cat,frac,run)
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

dataset_name    = 'magic';
c = sprintf('load Data/%s_kmat.mat',dataset_name);
eval(c);

num.draws = 3;
fprintf('Defining the conditions for experiment \n')
c = sprintf('load Data/cond/Conditions_%s_draws%d_run%d.mat', ...
    dataset_name, num.draws, run);
eval(c);

ids = unique(y);
num.pts = length(y);
num.classes = length(ids);
num.obs = length(conditions{1});

num.beta = 0.01;

res_store = zeros(num.draws, num.obs);
time_store = zeros(num.draws, num.obs);

W_Lap = Knn - diag(diag(Knn));
D_Lap = diag(sum(W_Lap,2));
Lap = D_Lap - W_Lap;
clear D_Lap W_Lap Knn;

switch reg_cat
    case 1
        reg_type = 'inv';
    case 2
        reg_type = 'diffusion';
    otherwise
        fprintf('This is a pursuit to nowhere\n')
end



if frac == 0
    fprintf('Computing baseline kernel \n')
        tic();
        switch reg_type
            case 'inv'
                % check this works on the cluster.
                K = Lap\distributed.speye(size(Lap,1));
            case 'diffusion'
                K = expm(-1*num.beta*Lap);
                %[V, D] = eigs(Lap,size(Lap,1)-1);
                %K = V*diag(exp(-1*num.beta*diag(D)))*V';
        end
        ker_comp = toc();
    
    fprintf('Computing baseline predictions \n')
    for cur_draw = 1:num.draws
        for cur_obs = 1:num.obs
            observed_inds = conditions{cur_draw}{cur_obs};
            num.observed = length(observed_inds);
            unobserved_inds = setdiff(1:num.pts,observed_inds);
            p = sum(y(unobserved_inds)==ids(1))/length(y(unobserved_inds));
            
            f_o = y(observed_inds);
            
            tic();
            %f_u = -Lap(unobserved_inds,unobserved_inds)\(Lap(unobserved_inds,observed_inds)*f_o);
            f_u = -K_star(unobserved_inds,:)*(K_star(observed_inds,:)\f_o);
            
            th = prctile(f_u,p*100);
            f_u_hat = ids(1).*(f_u<=th)+ ids(2).*(f_u>th);
            time_store(cur_draw,cur_obs) = toc()+ker_comp;
            
            acc = sum(f_u_hat == y(unobserved_inds))/(num.pts-num.observed);
            
            acc = (acc<0.5)*(1-acc)+(acc>=0.5)*acc;
            
            res_store(cur_draw,cur_obs) = acc;
        end
    end
else
    % We opt to do a MMF approach to predictions
    params = GP_params;
    fprintf('Computing MMF for frac = %d percent \n', frac)
    cur_frac = frac/100;
    params.dcore = round((1-cur_frac)*num.pts);
    params.nsparsestages = max(1,ceil((log(params.dcore) - log(num.pts))/log(1-params.fraction)));
    params.nclusters = -ceil(num.pts/params.maxclustersize);

    tic();
    switch reg_type
        case 'inv'
            K = MMF(Lap,params);
            fprintf('Computing MMF inverse for frac = %d percent \n', frac)
            K.invert();
        case 'diffusion'
            K = MMF(-1*num.beta*Lap,params);
            fprintf('Computing MMF exponential for frac = %d percent \n', frac)
            K.exp();
        otherwise
            fprintf('This is a pursuit to nowhere\n')
    end
    mmf_compute = toc();
    
    
    fprintf('Computing MMF predictions frac = %d percent \n', frac)
    for cur_draw = 1:num.draws
        for cur_obs = 1:num.obs
            observed_inds = conditions{cur_draw}{cur_obs};
            num.observed = length(observed_inds);
            unobserved_inds = setdiff(1:num.pts,observed_inds);
            p = sum(y(unobserved_inds)==ids(1))/length(y(unobserved_inds));
            
            f_o = y(observed_inds);
            
            tic();
            
            K_star = K.submatrix(1:num.pts,observed_inds);
            
            f_u = -K_star(unobserved_inds,:)*(K_star(observed_inds,:)\f_o);
            
            th = prctile(f_u,p*100);
            f_u_hat = ids(1).*(f_u<=th)+ ids(2).*(f_u>th);
            time_store(cur_draw,cur_obs) = mmf_compute + toc();
            
            acc = sum(f_u_hat == y(unobserved_inds))/(num.pts-num.observed);
            
            acc = (acc<0.5)*(1-acc)+(acc>=0.5)*acc;
            
            res_store(cur_draw,cur_obs) = acc;
        end
    end
    K.delete();
end


fprintf('Everything is done, saving file \n') 
save(sprintf('Data/GPR_%s_percData%d_obs%d_draws%d_frac%d_regType%d_%d.mat',...
    dataset_name, perc_data, num.obs,num.draws, frac, reg_cat, run),...
    'res_store','time_store')
