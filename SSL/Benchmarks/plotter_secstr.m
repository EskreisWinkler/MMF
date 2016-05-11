run_vec = 1:3;
n_obs = 10;
n_draws=3;
n_fracs=10;
perc_data = 5;
dataset_name = 'secstr';
for cur_run = run_vec
    s = sprintf('load Data/%s_percData%d_obs%d_draws%d_frac%d_%d.mat',dataset_name,perc_data, n_obs,n_draws,n_fracs,cur_run);
    eval(s);
    if cur_run == 1
        %KM_main = KM_store;
        KM_main_nn = KM_nn_store;
        %KM_main_mmf = KM_store_mmf;
        KM_main_nn_mmf = KM_nn_store_mmf;
    else
        %KM_main = [KM_main; KM_store];
        KM_main_nn = [KM_main_nn; KM_nn_store];
        for f_ind = 1:size(KM_main_nn_mmf,1)
            %KM_main_mmf{f_ind} = [KM_main_mmf{f_ind}; KM_store_mmf{f_ind}];
            KM_main_nn_mmf{f_ind} = [KM_main_nn_mmf{f_ind}; KM_nn_store_mmf{f_ind}];
        end
    end
end


% observed_grid = round(linspace(2,97, n_obs));
% plot(observed_grid,mean(KM_main,1),'LineWidth',3)
% 
% for f_ind = 1:size(KM_main_mmf,1)
%     hold on
%     %k = KM_main_mmf{f_ind};
%     %k(k<0.5) = 1-k(k<0.5);
%     %KM_main_mmf{f_ind} = k;
%     
%     plot(observed_grid,mean(KM_main_mmf{f_ind},1),'LineWidth',1)
%     %plot(observed_grid,KM_main_mmf{f_ind},'o')
%     hold off
% end
% 
% legend('Original','1%','12%','23%','34%','45%','55%','66%','77%','88%','99%')
% 

observed_grid = round(linspace(2,97, n_obs));
plot(observed_grid,mean(KM_main_nn,1),'LineWidth',3)

for f_ind = 1:size(KM_main_nn_mmf,1)
    hold on
    %k = KM_main_mmf{f_ind};
    %k(k<0.5) = 1-k(k<0.5);
    %KM_main_mmf{f_ind} = k;
    
    plot(observed_grid,mean(KM_main_nn_mmf{f_ind},1),'LineWidth',1)
    %plot(observed_grid,KM_main_mmf{f_ind},'o')
    hold off
end
title('Secstr dataset - MMF Compression results')
legend('Original','1%','12%','23%','34%','45%','55%','66%','77%','88%','99%')