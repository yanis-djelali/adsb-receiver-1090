function valide = crc_valide(bits)
% CRC_VALIDE  Vrai si la trame passe le controle CRC 24 bits (reste de division nul).
valide = ~any(crc_reste(bits));
end
