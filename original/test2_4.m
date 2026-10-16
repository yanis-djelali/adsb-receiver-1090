clear; close all; clc; %affichage majoritairement fait par l'ia, cela coincide bien avec la pratique

% Paramètres
Ts = 1; % Normalisation à Ts = 1 pour simplicité
N = 1000; % Nombre de points
tau = linspace(-2*Ts, 2*Ts, N); % Vecteur des décalages tau

% Définition de p(t) biphase
p = @(t) (-0.5).*(t>=0 & t<Ts/2) + (0.5).*(t>=Ts/2 & t<Ts);

% Calcul de l'autocorrélation Rp(tau)
Rp = zeros(size(tau));
for i = 1:length(tau)
    % Intégrale de p(u)*p(u+tau(i)) de -∞ à +∞
    % En pratique, p(t) est non-nul seulement sur [0,Ts]
    % donc l'intégrale est sur [0,Ts-|tau|] si |tau|<Ts
    
    if abs(tau(i)) < Ts
        % Points d'intégration
        u = linspace(0, Ts, 1000);
        integrand = p(u) .* p(u + tau(i));
        Rp(i) = trapz(u, integrand);
    else
        Rp(i) = 0;
    end
end

% Autocorrélation moyennée R̃sl(tau) = 0.25 + Rp(tau)
R_tilde = 0.25 + Rp;

% Tracé
figure('Position', [100 100 800 600]);
plot(tau/Ts, R_tilde, 'b-', 'LineWidth', 2);
hold on;
plot(tau/Ts, 0.25*ones(size(tau)), 'r--', 'LineWidth', 1); % Ligne de base
grid on;
xlabel('\tau/T_s');
ylabel('R̃_{sl}(\tau)');
title('Autocorrélation moyennée du signal PPM');
ylim([0 0.5]);

% Marquage des points importants
plot(0, R_tilde(N/2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(0.1, R_tilde(N/2), sprintf('Max = %.2f', R_tilde(N/2)));

% Valeurs théoriques attendues
fprintf('Valeur en τ=0: R̃sl(0) = %.3f\n', R_tilde(N/2));
fprintf('Valeur asymptotique: R̃sl(∞) = 0.25\n');