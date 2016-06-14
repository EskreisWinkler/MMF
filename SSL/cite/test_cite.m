addpath_ssl(0)

data = csvread('Data/cit-HepTh.csv');
p = SSL_params(1,1);
c.n = size(data,1);

c.num_edges = 10000;


data = data(randperm(c.n),:);

data_sub = data(1:c.num_edges,:);

c.node_ids = unique([data_sub(:,1); data_sub(:,2)]);
c.num_nodes = length(c.node_ids);

W = spalloc(c.num_nodes,c.num_nodes,2*c.num_edges);

for cur_edge = 1:c.num_edges
    if mod(cur_edge,100)==0
        %fprintf('cur_edge = %d \n', cur_edge)
    end
    i_id= data_sub(cur_edge,1);
    j_id = data_sub(cur_edge,2);
    i = find(i_id == c.node_ids);
    j = find(j_id == c.node_ids);
    
    W(i,j) = 1;
    W(j,i) = 1;
    W(i,i) = 0;
end



D = diag(sum(W,1));
Lap = D-W;

for cur_node = 1:c.num_nodes
    Lap(cur_node,cur_node) = Lap(cur_node,cur_node) + p.lambda;
end
p.num_core = 30;
core_vec = linspace(0.01,0.99,p.num_core);
core_store = zeros(size(core_vec));
for cur_core = 1:length(core_vec)
        
        p.dcore = round((1-core_vec(cur_core))*c.num_nodes);
        p.ndensestages = 15;
        p.nclusters = -ceil(c.num_nodes/p.maxclustersize);
        p.fraction = 0.6;
        p.verbosity = 0;
        
        tic();
        %Lap_mmf = MMF(Lap,p);
        toc();
        keyboard
        core_store(cur_core) = Lap_mmf.froberror;
        
        Lap_mmf.delete();
end

save('Data/test_cite.mat','core_vec','core_store')

