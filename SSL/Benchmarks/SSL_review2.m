function[] =SSL_review2(dataset_ind,graph_type)

% want to investigate where we are incurring error as a function of core
% size -- which singular values are causing us problems? is it high
% frequency regions of the graph?
%
% as expressed by projection of response onto different e-vecs of spectrum


grid_size = 20;
%grid_size = 1;
core_reduc_vec = linspace(0.1,0.99,grid_size);


% First choose a dataset
rng('shuffle')
server = 2; % change
addpath_ssl(server);

[X,y,dataset_name] = load_SSL(dataset_ind);

p = SSL_params(y,dataset_ind);
p.nn = 3;


[Lap] = lap_maker(X,p,graph_type);
% to hope for really good results, fix number observed to always be 10% of data
p.num_observed = round(0.1*p.pts);


tic();
K = pinv(Lap);
time = toc();
p.num_eigs = 50;
[V, D] = eig(K);

evals = [real(diag(D)) (1:size(D,1))'];
evals_sort = sort(evals,1); % low to high
benchmark.D = evals_sort(:,1);
V = V(:,evals_sort(:,2));
benchmark.V_lo = V(:,1:p.num_eigs);
benchmark.V_hi = V(:,(end-p.num_eigs+1):end);
% need to select the biggest ones:
%mmf_store = cell(length(core_reduc_vec),1);
frob_store = zeros(size(core_reduc_vec));
% K = V*D*V'

for cur_cr = 1:length(core_reduc_vec)
    p.dcore = round((1-core_reduc_vec(cur_cr))*p.pts);
    p.ndensestages = 6; % based on what I had before.
    p.nclusters = -ceil(p.pts/p.maxclustersize);
    p.fraction = 0.3;
    p.verbosity = 0;
    
    K_mmf = MMF(Lap,p);
    K_mmf.invert();

    [V, D] = eig(K_mmf.reconstruction());
    evals = [real(diag(D)) (1:size(D,1))'];
    evals_sort = sort(evals,1);
    eval(sprintf('mmf_store%d.D = evals_sort(:,1);',cur_cr));
    V = V(:,evals_sort(:,2));
    eval(sprintf('mmf_store%d.V_lo = V(:,1:p.num_eigs);',cur_cr));
    eval(sprintf('mmf_store%d.V_hi = V(:,(end-p.num_eigs+1):end);;',cur_cr));
    frob_store(cur_cr) = K_mmf.froberror;
    
    K_mmf.delete();
end

for i = 1:length(core_reduc_vec)
    if i==1
        s_tot = sprintf('\''mmf_store%d\''',i);
    else
        s = sprintf(',\''mmf_store%d\''',i);
        s_tot =  sprintf('%s%s',s_tot,s);
    end
end

term1 = sprintf('\''Data/review2_%s_graph%d.mat\''',dataset_name,graph_type);
s = sprintf('save(%s,\''benchmark\'',\''core_reduc_vec\'',\''frob_store\'',%s);',term1,s_tot);
eval(s);