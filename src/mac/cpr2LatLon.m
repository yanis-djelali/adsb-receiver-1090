function [lon, lat] = cpr2LatLon(regLAT, regLON, CPRF, refLat, refLon)
% CPR2LATLON  Decodage CPR local (annexe C, equations 2 a 8).
%   regLAT, regLON : entiers codes sur 17 bits ; CPRF : 0 trame paire, 1 trame impaire.
%   refLat, refLon : position de reference, a moins de 180 milles nautiques de l'avion.
NZ = 15;
Nb = 17;
lat_frac = regLAT / 2^Nb;
lon_frac = regLON / 2^Nb;

Dlat = 360 / (4*NZ - CPRF);
j = floor(refLat/Dlat) + floor(0.5 + cprMod(refLat, Dlat)/Dlat - lat_frac);
lat = Dlat * (j + lat_frac);

if cprNL(lat) - CPRF > 0
    Dlon = 360 / (cprNL(lat) - CPRF);
else
    Dlon = 360;
end
m = floor(refLon/Dlon) + floor(0.5 + cprMod(refLon, Dlon)/Dlon - lon_frac);
lon = Dlon * (m + lon_frac);
end
