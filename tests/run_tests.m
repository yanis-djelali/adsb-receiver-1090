function run_tests
% RUN_TESTS  Tests minimaux, sans les donnees de l'ecole.
%   Trames de reference publiques : J. Sun, The 1090 Megahertz Riddle, 2e ed., 2021.
%   Buffer synthetique : 2 avions fictifs (TEST01, TEST02) pres de Bordeaux.
tester('CRC valide puis corrompu', @test_crc);
tester('Trame d''identification', @test_identification);
tester('Altitude et position CPR', @test_position);
tester('Fonction NL', @test_cprNL);
tester('Preambule', @test_preambule);
tester('Chaine complete sur buffer synthetique', @test_buffer_synthetique);
fprintf('Tous les tests passent.\n');
end

function tester(nom, test)
test();
fprintf('[OK] %s\n', nom);
end

function test_crc
bits = hex2bits('8D4840D6202CC371C32CE0576098');
assert(crc_valide(bits));
bits(50) = 1 - bits(50);
assert(~crc_valide(bits));
r = bit2registre(bits);
assert(isempty(r.adresse));
end

function test_identification
r = bit2registre(hex2bits('8D4840D6202CC371C32CE0576098'));
assert(r.format == 17 && r.type == 4);
assert(strcmp(r.adresse, '4840D6') && strcmp(r.nom, 'KLM1023'));
end

function test_position
% trame paire decodee avec une reference proche (52.258 N, 3.918 E)
r = bit2registre(hex2bits('8D40621D58C382D690C8AC2863A7'), 3.918, 52.258);
assert(r.type == 11 && r.altitude == 38000 && r.cprFlag == 0);
assert(abs(r.latitude - 52.25720) < 1e-4 && abs(r.longitude - 3.91937) < 1e-4);
end

function test_cprNL
assert(cprNL(0) == 59 && cprNL(87) == 2 && cprNL(88) == 1);
assert(cprNL(52.2572) == 36 && cprNL(-44.8) == 42);
end

function test_preambule
assert(isequal(find(preambule_adsb(4)), [1 2 5 6 15 16 19 20]));
end

function test_buffer_synthetique
trames = {'8DF00001205054D4C3182014D1AA', '8DF0000158B981EEEFD33335B6E8', ...
          '8DF0000158B9857295D4DA3F1055', '8DF0000158B981F5C3D465638E97', ...
          '8DF0000158B985794BD60404C069', '8DF00002205054D4C328204923C5', ...
          '8DF00002587D81CCCDE51FC906A1', '8DF00002587D854B23E738928B8B', ...
          '8DF00002587D81C7AFE81B875C8A', '8DF00002587D85461BEA2206DC1B'};
amplitudes = [ones(1, 5), 0.4*ones(1, 5)];     % le second avion est plus faible
Fse = 4;
rng(1);
sp = preambule_adsb(Fse);
buffer = zeros(1, 2000*numel(trames) + 4000);
for k = 1:numel(trames)
    s = [sp, modulation_ppm(hex2bits(trames{k}), Fse)];
    debut = 1500 + 2000*(k-1);
    buffer(debut : debut+numel(s)-1) = amplitudes(k) * s * exp(1j*2*pi*rand);
end
buffer = buffer + 0.03*(randn(size(buffer)) + 1j*randn(size(buffer)));

registres = process_buffer(buffer, -0.606957, 44.806884, 0.1, Fse);
avions = mettre_a_jour_avions(containers.Map(), registres);
assert(numel(registres) == 10 && avions.Count == 2);
a = avions('F00001');
assert(strcmp(a.nom, 'TEST01') && all(a.altitudes == 36000));
assert(max(abs(a.positions(1,:) - [44.90 -0.75])) < 1e-4);
b = avions('F00002');
assert(strcmp(b.nom, 'TEST02') && all(b.altitudes == 24000));
assert(max(abs(b.positions(4,:) - [44.655 -0.375])) < 1e-4);
end

function bits = hex2bits(h)
bits = reshape(dec2bin(hex2dec(h(:)), 4).' - '0', 1, []);
end
