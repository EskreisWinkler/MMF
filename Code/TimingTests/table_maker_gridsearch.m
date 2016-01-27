addpath('../GP_functions/')
%addpath('~/MMF_project/mmfc/v4/src/matlab/')
addpath('~/galton_home/mmfc/v4/src/matlab/')
% Set up to imitate the test run by ONeil

n = [1e4 2e4 5e4 1e5 2e5 5e5 1e6]';
n = n/250;

grid_var = 'fraction';

table.assemb = zeros(size(n));
table.factor = table.assemb;
table.solve = table.factor;
table.det = table.solve;
table.error = table.det;

params = GP_params();
grid = [0.1 0.3 0.5 0.7 0.9];
table_store = cell(length(grid),1);
for grid_i = 1:length(frac_vals)
    params.fraction = grid(grid_i);
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

d = 1;
file_name = sprintf('gstore_%s_%d',grid_var,d);
save(file_name,'vars','table_store','n','grid')

