function[] = rep_analysis(snapset)

switch snapset
    case 1 % GR
        load Data/GR_rep.mat
        data = csvread('Data/ca-GrQc.csv');
        t = 'General Relativity Citations';
    case 2 % Gnu
        load Data/Gnu_rep_fro.mat
        data = csvread('Data/p2p-Gnutella06.csv');
        t = 'Gnutella06 Peer-to-Peer Network';
end

addpath_ssl(0) % change


p = SSL_params(1,1);
c.num_edges = size(data,1);

data = data(randperm(c.num_edges),:);

c.node_ids = sort(unique([data(:,1); data(:,2)]));
c.num_nodes = length(c.node_ids);

figure(1)
plot(c.num_nodes*(1-core_vec),err,'o-','LineWidth',3)
hold on
plot(c.num_nodes*(1-core_vec),nystrom,'o-','LineWidth',3)
hold off
legend('MMF','Uniform Nystrom')
title(sprintf('%s-Error',t))
xlabel('Dimension of compressed matrix')
ylabel('Relative Frobenius Norm Error')

figure(2)
plot(c.num_nodes*(1-core_vec),time,'o-','LineWidth',3)
title(sprintf('%s-Time',t))
xlabel('Dimension of compressed matrix')
ylabel('Time to compute MMF (s)')
legend('MMF')