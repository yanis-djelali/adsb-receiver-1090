function nl = cprNL(lat)
% CPRNL  Nombre de zones de longitude NL(lat) du codage CPR (annexe C, NZ = 15).
NZ = 15;
lat = abs(lat);
if lat == 0
    nl = 59;
elseif lat == 87
    nl = 2;
elseif lat > 87
    nl = 1;
else
    nl = floor(2*pi / acos(1 - (1 - cos(pi/(2*NZ))) / cos(pi*lat/180)^2));
end
end
