function avions = mettre_a_jour_avions(avions, registres)
% METTRE_A_JOUR_AVIONS  Regroupe les registres par adresse OACI.
%   avions : containers.Map, adresse -> struct(nom, positions [lat lon], altitudes).
%   Le nom et les positions arrivent dans des trames differentes : l'adresse les relie.
for k = 1:numel(registres)
    r = registres(k);
    if ~isKey(avions, r.adresse)
        avions(r.adresse) = struct('nom', '', 'positions', zeros(0, 2), 'altitudes', zeros(0, 1));
    end
    avion = avions(r.adresse);
    if ~isempty(r.nom)
        avion.nom = r.nom;
    end
    if ~isempty(r.latitude)
        avion.positions(end+1, :) = [r.latitude, r.longitude];
        avion.altitudes(end+1, 1) = r.altitude;
    end
    avions(r.adresse) = avion;
end
end
