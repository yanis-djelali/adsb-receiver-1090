function registre = bit2registre(bits)
    registre = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                      'altitude', [], 'timeFlag', [], 'cprFlag', [], ...
                      'latitude', [], 'longitude', []);
    bits = bits(:).';
    if numel(bits) ~= 112, return; end
    
    poly = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
    [~, err] = detect(crc.detector(poly), bits');
    if err, return; end
    
    registre.format = bi2de(bits(1:5), 'left-msb');
    registre.adresse = dec2hex(bi2de(bits(9:32),'left-msb'),6);
    data = bits(33:88);
    registre.type = bi2de(data(1:5), 'left-msb');
    
    if registre.type >= 1 && registre.type <= 4
        chars_bits = reshape(data(9:56),6,8).';
        
        % afficher les valeurs
        fprintf('Décodage nom pour FTC=%d:\n', registre.type);
        
        nom = '';
        for i = 1:8
            idx = bi2de(chars_bits(i,:), 'left-msb');
            fprintf('  Char %d: bits=%s, idx=%d', i, num2str(chars_bits(i,:)), idx);
            
            if idx == 32
                c = ' ';
            elseif idx >= 1 && idx <= 26
                c = char('A' - 1 + idx);
            elseif idx >= 48 && idx <= 57
                c = num2str(idx - 48);
            else
                c = ' ';
            end
            fprintf('    "%c"\n', c);
            nom = [nom c];
        end
        registre.nom = strtrim(nom);
        fprintf('Nom final: "%s"\n\n', registre.nom);
        
    elseif registre.type >= 9 && registre.type <= 18
        alt_bits = data(9:20);
        alt_bits(8) = [];
        registre.altitude = 25 * bi2de(alt_bits,'left-msb') - 1000;
        
        registre.timeFlag = data(21);
        registre.cprFlag = data(22);
        
        LAT = bi2de(data(23:39),'left-msb');
        LON = bi2de(data(40:56),'left-msb');
        
        refLat = 44.806884; 
        refLon = -0.606957;
        [lon, lat] = cpr2LatLon(LAT, LON, registre.cprFlag, refLat, refLon);
        registre.latitude = lat;
        registre.longitude = lon;
    end
end