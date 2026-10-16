function reste = crc_reste(bits)
% CRC_RESTE  Reste (24 bits) de la division modulo 2 de bits par le polynome generateur du sujet,
%   p(x) = x^24 + x^23 + ... + x^12 + x^10 + x^3 + 1. Une trame est intacte si ce reste est nul.
poly = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
r = double(bits(:).');
for i = 1:numel(r) - 24
    if r(i)
        r(i:i+24) = xor(r(i:i+24), poly);   % soustraction modulo 2 du polynome aligne sur le bit i
    end
end
reste = r(end-23:end);
end
