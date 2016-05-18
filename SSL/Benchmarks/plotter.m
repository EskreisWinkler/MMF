run_vec = 1:5;
n_obs = 10;
n_draws=3;
n_fracs=3;
dataset_name = 'digit1';
nn = 1;
for i = 1:length(run_vec)
    cur_run = run_vec(i);
    s = sprintf('load Data/GPR_%s_obs%d_draws%d_frac%d_%d.mat',dataset_name,n_obs,n_draws,n_fracs,cur_run);
    eval(s);
    if i == 1
        KM_main = KM_store;
        time_main = time_store;
        KM_main_mmf = KM_store_mmf;
        time_main_mmf = time_store_mmf;
    else
        KM_main = [KM_main; KM_store];
        time_main = [time_main; time_store];
        for f_ind = 1:size(KM_main_mmf,1)
            KM_main_mmf{f_ind} = [KM_main_mmf{f_ind}; KM_store_mmf{f_ind}];
            time_main_mmf{f_ind}=[time_main_mmf{f_ind}; time_store_mmf{f_ind}];
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
    figure(1)
    observed_grid = round(linspace(2,97, n_obs));
    plot(observed_grid,mean(KM_main,1),'LineWidth',3)
    
    for f_ind = 1:size(KM_main_mmf,1)
        hold on
        
        plot(observed_grid,mean(KM_main_mmf{f_ind},1),'LineWidth',1)
        hold off
    end
    % grid.fracs = [0.6 0.8 0.99];
    legend('Original','60%','80%','99%')
end
title(sprintf('%s dataset - MMF Compression results',dataset_name))

if nn==1
    observed_grid = round(linspace(2,97, n_obs));
    figure(2)
    plot(observed_grid,mean(time_main,1),'LineWidth',3)
    
    for f_ind = 1:size(time_main_mmf,1)
        hold on
        
        plot(observed_grid,mean(time_main_mmf{f_ind},1),'LineWidth',1)
        hold off
    end
    title(sprintf('%s dataset - MMF Compression results',dataset_name))
    legend('Original','60%','80%','99%')
end

% Now I want to plot the accuracies as a function of time.
%figure(1)
%figure(2)
figure(3)
frac_grid = [0.6 0.8 0.99];
for f_ind = 1:length(frac_grid)
    time = time_main_mmf{f_ind};
    acc = KM_main_mmf{f_ind};
    
    figure(3)
    hold on
    k(f_ind) = plot(log(time(:,10)),acc(:,10),'o');
    hold off
end
figure(3)
hold on
k(f_ind+1) =  plot(log(time_main(:,10)),KM_main(:,10),'o');
hold off
xlabel('Computation Time (log(sec))')
ylabel('Classification accuracy')
title(sprintf('Timing resutls for %s dataset',dataset_name))
legend(k,'60%','80%','99%','Original')