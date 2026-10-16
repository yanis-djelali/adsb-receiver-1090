clear; clc; close all;

Nb   = 20000;              
Fe   = 20e6;               
Te   = 1/Fe;               
Fse  = 20;                 
Ts   = Fse * Te;           
NFFT = 256;                

p = [ones(1,Fse/2), -ones(1,Fse/2)]; 

bits = randi([0 1],1,Nb);
A = 1 - 2*bits;             
sl = kron(A,p);             
sl = sl + 0.5;              
sl_noDC = sl - mean(sl);

% Welch maison
[Sxx_maison,f_axis] = Welch(sl_noDC, NFFT, Fe);

% Welch du prof
[Sxx_prof,f_prof] = Mon_Welch_(sl_noDC, NFFT, Fe);

% Tracer sur tout le spectre [-Fe/2 , +Fe/2]
figure;
plot(f_axis/1e6,10*log10(Sxx_maison),'r','LineWidth',1.5); hold on;
plot(f_prof/1e6,10*log10(Sxx_prof),'b--','LineWidth',1.5);
xlabel('Frequence [MHz]');
ylabel('DSP [dB/Hz]');
title('Comparaison Welch maison vs Welch prof (spectre complet)');
legend('Welch maison','Welch prof');
grid on;