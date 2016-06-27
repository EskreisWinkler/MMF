%function[] = SSL_review3_interpret(dataset_ind,graph_type)
dataset_ind=1;
graph_type=6;
% First choose a dataset
rng('shuffle')
server = 0; % change
addpath_ssl(server);

[X,y,dataset_name] = load_SSL(dataset_ind);

p = SSL_params(y,dataset_ind);

[Lap] = lap_maker(X,p,graph_type);

s = sprintf('load Data/review3_%s_graph%d.mat',dataset_name,graph_type);
eval(s)

% look at frob norm changing for 10% highest eigenvalued eigenvectors

% use sketching procedure to compare frobenius norm differences between
% weighted and unweighted projection matrices

proportion = 0.1;

d = real(diag(D));
s = sort(d);
thresh = s(round((1-proportion)*length(d)));

U = V(:,d>thresh);

err_store_hi = zeros(size(mmf_store,1),1);
for i = 1:length(err_store_hi)
    s = sort(mmf_store{i}.D);
    thresh = s(round((1-proportion)*length(s)));
    U_mmf = mmf_store{i}.V(:,mmf_store{i}.D>thresh);
    err_store_hi(i) = norm(U*U'-U_mmf*U_mmf','fro');
end


% look at frob norm changing for 10% highest eigenvalued eigenvectors

proportion = 0.1;

d = real(diag(D));
s = sort(d);
thresh = s(round((proportion)*length(d)));

U = V(:,d<thresh);

err_store_lo = zeros(size(mmf_store,1),1);
for i = 1:length(err_store_lo)
    s = sort(mmf_store{i}.D);
    thresh = s(round((proportion)*length(s)));
    U_mmf = mmf_store{i}.V(:,mmf_store{i}.D<thresh);
    err_store_lo(i) = norm(U*U'-U_mmf*U_mmf','fro');
    keyboard
end

