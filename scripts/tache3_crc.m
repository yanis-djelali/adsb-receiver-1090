% TACHE 3 : codage et detection CRC 24 bits sur un paquet de 88 bits d'information
clear; close all; clc;
bits_info = randi([0 1], 1, 88);

% codage : on ajoute le reste de la division de [bits_info, 24 zeros] par le polynome
bits_codes = [bits_info, crc_reste([bits_info, zeros(1, 24)])];   % 88 + 24 = 112 bits
fprintf('Sans erreur    : trame valide = %d (attendu 1)\n', crc_valide(bits_codes));

bits_errones = bits_codes;
bits_errones(10) = 1 - bits_errones(10);           % un bit inverse parmi les 88 bits utiles
fprintf('Un bit inverse : trame valide = %d (attendu 0)\n', crc_valide(bits_errones));
