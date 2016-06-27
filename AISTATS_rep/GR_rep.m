addpath_ssl(0) % change

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

save('Data/test_cite.mat','core_vec','core_store')

