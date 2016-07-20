function[] = plot_cluster(dataset_ind)

s = sprintf('load Data/review_data%d-%d.mat',round(floor(dataset_ind)),round(mod(dataset_ind*10,10)));
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
% (clustering_method,bypass_vec,core_reduc_vec,max_cluster_vec)

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

saveas(gcf,sprintf('figs/plot1_data%d-%d.png',round(floor(dataset_ind)),round(mod(dataset_ind*10,10))));

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

saveas(gcf,sprintf('figs/plot1_data%d-%d.png',round(floor(dataset_ind)),round(mod(dataset_ind*10,10))));


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


saveas(gcf,sprintf('figs/plot3_data%d-%d.png',round(floor(dataset_ind)),round(mod(dataset_ind*10,10))));

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
        subplot(length(clustering_method_vec),length(bypass_vec),(cur_cl-1)*length(bypass_vec)+cur_by)
        histogram(stages_store{cur_cl,cur_by,cur_cr,cur_mc},linspace(0, m,17))
        title(sprintf('Clustering Method: %d, Bypass: %d',clustering_method_vec(cur_cl),bypass_vec(cur_by)));
    end
end


saveas(gcf,sprintf('figs/plot4_data%d-%d.png',round(floor(dataset_ind)),round(mod(dataset_ind*10,10))));


%%%%%%%%%%%%%%
%stages_store2
%%%%%%%%%%%%%%
% assess distribution of clusterings across stages

figure(5)
cur_cr = 2;
cur_mc = 1;

% first find the right limit for all of the clusterings
m = 0;
stage_pick = 3;
for cur_cl = 1:length(clustering_method_vec)
    for cur_by = 1:length(bypass_vec)
       m = max(m,max(stages_store2{cur_cl,cur_by,cur_cr,cur_mc}{stage_pick}));
    end
end

for cur_cl = 1:length(clustering_method_vec)
    for cur_by = 1:length(bypass_vec)
        subplot(length(clustering_method_vec),length(bypass_vec),(cur_cl-1)*length(bypass_vec)+cur_by)
        histogram(stages_store2{cur_cl,cur_by,cur_cr,cur_mc}{stage_pick},linspace(0, m,17))
        title(sprintf('Clustering Method: %d, Bypass: %d',clustering_method_vec(cur_cl),bypass_vec(cur_by)));
    end
end


saveas(gcf,sprintf('figs/plot4_data%d-%d.png',round(floor(dataset_ind)),round(mod(dataset_ind*10,10))));


figure(6)

cur_mc = 1;
cur_cr = 2;

m_size = 10;
l_width = 3;
for cur_cl = 1:length(clustering_method_vec)
    for cur_by = 1:length(bypass_vec)
        cur_t = reshape(time_store(cur_cl,cur_by,cur_cr,:),[1 length(max_cluster_vec)]);
        %cur_t = reshape(time_store(cur_cl,cur_by,cur_cr,cur_mc),[1 1]);
        cur_f = reshape(frob_store_rel(cur_cl,cur_by,cur_cr,:),[1 length(max_cluster_vec)]);
        %cur_f = reshape(frob_store_rel(cur_cl,cur_by,cur_cr,cur_mc),[1 1]);
        if cur_cl==1 && cur_by==1
            plot(cur_t,cur_f,'*-','MarkerSize',m_size,'LineWidth',l_width)
            l = sprintf('\''Cl=%d, Bypass=%d\''',clustering_method_vec(cur_cl),bypass_vec(cur_by));
        else
            hold on
            plot(cur_t,cur_f,'*-','MarkerSize',m_size,'LineWidth',l_width)
            hold off
            l = sprintf('%s,\''Cl=%d, Bypass=%d\''',l, clustering_method_vec(cur_cl),bypass_vec(cur_by));
        end
    end
end
xlabel('Time (s)')
ylabel('Relative Error in Square Frob norm')
eval(sprintf('legend(%s)',l))


saveas(gcf,sprintf('figs/plot6_data%d-%d.png',round(floor(dataset_ind)),round(mod(dataset_ind*10,10))));

