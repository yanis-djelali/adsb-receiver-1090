function sl = modulation_ppm(bits, Fse)
% MODULATION_PPM  Signal PPM echantillonne, Fse echantillons par bit.
%   bit 1 : impulsion sur la premiere moitie du symbole (p1)
%   bit 0 : impulsion sur la seconde moitie (p0)
bits = double(bits(:).');
p1 = [ones(1, Fse/2), zeros(1, Fse/2)];
p0 = [zeros(1, Fse/2), ones(1, Fse/2)];
sl = kron(bits, p1) + kron(1 - bits, p0);
end
