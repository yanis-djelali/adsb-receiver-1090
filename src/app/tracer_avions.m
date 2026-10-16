function tracer_avions(avions, refLon, refLat)
% TRACER_AVIONS  Affiche les positions de chaque avion (points) avec son nom et son adresse.
%   Utilise affiche_carte (fond de carte fourni par l'ecole) s'il est sur le chemin MATLAB.
if exist('affiche_carte', 'file')
    affiche_carte(refLon, refLat);
else
    figure;
    plot(refLon, refLat, 'r^', 'MarkerSize', 10, 'MarkerFaceColor', 'y');
    text(refLon, refLat, '  Recepteur');
end
hold on;
grid on;
adresses = keys(avions);
couleurs = lines(max(1, numel(adresses)));
for k = 1:numel(adresses)
    avion = avions(adresses{k});
    if isempty(avion.positions)
        continue
    end
    plot(avion.positions(:,2), avion.positions(:,1), '.', 'Color', couleurs(k,:), 'MarkerSize', 10);
    etiquette = adresses{k};
    if ~isempty(avion.nom)
        etiquette = sprintf('%s\n%s', avion.nom, adresses{k});
    end
    text(avion.positions(end,2), avion.positions(end,1), etiquette, ...
         'Color', couleurs(k,:), 'FontWeight', 'bold');
end
xlabel('Longitude (degres)');
ylabel('Latitude (degres)');
title(sprintf('Trajectoires ADS-B : %d avion(s)', numel(adresses)));
end
