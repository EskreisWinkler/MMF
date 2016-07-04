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
server = 2; % change
addpath_ssl(server);

[X,y,dataset_name] = load_SSL(dataset_ind);

p = SSL_params(y,dataset_ind);
p.nn = 3;


[Lap] = lap_maker(X,p,graph_type);
% to hope for really good results, fix number observed to always be 10% of data
p.num_observed = round(0.1*p.pts);


tic();
K = pinv(Lap);
time = toc();
[V D] = eig(K);
%mmf_store = cell(length(core_reduc_vec),1);
frob_store = zeros(size(core_reduc_vec));
% K = V*D*V'

for cur_cr = 1:length(core_reduc_vec)
    p.dcore = round((1-core_reduc_vec(cur_cr))*p.pts);
    p.ndensestages = 6; % based on what I had before.
    p.nclusters = -ceil(p.pts/p.maxclustersize);
    p.fraction = 0.3;
    p.verbosity = 0;
    
    K_mmf = MMF(Lap,p);
    K_mmf.invert();
    
    eval(sprintf('mmf_store%d.V = zeros(size(V));',cur_cr));
    eval(sprintf('mmf_store%d.D = zeros(size(V,1),1);',cur_cr));
    
    K_temp = zeros(size(V));
    
    for col = 1:length(diag(D))
        fprintf('We are %2.2f of the way there\n',col/length(diag(D)))
        e_vec = zeros(size(V,1),1); e_vec(col)=1;
        K_temp(:,col) = K_mmf.hit(e_vec);
    end
    
    [Vm D] = eig(K_temp);
    eval(sprintf('mmf_store%d.V = Vm;',cur_cr));
    eval(sprintf('mmf_store%d.D = diag(D);',cur_cr));
    frob_store(cur_cr) = K_mmf.froberror;
    
    K_mmf.delete();
end



save(sprintf('Data/review2_%s_graph%d.mat',dataset_name,graph_type),'V','D',...
    'core_reduc_vec', 'frob_store',...
    'mmf_store1','mmf_store2','mmf_store3','mmf_store4','mmf_store5')
