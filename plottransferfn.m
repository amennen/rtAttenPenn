gain = 3;
x_shift = .2;
y_shift = .15;
steepness = .9;

vals = -1:.1:1;
y = [];
for i = 1:length(vals)
y(end+1) = steepness./(1+exp(-gain*(vals(i)-x_shift)))+y_shift;

end
figure;
plot(vals,y)

% min is 17.39; max is .975
min(y)
max(y)