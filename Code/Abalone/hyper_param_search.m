% IT SEEMS LIKE ALL PARAMETERS ARE WITHIN 0.1 and 2 and we can scale the
% first coordinate to be a tiny bit bigger.

% TRY OUT 20+1 STARTING POSITIONS
num_restarts = 20;

lims = [0.5 3; 0.05 1; 0.5 2];

num_l = length(theta)-2;

theta_o_store = zeros(num_restarts, length(theta_o));
theta_o_store(:,1) = rand(num_restarts,1)*(lims(1,2)-lims(1,1))+lims(1,1);
theta_o_store(:,2) = rand(num_restarts,1)*(lims(2,2)-lims(2,1))+lims(2,1);
theta_o_store(:,3:end) = rand(num_restarts,num_l)*(lims(3,2)-lims(3,1))+lims(3,1);

theta_store = zeros(size(theta_o_store));
fval_store = zeros(num_restarts,1);
for i = 1:num_restarts
    [theta, fval] = GP_param_fminsearch(theta_o_store(i,:));
    theta_store(i,:) = theta;
    fval_store(i) = fval;
end