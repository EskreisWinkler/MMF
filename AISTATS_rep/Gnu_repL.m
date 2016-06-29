addpath_ssl(1) % change

data = csvread('Data/p2p-Gnutella06.csv');
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

grid_size = 5;
core_reduc_vec = linspace(0.1,0.99,grid_size);
fraction_vec = linspace(0.01,0.99,grid_size);
stages_vec = round(linspace(1,20,grid_size));
frob_store = zeros(length(core_reduc_vec),length(fraction_vec),length(stages_vec));
time_store = zeros(size(frob_store));

p = SSL_params(1,1);

for cur_cr = 1:length(core_reduc_vec)
    % make nystrom predictions here:
    
    for cur_frac = 1:length(fraction_vec)
        for cur_stage = 1:length(stages_vec)
            p.dcore = round((1-core_reduc_vec(cur_cr))*p.pts);
            p.ndensestages = stages_vec(cur_stage);
            p.nclusters = -ceil(p.pts/p.maxclustersize);
            p.fraction = fraction_vec(cur_frac);
            p.verbosity = 0;
            
            tic();
            L_mmf = MMF(Lap,p);
            
            time_store(cur_cr,cur_frac,cur_stage) = toc();
            
            frob_store(cur_cr,cur_frac,cur_stage) = L_mmf.froberror/normalization;
            L_mmf.delete();
        end
    end
end



save('Data/Gnu-repL.mat','time_store','frob_store')


