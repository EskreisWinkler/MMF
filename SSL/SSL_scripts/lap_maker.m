function[Lap,Lap_w] = lap_maker(M,p,kmat)

switch kmat
    case 'nn'
        W_Lap = M - diag(diag(M));
        D_Lap = diag(sum(W_Lap,2));
        Lap = D_Lap - W_Lap;
    otherwise
        W = make_ker(M',p.pts,p.sigma);
        Wnn = zeros(size(W));
        
        for pt  = 1:p.pts
            m = W(pt,:);
            c = sort(m);
            c = c(length(c)-p.nn);
            Wnn(pt,m>c) = 1;
            Wnn(m>c,pt) = 1;
        end
        W_Lap = Wnn - diag(diag(Wnn));
        D_Lap = diag(sum(W_Lap,2));
        Lap = D_Lap - W_Lap;
        Lap_w = diag(sum(W,2)) - (W-diag(diag(W)));
end