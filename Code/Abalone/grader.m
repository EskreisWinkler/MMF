figure(2)
plot(1:length(TRUTH), TRUTH,'o')
hold on
plot(1:length(TRUTH),round(Y_predict));
hold off
hold on
plot(1:length(TRUTH),Y_pred_MMF,'o')%,'LineWidth',4)
plot(1:length(TRUTH),Y_pred_classic,'LineWidth',4)
hold off


%%% GRADING
% IF THE SUGGESTION IS WITHIN 2 OF THE TRUE AGE IT IS DEEMED CORRECT
% LMO MMF CLA

tolerance = 3;
LMO_good = 1*(abs(round(Y_predict)-TRUTH))<tolerance;
MMF_good =1*(abs(round(Y_pred_MMF)-TRUTH))<tolerance;
CLA_good =1*(abs(round(Y_pred_classic)-TRUTH))<tolerance;
grades = [LMO_good MMF_good CLA_good];
sum(grades,1)/length(TRUTH)
