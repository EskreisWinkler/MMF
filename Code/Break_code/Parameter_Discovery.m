function[c] = Parameter_Discovery(k,ndensestages,fraction,N) 
% This is a script intended to show the impact of different parameter adjustments in the MMF model. Parameter adjustments might be manifest by changes in computation time, accuracy.

addpath('~/MMF_project/mmfc/v4/src/matlab/')

% Generate N datapoints of dimensions 1, equally spaced between -d and d. 
dim = 1;
d = 3;
x = linspace(-1*d,d,N);

% make this into a Guassian kernel with parameter vector sigma
bandwidth = ones(dim,1);
add_noise = 1;

sq_term = repmat(x.*x,N,1)+repmat((x.*x)',1,N) - 2*x'*x; 
kern_mat = ones(N);
for cur_dim = 1:dim
	cur_data = x(cur_dim,:);
	sq_term = repmat(cur_data.*cur_data,N,1)+repmat((cur_data.*cur_data)',1,N) - 2*cur_data'*cur_data;
	kern_mat = kern_mat.* exp(-sq_term./bandwidth(cur_dim));
end 
kern_mat = kern_mat + add_noise*eye(N);

% Compute MMF for this kernel matrix.

% Setup MMF parameters
params.k=k;
params.ndensestages=ndensestages;
params.fraction=fraction;
kern_mat_MMF = MMF(kern_mat,params);
 

% Given this simple kernel matrix we want to make comparisons the same way that ONeil did. WHat were the points of measurement?





