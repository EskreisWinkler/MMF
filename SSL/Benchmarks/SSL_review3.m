function[] =SSL_review2(dataset_ind,graph_type)

% want to investigate where we are incurring error as a function of core
% size -- which singular values are causing us problems? is it high
% frequency regions of the graph?
%
% as expressed by projection of response onto different e-vecs of spectrum


grid_size = 5;
core_reduc_vec = linspace(0.1,0.99,grid_size);


% First choose a dataset
rng('shuffle')
server = 0; % change
addpath_ssl(server);

[X,y,dataset_name] = load_SSL(dataset_ind);

p = SSL_params(y,dataset_ind);
p.nn = 3;


[Lap] = lap_maker(X,p,graph_type);
% to hope for really good results, fix number observed to always be 10% of data
p.num_observed = round(0.1*p.pts);

[V D] = eig(Lap);
mmf_store = cell(length(core_reduc_vec),1);
frob_store = zeros(size(core_reduc_vec));
% K = V*D*V'

for cur_cr = 1:length(core_reduc_vec)
    p.dcore = round((1-core_reduc_vec(cur_cr))*p.pts);
    p.ndensestages = 6; % based on what I had before.
    p.nclusters = -ceil(p.pts/p.maxclustersize);
    p.fraction = 0.3;
    p.verbosity = 0;
    
    Lap_mmf = MMF(Lap,p);
    mmf_store{cur_cr}.V = zeros(size(V));
    mmf_store{cur_cr}.D = zeros(size(V,1),1);
    
    for col = 1:length(mmf_store{cur_cr}.D)
        mmf_store{cur_cr}.V(:,col) = Lap_mmf.hit(V(:,col));
        mmf_store{cur_cr}.D(col) = norm(mmf_store{cur_cr}.V(:,col));
    end
    frob_store(cur_cr) = Lap_mmf.froberror;
    Lap_mmf.delete();
end


save(sprintf('Data/review3_%s_graph%d.mat',dataset_name,graph_type),'V','D',...
    'mmf_store','core_reduc_vec', 'frob_store')
