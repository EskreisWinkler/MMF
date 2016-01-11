addpath('~/Google_Drive/16wint/Kondor/Code/GD_example/')
preprocess;

num_steps = 1000;
% this example considers an RBF kernel;
num_params = size(y,1)+2;
omega = linspace(0.01, 0.0001,num_steps);
theta_store = zeros(num_steps,num_params);
t_o = [1 0.25 1];
theta_store(1,:) = t_o;
LL_store = zeros(num_steps-1,1);
n = length(x);
for cur_step = 1:(num_steps-1)
    cur_theta = theta_store(cur_step,:);
    K = make_rbf(x,cur_theta);
    LL_store(cur_step) = -0.5*y*(K\y')-0.5*log(det(K))-0.5*n*log(2*pi);
    new_theta = cur_theta+omega(cur_step)*GD_update(theta);
end
miter=num_steps;
[theta_fmin, fval] = fminsearch(@LL_calc, t_o,optimset('Display','iter','MaxIter',miter));
 
grid = linspace(-3,3,round(num_datapoints*0.9));
K = make_rbf(x,theta);
K_star = make_rbf(x,theta,grid);
B = K\y';
y_pred = K_star'*B;

hold on
a(3) = plot(grid,y_pred)
hold off

legend(a,'Truth','Noisy','GPR')