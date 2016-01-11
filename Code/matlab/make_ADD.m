function[Y_pred] = make_ADD(X,T,num_steps)
num_params = size(X,2);
b = mean(T);
if isempty(num_steps)
    num_steps = 100;
end
m = zeros(length(T),num_params);
for cur_step = 1:num_steps
    %keyboard
    for cur_param = 1:num_params
        cur_resid = T - sum(m(:,setdiff(1:num_params,cur_param)),2) - b;
        if intersect(cur_param,1:3)
            cur_fit.f = mean(cur_resid(X(:,cur_param)==1))*(X(:,cur_param)==1) + ...
                mean(cur_resid(X(:,cur_param)==0))*(X(:,cur_param)==0);
        else
            cur_fit = ksrlin(X(:,cur_param),cur_resid,length(T));
            cur_fit.f(abs(cur_fit.f)>10e10)=0;
        end
        if cur_param==6
            %keyboard
        end
        m(:,cur_param) = cur_fit.f-mean(cur_fit.f);
    end
end
Y_pred = sum(m,2)+b;
