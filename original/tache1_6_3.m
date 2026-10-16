clear; 
clc; 
close all;
Fe = 20e6;
Fse = 20;
Te = 1/Fe;
Ts = Fse*Te;

p0 = [zeros(1, Fse/2), ones(1, Fse/2)];
p1 = [ones(1, Fse/2), zeros(1, Fse/2)];
Eb = Fse/2;
EbN0_dB = 0:1:10; % Eb/N0 en dB
BER_sim = zeros(size(EbN0_dB));

% pour regler erreur fin 
Nb_bits_par_trame = 1000; % bits par transmission
Nb_erreurs_min = 100; % nombre minimum d'erreurs pour avoir une statistique fiable

for i = 1:length(EbN0_dB)
    EbN0_lin = 10^(EbN0_dB(i)/10);
    sigma_n = sqrt(Eb/(2*EbN0_lin)); 
    
    % compteurs
    nb_erreurs_total = 0;
    nb_bits_total = 0;
    
    % continuer jusqu'à avoir au moins 100 erreurs
    while nb_erreurs_total < Nb_erreurs_min
        bits = randi([0 1], 1, Nb_bits_par_trame);
        
        % signal
        sl = [];
        for k = 1:Nb_bits_par_trame
            if bits(k)==0
                sl = [sl p0];
            else
                sl = [sl p1];
            end
        end
        
        % Ajout du bruit
        s_bruit = sl + sigma_n*randn(size(sl));
        
        % Corrélation avec p0 et p1
        r0 = conv(s_bruit, fliplr(p0), 'same');
        r1 = conv(s_bruit, fliplr(p1), 'same');
        
        % Échantillons centraux
        rm0 = zeros(1, Nb_bits_par_trame);
        rm1 = zeros(1, Nb_bits_par_trame);
        for k = 1:Nb_bits_par_trame
            rm0(k) = r0((k-1)*Fse + Fse/2);
            rm1(k) = r1((k-1)*Fse + Fse/2);
        end
        
        %car choix du bit = booleen sur le meilleur rapport de convulusion
        %(c l'avantage de la modulaton)
        bits_choisi = rm1 > rm0;
        
        % Comptage des erreurs
        nb_erreurs_total = nb_erreurs_total + sum(bits~=bits_choisi);
        nb_bits_total = nb_bits_total + Nb_bits_par_trame;
        
        % sinon on a eu des boucles infinis
        if nb_bits_total > 1e6 && nb_erreurs_total < 10
            fprintf('Eb/N0 = %d dB : Très peu d''erreurs après 1M bits (%d erreurs)\n', ...
                EbN0_dB(i), nb_erreurs_total);
            break;
        end
    end
    
    % Calcul TEB
    BER_sim(i) = nb_erreurs_total/nb_bits_total;
    fprintf('Eb/N0 = %2d dB : %d erreurs sur %d bits, TEB = %.4e\n', ...
        EbN0_dB(i), nb_erreurs_total, nb_bits_total, BER_sim(i));
end

% Courbe théorique ppm ayant une distance divisé par 2(+ compliqué de choisir du coup)
% comparé à une BPSK d'ou la perte de sensibilité et le rapport 2 qu'on retire.
Pb_th = 0.5*erfc(sqrt(10.^(EbN0_dB/10)));

% Tracé propre ia
figure;
semilogy(EbN0_dB, BER_sim,'o-','LineWidth',1.5, 'DisplayName', 'Simulation'); 
hold on;
semilogy(EbN0_dB, Pb_th,'r--','LineWidth',1.5, 'DisplayName', 'Théorie');
grid on;
xlabel('E_b/N_0 [dB]');
ylabel('Taux d''erreur binaire (TEB)');
legend('Location', 'best');
title('TEB du système PPM binaire');
ylim([1e-5 1]);