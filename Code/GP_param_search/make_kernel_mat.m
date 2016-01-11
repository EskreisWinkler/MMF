function[kernel_mat] = make_kernel_mat(kernel_type,X,theta)
%%%% KERNEL_TYPE = 1: the length-scale parameter is const across parameters
%%%% KERNEL_TYPE = 2: the length-scale parameter may vary across parameters

sigma_n = theta(1);
sigma_f = theta(2);
h       = theta(3:end);
n = size(X,2);
p = size(X,1);
kernel_mat = zeros(n);
if kernel_type ==1
    for i =1:n
        for j=1:n
            expo = 0;
            for k = 1:p
                expo = expo + ((X(k,i)-X(k,j))^2)/h(k);
            end
            kernel_mat(i,j) = sigma_f^2*exp(-0.5*expo)+sigma_n^2*(i==j);
        end
    end
elseif kernel_type ==2
    for i =1:n
        for j=1:n
            expo = 0;
            for k = 1:p
                expo = expo + ((X(k,i)-X(k,j))^2);
            end
            kernel_mat(i,j) = sigma_f^2*exp(-0.5*expo/h)+sigma_n^2*(i==j);
        end
    end
end
    
    
            