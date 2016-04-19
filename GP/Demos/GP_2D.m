%function[] = GP_2D(params)
params = GP_params();
params.num_dp = sqrt(params.num_dp);

addpath('../GP_functions/')
% Now link to the location of the MMF code for MMFC
addpath('~/MMF_project/mmfc/v4/src/matlab/')

x = linspace(-params.bdry,params.bdry,params.num_dp);

d = [repelem(x,params.num_dp); repmat(x,1,params.num_dp)]';
m = zeros(params.num_dp);
e = zeros(params.num_dp^2,1);

for col = 1:params.num_dp
    for row = 1:params.num_dp
        m(col,row) = cos(x(col))*x(col)*sin(x(row));
        e( (col-1)*params.num_dp+row) = m(col,row);
    end
end

y = m+randn(size(m))*params.data_noise;

% Observe the effect of the noise and assess the data being modelled.
figure(1)
surf(x,x,m);
hold on
surf(x,x,y)
hold off

print('GP_2Da','-djpeg','-noui')

figure(2)
a = zeros(4,1);
for cur_plot = 1:params.num_dp
    subplot(sqrt(params.num_dp),sqrt(params.num_dp),cur_plot)
    a(1) = plot(x,m(cur_plot,:));
    hold on
    a(2) = plot(x,y(cur_plot,:),'o');
    hold off
end

print('GP_2Db','-djpeg','-noui')


store.th = zeros(params.n_restarts,length(params.t_o_2D));
store.th_mmf = zeros(params.n_restarts,length(params.t_o_2D));
%store.t_o = zeros(params.n_restarts,length(params.t_o));


for i = 1:params.n_restarts
    t_cur = -1*ones(size(params.t_o_2D));
    while sum(t_cur<0)>0
    	t_cur = params.t_o_2D + randn(1,length(params.t_o_2D)).*params.t_o_2D*1;
    end
    %store.t_o(i,:) = t_cur;
    [th_mmf, fval_mmf] = fminsearch(@(theta) LL_calc(theta',d',e',1,params), t_cur,optimset('Display','iter','MaxIter',params.n_iters));
    [th, fval] = fminsearch(@(theta) LL_calc(theta',d',e',0,params), t_cur,optimset('Display','iter','MaxIter',params.n_iters));
    if sum(th_mmf<0)>0
        store.th_mmf(i,:) = nan(size(params.t_o_2D));
    else
    	store.th_mmf(i,:) = th_mmf;
    end
    if sum(th<0)>0
        store.th(i,:) = nan(size(params.t_o_2D));
    else
        store.th(i,:) = th;
    end
end
th_mmf = nanmean(store.th_mmf,1);
th = nanmean(store.th,1);

g_num_dp = round(params.num_dp*0.75);
g = linspace(-params.bdry,params.bdry,g_num_dp);
g_d = [repelem(g,g_num_dp); repmat(g,1,g_num_dp)];
K = make_rbf(d',th');
K_mmf = make_rbf(d',th_mmf');
K_star = make_rbf(d',th',g_d);
K_star_mmf = make_rbf(d',th_mmf',g_d);
B = K\e;
B_mmf = K_mmf\e;
e_pred = K_star'*B;
e_pred_mmf = K_star_mmf'*B;

% make e_pred into a y size matrix
y_pred = zeros(g_num_dp);
y_pred_mmf = y_pred;
for col = 1:g_num_dp
    for row = 1:g_num_dp
        y_pred(col,row) = e_pred((col-1)*g_num_dp+row);
        y_pred_mmf(col,row) = e_pred_mmf((col-1)*g_num_dp+row);
    end
end

figure(1)
hold on
surf(g,g,y_pred)
surf(g,g,y_pred_mmf);
hold off
print('GP_2Da','-djpeg','-noui')

figure(2)
% hard to compare in this direction since the grid is a little different.
for cur_plot = 1:g_num_dp
    subplot(sqrt(params.num_dp),sqrt(params.num_dp),cur_plot)
    hold on
    a(3) = plot(g,y_pred(cur_plot,:),'LineWidth',2);
    a(4) = plot(g,y_pred_mmf(cur_plot,:),'LineWidth',2);
    hold off
    if cur_plot == g_num_dp
        legend(a,'Truth','Data','GP','GP MMF')
    end
end
print('GP_2Db','-djpeg','-noui')

figure(3)
plot(e_pred,e_pred_mmf,'o')
print('GP_2Dc','-djpeg','-noui')
