clear all; close all; clc;


Ts = 1e-6;       
Te = Ts/2;        
Fs = 1/Te;
Tp = 8e-6;      
Nb_bits = 112;
Nb_trames = 1000;

% Création préambule sp (discretisé selon Te)
t_p = 0:Te:(Tp-Te);
sp = zeros(size(t_p));
for i = 1:4
    idx_s = (i-1)*round(2*Ts/Te) + 1;
    idx_e = idx_s + round(Ts/Te) - 1;
    sp(idx_s:idx_e) = 1;
end

% Eb/N0 en dB
EbN0_dB = 0:1:10;
EbN0_lin = 10.^(EbN0_dB/10);

% Parametres simulation (stop adaptatif)
target_errors = 100;   % nombre d'erreurs minimum par point SNR
max_bits_per_point = 1e6;

TEB_sim = zeros(size(EbN0_dB));

% formule theorique 2-PPM (cohérent) : Pe = Q(sqrt(Eb/N0))
Pe_theo_coherent = qfunc(sqrt(EbN0_lin));


 % Boucle Eb/N0
for idx = 1:length(EbN0_dB)
    fprintf('--- Eb/N0 = %d dB ---\n', EbN0_dB(idx));
    nb_err = 0;
    nb_bits_sent = 0;
    iter = 0;
    
    while (nb_err < target_errors) && (nb_bits_sent < max_bits_per_point) && (iter < Nb_trames*10)
        iter = iter + 1;
        b = randi([0 1], 1, Nb_bits);
        sl = mod_ppm(b, Ts, Te);          % signal de données (sans préambule)
        sl_full = [sp, sl];               % trame complète envoyée
        
        % Distorsions aléatoires
        dt = rand()*100*Te;               % délai uniforme entre 0 et 100Te
        df = (rand()-0.5)*2*1000;         % décalage fréquence entre -1kHz et 1kHz
        phi0 = rand()*2*pi;
        n_delay = round(dt/Te);
        
        % Canal : retard + shift fréquentiel + phase
        sl_d = [zeros(1,n_delay), sl_full];      % mise en retard
        t = (0:length(sl_d)-1)*Te;
        sl_d = sl_d .* exp(-1j*2*pi*df.*t + 1j*phi0);
        
    
        % Calcul Eb sur le signal de données uniquement (sl)
        Ps = mean(abs(sl).^2);      % puissance moyenne du signal de données (watts)
        Eb = Ps * Ts;               % energie par bit = puissance * durée bit
        N0 = Eb / EbN0_lin(idx);    % densité spectrale de bruit
        
        % Puissance du bruit par echantillon complexe discret
        Pn = N0 * Fs;               % <-- IMPORTANT : *Fs* (et non /2)
        bruit = sqrt(Pn/2) * (randn(size(sl_d)) + 1j*randn(size(sl_d)));
        
        yl = sl_d + bruit;          % signal reçu bruité
        
        % Synchronisation (estimation du délai en secondes)
        dt_est = sync_temps(yl, sp, Te);
        
        % Extraction du segment utile basé sur l'estimation
        i_deb = round(dt_est/Te) + length(sp) + 1;
        i_fin = i_deb + length(sl) - 1;
        if i_fin > length(yl)
            % trame tronquée par le retard -> on la jette (comportement comme avant)
            continue;
        end
        rl = yl(i_deb:i_fin);
        
        % Demodulation insensible a alpha et phi0
        b_est = demod_ppm(rl, Ts, Te);
        
        % Comptage erreurs
        if length(b_est) == length(b)
            nb_err = nb_err + sum(b ~= b_est);
            nb_bits_sent = nb_bits_sent + length(b);
        end
    end
    
    if nb_bits_sent == 0
        TEB_sim(idx) = NaN;
    else
        TEB_sim(idx) = nb_err / nb_bits_sent;
    end
    fprintf('Iter=%d, bits_sent=%d, errors=%d, BER_sim=%.3e\n', iter, nb_bits_sent, nb_err, TEB_sim(idx));
end

