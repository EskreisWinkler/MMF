addpath('../GP_functions/')
%addpath('~/MMF_project/mmfc/v4/src/matlab/')
addpath('~/galton_home/mmfc/v4/src/matlab/')
% Set up to imitate the test run by ONeil

n = [1e4 2e4 5e4 1e5 2e5 5e5 1e6]';
d=100;
n = n/d;

assemb = zeros(size(n));
factor = assemb;
solve = factor;
det = solve;
error = det;

params = GP_params();
for ind = 1:length(n)
	disp(ind)
	cur_n = n(ind);
	x = linspace(-params.bdry,params.bdry,cur_n);
	tic()
	K = make_rbf(x,params.t_o_1D); 	
	assemb(ind) = toc();
	tic()
	K_mmf = MMF(K, params);
	factor(ind) = toc();
	tic()
	d = K_mmf.determinant();
	det(ind) = toc();
	K_mmf_inv = K_mmf;
	tic()
	K_mmf_inv.invert()
	solve(ind) = toc();
	error(ind) = K_mmf.froberror();
end

vars = {'Assembly Time','Factoring Time','Inversion Time','Determinant Computation Time','Matrix Error'};
table = [assemb factor solve det error];

file_name = sprintf('tstore_general_d%d',d);
save(file_name,'vars','table','n')

