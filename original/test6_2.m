clear; clc; close all;
%ecole
REF_LAT = 44.806884;
REF_LON = -0.606957;
load('adsb_msgs.mat');
[n_bits, n_trames] = size(adsb_msgs);
fprintf('Fichier : %d trames de %d bits\n\n', n_trames, n_bits);
%décodage
registres = [];
positions = [];
nom_avion = ''; % Variable pour stocker le nom de l'avion
for k = 1:n_trames
 bits = adsb_msgs(:,k);
 registre = bit2registre(bits);
if ~isempty(registre)
 registres = [registres, registre];
if ~isempty(registre.latitude) && ~isempty(registre.longitude)
 positions = [positions; registre.latitude, registre.longitude];
end
 fprintf('Trame %2d : FTC=%2d, AA=%s', k, registre.type, registre.adresse);
% Si c'est une trame d'identification (FTC 1-4) et qu'on a un nom
if registre.type >= 1 && registre.type <= 4 && ~isempty(registre.nom)
 nom_avion = registre.nom; % Stocker le nom
 fprintf(', Nom=%s', registre.nom);
end
if ~isempty(registre.altitude)
 fprintf(', Alt=%d ft', round(registre.altitude));
end
 fprintf('\n');
end
end
fprintf('\nTrames valides : %d/%d\n', length(registres), n_trames);
fprintf('Positions décodées : %d\n', size(positions,1));
fprintf('Nom de l''avion : %s\n\n', nom_avion);
% affichage carte trajectoire
 affiche_carte(REF_LON, REF_LAT);
% aidé par l'IA pour l'affichage
 plot(REF_LON, REF_LAT, 'r^', 'MarkerSize', 10, 'MarkerFaceColor', 'y');
 plot(positions(:,2), positions(:,1), 'b-', 'LineWidth', 2);
 plot(positions(:,2), positions(:,1), 'b.', 'MarkerSize', 10);
 plot(positions(1,2), positions(1,1), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
 plot(positions(end,2), positions(end,1), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
 title(sprintf('Trajectoire ADS-B - %s', nom_avion));