function[X,y,dataset_name] = load_SSL(dataset_ind)


switch dataset_ind
    case 1
        dataset_name = 'digit1';
        eval(sprintf('load Data/%s.mat',dataset_name))
        sigma = 20;
    case 2
        dataset_name = 'coil';
        eval(sprintf('load Data/%s.mat',dataset_name))
        sigma = 93;
        y2 = -1*(y<=2)+1*(y>=3);
        y = y2;
        clear y2;
    case 3
        dataset_name = 'usps';
        eval(sprintf('load Data/%s.mat',dataset_name))
        sigma = 733;
    case 4
        dataset_name = 'text';
        eval(sprintf('load Data/%s.mat',dataset_name))
        sigma = 6772;
    case 5
        dataset_name = 'secstr';
        eval(sprintf('load Data/%s.mat',dataset_name))
        sigma = 6;
        % if we want to only look at a subsample because of the austere
        % size;
        s = randsample(size(T,1),5000,0);
        X=double(T(s,:));
        y2 = -1*(y(s)<1)+y(s);
        y=y2;
        clear y2;
    otherwise
        fprintf('This jawn is messed up\n')
end