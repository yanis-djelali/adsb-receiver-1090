function registre = bit2registre(bits, refLon, refLat)
% BIT2REGISTRE  Decode une trame ADS-B de 112 bits (sans le preambule).
%   registre = bit2registre(bits, refLon, refLat) renvoie la structure registre remplie
%   si le CRC est valide, et une structure aux champs vides sinon.
%   refLon, refLat : position de reference du decodage CPR (par defaut, l'ecole).
if nargin < 3
    refLon = -0.606957;
    refLat = 44.806884;
end
registre = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                  'altitude', [], 'timeFlag', [], 'cprFlag', [], ...
                  'latitude', [], 'longitude', []);
bits = double(bits(:).');
if numel(bits) ~= 112 || ~crc_valide(bits)
    return
end

registre.format = bits2entier(bits(1:5));                % DF
registre.adresse = dec2hex(bits2entier(bits(9:32)), 6);  % adresse OACI
me = bits(33:88);                                        % donnees ADS-B, 56 bits
registre.type = bits2entier(me(1:5));                    % FTC

if registre.type >= 1 && registre.type <= 4              % identification
    registre.nom = decoder_nom(me(9:56));
elseif registre.type >= 9 && registre.type <= 18         % position en vol
    registre.altitude = decoder_altitude(me(9:20));
    registre.timeFlag = me(21);
    registre.cprFlag = me(22);
    LAT = bits2entier(me(23:39));
    LON = bits2entier(me(40:56));
    [registre.longitude, registre.latitude] = cpr2LatLon(LAT, LON, registre.cprFlag, refLat, refLon);
end
end

function nom = decoder_nom(bits_nom)
% 8 caracteres de 6 bits (annexe D) : 1 a 26 pour A a Z, 48 a 57 pour 0 a 9, 32 pour l'espace
nom = blanks(8);
for k = 1:8
    code = bits2entier(bits_nom(6*k-5 : 6*k));
    if code >= 1 && code <= 26
        nom(k) = char('A' + code - 1);
    elseif code >= 48 && code <= 57
        nom(k) = char('0' + code - 48);
    end
end
nom = strtrim(nom);
end

function altitude = decoder_altitude(bits_alt)
% 12 bits dont le 8e n'est pas utilise (annexe C) ; altitude en pieds
bits_alt(8) = [];
altitude = 25 * bits2entier(bits_alt) - 1000;
end
