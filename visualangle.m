% purpose: solve for image resolution based on visual angle

function [resy] = visualangle(screendims,screenres,distancefromscreen,anglewanted)
% h = tan(theta/2) * 2 * d
% first calculate ppd
ppd = ((screenres(2)/2) / atand((screendims(2)/2)/distancefromscreen));
%tan_val = tan((anglewanted/2)*(pi/180)); % convert to radians
%h = tan_val * 2 * distancefromscreen;
%res_conversion = [screenres(2)/screendims(2)];
%resy = h * res_conversion;
resy = ppd*anglewanted;
end