global TEST_DATA;
global TRAIN_DATA;
X= TRAIN_DATA(:,1:(end-1));
T= TRAIN_DATA(:,end);
X_grid = TEST_DATA(:,1:(end-1));
TRUTH = TEST_DATA(:,end);
figure(2)
hist(TRUTH,29)

% FIRST TRY ADDITIVE MODEL
%%% EXTRACT THE COLUMNS IN THE TEST MATRIX THAT ARE ALWAYS IDENTICAL. FOR
%%% WITHIN DATA COMPARISONS THEY WILL SHED NO LIGHT.
Y_ADD = make_ADD(X_grid,TRUTH,50);
hold on
plot(X_grid(:,3),Y_ADD);
hold off

% now use THETA which was found by the GP_param_fminsearch.
ninf_store_cl = zeros(7,length(TRUTH));
ninf_store_mmf=ninf_store_cl;
for k = 1:7
    theta = theta_store_ninf(k,:);
    K = make_rbf(X',theta');
    
    %is_MMF = 0;
    fprintf('Computing MMF factorization\n\n')
    tic()
    K_mmf = MMF(K,params);
    
    K_mmf_inv = K_mmf;
    K_mmf_inv.invert();
    toc()
    %K_inv = inv(K);
    %B = K_inv*T;
    B = (K\T);
    Y_pred_classic = zeros(size(TRUTH));
    Y_pred_MMF = Y_pred_classic;
    for i = 1:length(Y_pred_classic)
        K_star = make_rbf(X',theta',X_grid(i,:)');
        %if is_MMF == 0
            Y_pred_classic(i) = K_star'*B;
        %end
        %if is_MMF == 1
            Y_pred_MMF(i) = K_star'*K_mmf_inv.hit(T);
            
        %end
    end
    ninf_store_cl(k,:) = Y_pred_classic;
    ninf_store_mmf(k,:)= Y_pred_MMF;
end
hold on
plot(X_grid(:,3),ninf_store_mmf)
hold off
hold on 
plot(X_grid(:,3),mean(ninf_store_mmf(1:2,:),1),'LineWidth',4)
plot(X_grid(:,3),mean(ninf_store_cl(1:2,:),1),'LineWidth',4)
hold off
legend('True Data', 'Smoothed Data','GPR Predictions (MMF)','GPR Predictions(Inversion)')
title('Predictions for Monthly Wind Speeds in Mullingar')
ylabel('m/s')
xlabel('Month ID (Jan 1961 - Dec 1978)')