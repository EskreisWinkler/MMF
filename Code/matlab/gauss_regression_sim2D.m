addpath('~/Documents/MATLAB/ksrlin', '~/MMF_project/mmfc/v4/src/matlab/',...
    '~/Google_Drive/15fall/Kondor/Code/matlab')

% simulate data
n=10;
f=25;
grid_max=40;
X = linspace(0,grid_max,n);
Y = X;
Z = zeros(n);
for i = 1:n
    for j = 1:n
        Z(i,j) = sin(X(i))+Y(j)-X(i)*Y(j);
    end
end
surf(Z)
T = Z + f*randn(n);
surf(T)

surf(Z);
hold on
surf(T)
hold off

X_a = zeros(n^2,4);
for i = 1:n
    for j=1:n
        (i-1)*n+j;
        X_a((i-1)*n+j,:) = [X(i) Y(j) T(i,j) Z(i,j)];

    end
end
X_x = X_a(:,1:2)';
X_t = X_a(:,3)';
X_z = X_a(:,4)';

% first try LLR
Y_LLR = ksrlin(X_a(:,2),X_a(:,3)',0.75,500);
figure(1)
plot(X_a(:,2),X_a(:,3),'r','LineWidth',4)
hold on
plot(Y_LLR.x,Y_LLR.f, 'b','LineWidth',4)
hold off
% Now try to implement GP regression.
% form kernel matrix, default
%theta= [1,1,10]';
%theta=theta_use;
K = make_rbf(X_x,theta');
K2 = kernelmatrix('rbf',X',X',1) + eye(length(X))*10;
X_grid = X_x;
T = X_t;
%X_grid = 1;
T_pred_classic = zeros(size(T));
%Y_pred_MMF = Y_pred_classic;
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
for i = 1:length(T_pred_classic)
    
    K_star = make_rbf(X_x,theta',X_x(:,i));
    if is_MMF == 0
        T_pred_classic(i) = K_star'*B;
    end
    %if is_MMF == 1
    %   Y_pred_MMF(i) = K_star*mmf_inv.hit(T);
    %end
        
    
end
toc()
hold on
plot(X_grid,Y_pred_classic,'g','LineWidth',4)
%plot(X_grid,Y_pred_MMF,'y','LineWidth',4)
hold off
%legend('Data','Local Linear Regression','GPR','GPR-MMF')
