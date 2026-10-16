% TACHE 1 (sous-taches 4 et 5) : sl(t), rl(t) et rm pour la sequence [1 0 0 1 0], sans bruit
clear; close all; clc;
Fe = 20e6;
Te = 1/Fe;
Fse = 20;
bits = [1 0 0 1 0];
Nb = numel(bits);

p1 = [ones(1, Fse/2), zeros(1, Fse/2)];
sl = modulation_ppm(bits, Fse);
rl = conv(sl, fliplr(p1), 'same');
rm = rl((0:Nb-1)*Fse + Fse/2);          % sortie du filtre adapte en fin de premiere demi-periode
t = (0:numel(sl)-1) * Te * 1e6;

figure;
subplot(3,1,1); plot(t, sl, 'LineWidth', 1.2); grid on;
title('Signal transmis s_l(t)'); xlabel('Temps (\mus)'); ylabel('Amplitude');
subplot(3,1,2); plot(t, rl, 'LineWidth', 1.2); grid on;
title('Sortie du filtre adapte r_l(t)'); xlabel('Temps (\mus)'); ylabel('Amplitude');
subplot(3,1,3); stem(1:Nb, rm, 'filled'); grid on;
title('Echantillons r_m utilises pour la decision'); xlabel('Indice de bit'); ylabel('Valeur');
sauver_figure('tache1_signaux');
