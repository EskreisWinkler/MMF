addpath('../GP_functions/')
%addpath('~/MMF_project/mmfc/v4/src/matlab/')
addpath('~/galton_home/mmfc/v4/src/matlab/')
% Set up to imitate the test run by ONeil

n = [1e4 2e4 5e4 1e5 2e5 5e5 1e6]';
div = 100;
n = n/div;


% fraction -- 1
% minclustersize -- 2
% k -- 3
% ndensestages -- 4
var_num = 4;
switch var_num
    case 1
        grid_var = 'fraction';
        grid = [0.1 0.3 0.5 0.7 0.9];
    case 2
        grid_var = 'minclustersize';
        grid = [1 2 4 8 10];
    case 3
        grid_var = 'k';
        grid = 1:5;
    case 4
        grid_var = 'ndensestages';
        grid = 1:5;
    otherwise
        disp('errorerrorerrorerrorerror')
end

table.assemb = zeros(size(n));
table.factor = table.assemb;
table.solve = table.factor;
table.det = table.solve;
table.error = table.det;

params = GP_params();

table_store = cell(length(grid),1);
for grid_i = 1:length(grid)
    switch var_num
        case 1
            params.fraction = grid(grid_i);
        case 2
            params.minclustersize = grid(grid_i);
        case 3
            params.k = grid(grid_i);
        case 4
            params.ndensestages = grid(grid_i);
    end
            
    for ind = 1:length(n)
        disp(ind)
        cur_n = n(ind);
        x = linspace(-params.bdry,params.bdry,cur_n);
        tic()
        K = make_rbf(x,params.t_o_1D);
        table.assemb(ind) = toc();
        tic()
        K_mmf = MMF(K, params);
        table.factor(ind) = toc();
        tic()
        d = K_mmf.determinant();
        table.det(ind) = toc();
        K_mmf_inv = K_mmf;
        tic()
        K_mmf_inv.invert()
        table.solve(ind) = toc();
        table.error(ind) = K_mmf.froberror();
    end
    table_store{grid_i} = table;
end

vars = {'Assembly Time','Factoring Time','Inversion Time','Determinant Computation Time','Matrix Error'};

file_name = sprintf('gstore_%s_d%d',grid_var,div);
save(file_name,'vars','table_store','n','grid')

