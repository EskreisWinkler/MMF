function[] = addpath_ssl(server)
if server == 0 %home
    risi = '/Users/jeskreiswinkler/Drive/15fall/Kondor/';
    mmf = '/Users/jeskreiswinkler/mmfc/v4/src/matlab';
elseif server == 1; % aitken
    risi = '/net/wallace/ga/eskreiswinkler/MMF/';
    mmf = '/net/wallace/ga/eskreiswinkler/mmfc/v4/src/matlab';
elseif server==2 %rcc
    risi = '/home/eskreiswinkler/MMF/';
    mmf = '/home/eskreiswinkler/mmfc/v4/src/matlab';
end

addpath(sprintf('%s/SSL/Buffalo/',risi),sprintf('%s/SSL/Benchmarks/',risi));
addpath(sprintf('%s/GP/GP_param_search/',risi),sprintf('%s/GP/GP_functions/',risi));
addpath(sprintf('%s/SSL/SSL_scripts/',risi))
addpath(sprintf('%s',mmf));