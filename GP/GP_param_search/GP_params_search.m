%function[theta_store,LL_store] = GP_params_search(X,T,theta_o)

addpath('~/Documents/MATLAB/ksrlin', '~/MMF_project/mmfc/v4/src/matlab/',...
    '~/Google_Drive/15fall/Kondor/Code/matlab',...
    '~/Google_Drive/15fall/Kondor/Code/GP_param_search')

% for each possible parameter set THETA we evaluate the log-likelihood
% given those parameters, then we update the parameters via gradient
% descent. then we re-evaluate the log-liklihood. Initialize the whole
% process by starting from theta_o
num_steps = 1000;
num_params= length(theta_o);
omega1 = linspace(0.01, 0.0001,num_steps); % LEARNING WEIGHT
omega2 = omega1;
%omega3 = linspace(0.0001, 0.00001, num_steps);
omega3 =omega2;
omega=  [omega1;omega2;omega3];
bw_cap = (max(X)-min(X));
LL_store = zeros(num_steps-1,1);
theta_store = zeros(num_steps,num_params);
theta_store(1,:) = theta_o';
for cur_step = 1:(num_steps-1)
    if mod(cur_step,100)==0
        cur_step
    end
    cur_theta = theta_store(cur_step,:)';
    K = make_rbf(X,cur_theta);
    LL_store(cur_step) = marginal_likelihood(X,T,K,0);
    new_theta = cur_theta + omega(:,cur_step).*grad_LL(X,T,K,cur_theta);
    %new_theta = abs(new_theta);
    %if new_theta(3)>bw_cap
    %    new_theta(3) = bw_cap;
    %end
    theta_store(cur_step+1,:) = new_theta';
end
LL_store(cur_step) = marginal_likelihood(X,T,K,0);
plot(1:num_steps-1,real(LL_store),'o')
theta = theta_store(max(LL_store)==LL_store,:)

