% IT SEEMS LIKE ALL PARAMETERS ARE WITHIN 0.1 and 2 and we can scale the
% first coordinate to be a tiny bit bigger.
%%%addpath('/net/wallace/ga/eskreiswinkler/MMF/Code/Wind/')
%%%addpath('/net/wallace/ga/eskreiswinkler/MMF/Code/GP_param_search/')
addpath('../GP_param_search/')
% TRY OUT 20+1 STARTING POSITIONS
num_restarts = 20;

lims = [0.25 1; 0.05 1; 0.25 1];

load full_wind_data.mat
theta = zeros(size(TRAIN_DATA,2)+1,1);

n.l = length(theta)-2;
n.iter = 500;

theta_o_store = zeros(num_restarts, length(theta));
theta_o_store(:,1) = rand(num_restarts,1)*(lims(1,2)-lims(1,1))+lims(1,1);
theta_o_store(:,2) = rand(num_restarts,1)*(lims(2,2)-lims(2,1))+lims(2,1);
theta_o_store(:,3:end) = rand(num_restarts,num_l)*(lims(3,2)-lims(3,1))+lims(3,1);

theta_store = zeros(size(theta_o_store));
fval_store = zeros(num_restarts,1);
for i = 1:num_restarts
    %[theta, fval] = fminsearch(@marginal_likelihood_fminsearch, theta_o_store(i,:));
    [theta, fval] = fminsearch(@marginal_likelihood_fminsearch, theta_o_store(i,:),optimset('Display','iter','MaxIter',n.iter));
    theta_store(i,:) = theta;
    fval_store(i) = fval;
end

num = round(rand(1)*1000);
file_name = sprintf('Data/wind_params_%d',num);
save(file_name,'theta_store','fval_store')