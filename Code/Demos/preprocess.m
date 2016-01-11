num_datapoints = 500;
x = linspace(-3,3,num_datapoints);

m = cos(2*x)+x;
% True function
a=zeros(3,1);
a(1) = plot(x,m)
% Add noise
factor = 1;
y = m + randn(size(m))*factor;
hold on
a(2) = plot(x,y,'o')
hold off
global x;
global y;