clear; clc; close all;

%% === Test de la fonction bit2registre ===
load('adsb_msgs.mat');   % fichier 112x27 double
[n_bits, n_trames] = size(adsb_msgs);
fprintf("Chargement : %d trames de %d bits.\n", n_trames, n_bits);

registres = [];
fprintf("\n--- Décodage des trames ---\n");

for k = 1:n_trames
    bits = adsb_msgs(:,k);
    registre = bit2registre(bits);

    if ~isempty(registre)
        registres = [registres, registre];

        fprintf("Trame %2d -> DF=%d | FTC=%d | AA=%s", ...
            k, registre.format, registre.type, registre.adresse);

        if ~isempty(registre.nom)
            fprintf(" | Nom=%s", registre.nom);
        end
        if ~isempty(registre.altitude)
            fprintf(" | Alt=%d ft", registre.altitude);
        end
        fprintf("\n");
    else
        fprintf("Trame %2d -> CRC invalide ou non reconnue\n", k);
    end
end

fprintf("\nNombre de trames valides : %d / %d\n", length(registres), n_trames);

%% --- Extraction des positions si dispo
lat = []; lon = []; alt = [];
for i = 1:length(registres)
    if ~isempty(registres(i).latitude) && ~isempty(registres(i).longitude)
        lat = [lat, registres(i).latitude];
        lon = [lon, registres(i).longitude];
        alt = [alt, registres(i).altitude];
    end
end

%% --- Affichage de la trajectoire
if ~isempty(lat)
    figure;
    plot(lon, lat, 'bo-', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
    grid on;
    xlabel('Longitude [°]');
    ylabel('Latitude [°]');
    title('Trajectoire estimée de l''avion (en degrés)');
else
    disp('Aucune trame de position disponible.');
end
