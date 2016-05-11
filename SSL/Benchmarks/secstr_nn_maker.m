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

s = randsample(size(T,1),round(perc_data*size(T,1)/100));
T = T(s,:);

nn = 100;
Knn = spalloc(size(T,1),size(T,1),(nn*1.5)*size(T,1));
t = zeros(1,size(T,1));
for dp = 1:size(T,1)
    tic();
    cur_dp = repmat(T(dp,:),size(T,1),1);
    d = sqrt(sum((cur_dp - T).^2,2));
    d_sort = sort(d);   
    threshold = d_sort(nn);
    Knn(dp,d<=threshold) = 1;
    t(dp) = toc();
end

h = plot(1:dp,cumsum(t(1:dp)));
saveas(h,sprintf('Data/%s_kmat_timer.jpg',dataset_name));

y2 = y;
y = y2(s);
clear y2;
save(sprintf('Data/%s_kmat_p%d.mat',dataset_name,perc_data),'Knn','y');
