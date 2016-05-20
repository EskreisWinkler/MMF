rng('shuffle')
on_galton = 0;
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

dataset_name = 'magic';
eval(sprintf('load Data/%s.mat',dataset_name))


nn = 100;
Knn = spalloc(size(X,1),size(X,1),(nn*1.5)*size(X,1));
t = zeros(1,size(X,1));
for dp = 1:size(X,1)
    tic();
    cur_dp = repmat(X(dp,:),size(X,1),1);
    d = sqrt(sum((cur_dp - X).^2,2));
    d_sort = sort(d);   
    threshold = d_sort(nn);
    Knn(dp,d<=threshold) = 1;
    Knn(d<=threshold,dp) = 1;
    t(dp) = toc();
    if mod(dp,500)==0
        fprintf('Doing well, %d percent there \n',round(100*dp/size(X,1)));
    end
end

h = plot(1:dp,cumsum(t(1:dp)));

save(sprintf('Data/%s_kmat.mat',dataset_name),'Knn','y');
