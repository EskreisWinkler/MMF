function[theta,fval] = GP_param_fminsearch(theta_o)




miter = 5;

[theta, fval] = fminsearch(@marginal_likelihood_fminsearch, theta_o,optimset('Display','iter','MaxIter',miter));