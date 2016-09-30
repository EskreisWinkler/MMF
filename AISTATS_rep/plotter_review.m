%function[] = plotter_review(dataset_ind,graph_type)
draws=20;
switch dataset_ind
    case 1
        dataset_name = 'digit1';
    case 2
        dataset_name = 'coil';
    case 3
        dataset_name = 'usps';
    case 4
        dataset_name = 'text';
    case 5
        dataset_name = 'secstr';
end

s = sprintf('load Data/review_%s_graph%d_draws%d.mat',dataset_name,graph_type,draws);
eval(s)

grid_size = 5;
core_reduc_vec = linspace(0.1,0.99,grid_size);
fraction_vec = linspace(0.01,0.99,grid_size);
stages_vec = round(linspace(1,20,grid_size));

figure(1)
for cr_ind = 1:grid_size
    cur_res = res_store(cr_ind,:,:);
    cur_res = reshape(cur_res,grid_size,grid_size);
    subplot(grid_size,1,cr_ind)
    plot(fraction_vec,cur_res)
    xlabel('Fraction')
    ylabel('Accuracy')
    title(sprintf('Core size: %d Percent',round(core_reduc_vec(cr_ind)*100)))
    if cr_ind ==1
        legend(sprintf('Stages: %d',stages_vec(1)),sprintf('Stages: %d',stages_vec(2)),...
            sprintf('Stages: %d',stages_vec(3)),sprintf('Stages: %d',stages_vec(4)),sprintf('Stages: %d',stages_vec(5)))
    end
end

figure(2)
for cr_ind = 1:grid_size
    cur_res = res_store(cr_ind,2:end,:);
    cur_res = reshape(cur_res,grid_size^2-grid_size,1);
    cur_err = frob_store(cr_ind,2:end,:);
    cur_err = reshape(cur_err,grid_size^2-grid_size,1);
    if cr_ind>1
        hold on
    end
    plot(cur_err,cur_res,'o')
    if cr_ind>1
        hold off
    end
    xlabel('Frob. Error')
    ylabel('Accuracy')
end
title('Accuracy as a function of Approximation Error')
legend(sprintf('Core: %d ',round(100*core_reduc_vec(1))),sprintf('Core: %d',round(100*core_reduc_vec(2))),...
            sprintf('Core: %d',round(100*core_reduc_vec(3))),sprintf('Core: %d',round(100*core_reduc_vec(4))),sprintf('Core: %d',round(100*core_reduc_vec(5))))
        
figure(3)
for cr_ind = 1:grid_size
    cur_err = frob_store(cr_ind,:,:);
    cur_err = reshape(cur_err,grid_size,grid_size);
    subplot(grid_size,1,cr_ind)
    plot(fraction_vec,cur_err)
    xlabel('Fraction')
    ylabel('Error')
    title(sprintf('Core size: %d Percent',round(core_reduc_vec(cr_ind)*100)))
    if cr_ind ==1
        legend(sprintf('Stages: %d',stages_vec(1)),sprintf('Stages: %d',stages_vec(2)),...
            sprintf('Stages: %d',stages_vec(3)),sprintf('Stages: %d',stages_vec(4)),sprintf('Stages: %d',stages_vec(5)))
    end
end


figure(4)
for st_ind = 1:grid_size
    % res_store = zeros(length(core_reduc_vec),length(fraction_vec),length(stages_vec));
    cur_err = frob_store(1:end,:,st_ind);
    cur_err = reshape(cur_err,grid_size,grid_size);
    subplot(length(stages_vec),1,st_ind)
    plot(core_reduc_vec(1:end),cur_err) % check this is doing what I want
    xlabel('Core Reduction')
    ylabel('Error')
    title(sprintf('Stages: %d',round(stages_vec(st_ind))))
    if cr_ind ==1
        legend(sprintf('Stages: %d',stages_vec(1)),sprintf('Stages: %d',stages_vec(2)),...
            sprintf('Stages: %d',stages_vec(3)),sprintf('Stages: %d',stages_vec(4)),sprintf('Stages: %d',stages_vec(5)))
    end
end
