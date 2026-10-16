clear; 
close all; 
clc;

Nb_bits_infos=88;
Nb_bits_crc=24;
Nb_bits_total=112;

poly_crc = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];

gen = crc.generator(poly_crc);
det = crc.detector(poly_crc);


bits_info = randi([0 1], 1, Nb_bits_infos);

% Ajout du CRC 
bits_codes = generate(gen, bits_info.');



% Verification sans erreur
[~, erreur_detectee] = detect(det, bits_codes);
fprintf(" %d (0 = valide, 1 = erreur detectee)\n", erreur_detectee);

% Simulation d'une erreur
bits_errones = bits_codes;
bits_errones(10) = ~bits_errones(10);


[~, erreur_detectee2] = detect(det, bits_errones);
fprintf(" %d (0 = valide, 1 = erreur detectee)\n", erreur_detectee2);
