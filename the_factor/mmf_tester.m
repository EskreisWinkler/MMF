%function[L] = mmf_tester(gens,kids)

addpath_factor(0);
gens=6;
kids=3;
p = factor_params;
p.clustering_method = 2;
p.dcore = 1;
[A, g] = tree_graph_maker(gens,kids);
noise_vec = g;


noise_vec = round(linspace(1,1000,5));
err_storeR = zeros(size(noise_vec));
err_storeF = err_storeR;
type = 1;
for cur_noise = 1:length(noise_vec)
    A = lap_augmenter(A,noise_vec(cur_noise),type);
    L = diag(sum(A,1))-A;
    cur_L_mmf = MMF(L,p);
    err_storeR(cur_noise) = cur_L_mmf.diagnostic.rel_error;
    err_storeF(cur_noise) = cur_L_mmf.froberror;
end
s = sprintf('err_storeR%d = err_storeR',type);
eval(s)
s = sprintf('err_storeF%d = err_storeF',type);
eval(s)
type = 2;
for cur_noise = 1:length(noise_vec)
    A = lap_augmenter(A,noise_vec(cur_noise),type);
    L = diag(sum(A,1))-A;
    cur_L_mmf = MMF(L,p);
    err_storeR(cur_noise) = cur_L_mmf.diagnostic.rel_error;
    err_storeF(cur_noise) = cur_L_mmf.froberror;
end
s = sprintf('err_storeR%d = err_storeR',type);
eval(s)
s = sprintf('err_storeF%d = err_storeF',type);
eval(s)


plotter= 1;
lw=4;
figure(1)
if plotter
    plot(noise_vec,(err_storeR1),'LineWidth',lw)
    hold on
    plot(noise_vec,(err_storeR2),'LineWidth',lw)
    hold off
end

figure(2)
if plotter
    plot(noise_vec,(err_storeF1),'LineWidth',lw)
    hold on
    plot(noise_vec,(err_storeF2),'LineWidth',lw)
    hold off
end
legend('Method 1','Method 2')
xlabel('Number of Added Nodes')
ylabel('(Frobenius Norm Error)')
title(sprintf('Tree Graph: %d generations, %d children',gens,kids))