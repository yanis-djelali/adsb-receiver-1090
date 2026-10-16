function [retard, rho] = estimer_retard(y, sp)
% ESTIMER_RETARD  Retard (en echantillons) qui maximise la correlation normalisee |rho|
%   entre le signal recu y et le preambule sp (tache 4). |rho| <= 1 et ne depend pas de alpha.
Np = numel(sp);
rho = zeros(1, numel(y) - Np + 1);
for k = 1:numel(rho)
    fenetre = y(k : k+Np-1);
    rho(k) = abs(sum(fenetre .* conj(sp))) / sqrt(sum(abs(sp).^2) * sum(abs(fenetre).^2));
end
[~, k_max] = max(rho);
retard = k_max - 1;   % l'indice 1 correspond a un retard nul
end
