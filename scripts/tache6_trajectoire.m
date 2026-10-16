% TACHE 6 (sous-tache 3) : decodage de adsb_msgs.mat et trajectoire de l'avion
clear; close all; clc;
REF_LAT = 44.806884;     % position de l'ecole, reference du decodage CPR
REF_LON = -0.606957;

donnees = load('adsb_msgs.mat');
adsb_msgs = donnees.adsb_msgs;   % 112 x N bits, une trame par colonne
avions = containers.Map();
nb_valides = 0;
for k = 1:size(adsb_msgs, 2)
    registre = bit2registre(adsb_msgs(:, k), REF_LON, REF_LAT);
    if isempty(registre.adresse)
        fprintf('Trame %2d : CRC invalide\n', k);
        continue
    end
    nb_valides = nb_valides + 1;
    afficher_registre(k, registre);
    avions = mettre_a_jour_avions(avions, registre);
end
fprintf('\nTrames valides : %d / %d\n', nb_valides, size(adsb_msgs, 2));
resumer_avions(avions);
tracer_avions(avions, REF_LON, REF_LAT);
sauver_figure('tache6_trajectoire');

function afficher_registre(k, r)
fprintf('Trame %2d : FTC = %2d, adresse = %s', k, r.type, r.adresse);
if ~isempty(r.nom),      fprintf(', nom = %s', r.nom); end
if ~isempty(r.altitude), fprintf(', altitude = %d ft', r.altitude); end
if ~isempty(r.latitude), fprintf(', position = (%.4f, %.4f)', r.latitude, r.longitude); end
fprintf('\n');
end
