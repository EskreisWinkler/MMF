run_vec = 1:5;
n_obs = 10;
n_draws=3;
n_fracs=10;
dataset_name = 'usps';
nn = 1;
for cur_run = run_vec
    s = sprintf('load Data/%s_obs%d_draws%d_frac%d_%d.mat',dataset_name,n_obs,n_draws,n_fracs,cur_run);
    eval(s);
    if cur_run == 1
        KM_main = KM_store;
        KM_main_nn = KM_nn_store;
        KM_main_mmf = KM_store_mmf;
        KM_main_nn_mmf = KM_nn_store_mmf;
    else
        KM_main = [KM_main; KM_store];
        KM_main_nn = [KM_main_nn; KM_nn_store];
        for f_ind = 1:size(KM_main_mmf,1)
            KM_main_mmf{f_ind} = [KM_main_mmf{f_ind}; KM_store_mmf{f_ind}];
            KM_main_nn_mmf{f_ind} = [KM_main_nn_mmf{f_ind}; KM_nn_store_mmf{f_ind}];
        end
    end
end

if nn==0
    observed_grid = round(linspace(2,97, n_obs));
    
    plot(observed_grid,mean(KM_main,1),'LineWidth',3)
    
    for f_ind = 1:size(KM_main_mmf,1)
        hold on
        %k = KM_main_mmf{f_ind};
        %k(k<0.5) = 1-k(k<0.5);
        %KM_main_mmf{f_ind} = k;
        
        plot(observed_grid,mean(KM_main_mmf{f_ind},1),'LineWidth',1)
        %plot(observed_grid,KM_main_mmf{f_ind},'o')
        hold off
    end
    
    legend('Original','1%','12%','23%','34%','45%','55%','66%','77%','88%','99%')
end

if nn==1
    observed_grid = round(linspace(2,97, n_obs));
    plot(observed_grid,mean(KM_main_nn,1),'LineWidth',3)
    
    for f_ind = 1:size(KM_main_mmf,1)
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
end

if nn == 1
    for cur_run = run_vec
        s = sprintf('load Data/%s_obs%d_draws%d_frac%d_%d.mat',dataset_name,n_obs,n_draws,n_fracs,cur_run);
        eval(s);
        if cur_run == 1
            time_main = time_store;
            time_main_nn = time_nn_store;
            time_main_mmf = time_store_mmf;
            time_main_nn_mmf = time_nn_store_mmf;
        else
            time_main = [time_main; time_store];
            time_main_nn = [time_main_nn; time_nn_store];
            for f_ind = 1:size(time_store_mmf,1)
                time_main_mmf{f_ind} = [time_main_mmf{f_ind}; time_main_mmf{f_ind}];
                time_main_nn_mmf{f_ind} = [time_main_nn_mmf{f_ind}; time_nn_store_mmf{f_ind}];
            end
        end
    end
end


if nn==1
    observed_grid = round(linspace(2,97, n_obs));
    plot(observed_grid,mean(time_main_nn,1),'LineWidth',3)
    
    for f_ind = 1:size(time_main_mmf,1)
        hold on
        %k = KM_main_mmf{f_ind};
        %k(k<0.5) = 1-k(k<0.5);
        %KM_main_mmf{f_ind} = k;
        
        plot(observed_grid,mean(time_main_nn_mmf{f_ind},1),'LineWidth',1)
        %plot(observed_grid,KM_main_mmf{f_ind},'o')
        hold off
    end
    title('Secstr dataset - MMF Compression results')
    legend('Original','1%','12%','23%','34%','45%','55%','66%','77%','88%','99%')
end

% Now I want to plot the accuracies as a function of time.
%figure(1)
%figure(2)
figure(3)
frac_grid = round(linspace(1,99,n_fracs));
for f_ind = 1:length(frac_grid)
    time = time_main_nn_mmf{f_ind};
    acc = KM_main_nn_mmf{f_ind};
    for draw = 1:size(time,1)
        %figure(1)
        %hold on
        %plot(time(draw,:),acc(draw,:),'o')
        %hold off
    end
    %     figure(2)
    %     hold on
    %     plot(mean(time,1),mean(acc,1),'o')
    %     hold off
    figure(3)
    hold on
    k(f_ind) = plot(log(time(:,10)),acc(:,10),'o');
    hold off
end
figure(3)
hold on
k(f_ind+1) =  plot(log(time_main_nn(:,10)),KM_main_nn(:,10),'o');
hold off
xlabel('Computation Time (log(sec))')
ylabel('Classification accuracy')
title(sprintf('Timing resutls for %s dataset',dataset_name))
legend(k,'1%','12%','23%','34%','45%','55%','66%','77%','88%','99%','Original')
