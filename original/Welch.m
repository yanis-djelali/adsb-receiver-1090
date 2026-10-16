
function [Sxx, f] = Welch(x, NFFT, Fe)
    L  = floor(length(x)/NFFT) * NFFT;
    x  = x(1:L);
    K  = L / NFFT;
    S  = zeros(1, NFFT);

    for k = 1:K
        seg = x((k-1)*NFFT + (1:NFFT));
        Xk  = fft(seg, NFFT);
        Pk  = (1/(Fe*NFFT)) * abs(Xk).^2;
        S   = S + Pk;
    end

    Sxx = S / K;
    Sxx = fftshift(Sxx);
    df  = Fe / NFFT;
    f   = (-NFFT/2:NFFT/2-1) * df;
end


