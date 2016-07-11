function[] =SSL_review(dataset_ind,graph_type)

% want to investigate dependencies of
%   (1) core_reduc (dcore),
%   (2) fraction elimated at each stage,
%   (3) number of stages.
%   (4) different graph_types
%
% -> As expressed by accuracy and frobenius error.

draws=1;

grid_size = 5;
core_reduc_vec = linspace(0.1,0.99,grid_size);
fraction_vec = linspace(0.1,0.99,grid_size);
fraction_vec = [0.2 0.4 0.6];
stages_vec = round(linspace(1,10,grid_size));
max_cluster_vec = round(linspace(20,200,grid_size));
max_cluster_vec = [20 100 200];
res_store = zeros(length(max_cluster_vec),length(core_reduc_vec),length(fraction_vec),length(stages_vec));
frob_store = res_store;
frob_store_rel = frob_store;
actual_core_size = frob_store;
actual_stages = frob_store;
time_store = zeros(size(res_store));
stages_store = cell(length(max_cluster_vec),length(core_reduc_vec),length(fraction_vec),length(stages_vec));

% First choose a dataset
rng('shuffle')
server = 2; % change
addpath_ssl(server);

[X,y,dataset_name] = load_SSL(dataset_ind);

s = sprintf('output/review_%s_graph%d.out',dataset_name,graph_type);
fileID = fopen(s,'w');

p = SSL_params(y,dataset_ind);
p.draws = draws;
p.nn = 3;

[Lap] = lap_maker(X,p,graph_type);
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
    for cur_mc = 1:length(max_cluster_vec)
        for cur_cr = 1:length(core_reduc_vec)
            % make nystrom predictions here:
            for cur_frac = 1:length(fraction_vec)
                for cur_stage = 1:length(stages_vec)
                    
                    p.maxclustersize = max_cluster_vec(cur_mc);
                    p.nclusters = round(p.pts/p.maxclustersize);
                    fprintf(fileID,'Current Num Clusters: %d\t',round(p.pts/p.maxclustersize));
                    
                    p.dcore = round((1-core_reduc_vec(cur_cr))*p.pts);
                    fprintf(fileID,'Current Core Size: %d\t',p.dcore);
                    
                    p.fraction = fraction_vec(cur_frac);
                    fprintf(fileID,'Current Fraction: %0.2f\t',p.fraction);
                    
                    p.ndensestages = stages_vec(cur_stage);
                    fprintf(fileID,'Current Num Stages: %d\t',p.ndensestages);
                    
                    fprintf(fileID,'\n');
                    p.verbosity = 0;
                    tic();
                    
                    K_mmf = MMF(Lap,p);
                    K_mmf.invert();
                    K_star = zeros(p.pts,length(observed_inds));
                    for i = 1:length(observed_inds)
                        %if mod(i,100)==0
                            %fprintf('We are %0.2f of the way there \n', i/ length(observed_inds));
                        %end
                        e = zeros(p.pts,1); e(observed_inds(i))=1;
                        K_star(:,i) = K_mmf.hit(e);
                    end
                    
                    f_u_pre = K_star(unobserved_inds,:)*(K_star(observed_inds,:)\f_o);
                    
                    th = prctile(f_u_pre,prior*100);
                    f_u_hat = p.ids(1)*(f_u_pre<=th)+ p.ids(2)*(f_u_pre>th);
                    time_store(cur_mc, cur_cr,cur_frac,cur_stage) = time_store(cur_mc, cur_cr,cur_frac,cur_stage)+ ...
                        (1/p.draws)*toc();
                    
                    res_store(cur_mc,cur_cr,cur_frac,cur_stage) = res_store(cur_mc, cur_cr,cur_frac,cur_stage)+...
                        (1/p.draws)*sum(f_u_hat == y(unobserved_inds))/(length(unobserved_inds));
                    %frob_store(cur_mc, cur_cr,cur_frac,cur_stage) = K_mmf.diagnostic.frob_error;
                    %frob_store_rel(cur_mc, cur_cr,cur_frac,cur_stage) = K_mmf.diagnostic.rel_error;
                    
                    % store core sizes
                    %actual_core_size(cur_mc, cur_cr,cur_frac,cur_stage) = K_mmf.diagnostic.core_size;
                    % store distribution of clusters
                    %actual_stages(cur_mc, cur_cr,cur_frac,cur_stage) = size(K_mmf.diagnostic.stages,1);
                    for i = 1:actual_stages(cur_mc, cur_cr,cur_frac,cur_stage)
                        if i==1
                            s_tot = sprintf('a%d',i);
                        else
                            s = sprintf(',a%d',i);
                            s_tot =  sprintf('%s%s',s_tot,s);
                        end
                        s = sprintf('[%s] = K_mmf.diagnostic.stages.cluster_sizes;',s_tot);
                        %eval(s);
                        s = sprintf('stages_store{cur_mc, cur_cr,cur_frac,cur_stage}= [%s];',s_tot);
                        %eval(s);
                    end
                    %K_mmf.delete();
                end
            end
        end
    end
end
fclose(fileID);


%save(sprintf('Data/review_%s_graph%d_draws%d_INNERP.mat',dataset_name,graph_type,draws),'res_store','time_store','bench_res','bench_time', 'frob_store',...
%        'frob_store_rel','actual_core_size','actual_stages','stages_stores',...
%        'core_reduc_vec', 'fraction_vec','stages_vec','max_cluster_vec')

save(sprintf('Data/review_%s_graph%d_draws%d_INNERP.mat',dataset_name,graph_type,draws),'res_store','time_store','bench_res','bench_time', 'frob_store',...
        'frob_store_rel','actual_core_size','actual_stages','stages_store',...
        'core_reduc_vec', 'fraction_vec','stages_vec','max_cluster_vec')

