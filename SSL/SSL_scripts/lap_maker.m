function[Lap] = lap_maker(M,p,lap_type)

switch lap_type
    case 1 % this is an unweighted p.nn-graph
        
        W = make_ker(M',p.pts,p.sigma);
        Wnn = zeros(size(W));
        
        for pt  = 1:p.pts
            m = W(pt,:);
            c = sort(m);
            c = c(length(c)-p.nn);
            Wnn(pt,m>c) = 1;
            Wnn(m>c,pt) = 1;
        end
        Lnn_W = Wnn - diag(diag(Wnn));
        Lnn_D = diag(sum(Lnn_W,2));
        Lap = Lnn_D - Lnn_W;
    case 2 % this is a weighted p.nn-graph
        
        W = make_ker(M',p.pts,p.sigma);
        Wnn = zeros(size(W));
        
        for pt  = 1:p.pts
            m = W(pt,:);
            c = sort(m);
            c = c(length(c)-p.nn);
            Wnn(pt,m>c) = 1;
            Wnn(m>c,pt) = 1;
        end
        Lnn_W = Wnn - diag(diag(Wnn));
        Ww = (W-diag(diag(W)));
        
        WnnW = Ww.*Lnn_W;
        DnnW = diag(sum(WnnW,2));
        Lap = DnnW-WnnW;
    case 3 % this is a complete weighted graph
        
        W = make_ker(M',p.pts,p.sigma);
        Ww = (W-diag(diag(W)));
        Dw = diag(sum(W,2));
        Lap = Dw - Ww;
    case 0 % this is a scenario where you already have the laplacian made using weights
        W_Lap = M - diag(diag(M));
        D_Lap = diag(sum(W_Lap,2));
        Lap = D_Lap - W_Lap;
    otherwise
        fprintf('This jawn is messed up\n')
end


