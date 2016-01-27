% First code to be used to visualize the trends for the base "general" file
% with no grid to it.

load tstore_general_1.mat;

figure(1)
for i = 1:length(vars)
      subplot(length(vars),1,i);
      plot(n,table(:,i));
      t = strcat(vars(i),' (dp = ', num2str(length(n)),')');
      title(t);
end

% consider the trends in fraction by table-features.

load gstore_fraction_1.mat;

figure(2)
subplot(5,1,1)
title('Assemb')
for f_i = 1:length(table_store)
    hold on
    plot(n, table_store{f_i}.assemb)
    hold off
end
l = cellstr(num2str(grid', 'grid=-%d'))
legend(l);

subplot(5,1,2)
title('Factor')
for f_i = 1:length(table_store)
    hold on
    plot(n, table_store{f_i}.factor)
    hold off
end
l = cellstr(num2str(grid', 'grid=-%d'))
legend(l);

subplot(5,1,3)
title('Solve')
for f_i = 1:length(table_store)
    hold on
    plot(n, table_store{f_i}.solve)
    hold off
end
l = cellstr(num2str(grid', 'grid=-%d'))
legend(l);

subplot(5,1,4)
title('Det')
for f_i = 1:length(table_store)
    hold on
    plot(n, table_store{f_i}.det)
    hold off
end
l = cellstr(num2str(grid', 'grid=-%d'))
legend(l);

subplot(5,1,5)
title('Error')
for f_i = 1:length(table_store)
    hold on
    plot(n, table_store{f_i}.error)
    hold off
end
l = cellstr(num2str(grid', 'grid=-%d'))
legend(l);
