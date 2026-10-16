function r = cprMod(a, b)
% CPRMOD  Modulo reel a valeur dans [0, b[ : MOD(a, b) = a - b*floor(a/b) (annexe C).
r = a - b * floor(a / b);
end
