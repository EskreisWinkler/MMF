function[] =SSL_review(dataset_ind,draws)

% want to investigate dependencies of
%   (1) core_reduc (dcore),
%   (2) fraction elimated at each stage,
%   (3) number of stages.


grid_size = 5;
core_reduc_vec = linspace(0.1,0.99,grid_size);
fraction_vec = linspace(0.01,0.99,grid_size);
stages_vec = round(linspace(1,20,grid_size));
res_store = zeros(length(core_reduc_vec),length(fraction_vec),length(stages_vec));
time_store = zeros(size(res_store));

% First choose a dataset
rng('shuffle')
server = 1;
addpath('../SSL_scripts/')
addpath_ssl(server);

[X,y,dataset_name] = load_SSL(dataset_ind);

p = SSL_params(y);
p.draws = draws;

%eval(sprintf('load Data/cond/%s-conditions_draws%d_run%d.mat',dataset_name,p.draws,run))
%p.obs = length(conditions{1});

[Lap, Lap_w] = lap_maker(X,p,'reg');
%Lap = Lap_w;
% to hope for really good results, fix number observed to always be 10% of data
p.num_observed = round(0.1*p.pts);


% fix a benchmark

tic();
K = pinv(Lap);
k_compute = toc();

bench_res = zeros(p.draws,1);
bench_time = zeros(p.draws,1);

for cur_draw = 1:p.draws
    observed_inds = randsample(1:p.pts,p.num_observed);
    unobserved_inds = setdiff(1:p.pts,observed_inds);
    prior = sum(y(unobserved_inds)==p.ids(1))/length(y(unobserved_inds));
    
    f_o = y(observed_inds);
    
    tic();
    K_star = K(:,observed_inds);
    f_u_pre = K_star(unobserved_inds,:)*(K_star(observed_inds,:)\f_o);
    
    th = prctile(f_u_pre,prior*100);
    f_u_hat = p.ids(1)*(f_u_pre<=th)+ p.ids(2)*(f_u_pre>th);
    bench_time(cur_draw) = k_compute + toc();
    
    bench_res(cur_draw) = ...
        sum(f_u_hat == y(unobserved_inds))/(length(unobserved_inds));
    
    
    for cur_cr = 1:length(core_reduc_vec)
        for cur_frac = 1:length(fraction_vec)
            for cur_stage = 1:length(stages_vec)
                p.dcore = round((1-core_reduc_vec(cur_cr))*p.pts);
                p.ndensestages = stages_vec(cur_stage);
                p.nclusters = -ceil(p.pts/p.maxclustersize);
                p.fraction = fraction_vec(cur_frac);
                p.verbosity = 0;
                
                tic();
                K_mmf = MMF(Lap,p);
                K_mmf.invert();
                K_star = zeros(p.pts,length(observed_inds));
                for i = 1:length(observed_inds)
                    e = zeros(p.pts,1); e(observed_inds(i))=1;
                    K_star(:,i) = K_mmf.hit(e);
                end
                
                f_u_pre = K_star(unobserved_inds,:)*(K_star(observed_inds,:)\f_o);
                
                th = prctile(f_u_pre,prior*100);
                f_u_hat = p.ids(1)*(f_u_pre<=th)+ p.ids(2)*(f_u_pre>th);
                time_store(cur_cr,cur_frac,cur_stage) = time_store(cur_cr,cur_frac,cur_stage)+ ...
                    (1/p.draws)*toc();
                
                res_store(cur_cr,cur_frac,cur_stage) = res_store(cur_cr,cur_frac,cur_stage)+...
                    (1/p.draws)*sum(f_u_hat == y(unobserved_inds))/(length(unobserved_inds));
                
                K_mmf.delete();
            end
        end
    end
end


save(sprintf('Data/review_%s_draws%d.mat',dataset_name,draws),'res_store','time_store',...
    'bench_res','bench_time')


