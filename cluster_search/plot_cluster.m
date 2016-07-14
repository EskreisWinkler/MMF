function[] = plot_cluster(dataset_ind)

s = sprintf('load Data/review_data%d-%d.mat',floor(dataset_ind),mod(dataset_ind*10,10));
eval(s)


% we want to go through each of the data objects and have some graphical
% representation of them.

% I elect to only look at the compressions for the higher level of
% core_reduc_vec and then have every other tuple of the first two indices
% be a unique line. The x axis will be max_cluster.

%%%%%%%%%%%%
% frob_store
%%%%%%%%%%%%
figure(1)
% (clustering_method_vec,bypass_vec,core_reduc_vec,max_cluster_vec)

cur_cr=2;
for cur_cl = 1:length(clustering_method_vec)
    for cur_by = 1:length(bypass_vec)
        cur_f = reshape(frob_store(cur_cl,cur_by,cur_cr,:),[1 length(max_cluster_vec)]);
        if cur_cl==1 && cur_by==1
            plot(max_cluster_vec,cur_f,'o-')
            l = sprintf('\''Cl=%d, Bypass=%d\''',clustering_method_vec(cur_cl),bypass_vec(cur_by));
        else
            hold on
            plot(max_cluster_vec,cur_f,'o-')
            hold off
            l = sprintf('%s,\''Cl=%d, Bypass=%d\''',l, clustering_method_vec(cur_cl),bypass_vec(cur_by));
        end
    end
end
xlabel('Maximum Cluster Size')
eval(sprintf('legend(%s)',l))

%%%%%%%%%%%%%%%%
% frob_store_rel
%%%%%%%%%%%%%%%%
figure(1)
% (clustering_method_vec,bypass_vec,core_reduc_vec,max_cluster_vec)

cur_cr=2;
for cur_cl = 1:length(clustering_method_vec)
    for cur_by = 1:length(bypass_vec)
        cur_f = reshape(frob_store_rel(cur_cl,cur_by,cur_cr,:),[1 length(max_cluster_vec)]);
        if cur_cl==1 && cur_by==1
            plot(max_cluster_vec,cur_f,'o-')
            l = sprintf('\''Cl=%d, Bypass=%d\''',clustering_method_vec(cur_cl),bypass_vec(cur_by));
        else
            hold on
            plot(max_cluster_vec,cur_f,'o-')
            hold off
            l = sprintf('%s,\''Cl=%d, Bypass=%d\''',l, clustering_method_vec(cur_cl),bypass_vec(cur_by));
        end
    end
end
xlabel('Maximum Cluster Size')
ylabel('Normalized Frobenius Error')
eval(sprintf('legend(%s)',l))


%%%%%%%%%%%%
% time_store
%%%%%%%%%%%%

figure(3)
% (clustering_method_vec,bypass_vec,core_reduc_vec,max_cluster_vec)

cur_cr=2;
for cur_cl = 1:length(clustering_method_vec)
    for cur_by = 1:length(bypass_vec)
        cur_f = reshape(time_store(cur_cl,cur_by,cur_cr,:),[1 length(max_cluster_vec)]);
        if cur_cl==1 && cur_by==1
            plot(max_cluster_vec,cur_f,'o-')
            l = sprintf('\''Cl=%d, Bypass=%d\''',clustering_method_vec(cur_cl),bypass_vec(cur_by));
        else
            hold on
            plot(max_cluster_vec,cur_f,'o-')
            hold off
            l = sprintf('%s,\''Cl=%d, Bypass=%d\''',l, clustering_method_vec(cur_cl),bypass_vec(cur_by));
        end
    end
end
xlabel('Maximum Cluster Size')
ylabel('Time to compute MMF (s)')
eval(sprintf('legend(%s)',l))


%%%%%%%%%%%%%
%stages_store
%%%%%%%%%%%%%
% assess distribution of clusterings across stages

figure(4)
cur_cr = 2;
cur_mc = 1;

% first find the right limit for all of the clusterings
m = 0;
for cur_cl = 1:length(clustering_method_vec)
    for cur_by = 1:length(bypass_vec)
       m = max(m,max(stages_store{cur_cl,cur_by,cur_cr,cur_mc}));
    end
end


for cur_cl = 1:length(clustering_method_vec)
    for cur_by = 1:length(bypass_vec)
        subplot(length(clustering_method_vec),length(bypass_vec),(cur_cl-1)*length(clustering_method_vec)+cur_by)
        histogram(stages_store{cur_cl,cur_by,cur_cr,cur_mc},linspace(0, m,17))
        title(sprintf('Clustering Method: %d, Bypass: %d',clustering_method_vec(cur_cl),bypass_vec(cur_by)));
    end
end