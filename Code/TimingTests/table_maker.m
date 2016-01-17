function[assemb] = table_maker()
addpath('../GP_functions/')
% Set up to imitate the test run by ONeil

n = [1e4 2e4 5e4 1e5 2e5 5e5 1e6];
n = [1e3 2e3 3e3 4e3 5e3 6e3];
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
end
