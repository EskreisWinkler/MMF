function[] = repL_analysis(snapset)

grid_size = 5;
core_reduc_vec = linspace(0.1,0.99,grid_size);
fraction_vec = linspace(0.1,0.99,grid_size);
stages_vec = round(linspace(1,20,grid_size));
max_cluster_vec = round(linspace(20,200,grid_size));

% this is the structure
% frob_store = (max_cluster,core_reduc_vec,fraction,stages)
% time_store = (max_cluster,core_reduc_vec,fraction,stages)

switch snapset
    case 1 % GR
        load Data/GR-repL_fro.mat
        data = csvread('Data/ca-GrQc.csv');
    case 2 % Gnu
        load Data/Gnu-repL_fro.mat
        data = csvread('Data/p2p-Gnutella06.csv');
end

addpath_ssl(0) % change


p = SSL_params(1,1);

% this is the structure
% frob_store = (max_cluster,core_reduc_vec,fraction,stages)
% time_store = (max_cluster,core_reduc_vec,fraction,stages)

figure(1) % core x fraction x stage
for cr_ind = 1:grid_size
    %cur_res = frob_store(1,cr_ind,:,2:end);
    %cur_res = reshape(cur_res,grid_size,grid_size-1);
    
    cur_res = frob_store(1,cr_ind,:,:);
    cur_res = reshape(cur_res,grid_size,grid_size);
    subplot(grid_size,1,cr_ind)
    plot(fraction_vec,cur_res)
    xlabel('Fraction')
    ylabel('Error')
    title(sprintf('Core size: %d Percent',round(core_reduc_vec(cr_ind)*100)))
    if cr_ind ==1
        legend(sprintf('Stages: %d',stages_vec(1)),sprintf('Stages: %d',stages_vec(2)),...
            sprintf('Stages: %d',stages_vec(3)),sprintf('Stages: %d',stages_vec(4)),sprintf('Stages: %d',stages_vec(5)))
    end
end

figure(2) % max_cluster x core x fraction
for mc_ind = 1:grid_size
    %cur_res = frob_store(1,cr_ind,:,2:end);
    %cur_res = reshape(cur_res,grid_size,grid_size-1);
    
    cur_res = frob_store(mc_ind,3,:,:);
    cur_res = reshape(cur_res,grid_size,grid_size);
    subplot(grid_size,1,mc_ind)
    plot(fraction_vec,cur_res)
    xlabel('Fraction')
    ylabel('Error')
    title(sprintf('Max Cluster size: %d ',round(max_cluster_vec(mc_ind))))
    if mc_ind ==1
        legend(sprintf('Stages: %d',stages_vec(1)),sprintf('Stages: %d',stages_vec(2)),...
            sprintf('Stages: %d',stages_vec(3)),sprintf('Stages: %d',stages_vec(4)),sprintf('Stages: %d',stages_vec(5)))
    end
end


%figure(3) % max_cluster x core x fraction
for fr_ind = 1:grid_size
    %cur_res = frob_store(1,cr_ind,:,2:end);
    %cur_res = reshape(cur_res,grid_size,grid_size-1);
    
    cur_res = frob_store(:,:,fr_ind,4);
    cur_res = reshape(cur_res,grid_size,grid_size);
    subplot(grid_size,1,fr_ind)
    plot(max_cluster_vec,cur_res)
    xlabel('Max Cluster Size')
    ylabel('Error')
    title(sprintf('Fraction size: %0.2f ',(fraction_vec(fr_ind))))
    if fr_ind ==1
        legend(sprintf('Core: %0.2f',core_reduc_vec(1)),sprintf('Core: %0.2f',core_reduc_vec(2)),...
            sprintf('Core: %0.2f',core_reduc_vec(3)),sprintf('Core: %0.2f',core_reduc_vec(4)),sprintf('Core: %0.2f',core_reduc_vec(5)))
    end
end

% reproduce the main plot for DC vs frob:
figure(4)
core_reduc_vec_store = zeros(5,1);
fraction_vec_store = zeros(5,1);
vec_store = fraction_vec_store;
for cr_ind = 1:length(core_reduc_vec_store)
    cur_res =  frob_store(cr_ind,3,:,:);
    cur_res = reshape(cur_res,[numel(cur_res) 1]);
    vec_store(cr_ind) = mean(cur_res);
end

%plot(core_reduc_vec,core_reduc_vec_store,'o')
subplot(1,1,1)
plot(stages_vec,vec_store,'o')
