% TACHE 2 : autocorrelation moyennee et DSP du signal PPM (Welch et expression analytique)
clear; close all; clc;

%% Autocorrelation moyennee (sous-tache 4), Ts normalise a 1
Ts = 1;
tau = linspace(-2*Ts, 2*Ts, 1001);                % tau = 0 a l'indice 501
p = @(t) -0.5*(t >= 0 & t < Ts/2) + 0.5*(t >= Ts/2 & t < Ts);   % forme d'onde biphase
u = linspace(0, Ts, 1000);
Rp = zeros(size(tau));
for i = 1:numel(tau)
    Rp(i) = trapz(u, p(u) .* p(u + tau(i)));      % nul des que |tau| >= Ts
end
R_moy = 0.25 + Rp / Ts;
figure;
plot(tau/Ts, R_moy, 'LineWidth', 2); grid on; ylim([0 0.5]);
xlabel('\tau / T_s'); ylabel('Autocorrelation moyennee');
title('Autocorrelation moyennee du signal PPM');
sauver_figure('tache2_autocorrelation');

%% DSP : periodogramme de Welch (sous-tache 6) et expression analytique (sous-tache 5)
Fe = 20e6;
Fse = 20;
Ts = 1e-6;
NFFT = 256;
Nb = 20000;                                       % 20000*20/256 = 1562 FFT moyennees
sl = modulation_ppm(randi([0 1], 1, Nb), Fse);    % sl = 0.5 + somme de Ak p(t - kTs)
[Sxx, f] = Mon_Welch(sl - mean(sl), NFFT, Fe);    % moyenne retiree : le Dirac 0.25 delta(f) disparait

Gamma = Ts * sin(pi*f*Ts/2).^4 ./ (pi*f*Ts).^2;   % (1/Ts) |P(f)|^2
Gamma(f == 0) = 0;                                % limite en f = 0

figure;
plot(f/1e6, 10*log10(Sxx), 'LineWidth', 1.5); hold on;
plot(f/1e6, 10*log10(Gamma), '--', 'LineWidth', 1.5);
grid on; xlabel('Frequence (MHz)'); ylabel('DSP (dB/Hz)');
legend('Welch (simulation)', 'Expression analytique');
title('DSP du signal PPM');
sauver_figure('tache2_dsp');
