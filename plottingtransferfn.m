
gain = 4;
x_shift = .12;
y_shift = .25;
steepness = .6;
cs = -1:.1:1;
y2 = steepness./(1+exp(-gain*(cs-x_shift)))+y_shift;

gain = 3;
x_shift = .2;
y_shift = .15;
steepness = .9;
cs = -1:.1:1;
y = steepness./(1+exp(-gain*(cs-x_shift)))+y_shift;

figure;
plot(cs,y)
hold on;
plot(cs,y2, 'r');
legend('original', 'proposed')
xlabel('Category separation');
ylabel('Opacity proportion');
title('Transfer functions')
ylim([0 1])
set(findall(gcf,'-property','FontSize'),'FontSize',20)