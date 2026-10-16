% TACHE 1 (sous-taches 6 et 7) : TEB de la chaine PPM en fonction de Eb/N0, simulation et theorie
clear; close all; clc;
Fse = 20;
Nb = 1000;                        % taille d'un paquet
EbN0_dB = 0:10;
nb_erreurs_min = 100;             % une valeur de TEB n'est retenue qu'au-dela de 100 erreurs

p1 = [ones(1, Fse/2), zeros(1, Fse/2)];
Eb = sum(p1.^2);                  % 1 bit par symbole
TEB = zeros(size(EbN0_dB));

for i = 1:numel(EbN0_dB)
    sigma = sqrt(Eb / 10^(EbN0_dB(i)/10) / 2);   % variance du bruit par echantillon : N0/2
    nb_erreurs = 0;
    nb_bits = 0;
    while nb_erreurs < nb_erreurs_min
        bits = randi([0 1], 1, Nb);
        yl = modulation_ppm(bits, Fse) + sigma * randn(1, Nb*Fse);
        rl = conv(yl, fliplr(p1), 'same');
        r = rl(Fse/2 : Fse/2 : end);              % r(2k-1) : 1re moitie du bit k, r(2k) : 2e moitie
        bits_estimes = r(1:2:end) >= r(2:2:end);
        nb_erreurs = nb_erreurs + sum(bits ~= bits_estimes);
        nb_bits = nb_bits + Nb;
    end
    TEB(i) = nb_erreurs / nb_bits;
    fprintf('Eb/N0 = %2d dB : %d erreurs sur %d bits, TEB = %.3g\n', ...
            EbN0_dB(i), nb_erreurs, nb_bits, TEB(i));
end

Pb = 0.5 * erfc(sqrt(10.^(EbN0_dB/10) / 2));     % Pb = Q(sqrt(Eb/N0))
figure;
semilogy(EbN0_dB, TEB, 'o-', 'LineWidth', 1.5); hold on;
semilogy(EbN0_dB, Pb, '--', 'LineWidth', 1.5);
grid on; xlabel('E_b/N_0 (dB)'); ylabel('TEB');
legend('Simulation', 'Theorie : Q(\surd(E_b/N_0))', 'Location', 'southwest');
title('TEB de la modulation PPM binaire');
sauver_figure('tache1_teb');
