% We are interested in verifying a GPR can be optimized with standard methods, with MMF substituted in, ?

N=100;
d = 3;
x = linspace(-1*d,d,N);
y = (x-3).^2+5*cos((3.14)*x);
plot(x,y)

sigma_s = 0.5;
y_err = y + 4*randn(1,N);
hold on
plot(x,y_err,'o')
hold off

% try simple moving average
ARMA = zeros(N,1);
ARMA(1) = mean(y_err(1:3));
ARMA(N) = mean(y_err((N-2):N));
for i = 2:(N-1)
	ARMA(i) = mean(y_err((i-1):(i+1)));
end

plot(x,y)
hold on
plot(x,ARMA)
hold off

% compare to GPR regression
% which kernel? start with Gaussian
bw = 1;





