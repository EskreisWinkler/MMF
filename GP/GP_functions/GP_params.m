function[params] =GP_params()

% Demo parameters
params.num_dp = 50;
params.bdry = 3;
params.data_noise = 10;
params.restart_noise = 1.5;
params.n_iters = 3;
params.n_restarts = 1;
params.t_o_1D = [3 0.5 0.5];
params.t_o_2D = [3 0.25 0.25 0.5];
params.rel_grid_size = 0.75;

% MMF parameters
params.k = 2; 
params.nsparsestages = 3; 
params.fraction = 0.2;
params.maxclustersize = 2000; 
params.bypass=3; 
params.minclustersize = 1;
params.verbosity = 0;
%%params.dcore = 10;
% A is teh size of the matrix
%params.nsparsestages = max(1,ceil((log(params.dcore) - log(A.nrows))/log(1-params.fraction)));

% A is teh size of the matrix
%params.nclusters = -ceil(A.nrows*1.0/params.maxclustersize);