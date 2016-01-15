function[] = GP_1D()
params = GP_params;

addpath('../GP_functions/')
% Now link to the location of the MMF code for MMFC
addpath('~/MMF_project/mmfc/v4/src/matlab/')


x = linspace(-params.bdry,params.bdry,params.num_dp);
% Define a function here
%m = -20*(x<=0)+20*(x>=0);
m = 5*cos(2*x)+x.^2;

% The received data $y$ is the true function with noise.
y = m + randn(size(m))*params.data_noise;

% Plot true function and noisy received signal.
figure(1)
a(1) = plot(x,m,'LineWidth',4);
hold on
a(2) = plot(x,y,'o');
hold off
legend('True function','Data')
disp('Plot true function and data')

store.th = zeros(params.n_restarts,3);
store.th_mmf = zeros(params.n_restarts,3);
%store.t_o = zeros(params.n_restarts,3);

disp('Run search for best parameter set by minimizing a series of minimizing algorithms')
for i = 1:params.n_restarts
    t_cur = -1*ones(size(params.t_o_1D));
    while sum(t_cur<0)>0
    	t_cur = params.t_o_1D + randn(1,3).*params.t_o_1D*params.restart_noise;
        disp(t_cur)
    end
    %store.t_o(i,:) = t_cur;
    [th_mmf, fval_mmf] = fminsearch(@(theta) LL_calc(theta,x,y,1,params), t_cur,optimset('Display','iter','MaxIter',params.n_iters));
    [th, fval] = fminsearch(@(theta) LL_calc(theta,x,y,0,params), t_cur,optimset('Display','iter','MaxIter',params.n_iters));
    if sum(th_mmf<0)>0
        store.th_mmf(i,:) = nan(size(params.t_o_1D));
    else
    	store.th_mmf(i,:) = th_mmf;
    end
    if sum(th<0)>0
        store.th(i,:) = nan(size(params.t_o_1D));
    else
        store.th(i,:) = th;
    end
end

th_mmf = nanmean(store.th_mmf,1);
th = nanmean(store.th,1);

disp('Define a grid over which predictions are to be made with the GPR')
grid = linspace(-params.bdry,params.bdry,round(params.num_dp*params.rel_grid_size));
K = make_rbf(x,th);
K_mmf = make_rbf(x, th_mmf);
K_star = make_rbf(x,th,grid);
K_star_mmf = make_rbf(x,th_mmf,grid);
B = K\y';
B_mmf = K_mmf\y';
y_pred = K_star'*B;
y_pred_mmf = K_star_mmf'*B;

disp('Plot predictions to compare performance of MMF')
hold on
a(3) = plot(grid,y_pred,'LineWidth',4);
a(4) = plot(grid,y_pred_mmf,'LineWidth',4);
hold off

legend(a,'Truth','Noisy','GPR','GPR MMF')

print('GP_1Da','-djpeg','-noui')

figure(2)

plot(y_pred,y_pred_mmf,'o')
print('GP_1Db','-djpeg','-noui')
