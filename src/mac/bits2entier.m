function n = bits2entier(bits)
% BITS2ENTIER  Entier non signe code par bits, bit de poids fort en premier.
bits = double(bits(:).');
n = bits * 2.^(numel(bits)-1 : -1 : 0).';
end
