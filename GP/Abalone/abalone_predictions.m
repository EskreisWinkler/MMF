TEST_DATA = sortrows(TEST_DATA,size(TEST_DATA,2));

X= TRAIN_DATA(:,1:(end-1));
T= TRAIN_DATA(:,end);
X_grid = TEST_DATA(:,1:(end-1));
TRUTH = TEST_DATA(:,end);
figure(2)
plot(1:length(TRUTH), TRUTH,'o')

% FIRST TRY ADDITIVE MODEL
%%% EXTRACT THE COLUMNS IN THE TEST MATRIX THAT ARE ALWAYS IDENTICAL. FOR
%%% WITHIN DATA COMPARISONS THEY WILL SHED NO LIGHT.
Y_predict = zeros(size(TRUTH));
mdl = fitlm(X,T,'interactions');
for i = 1:length(Y_predict)
    Y_predict(i) = predict(mdl, X_grid(i,:));
end
hold on
plot(1:length(TRUTH),Y_predict);
hold off

% now use THETA which was found by the GP_param_fminsearch.

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
    i/length(Y_pred_classic)
    K_star = make_rbf(X',theta',X_grid(i,:)');
    %if is_MMF == 0
    Y_pred_classic(i) = K_star'*B;
    %end
    %if is_MMF == 1
    Y_pred_MMF(i) = K_star'*K_mmf_inv.hit(T);
    
    %end
end
Y_pred_classic(Y_pred_classic<0) =0;
Y_pred_MMFm = Y_pred_MMF;
Y_pred_MMF = Y_pred_MMF*0.5;
Y_pred_MMFm(Y_pred_MMFm<0)=0;
hold on
plot(1:length(TRUTH),Y_pred_MMFm,'LineWidth',4)
plot(1:length(TRUTH),Y_pred_classic,'LineWidth',4)
hold off
legend('True Data', 'Smoothed Data','GPR Predictions (MMF)','GPR Predictions(Inversion)')
title('Predictions for Monthly Wind Speeds in Mullingar')
ylabel('m/s')
xlabel('Month ID (Jan 1961 - Dec 1978)')