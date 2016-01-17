function[elapsed_time,Ns] = matlab_demo(k,ndensestages,fraction)

% This is the local path to the most recent version of MMF's matlab directory.
addpath('/net/wallace/ga/eskreiswinkler/mmfc/v4/src/matlab/')


Ns = linspace(100,500,10);
elapsed_time = zeros(size(Ns));

for i = 1:length(Ns)
	% dimensions 1, equally spaced between -d and d.
	N = round(Ns(i));
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
	tic()
	% Setup MMF parameters
	if nargin == 0
		params.k = 2;
		params.ndensestages = 1;
		params.fraction = 0.4;
		params.maxclustersize = 100;
		params.bypass=1;
		params.minclustersize = 20;
	else
		params.k=k;
		params.ndensestages=ndensestages;
		params.fraction=fraction;
	end	
	kern_mat_MMF = MMF(kern_mat,params);
	elapsed_time(i) = toc();
end

plot(Ns,elapsed_time,'o')
print('test','-djpeg','-noui')
