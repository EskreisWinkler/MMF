function[] =cluster_review(dataset_ind)

% want to investigate dependencies of
%   (1) core_reduc (dcore),
%   (2) maxclustersize/number of clusters
%   (3) whether or not bypass matters
%   (4) even/innerprod clustering
%   (5) different graph_types
%
% -> As expressed by accuracy and frobenius error.


% things to do,
%   1) decide on grid
%   2) set parameters better.

core_reduc_vec = linspace(0.8,0.99,2);
max_cluster_vec = [200 500 1000];
bypass_vec = 0:1;
clustering_method_vec = 0:2;

frob_store = zeros(length(clustering_method_vec),length(bypass_vec),length(core_reduc_vec),length(max_cluster_vec));
frob_store_rel = frob_store;
actual_core_size = frob_store;
actual_stages = frob_store;
time_store = zeros(size(frob_store));
stages_store = cell(length(clustering_method_vec),length(bypass_vec),length(core_reduc_vec),length(max_cluster_vec));
stages_store2= cell(length(clustering_method_vec),length(bypass_vec),length(core_reduc_vec),length(max_cluster_vec));
param_store = cell(length(clustering_method_vec),length(bypass_vec),length(core_reduc_vec),length(max_cluster_vec));
% First choose a dataset
rng('shuffle')

%addpath_mmf(server);
server = 2; % change
addpath_mmf(server);
server = 0; % change
addpath_mmf(server);

if dataset_ind>=1 && dataset_ind<2
    s = sprintf('load Data/digit1_lap%d',round(mod(dataset_ind*10,10)));
    eval(s)
elseif dataset_ind>=2&& dataset_ind<3
    s = sprintf('load Data/coil_lap%d',round(mod(dataset_ind*10,10)));
    eval(s)
elseif dataset_ind>=3 && dataset_ind<4
    s = sprintf('load Data/usps_lap%d',round(mod(dataset_ind*10,10)));
    eval(s)
elseif dataset_ind>=4 && dataset_ind<5
    s = sprintf('load Data/text_lap%d',round(mod(dataset_ind*10,10)));
    eval(s)
elseif dataset_ind==5
    load Data/ca-GrQc
elseif dataset_ind==6
    load Data/p2p-Gnutella06
elseif dataset_ind==7
    load Data/magic
elseif dataset_ind==8
    load Data/cit-HepTh
else
    fprintf('Notworking\n')
    eval('exit;')
end

s = sprintf('output/review_data%d-%d.out',floor(dataset_ind),mod(dataset_ind*10,10));
fileID = fopen(s,'w');

p = mmf_params;
p.pts = size(M,1);


% (clustering_method_vec,bypass_vec,core_reduc_vec,max_cluster_vec)
for cur_cl = 1:length(clustering_method_vec)
    for cur_by = 1:length(bypass_vec)
        
        for cur_cr = 1:length(core_reduc_vec)
            for cur_mc = 1:length(max_cluster_vec)
                
                
                p.clustering_method = clustering_method_vec(cur_cl);
                fprintf(fileID,'Current clustering method: %d\t',p.clustering_method);
                
                p.bypass = bypass_vec(cur_by);
                fprintf(fileID,'Bypass set to: %d\t',p.bypass);
                
                p.dcore = round((1-core_reduc_vec(cur_cr))*p.pts);
                fprintf(fileID,'Current Core Size: %d\t',p.dcore);
                
                p.maxclustersize = max_cluster_vec(cur_mc);
                fprintf(fileID,'Current Max Cluster: %d\t',p.maxclustersize);
                % we can impose a number of clusters so that we insure we
                % compare apples to apples in different clustering methods
                p.nclusters = round(size(M,1)/p.maxclustersize);
                
                fprintf(fileID,'\n');
                
                params_store{cur_cl,cur_by,cur_cr,cur_mc} = [p.clustering_method p.bypass p.dcore p.maxclustersize];
                p.verbosity = 0;

                tic();
                M_mmf = MMF(M,p);
                
                time_store(cur_cl,cur_by,cur_cr,cur_mc) = toc();
                
                frob_store(cur_cl,cur_by,cur_cr,cur_mc) = M_mmf.diagnostic.frob_error;
                frob_store_rel(cur_cl,cur_by,cur_cr,cur_mc) = M_mmf.diagnostic.rel_error;
                
                % store core sizes
                actual_core_size(cur_cl,cur_by,cur_cr,cur_mc) = M_mmf.diagnostic.core_size;
                % store distribution of clusters
                actual_stages(cur_cl,cur_by,cur_cr,cur_mc) = size(M_mmf.diagnostic.stages,1);
                stages_store2{cur_cl,cur_by,cur_cr,cur_mc} = cell(actual_stages(cur_cl,cur_by,cur_cr,cur_mc),1);
                for i = 1:actual_stages(cur_cl,cur_by,cur_cr,cur_mc)
                    
                    if i==1
                        s_tot = sprintf('a%d',i);
                        s_tot2 = sprintf('a%d',i);
                    else
                        s = sprintf(',a%d',i);
                        s_tot = sprintf('%s%s',s_tot,s);
                        s_tot2 = sprintf('%s;a%d',s_tot2,i);
                    end
                end
                s = sprintf('[%s] = M_mmf.diagnostic.stages.cluster_sizes;',s_tot);
                eval(s);
                s = sprintf('stages_store{cur_cl,cur_by,cur_cr,cur_mc}= [%s];',s_tot2);
                eval(s);
                for i = 1:actual_stages(cur_cl,cur_by,cur_cr,cur_mc)
                    s = sprintf('stages_store2{cur_cl,cur_by,cur_cr,cur_mc}{i} = a%d;',i);
                    eval(s);
                end
                %M_mmf.delete();
            end
        end
    end
end
fclose(fileID);


%save(sprintf('Data/review_%s_graph%d_draws%d_INNERP.mat',dataset_name,graph_type,draws),'res_store','time_store','bench_res','bench_time', 'frob_store',...
%        'frob_store_rel','actual_core_size','actual_stages','stages_stores',...
%        'core_reduc_vec', 'fraction_vec','max_cluster_vec')

save(sprintf('Data/review_data%d-%d.mat',floor(dataset_ind),mod(dataset_ind*10,10)),'time_store','frob_store','frob_store_rel',...
    'actual_core_size','actual_stages','stages_store', 'stages_store2','params_store',...
    'clustering_method_vec', 'bypass_vec','max_cluster_vec','core_reduc_vec')
