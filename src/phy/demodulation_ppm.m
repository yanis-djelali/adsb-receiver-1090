function bits = demodulation_ppm(module, Fse)
% DEMODULATION_PPM  Decision PPM sur le module du signal, donc insensible a alpha et a phi0.
%   bit 1 si l'amplitude cumulee de la premiere moitie du symbole depasse celle de la seconde.
symboles = reshape(module(:), Fse, []);          % une colonne par bit
premiere_moitie = sum(symboles(1:Fse/2, :), 1);
seconde_moitie = sum(symboles(Fse/2+1:end, :), 1);
bits = double(premiere_moitie > seconde_moitie).';
end
