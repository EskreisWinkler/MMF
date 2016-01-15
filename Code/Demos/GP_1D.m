function[] = GP_1D(params)
params.num_dp = 700;
params.bdry = 7;
params.noise_factor = 10;
params.n_iters = 3;
params.n_restarts = 20;
params.t_o = [5 0.5 0.5];
params.k = 2;
params.ndensestages = 1;
params.fraction = 0.6;
params.maxclustersize = 100;
params.bypass=3;
params.minclustersize = 1;

addpath('../GP_functions/')
% Now link to the location of the MMF code for MMFC
addpath('~/MMF_project/mmfc/v4/src/matlab/')


x = linspace(-params.bdry,params.bdry,params.num_dp);
% Define a function here
%m = -20*(x<=0)+20*(x>=0);
m = 5*cos(2*x)+x.^2;

% The received data $y$ is the true function with noise.
y = m + randn(size(m))*params.noise_factor;

% Plot true function and noisy received signal.
a(1) = plot(x,m,'LineWidth',4);
hold on
a(2) = plot(x,y,'o');
hold off
legend('True function','Data')


store.th = zeros(params.n_restarts,3);
store.th_mmf = zeros(params.n_restarts,3);
store.t_o = zeros(params.n_restarts,3);

for i = 1:params.n_restarts
    t_cur = -1*ones(size(params.t_o));
    while sum(t_cur<0)>0
    	t_cur = params.t_o + randn(1,3).*params.t_o*1.5;
    end
    store.t_o(i,:) = t_cur;
    [th_mmf, fval_mmf] = fminsearch(@(theta) LL_calc(theta,x,y,1,params), t_cur,optimset('Display','iter','MaxIter',params.n_iters));
    [th, fval] = fminsearch(@(theta) LL_calc(theta,x,y,0,params), t_cur,optimset('Display','iter','MaxIter',params.n_iters));
    if sum(th_mmf<0)>0
        store.th_mmf(i,:) = nan(size(params.t_o));
    else
    	store.th_mmf(i,:) = th_mmf;
    end
    if sum(th<0)>0
        store.th(i,:) = nan(size(params.t_o));
    else
        store.th(i,:) = th;
    end
end

th_mmf = nanmean(store.th_mmf,1);
th = nanmean(store.th,1);

grid = linspace(-params.bdry,params.bdry,round(params.num_dp*0.75));
K = make_rbf(x,th);
K_mmf = make_rbf(x, th_mmf);
K_star = make_rbf(x,th,grid);
K_star_mmf = make_rbf(x,th_mmf,grid);
B = K\y';
B_mmf = K_mmf\y';
y_pred = K_star'*B;
y_pred_mmf = K_star_mmf'*B;

hold on
a(3) = plot(grid,y_pred,'LineWidth',4);
a(4) = plot(grid,y_pred_mmf,'LineWidth',4);
hold off

legend(a,'Truth','Noisy','GPR','GPR MMF')

print('GP_1D','-djpeg','-noui')
