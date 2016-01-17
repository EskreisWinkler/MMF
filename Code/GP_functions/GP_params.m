function[params] =GP_params()

% Demo parameters
params.num_dp = 625;
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
params.ndensestages = 1;
params.fraction = 0.7;
params.maxclustersize = 100;
params.bypass=3;
params.minclustersize = 1;
