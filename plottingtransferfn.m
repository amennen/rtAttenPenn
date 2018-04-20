
% gain = 3;
% x_shift = .2;
% y_shift = 0.15;
% steepness = .9;
% cs = -1:.1:1;
% y = steepness./(1+exp(-gain*(cs-x_shift)))+y_shift;

gain = 2.75;
x_shift = .2;
y_shift = 0.05;
steepness = .9;
cs = -1:.1:1;
y2 = steepness./(1+exp(-gain*(cs-x_shift)))+y_shift;

figure;
%plot(cs,y)
%hold on;
plot(cs,y2, 'r');
legend('original', 'proposed')
xlabel('Category separation');
ylabel('Attended category opacity proportion');
title('Transfer function')
ylim([0 1])
set(findall(gcf,'-property','FontSize'),'FontSize',20)