function[] = ex1()
c.n_clusters = 1;
c.n_per_cluster = 20;
c.intercluster_wt = 1;
c.intracluster_wt = 1;
c.total_loop = 0;
c.num_vecs = c.n_clusters;
c.num_vecs = 10;

E = zeros(c.n_clusters*c.n_per_cluster);
if c.total_loop==1
    E(1,end) = c.intercluster_wt;
end
for cur_conn = 1:(c.n_clusters-1)
    cur_conn_start = c.n_per_cluster*cur_conn;
    E(cur_conn_start,cur_conn_start+1) = c.intercluster_wt;
end

for cur_cluster = 1:c.n_clusters
    for cur_node = 1:(c.n_per_cluster-1)
        cur_start = (cur_cluster-1)*c.n_per_cluster+cur_node;
        E(cur_start,cur_start+1) = c.intracluster_wt;
    end
end

E = E+E';

L = diag(sum(E,1))-E;

cd ..
addpath_factor(1);
p = factor_params;
p.dcore = 1;
p.fraction = 0.5;
p.clustering_method = 0;
cd evd_approx/
keyboard
L_mmf = MMF(L,p);
L_mmfR = L_mmf.reconstruction;

[V,D] = eig(L);
a = [diag(D) (1:size(D,1))'];
a = sortrows(a);
D = diag(a(:,1));
V = V(:,a(:,2));

[VR,DR] = eig(L_mmfR);
%a = [diag(DR) (1:size(DR,1))'];
%a = sortrows(a);
%DR = diag(a(:,1));
%VR = VR(:,a(:,2));
keyboard
figure(1)
% top 5
for cur_plot = 1:c.num_vecs
    subplot(1,c.num_vecs,cur_plot)
    plot(1:size(L,1),V(:,cur_plot),'.-')
    hold on
    plot(1:size(L,1),VR(:,cur_plot),'.-')
    hold off
    legend('Orig','MMF');
    title(sprintf('O: %2.4f, MMF: %2.4f',D(cur_plot,cur_plot),DR(cur_plot,cur_plot)))
end

figure(2)
% bottom 5
for cur_plot = 1:c.num_vecs
    subplot(1,c.num_vecs,cur_plot)
    plot(1:size(L,1),V(:,size(L,1)+1-cur_plot),'.-')
    hold on
    plot(1:size(L,1),VR(:,size(L,1)+1-cur_plot),'.-')
    hold off
    legend('Orig','MMF');
    title(sprintf('O: %2.4f, MMF: %2.4f',D(size(L,1)+1-cur_plot,size(L,1)+1-cur_plot),DR(size(L,1)+1-cur_plot,size(L,1)+1-cur_plot)))
end

figure(3)



L_mmfH = L_mmf.Hmatrix;

l1 = L_mmfH(1:L_mmf.diagnostic.core_size,1:L_mmf.diagnostic.core_size); 
[l1V, l1D] = eig(l1);
d1 = diag(l1D);
l2 = diag(L_mmfH);
d2 = l2((L_mmf.diagnostic.core_size+1):end);
d_mmf = [d1;d2];
d = diag(D);
plot(d_mmf,'.-')
hold on
plot(d,'.-')
hold off


