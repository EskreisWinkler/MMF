addpath('../GP_functions/')

num_datapoints = 200;
x = linspace(-3,3,num_datapoints);

m = cos(2*x)+x;
% True function
a=zeros(3,1);
a(1) = plot(x,m,'LineWidth',4);
% Add noise
factor = 1.2;
y = m + randn(size(m))*factor;
hold on
a(2) = plot(x,y,'o');
hold off
legend('True function','Data')



num_steps = 30;
% this example considers an RBF kernel;
t_o = [2 0.25 0.5];
miter=num_steps;
[theta_fmin, fval] = fminsearch(@(theta) LL_calc(theta,x,y), t_o,optimset('Display','iter','MaxIter',miter));

grid = linspace(-3,3,round(num_datapoints*0.9));
K = make_rbf(x,theta_fmin);
K_star = make_rbf(x,theta_fmin,grid);
B = K\y';
y_pred = K_star'*B;

hold on
a(3) = plot(grid,y_pred,'LineWidth',4)
hold off

legend(a,'Truth','Noisy','GPR')
