
ABA = csvread('abalone_nh.csv');

size(ABA)
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
% COL | VAR_DESCRIPTION
% 1 FEMALE      (BINARY)
% 2 INFANT      (BINARY)
% 3 MALE        (BINARY)
% 4 LENGTH      (CONT'S)
% 5 DIAMETER    (CONT'S)
% 6 HEIGHT      (CONT'S)
% 7 WHOLE WGHT  (CONT'S)
% 8 SHUCKED WGHT(CONT'S)
% 9 VISCERA WGHT(CONT'S)
% 10 SHELL WGHT  (CONT'S)
% 11 RINGS      (INTGR) +1.5 gives age in years.

%%% CHOOSE 85% FOR TRAINING
perc=0.85;
TRAIN_ROWS = randsample(size(ABA,1), round(perc*size(ABA,1)));
TEST_ROWS  = setdiff(1:size(ABA,1),TRAIN_ROWS);

TRAIN_DATA = ABA(TRAIN_ROWS,:);
TEST_DATA  = ABA(TEST_ROWS ,:);
global TRAIN_DATA;
global TEST_DATA;

