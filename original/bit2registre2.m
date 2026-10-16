function registre = bit2registre2(bits)
% BIT2REGISTRE - Décode une trame ADS-B (112 bits)
% Utilise les fonctions CPR officielles : cpr2LatLon, cprNL, cprMod.

    % --- Initialisation
    registre = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                      'altitude', [], 'timeFlag', [], 'cprFlag', [], ...
                      'latitude', [], 'longitude', []);
    
    % --- Vérification taille
    bits = bits(:).';
    if length(bits) ~= 112
        return;
    end
    
    % --- Vérification CRC
    poly_crc = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
    det = crc.detector(poly_crc);
    [~, erreur_detectee] = detect(det, bits');
    if erreur_detectee
        registre = [];
        return;
    end

    % --- Extraction des champs
    DF = bi2de(bits(1:5), 'left-msb');
    AA = bi2de(bits(9:32), 'left-msb');
    ME = bits(33:88);

    registre.format  = DF;
    registre.adresse = dec2hex(AA, 6);

    FTC = bi2de(ME(1:5), 'left-msb');
    registre.type = FTC;

    % ==============================================================
    % 1) IDENTIFICATION (FTC = 1–4)
    % ==============================================================
    if FTC >= 1 && FTC <= 4
        chars_bits = ME(9:56);
        chars = reshape(chars_bits, 6, 8).';
        charset = '#ABCDEFGHIJKLMNOPQRSTUVWXYZ##### ###############0123456789######';

        nom = '';
        for i = 1:8
            idx = bi2de(chars(i,:), 'left-msb');
            if idx <= 63
                c = charset(idx + 1);
                if c ~= '#'
                    nom = [nom c];
                end
            end
        end
        registre.nom = strtrim(nom);

    % ==============================================================
    % 2) POSITION EN VOL (FTC = 9–18)
    % ==============================================================
    elseif FTC >= 9 && FTC <= 18
        % --- Altitude (11 bits utiles, ignorer le 8e)
        alt_bits = ME(9:20);
        alt_bits(8) = [];  % suppression bit inutilisé
        registre.altitude = 25 * bi2de(alt_bits, 'left-msb') - 1000;

        % --- Flags CPR
        registre.timeFlag = ME(21);
        registre.cprFlag  = ME(22);

        % --- Champs CPR
        LAT = bi2de(ME(23:39), 'left-msb');
        LON = bi2de(ME(40:56), 'left-msb');

        % --- Décodage CPR local autour du récepteur
        refLat = 44.806884;  % position de l’école
        refLon = -0.606957;

        [lon, lat] = cpr2LatLon(LAT, LON, registre.cprFlag, refLat, refLon);

        registre.latitude  = lat;
        registre.longitude = lon;
    end
end
