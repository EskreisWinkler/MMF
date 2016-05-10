rng('shuffle')
on_galton = 1;
if on_galton == 0
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Buffalo')
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Benchmarks')
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_param_search/',...
        '/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_functions/')
    addpath('/Users/jeskreiswinkler/mmfc/v4/src/matlab')
elseif on_galton == 1;
    
    addpath('/net/wallace/ga/eskreiswinkler/MMF/SSL/Buffalo')
    addpath('/net/wallace/ga/eskreiswinkler/MMF/SSL/Benchmarks')
    addpath('/net/wallace/ga/eskreiswinkler/MMF/GP/GP_param_search/',...
        '/net/wallace/ga/eskreiswinkler/MMF/GP/GP_functions/')
    addpath('/net/wallace/ga/eskreiswinkler/mmfc/v4/src/matlab')
end

dataset_name = 'secstr';
eval(sprintf('load Data/%s.mat',dataset_name))

nn = 100;
Knn = sparse(size(T,1),size(T,1),(nn*1.5)*size(T,1));
t = zeros(1,size(T,1));
for dp = 1:1000%size(T,1)
    tic();
    cur_dp = repmat(T(dp,:),size(T,1),1);
    d = sqrt(sum((cur_dp - T).^2,2));
    d_sort = sort(d);   
    threshold = d_sort(nn_rem);
    Knn(dp,d<=threshold) = 1;
    t(dp) = toc();
end

h = plot(1:dp,cumsum(t(1:dp)));
saveas(h,sprintf('%s_ktimer.jpg',dataset_name));

save(sprintf('%s_kmat.mat',dataset_name),'Knn');