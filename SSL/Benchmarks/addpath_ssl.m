function[] = addpath_ssl(server)
if server == 0 %home
    risi = '/Users/jeskreiswinkler/Drive/15fall/Kondor/';
    mmf = '/Users/jeskreiswinkler/mmfc/release1.0/pMMF/matlab/';
elseif server == 1; % aitken
    risi = '/net/wallace/ga/eskreiswinkler/MMF/';
    mmf = '/net/wallace/ga/eskreiswinkler/mmfc/v4/src/matlab/';
elseif server==2 %rcc
    risi = '/home/eskreiswinkler/MMF/';
    mmf = '/home/eskreiswinkler/mmfc/release1.0/pMMF/matlab/';
    mmf = '/home/eskreiswinkler/mmfc/v4/src/matlab/';
end

addpath(sprintf('%sSSL/Buffalo/',risi),sprintf('%s/SSL/Benchmarks/',risi));
addpath(sprintf('%sGP/GP_param_search/',risi),sprintf('%s/GP/GP_functions/',risi));
addpath(sprintf('%sSSL/SSL_scripts/',risi))
addpath(sprintf('%s/',mmf));
