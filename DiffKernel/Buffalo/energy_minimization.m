function[f_u_new] = energy_minimization(f_u,f_o,unobserved_inds,L,labs)

energy_store = zeros(size(unobserved_inds));
f = zeros(length(f_u)+length(f_o),1);
f(setdiff(1:length(f),unobserved_inds)) = f_o;
f_u_sort = sort(f_u);
for i = 1:length(energy_store)
    cur_thresh = f_u_sort(i);
    f_u_hat = (f_u<=cur_thresh)*labs(1) + (f_u>cur_thresh)*labs(2);
    f(unobserved_inds) = f_u_hat;
    energy_store(i) = -f'*L*f;
end

[m, i] = max(energy_store);
final_thresh = f_u(i);
f_u_new = (f_u<=final_thresh)*labs(1) + (f_u>final_thresh)*labs(2);


