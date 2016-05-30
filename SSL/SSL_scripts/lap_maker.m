function[Lnn,Lw, LnnW] = lap_maker(M,p,kmat)

switch kmat
    case 'nn'
        W_Lap = M - diag(diag(M));
        D_Lap = diag(sum(W_Lap,2));
        Lnn = D_Lap - W_Lap;
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
        Lnn_W = Wnn - diag(diag(Wnn));
        Lnn_D = diag(sum(Lnn_W,2));
        Lnn = Lnn_D - Lnn_W;
        Ww = (W-diag(diag(W)));
        Dw = diag(sum(W,2));
        Lw = Dw - Ww;
        WnnW = Ww.*Lnn_W;
        DnnW = diag(sum(WnnW,2));
        LnnW = DnnW-WnnW;
        
end