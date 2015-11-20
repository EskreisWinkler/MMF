addpath('~/Documents/MATLAB/ksrlin', '~/MMF_project/mmfc/v4/src/matlab/',...
    '~/Google_Drive/15fall/Kondor/Code/matlab')
% 
% simulate data
n=100;
f=50;
x_max=40;
X = sort(x_max*rand(n,1))';
Y = X.^2+ 200*sin(X);
T = Y+ f*randn(1,n);
plot(X,Y,'r');
hold on
plot(X,T, 'o');
hold off
global X;
global T;

% first try LLR
Y_LLR = ksrlin(X,T,0.75,500);
figure(1)
plot(X,Y,'r','LineWidth',4)
hold on
plot(Y_LLR.x,Y_LLR.f, 'b','LineWidth',4)
hold off
% Now try to implement GP regression.
% form kernel matrix, default
%theta= [1,1,10]';
%theta=theta_use;
K = make_rbf(X,theta);
K2 = kernelmatrix('rbf',X',X',1) + eye(length(X))*10;
X_grid = linspace(0,x_max,100);
%X_grid = 1;
Y_pred_classic = zeros(size(X_grid));
Y_pred_MMF = Y_pred_classic;
% y^*|y \sim N(K_*K^{-1}y, K_{**}-K_*K^{-1}K_*^T)
% setup MMF
%params.k=2;
%params.ndensestages=1;
%params.fraction=0.8;
%mmf1 = MMF(K,params);
%mmf1.reconstruction();
is_MMF = 0;
%mmf_inv = mmf1;
%mmf_inv.invert();
B = (K\T');
tic()
for i = 1:length(Y_pred_MMF)
    
    K_star = make_rbf(X,theta,X_grid(i));
    if is_MMF == 0
        Y_pred_classic(i) = K_star'*B;
    end
    if is_MMF == 1
       Y_pred_MMF(i) = K_star*mmf_inv.hit(T);
    end
end
toc()
hold on
plot(X_grid,Y_pred_classic,'g','LineWidth',4)
%plot(X_grid,Y_pred_MMF,'y','LineWidth',4)
hold off
%legend('Data','Local Linear Regression','GPR','GPR-MMF')
