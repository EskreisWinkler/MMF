dataset_ind_vec = [1.5:0.1:1.8 2.5:0.1:2.8 3.5:0.1:3.8 4.5:0.1:4.8 5 6 7 8];
%dataset_ind_vec = [1.5:0.1:1.8 2.5:0.1:2.8 3.5:0.1:3.8 4.5:0.1:4.8 5 6 8];
dataset_ind_vec = [2.5:0.1:2.8 1.5:0.1:1.8 3.5:0.1:3.8 4.5:0.1:4.8 5 6 7 8];

for cur_ds = 1:length(dataset_ind_vec)
    cluster_review(dataset_ind_vec(cur_ds));
end

for cur_ds = 1:length(dataset_ind_vec)
    plot_cluster(dataset_ind_vec(cur_ds));
end
