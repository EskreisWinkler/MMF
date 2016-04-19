function[theta,fval] = GP_param_fminsearch(theta_o)

addpath('~/Documents/MATLAB/ksrlin', '~/MMF_project/mmfc/v4/src/matlab/',...
    '~/Google_Drive/15fall/Kondor/Code/matlab',...
    '~/Google_Drive/15fall/Kondor/Code/GP_param_search')
miter = 30;
[theta, fval] = fminsearch(@marginal_likelihood_fminsearch, theta_o,optimset('Display','iter','MaxIter',miter));
