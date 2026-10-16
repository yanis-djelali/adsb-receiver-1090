function [Sxx, f] = Mon_Welch(x, NFFT, Fe)
% MON_WELCH  Periodogramme de Welch sans chevauchement ni fenetre de ponderation.
%   Sxx : DSP bilaterale estimee (unite de x au carre par Hz), centree sur 0 ; f : axe en Hz.
x = x(:).';
K = floor(numel(x) / NFFT);                % nombre de segments moyennes
S = zeros(1, NFFT);
for k = 1:K
    segment = x((k-1)*NFFT + (1:NFFT));
    S = S + abs(fft(segment, NFFT)).^2 / (Fe*NFFT);
end
Sxx = fftshift(S / K);
f = (-NFFT/2 : NFFT/2-1) * Fe / NFFT;
end
