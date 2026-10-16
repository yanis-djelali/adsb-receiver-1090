% TACHE 8 : traitement des enregistrements reels de buffers.mat (plusieurs avions)
clear; close all; clc;
REF_LAT = 44.806884;
REF_LON = -0.606957;
seuil = 0.1;                     % seuil sur la correlation normalisee par son maximum

donnees = load('buffers.mat');
buffers = donnees.buffers;       % echantillons complexes, un buffer par colonne
Fse = round(donnees.Rs / 1e6);   % echantillons par microseconde (Rs = 4 MHz)
avions = containers.Map();
for k = 1:size(buffers, 2)
    registres = process_buffer(buffers(:, k), REF_LON, REF_LAT, seuil, Fse);
    fprintf('Buffer %d / %d : %d trames valides\n', k, size(buffers, 2), numel(registres));
    avions = mettre_a_jour_avions(avions, registres);
end
resumer_avions(avions);
tracer_avions(avions, REF_LON, REF_LAT);
sauver_figure('tache8_avions');
