
clear; close all; clc;

Fe  = 20e6;               % fréquence d'éch
Te  = 1/Fe;           
Fse = 20;             
Ts  = Fse * Te;          

bits = [1 0 0 1 0];       
Nb   = length(bits);      % nombre de bits

p0 = [zeros(1, Fse/2), ones(1, Fse/2)];  
p1 = [ones(1, Fse/2), zeros(1, Fse/2)];  


%Signal émis s_l(t)
sl = [];
for k = 1:Nb
    if bits(k) == 0
        sl = [sl p0];
    else
        sl = [sl p1];
    end
end


rl = conv(sl, fliplr(p1),"same");

rm = zeros(1, Nb);
for k = 1:Nb
    rm(k) = rl((k-1)*Fse + Fse/2);
end





t_global = (0:length(sl)-1)*Te; % axe temporel global

figure;
subplot(3,1,1);
plot(t_global*1e6, sl, 'LineWidth',1.2);
title('Signal transmis s_i(t)');
xlabel('Temps [µs]'); ylabel('Amplitude'); 
grid on;

subplot(3,1,2);
plot(t_global*1e6, rl, 'LineWidth',1.2);
title('Sortie du corrélateur r_l(t)');
xlabel('Temps [µs]'); ylabel('Amplitude'); 
grid on;

subplot(3,1,3);
stem(1:Nb, rm, 'filled');
title('Échantillons r_m utilisés pour la décision');
xlabel('Indice de symbole'); ylabel('Valeur');  
grid on;



