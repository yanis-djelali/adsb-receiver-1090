function sp = preambule_adsb(Fse)
% PREAMBULE_ADSB  Preambule de 8 us : impulsions de 0,5 us debutant a 0, 1, 3,5 et 4,5 us.
%   Fse : nombre d'echantillons par microseconde (pair).
sp = zeros(1, 8*Fse);
for debut = [0 1 3.5 4.5]
    sp(round(debut*Fse) + (1:Fse/2)) = 1;
end
end
