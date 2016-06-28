addpath_ssl(1) % change

data = csvread('Data/ca-GrQc.csv');
p = SSL_params(1,1);
c.num_edges = size(data,1);

data = data(randperm(c.num_edges),:);

c.node_ids = sort(unique([data(:,1); data(:,2)]));
c.num_nodes = length(c.node_ids);

W = spalloc(c.num_nodes,c.num_nodes,3*c.num_edges);


for cur_edge = 1:c.num_edges
    if mod(cur_edge,1000)==0
        fprintf('cur_edge = %d \n', cur_edge)
    end
    i_name= data(cur_edge,1);
    j_name = data(cur_edge,2);
    i_ind = find(i_name == c.node_ids);
    j_ind = find(j_name == c.node_ids);
    
    W(i_ind,j_ind) = 1;
    W(i_ind,j_ind) = 1;
    W(i_ind,i_ind) = 0;
end

k = 100;
[U, S, V] = svds(W,k);
% best rank k approximation
normalization = norm(W-U*S*V','fro');

D = diag(sum(W,1));
Lap = D-W;

for cur_node = 1:c.num_nodes
    Lap(cur_node,cur_node) = Lap(cur_node,cur_node) + p.lambda;
end
p.num_core = 10;
core_vec = linspace(0.01,0.99,p.num_core);
err_store = zeros(size(core_vec));
for cur_core = 1:length(core_vec)
        
        p.dcore = round((1-core_vec(cur_core))*c.num_nodes);
        p.ndensestages = 15;
        p.nclusters = -ceil(c.num_nodes/p.maxclustersize);
        p.fraction = 0.3;
        p.verbosity = 0;
        
        tic();
        Lap_mmf = MMF(Lap,p);
        toc();
        err_store(cur_core) = Lap_mmf.froberror;
        Lap_mmf.delete();
end
err_store_normed = err_store/normalization;

% now work on EVD as an interpretation for what is going on:
k = 100; 
[V, D] = eigs(Lap,k,'lm');
baseline_store.V = V;
baseline_store.D = diag(D);


mmf_store = cell(length(core_vec),1);

for cur_cr = 1:length(core_vec)
    p.dcore = round((1-core_vec(cur_cr))*p.pts);
    p.nsparsestages = 6; % based on what I had before.
    p.nclusters = -ceil(p.pts/p.maxclustersize);
    p.fraction = 0.3;
    p.verbosity = 1;
    
    L_mmf = MMF(Lap,p);
    
    mmf_store{cur_cr}.V = zeros(size(V));
    mmf_store{cur_cr}.D = zeros(size(V,1),1);
    
    L_temp = zeros(Lap);
    for col = 1:length(mmf_store{cur_cr}.D)
        e_vec = zeros(size(V,1),1); e_vec(col)=1;
        L_temp(:,col) = L_mmf.hit(e_vec);
    end
    
    [mmf_store{cur_cr}.V D] = eig(K_temp);
    mmf_store{cur_cr}.D = diag(D);
    frob_store(cur_cr) = K_mmf.froberror;
    
    K_mmf.delete();
end

save('Data/GR_rep_fro.mat','core_vec','core_store','normalization')
save('Data/GR_rep_EVD.mat','core_vec','mmf_store','baseline_store')

