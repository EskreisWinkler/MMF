addpath_ssl(0) % change

load Data/GR_rep.mat

data = csvread('Data/ca-GrQc.csv');
p = SSL_params(1,1);
c.num_edges = size(data,1);

data = data(randperm(c.num_edges),:);

c.node_ids = sort(unique([data(:,1); data(:,2)]));
c.num_nodes = length(c.node_ids);

plot(c.num_nodes*(1-core_vec),err_store_normed,'o')