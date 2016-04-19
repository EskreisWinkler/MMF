

% how does fraction change: start at 0 and we expect to see the same thing.
grid_size=3;
grid_min = 0;
grid_max = 0.9;
grid = linspace(grid_min,grid_max,grid_size);

for j = 1:grid_size
    params.fraction = grid(j);
    M_inv = MMF(M,params);
    M_inv.invert();
    L_pre = W(unobserved,observed);
    L = zeros(size(W(unobserved,observed)));
    for i = 1:size(L,2)
        L(:,i) = M_inv.hit(L_pre(:,i));
    end
    f_u_mmf = L*f_o;
    figure(2)
    subplot(2,grid_size,j)
    hist(f_u_mmf(response(unobserved)==1))
    subplot(2,grid_size,j+grid_size)
    hist(f_u_mmf(response(unobserved)==2))
    figure(3)
    subplot(2,grid_size,j)
    title('Standard')
    plot(f_u, response(unobserved),'o')
    subplot(2,grid_size,j+grid_size)
    title('MMF')
    plot(f_u_mmf, response(unobserved),'o')
end