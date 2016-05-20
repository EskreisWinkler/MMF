% First choose a dataset
run_vec = 1:30;
rng('shuffle')
server = 0;
if server == 0
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Buffalo')
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/SSL/Benchmarks')
    addpath('/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_param_search/',...
        '/Users/jeskreiswinkler/Drive/15fall/Kondor/GP/GP_functions/')
    addpath('/Users/jeskreiswinkler/mmfc/v4/src/matlab')
elseif server == 1;
    addpath('/net/wallace/ga/eskreiswinkler/MMF/SSL/Buffalo')
    addpath('/net/wallace/ga/eskreiswinkler/MMF/SSL/Benchmarks')
    addpath('/net/wallace/ga/eskreiswinkler/MMF/GP/GP_param_search/',...
        '/net/wallace/ga/eskreiswinkler/MMF/GP/GP_functions/')
    addpath('/net/wallace/ga/eskreiswinkler/mmfc/v4/src/matlab')
elseif server==2
    addpath('/home/eskreiswinkler/MMF/SSL/Buffalo')
    addpath('/home/eskreiswinkler/MMF/SSL/Benchmarks')
    addpath('/home/eskreiswinkler/MMF/GP/GP_param_search/',...
        '/home/eskreiswinkler/MMF/GP/GP_functions/')
    addpath('/home/eskreiswinkler/mmfc/v4/src/matlab')
end
fprintf('Defining the conditions for experiment MAGIC \n')
dataset_name    = 'magic';
c = sprintf('load Data/%s_kmat.mat',dataset_name);
eval(c);

ids = unique(y);
num.pts = length(y);
num.classes = length(ids);
num.obs = 10;

grid.observed = round([max(2,0.001*num.pts) max(2,0.005*num.pts) max(2,0.01*num.pts) max(2,0.02*num.pts) max(2,0.05*num.pts)]);
num.draws = 3;

for run= run_vec
    fprintf('Defining the conditions for experiment run %d \n', run)
    % assign conditions
    conditions = cell(num.draws,1);
    for cur_draw = 1:num.draws
        conditions{cur_draw} = cell(length(grid.observed),1);
        for cur_obs = 1:length(grid.observed)
            num.observed = grid.observed(cur_obs);
            good_draw = false;
            while good_draw == false
                observed_inds = randsample(1:num.pts,num.observed);
                good_draw = length(unique(y(observed_inds)))==num.classes;
            end
            conditions{cur_draw}{cur_obs} = observed_inds;
        end
    end
    
    
    save(sprintf('Data/cond/Conditions_%s_draws%d_run%d.mat', dataset_name, num.draws, run),...
        'conditions')
end
