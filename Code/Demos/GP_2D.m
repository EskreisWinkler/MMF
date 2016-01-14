addpath('../GP_functions/')

num_dp = 25;
end_pt = 3;
x = linspace(-end_pt,end_pt,num_dp);

d = [repelem(x,num_dp); repmat(x,1,num_dp)]';
m = zeros(num_dp);
e = zeros(num_dp^2,1);

for col = 1:num_dp
    for row = 1:num_dp
        m(col,row) = cos(x(col))*x(col)*sin(x(row));
        e( (col-1)*num_dp+row) = m(col,row);
    end
end

factor = 0.5;
y = m+randn(size(m))*factor;

% Observe the effect of the noise and assess the data being modelled.
figure(1)
surf(x,x,m);
hold on
surf(x,x,y)
hold off

figure(2)
for cur_plot = 1:num_dp
    subplot(5,5,cur_plot)
    plot(x,m(cur_plot,:))
    hold on
    plot(x,y(cur_plot,:),'o')
    hold off
end



num_steps = 30;
% this example considers an RBF kernel;
t_o = [2 0.25 0.5 0.5];
miter=num_steps;
[theta_fmin, fval] = fminsearch(@(theta) LL_calc(theta',d',e'), t_o,optimset('Display','iter','MaxIter',miter));

g_num_dp = round(num_dp*0.9);
g = linspace(-end_pt,end_pt,g_num_dp);
g_d = [repelem(g,g_num_dp); repmat(g,1,g_num_dp)];
K = make_rbf(d',theta_fmin');
K_star = make_rbf(d,theta_fmin,g_d);
B = K\e;
e_pred = K_star'*B;

% make e_pred into a y size matrix
y_pred = zeros(g_num_dp);
for col = 1:g_num_dp
    for row = 1:g_num_dp
        y_pred(col,row) = e_pred((col-1)*g_num_dp+row);
    end
end

figure(1)
hold on
surf(g,g,y_pred)
hold off

figure(2)
% hard to compare in this direction since the grid is a little different.
for cur_plot = 1:g_num_dp
    subplot(5,5,cur_plot)
    hold on
    plot(g,y_pred(cur_plot,:))
    hold off
end
