plot(X_grid(:,3),m, 'LineWidth',1)
xlabel('MonthID')
ylabel('Wind Speed')
hold on
plot(X_grid(:,3),TRUTH,'o')
hold off

hold on
%plot(X_grid(:,3),mean(ninf_store_mmf(1:2,:),1),'LineWidth',4)
plot(X_grid(:,3),ninf_store_mmf(2,:),'LineWidth',2)
plot(X_grid(:,3),ninf_store_cl(2,:),'LineWidth',2)
hold off
legend('Avg of Others', 'True Speed', 'Matlab Inv', 'MMF')

err_mean = sum((m-TRUTH).^2)
err_MMF = sum((ninf_store_mmf(2,:)-TRUTH').^2)
err_cl = sum((ninf_store_cl(2,:)-TRUTH').^2)
