function[] = addpath_AISTATS(server)
if server == 0
    risi = '/Users/jeskreiswinkler/Drive/15fall/Kondor/';
    mmf = '/Users/jeskreiswinkler/mmfc/release1.0/pMMF/';
elseif server == 1;
    risi = '/net/wallace/ga/eskreiswinkler/MMF/';
    mmf = '/net/wallace/ga/eskreiswinkler/mmfc/release1.0/pMMF/';
elseif server==2
    risi = '/home/eskreiswinkler/MMF/';
    mmf = '/home/eskreiswinkler/mmfc/release1.0/pMMF/';
end

addpath(sprintf('%s/SSL/Buffalo/',risi),sprintf('%s/SSL/Benchmarks/',risi));
addpath(sprintf('%s/GP/GP_param_search/',risi),sprintf('%s/GP/GP_functions/',risi));
addpath(sprintf('%s/SSL/SSL_scripts/',risi))
addpath(sprintf('%s',mmf));