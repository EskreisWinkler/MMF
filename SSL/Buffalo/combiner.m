% *M_store non-MMF is n_reps X n_obs
% *M_store_mmf is a cell array with a number of fracs and each one is
% n_reps x n_obs

n_obs = 10;
observed_grid = round(linspace(2,97, n_obs));

load Data/ZhuFigMaker_obs10_draws5_frac0001.mat

EM_store0001 = EM_store;
EM_store_mmf0001 = EM_store_mmf;
KM_store0001 = KM_store;
KM_store_mmf0001 = KM_store_mmf;

load Data/ZhuFigMaker_obs10_draws5_frac0203.mat

EM_store0203 = EM_store;
EM_store_mmf0203 = EM_store_mmf;
KM_store0203 = KM_store;
KM_store_mmf0203 = KM_store_mmf;

load Data/ZhuFigMaker_obs10_draws5_frac0405.mat

EM_store0405 = EM_store;
EM_store_mmf0405 = EM_store_mmf;
KM_store0405 = KM_store;
KM_store_mmf0405 = KM_store_mmf;


EM_store = [EM_store0001; EM_store0203; EM_store0405];
EM_store = [EM_store0203; EM_store0405];
KM_store = [KM_store0203; KM_store0405];

EM_store_mmf = cell(6,1);
KM_store_mmf = cell(6,1);
EM_store_mmf{1} = EM_store_mmf0001{1};
EM_store_mmf{2} = EM_store_mmf0001{2};
EM_store_mmf{3} = EM_store_mmf0203{1};
EM_store_mmf{4} = EM_store_mmf0203{2};
EM_store_mmf{5} = EM_store_mmf0405{1};
EM_store_mmf{6} = EM_store_mmf0405{2};

KM_store_mmf{1} = KM_store_mmf0001{1};
KM_store_mmf{2} = KM_store_mmf0001{2};
KM_store_mmf{3} = KM_store_mmf0203{1};
KM_store_mmf{4} = KM_store_mmf0203{2};
KM_store_mmf{5} = KM_store_mmf0405{1};
KM_store_mmf{6} = KM_store_mmf0405{2};

% % Now investigate a ton of plots...
figure(1)
plot(observed_grid,mean(KM_store,1),'LineWidth',5)
%plot(observed_grid,KM_store','o','LineWidth',5)
hold on
%plot(observed_grid,mean(KM_store_mmf{1},1))
%plot(observed_grid,mean(KM_store_mmf{2},1))
%plot(observed_grid,KM_store_mmf{3},'o')
plot(observed_grid,mean(KM_store_mmf{3},1))
%plot(observed_grid,KM_store_mmf{4},'o')
plot(observed_grid,mean(KM_store_mmf{4},1))
%plot(observed_grid,KM_store_mmf{5},'o')
plot(observed_grid,mean(KM_store_mmf{5},1))
%plot(observed_grid,KM_store_mmf{6},'o')
plot(observed_grid,mean(KM_store_mmf{6},1))
hold off
legend('0%','20%','30%','40%','50%')



figure(2)
% % Now investigate a ton of plots...
 plot(observed_grid,mean(KM_store,1),'LineWidth',5)
 hold on
 %plot(observed_grid,mean(KM_store_mmf{1},1))
 plot(observed_grid,mean(KM_store_mmf{2},1))
 plot(observed_grid,mean(KM_store_mmf{3},1))
 plot(observed_grid,mean(KM_store_mmf{4},1))
 plot(observed_grid,mean(KM_store_mmf{5},1))
 hold off
 legend('0%','12.5%','25%','37.5%','50%')