clear; clc; close all;

% Parametres
Fe = 20e6;            % frequence d'echantillonnage
Te = 1/Fe;
Fse = 20;             % nb echantillons par symbole
Ts = Fse*Te;
NFFT = 256;

% Duree preambule 8 us
Tp = 8e-6;                           
Np = round(Tp*Fe);

% Generation d'un preambule simple 
preamble = [ones(1,Np/2), -ones(1,Np/2)];  

% signal preambule +data
Nb_data = 100; 
data = randi([0 1],1,Nb_data);
A = 1 - 2*data;
pulse = [ones(1,Fse/2), -ones(1,Fse/2)];
signal_data = kron(A,pulse);

sl = [preamble signal_data];  % trame envoyee

% application decalages
delta_t = randi([0 100]);    % retard en nb d'echantillons (<= 100*Te)
delta_f = (2*rand-1)*1e3;    % decalage freq dans [-1kHz, 1kHz]
phi0    = 2*pi*rand;         % phase initiale

n = 0:length(sl)-1;
y = [zeros(1,delta_t), sl];   % retard
n = 0:length(y)-1; 
y = y .* exp(1j*(2*pi*delta_f*n*Te + phi0));       % decalage freq + phase

%%synchronisation temporelle par correlation
rho = zeros(1, length(y)-Np);
for k = 1:length(y)-Np
    num = sum(y(k:k+Np-1) .* conj(preamble));
    den = sqrt(sum(abs(preamble).^2) * sum(abs(y(k:k+Np-1)).^2));
    rho(k) = abs(num)/den;
end

[~,est_delta_t] = max(rho);

fprintf("Décalage appliqué = %d echantillons\n",delta_t);
fprintf("Décalage estimé   = %d echantillons\n",est_delta_t -1); % car on commence à 1 en matlab

%affichage correlation
figure;
plot(rho,'LineWidth',1.5); grid on;
xlabel('Décalage (echantillons)');
ylabel('|rho|');
title('Intercorrelation avec le preambule');

