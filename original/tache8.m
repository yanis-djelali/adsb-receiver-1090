clear; close all; clc;

load('buffers.mat');
Fe = Rs; % frequence echantillonnage
Te = 1/Fe; % periode echantillonnage
Ts = 1e-6; % pas temporel
Fse = round(Ts/Te); % facteur surechantillonnage
% definition du preambule adsb
T_imp = 0.5e-6;
T_gap1 = 0.5e-6;
T_gap2 = 2.0e-6;
T_gap3 = 0.5e-6;
T_gap4 = 3.0e-6;
N_imp = round(Fe * T_imp);
N_gap1 = round(Fe * T_gap1);
N_gap2 = round(Fe * T_gap2);
N_gap3 = round(Fe * T_gap3);
N_gap4 = round(Fe * T_gap4);
preambule = [ones(1,N_imp), zeros(1,N_gap1), ones(1,N_imp), zeros(1,N_gap2), ...
   ones(1,N_imp), zeros(1,N_gap3), ones(1,N_imp), zeros(1,N_gap4)];
N_pre = length(preambule);
% parametres detection
seuil_corr = 0.1;
distance_min_trames = 400;
REF_LAT = 44.84;
REF_LON = -0.7;
% dictionnaire pour stocker les avions par adresse OACI
avions = containers.Map();
% boucle sur chaque buffer
for idx_buf = 1:size(buffers, 2)
   fprintf('\n=== analyse buffer %d/%d ===\n', idx_buf, size(buffers,2));
   signal = buffers(:, idx_buf);
   module_signal = abs(signal);
  
   % correlation avec le preambule
   pre_norm = preambule - mean(preambule);
   correlation = conv(module_signal, fliplr(pre_norm), 'valid');
   correlation_norm = correlation / max(abs(correlation));
  
   % detection des pics au dessus du seuil
   [pics, locs] = findpeaks(correlation_norm, 'MinPeakHeight', seuil_corr, ...
       'MinPeakDistance', distance_min_trames);
   fprintf(' %d trames detectees potentiellement\n', length(pics));
  
   % decodage trame par trame
   for idx_trame = 1:length(locs)
       delta = locs(idx_trame) - 1;
       debut_bits = delta + N_pre;
      
       if debut_bits + 112*Fse > length(module_signal)
           continue
       end
      
       % recuperation des 112 bits
       bits_trame = zeros(112, 1);
       for b = 1:112
           indices = debut_bits + (b-1)*Fse + (1:Fse);
           segment = module_signal(indices);
           % demodulation ppm energie premiere moitie / seconde moitie
           E1 = sum(segment(1:Fse/2));
           E2 = sum(segment(Fse/2+1:end));
           bits_trame(b) = (E1 > E2); % 0 si E1>E2 sinon 1
       end
      
       % decodage avec bit2registre
       try
           registre = bit2registre(bits_trame);
          
           if ~isempty(registre.adresse)
               % Récupérer ou créer l'entrée pour cet avion
               aa = registre.adresse;
              
               if ~isKey(avions, aa)
                   avions(aa) = struct('nom', '', 'positions', [], ...
                       'altitudes', [], 'types', []);
               end
              
               avion = avions(aa);
              
               % Ajouter le type de message
               if ~isempty(registre.type)
                   avion.types = [avion.types; registre.type];
               end
              
               % Si c'est un message d'identification (FTC 1-4)
               if registre.type >= 1 && registre.type <= 4 && ~isempty(registre.nom)
                   avion.nom = registre.nom;
                   fprintf(' -> Identification %s: %s\n', aa, registre.nom);
               end
              
               % Si c'est un message de position (FTC 9-18)
               if registre.type >= 9 && registre.type <= 18
                   if ~isempty(registre.latitude) && ~isempty(registre.longitude)
                       avion.positions = [avion.positions; registre.latitude, registre.longitude];
                       if ~isempty(registre.altitude)
                           avion.altitudes = [avion.altitudes; registre.altitude];
                       end
                   end
               end
              
               avions(aa) = avion;
           end
       catch
           % erreur silencieuse
       end
   end
end

fprintf('\nRÉSUMÉ DES AVIONS DÉTECTÉS\n');
keys_list = keys(avions);
fprintf('Nombre d''avions: %d\n\n', length(keys_list));
% on crée une structure pour l'affichage
all_positions = [];
labels = {};
colors = lines(length(keys_list));
for idx = 1:length(keys_list)
  aa = keys_list{idx};
  avion = avions(aa);
   fprintf('Avion %s:\n', aa);
  if ~isempty(avion.nom)
      fprintf('  Nom: %s\n', avion.nom);
  else
      fprintf('  Nom: (non identifié)\n');
  end
  fprintf('  Positions: %d\n', size(avion.positions, 1));
  if ~isempty(avion.altitudes)
      fprintf('  Altitude moy: %.0f ft\n', mean(avion.altitudes));
  end
   % types de messages reçus
  unique_types = unique(avion.types);
  fprintf('  Types de messages: ');
  fprintf('%d ', unique_types);
  fprintf('\n\n');
end
% affichage carte avec toutes les trajectoires
figure;
affiche_carte(REF_LON, REF_LAT);
hold on;
for idx = 1:length(keys_list)
   aa = keys_list{idx};
   avion = avions(aa);
   if ~isempty(avion.positions)
       % trajectoire simple
       plot(avion.positions(:,2), avion.positions(:,1), '-k', 'LineWidth', 1);
       plot(avion.positions(:,2), avion.positions(:,1), 'ok', 'MarkerSize', 5);
       % Label simple au dernier point
       if ~isempty(avion.nom)
           label = sprintf('%s', avion.nom);
       else
           label = aa;
       end
       text(avion.positions(end,2), avion.positions(end,1), label, ...
           'FontSize', 8, 'Color', 'k');
   end
end
% position de référence
plot(REF_LON, REF_LAT, 'r^', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(REF_LON, REF_LAT, ' École', 'FontSize', 9);
title(sprintf('Trajectoires ADS-B - %d avions détectés', length(keys_list)));
xlabel('Longitude'); ylabel('Latitude'); grid on;