% Tracé
figure('Position', [100 100 900 600]);
semilogy(EbN0_dB, Pe_theo_coherent, 'b-', 'LineWidth', 2, 'DisplayName', 'theorique 2-PPM');
hold on;
semilogy(EbN0_dB, TEB_sim, 'ro-', 'LineWidth', 1.5, 'MarkerSize', 7, 'DisplayName', 'simule avec sync');
grid on;
xlabel('E_b/N_0 (dB)'); ylabel('TEB');
title('TEB - 2-PPM avec synchronisation temps (simulation corrigée)');
legend('Location', 'southwest');
ylim([1e-5 1]);

% Perte à TEB = 1e-3
TEB_cible = 1e-3;
if all(~isnan(Pe_theo_coherent)) && any(TEB_sim>0)
    if min(Pe_theo_coherent) < TEB_cible && max(Pe_theo_coherent) > TEB_cible
        EbN0_theo = interp1(Pe_theo_coherent, EbN0_dB, TEB_cible);
    else
        EbN0_theo = NaN;
    end
    if min(TEB_sim) < TEB_cible && max(TEB_sim) > TEB_cible
        EbN0_sim = interp1(TEB_sim, EbN0_dB, TEB_cible);
    else
        EbN0_sim = NaN;
    end
    if ~isnan(EbN0_theo) && ~isnan(EbN0_sim)
        perte = EbN0_sim - EbN0_theo;
        fprintf('\n=== teb = 10^-3 ===\n');
        fprintf('eb/n0 theorique: %.2f dB\n', EbN0_theo);
        fprintf('eb/n0 simule  : %.2f dB\n', EbN0_sim);
        fprintf('perte          : %.2f dB\n', perte);
        plot([min(EbN0_dB) max(EbN0_dB)], [TEB_cible TEB_cible], 'k--', 'DisplayName', 'teb = 10^{-3}');
        legend('Location', 'southwest');
    else
        fprintf('TEB = 1e-3 non atteint/interpolable sur les courbes.\n');
    end
end

% Fonctions locales

function sl = mod_ppm(b, Ts, Te)
    % modulation 2-PPM (binaire) : chaque bit = 2* (Ts/2) fenêtres
    samples_per_bit = round(Ts/Te);      % ex: Ts=1µs, Te=0.5µs -> 2 samples par bit
    if mod(samples_per_bit,2)~=0
        % s'assurer paire pour couper en deux
        samples_per_bit = samples_per_bit + 1;
    end
    half = samples_per_bit/2;
    sl = zeros(1, length(b)*samples_per_bit);
    for i = 1:length(b)
        idx = (i-1)*samples_per_bit;
        if b(i) == 0
            sl(idx + (1:half)) = 1;
        else
            sl(idx + (half+1: samples_per_bit)) = 1;
        end
    end
end

function dt_hat = sync_temps(yl, sp, Te)
    % synchronisation par intercorrelation normalisée (recherche du max)
    E_sp = sum(abs(sp).^2);
    max_d = length(yl) - length(sp) + 1;
    if max_d < 1
        dt_hat = 0;
        return;
    end
    rho = zeros(1, max_d);
    for d = 0:max_d-1
        y_fen = yl(d+1 : d+length(sp));
        num = abs(sum(y_fen .* conj(sp)));
        den = sqrt(sum(abs(y_fen).^2) * E_sp);
        if den > 0
            rho(d+1) = num / den;
        else
            rho(d+1) = 0;
        end
    end
    [~, idx] = max(rho);
    dt_hat = (idx-1) * Te;
end

function b_hat = demod_ppm(rl, Ts, Te)
    % demodulation insensible a alpha et phi0 : compare energies des deux moitiés
    N_sym = round(Ts/Te);
    if mod(N_sym,2)~=0
        N_sym = N_sym + 1;
    end
    half = N_sym/2;
    Nb_sym = floor(length(rl)/N_sym);
    b_hat = zeros(1, Nb_sym);
    for m = 0:Nb_sym-1
        i1 = m*N_sym + 1;
        mid = i1 + half - 1;
        i3 = i1 + N_sym - 1;
        r0 = sum(rl(i1:mid));
        r1 = sum(rl(mid+1:i3));
        % comparaison des modules (insensible a alpha et phi0)
        b_hat(m+1) = (abs(r1) > abs(r0));
    end
end
