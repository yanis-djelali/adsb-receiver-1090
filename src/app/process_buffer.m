function [registres, correlation] = process_buffer(buffer, refLon, refLat, seuil, Fse)
% PROCESS_BUFFER  Detecte et decode les trames ADS-B d'un buffer complexe.
%   Correlation du module avec le preambule centre, detection des pics au-dessus de seuil
%   (correlation normalisee par son maximum), demodulation PPM, puis bit2registre.
%   Fse : echantillons par microseconde (4 pour Fe = 4 MHz).
%   registres : tableau des registres dont le CRC est valide.
module = abs(buffer(:));
sp = preambule_adsb(Fse);
Np = numel(sp);
Nd = 112 * Fse;

noyau = fliplr(sp - mean(sp));           % preambule centre : un niveau constant ne correle pas
correlation = conv(module, noyau(:), 'valid');
correlation = correlation / max(abs(correlation));
[~, debuts] = findpeaks(correlation, 'MinPeakHeight', seuil, 'MinPeakDistance', 100*Fse);

registres = [];
for k = 1:numel(debuts)
    premier = debuts(k) + Np;            % premier echantillon des donnees
    if premier + Nd - 1 > numel(module)
        continue
    end
    bits = demodulation_ppm(module(premier : premier+Nd-1), Fse);
    registre = bit2registre(bits, refLon, refLat);
    if ~isempty(registre.adresse)
        registres = [registres, registre]; %#ok<AGROW>
    end
end
end
