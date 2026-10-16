% TACHE 4 (sous-taches 5 et 6) : synchronisation temporelle par correlation avec le preambule
clear; close all; clc;
Fe = 20e6;
Te = 1/Fe;
Fse = 20;

sp = preambule_adsb(Fse);
sl = [sp, modulation_ppm(randi([0 1], 1, 100), Fse)];

% distorsions aleatoires (alpha = 1, sans bruit)
delta_t = randi([0 100]);                % retard en echantillons, au plus 100 Te
delta_f = (2*rand - 1) * 1e3;            % decalage en frequence dans [-1 kHz, 1 kHz]
phi0 = 2*pi*rand;
y = [zeros(1, delta_t), sl];
n = 0:numel(y)-1;
y = y .* exp(-1j*2*pi*delta_f*n*Te + 1j*phi0);

[delta_t_estime, rho] = estimer_retard(y, sp);
fprintf('Retard applique : %d echantillons\n', delta_t);
fprintf('Retard estime   : %d echantillons\n', delta_t_estime);

figure;
plot(0:numel(rho)-1, rho, 'LineWidth', 1.5); grid on;
xlabel('Retard teste (echantillons)'); ylabel('|\rho|');
title('Correlation normalisee avec le preambule');
sauver_figure('tache4_correlation');
