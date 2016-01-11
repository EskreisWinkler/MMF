num_datapoints = 500;
x = linspace(-3,3,num_datapoints);

m = cos(2*x)+x;
% True function
a=zeros(3,1);
a(1) = plot(x,m);
% Add noise
factor = 1;
y = m + randn(size(m))*factor;
hold on
a(2) = plot(x,y,'o');
hold off
legend('True function','Data')



num_steps = 1000;
% this example considers an RBF kernel;
t_o = [1 0.25 1];
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
