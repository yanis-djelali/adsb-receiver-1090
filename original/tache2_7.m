clear; clc; close all;

%% Parametres
Fe  = 20e6;             
Te  = 1/Fe;
Fse = 20;               
Ts  = Fse*Te;           
Tp  = 8e-6;             
Np  = round(Tp*Fe);     

Nb_bits   = 1000;     % nb de bits par trame
Nb_trames = 100;      % nb de trames par point Eb/N0

% Preambule (simplifie biphase)
preamble = [ones(1,Np/2), -ones(1,Np/2)];

% Impulsion pour bits
pulse = [ones(1,Fse/2), -ones(1,Fse/2)];

% Eb/N0 en dB
EbN0_dB = 0:10;   
TEB_sim = zeros(size(EbN0_dB));

%% Boucle sur Eb/N0
for i = 1:length(EbN0_dB)
    nb_err = 0; nb_total = 0;
    
    for tr = 1:Nb_trames
        
        % ----- 1. Donnees -----
        bits = randi([0 1], 1, Nb_bits);
        A = 1 - 2*bits;
        signal_data = kron(A,pulse);
        sl = [preamble, signal_data];
        
        % ----- 2. Desynchronisations -----
        delta_t = randi([0 100]);     
        delta_f = (2*rand-1)*1e3;     
        phi0    = 2*pi*rand;          
        
        y = [zeros(1,delta_t), sl];     
        n = 0:length(y)-1;
        y = y .* exp(1j*(2*pi*delta_f*n*Te + phi0));
        
        % ----- 3. Ajout bruit -----
        Eb = sum(abs(pulse).^2)/length(pulse);
        EbN0_lin = 10^(EbN0_dB(i)/10);
        N0 = Eb/EbN0_lin;
        sigma2 = N0/2;
        bruit = sqrt(sigma2)*(randn(size(y)) + 1j*randn(size(y)));
        y = y + bruit;
        
        % ----- 4. Synchronisation temporelle -----
        rho = zeros(1,length(y)-Np);
        for k = 1:length(y)-Np
            seg = y(k:k+Np-1);
            num = sum(seg .* conj(preamble));
            den = sqrt(sum(abs(preamble).^2) * sum(abs(seg).^2));
            rho(k) = abs(num)/den;
        end
        [~,est_delta_t] = max(rho);
        est_delta_t = est_delta_t - 1;
        
        % ----- 5. Extraction des donnees apres synchro -----
        y_sync = y(est_delta_t+Np+1:end);
        Lbit = Fse;  
        
        % Tronquer a un multiple de Lbit
        Nb_bits_rx = floor(length(y_sync)/Lbit);
        y_sync = y_sync(1:Nb_bits_rx*Lbit);
        
        bits_est = zeros(1,Nb_bits_rx);
        for k = 1:Nb_bits_rx
            seg = y_sync((k-1)*Lbit+1 : k*Lbit);
            if real(seg(Lbit/2)) > 0
                bits_est(k) = 0;
            else
                bits_est(k) = 1;
            end
        end
        
        % ----- 6. Compter erreurs -----
        nb_err = nb_err + sum(bits(1:Nb_bits_rx) ~= bits_est);
        nb_total = nb_total + Nb_bits_rx;
    end
    
    TEB_sim(i) = nb_err/nb_total;
    fprintf("Eb/N0 = %d dB -> TEB = %.3g\n", EbN0_dB(i), TEB_sim(i));
end

%% Courbe theorique (approximation modulation orthogonale)
EbN0_lin = 10.^(EbN0_dB/10);
TEB_theo = qfunc(sqrt(EbN0_lin));

%% Affichage
figure;
semilogy(EbN0_dB, TEB_sim, 'ro-','LineWidth',1.5); hold on;
semilogy(EbN0_dB, TEB_theo,'b--','LineWidth',1.5);
xlabel('E_b/N_0 [dB]');
ylabel('Taux d''erreur binaire (TEB)');
title('TEB avec desynchronisation + bruit vs theorique');
legend('Simule','Theorique');
grid on;

%% Calcul de la perte en dB pour TEB = 1e-3
target = 1e-3;

% Interpolation log-lin
dB_sim = interp1(log10(TEB_sim), EbN0_dB, log10(target));
dB_theo = interp1(log10(TEB_theo), EbN0_dB, log10(target));
perte_dB = dB_sim - dB_theo;

fprintf("Perte en dB pour TEB = 1e-3 : %.2f dB\n", perte_dB);
