addpath_ssl(1) % change

p = AISTATS_params;

load Data/ca-GrQc.mat

p.num_core = 10;

core_vec = linspace(0.01,0.99,p.num_core);
clustering_method_vec = 0:2;
frob_store = zeros(length(clustering_method_vec),length(core_vec));
time_store = frob_store;
for cur_cl = 1:length(clustering_method_vec)
    for cur_cr = 1:length(core_vec)
        
        p.dcore = round((1-core_vec(cur_cr))*size(M,1));
        p.verbosity = 0;
        p.clustering_method = clustering_method_vec(cur_cl);
        tic();
        M_mmf = MMF(M,p);
        time_store(cur_cl,cur_cr) = toc();
        frob_store(cur_cl,cur_cr) = M_mmf.froberror;
        
    end
end

save('Data/GR_rep_fro.mat','core_vec','time_store','frob_store','core_vec','clustering_method_vec')

