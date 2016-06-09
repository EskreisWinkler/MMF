function[p] = SSL_params(y,dataset_ind)

switch dataset_ind % need to empirically find what works.
    case 1
        p.sigma = 1;
    case 2
        p.sigma = 90;
    case 3
        p.sigma = 3.5;
    case 4
        p.sigma = 1;
    otherwise
        fprintf('This is not a valid dataset_ind\n')
end

p.ids = unique(y);
p.pts = length(y);
p.classes = length(p.ids);
%p.obs = 10;
%p.observed = round(linspace(2,97, p.obs));
%p.obs = length(p.observed);
p.draws = 3;
p.nn = 3;
p.beta = 0.01;
p.lambda=1;
% for a weighted graph where we threshold weights to be over a certain
% point, we threshold at a percentile: what proportion of the weights in
% the complete graph should be preserved
p.edge_percent = 0.25;

% MMF parameters
p.k = 2;
p.fraction = 0.02;
p.maxclustersize = 500;
p.bypass=3;
p.minclustersize = 1;
p.verbosity = 0;
p.nsparsestages = 1; % This will have some introspection.
p.nclusters = -1; % this will have some introspection.
% A is teh size of the matrix
%params.nsparsestages = max(1,ceil((log(params.dcore) - log(A.nrows))/log(1-params.fraction)));

% A is teh size of the matrix
%params.nclusters = -ceil(A.nrows*1.0/params.maxclustersize);