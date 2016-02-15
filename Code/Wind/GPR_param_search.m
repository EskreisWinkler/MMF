% IT SEEMS LIKE ALL PARAMETERS ARE WITHIN 0.1 and 2 and we can scale the
% first coordinate to be a tiny bit bigger.
%%%addpath('/net/wallace/ga/eskreiswinkler/MMF/Code/Wind/')
%%%addpath('/net/wallace/ga/eskreiswinkler/MMF/Code/GP_param_search/')
addpath('../GP_param_search/','../GP_functions')
%addpath('~/MMF_project/mmfc/v4/src/matlab/')
addpath('~/galton_home/mmfc/v4/src/matlab/')

lims = [0.25 1; 0.05 1; 0.25 1];
perc = perc_assign;
exec = sprintf('load Data/full_wind_data_%d',perc*1000);
eval(exec)

theta = zeros(size(X,2)+1,1);

n.l = length(theta)-2;
n.iter = 10;
n.restarts = 20;

theta_o_store = zeros(n.restarts, length(theta));
theta_o_store(:,1) = rand(n.restarts,1)*(lims(1,2)-lims(1,1))+lims(1,1);
theta_o_store(:,2) = rand(n.restarts,1)*(lims(2,2)-lims(2,1))+lims(2,1);
theta_o_store(:,3:end) = rand(n.restarts,n.l)*(lims(3,2)-lims(3,1))+lims(3,1);

theta_store = zeros(size(theta_o_store));
fval_store = zeros(n.restarts,1);
for i = 1:n.restarts
    %[theta, fval] = fminsearch(@marginal_likelihood_fminsearch, theta_o_store(i,:));
    [theta, fval] = fminsearch(@marginal_likelihood_fminsearch, theta_o_store(i,:),optimset('Display','iter','MaxIter',n.iter));
    theta_store(i,:) = theta;
    fval_store(i) = fval;
end

c = clock;
num = mod(round(c(6)*1000000),10000);
file_name = sprintf('Data/params_p%d_%d',perc*1000,num);
save(file_name,'theta_store','fval_store','perc')
