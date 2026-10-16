function resumer_avions(avions)
% RESUMER_AVIONS  Affiche, pour chaque avion, son nom, ses positions, leur etendue et l'altitude moyenne.
adresses = keys(avions);
fprintf('\n%d avion(s) detecte(s)\n', numel(adresses));
for k = 1:numel(adresses)
    a = avions(adresses{k});
    nom = a.nom;
    if isempty(nom)
        nom = '-';                    % un argument vide decalerait les champs de fprintf
    end
    fprintf('%s  %-8s  %3d positions', adresses{k}, nom, size(a.positions, 1));
    if ~isempty(a.positions)
        fprintf('  lat %.3f a %.3f  lon %.3f a %.3f  alt moy %.0f ft', ...
                min(a.positions(:,1)), max(a.positions(:,1)), ...
                min(a.positions(:,2)), max(a.positions(:,2)), mean(a.altitudes));
    end
    fprintf('\n');
end
end
