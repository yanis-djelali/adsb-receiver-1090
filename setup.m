% SETUP  Ajoute les dossiers du projet au chemin MATLAB et verifie la boite a outils requise.
%   A lancer une fois depuis la racine du depot.
racine = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(racine, 'src')));
addpath(fullfile(racine, 'scripts'), fullfile(racine, 'tests'), ...
        fullfile(racine, 'data'), fullfile(racine, 'ecole'));

v = ver;
if ~any(strcmp({v.Name}, 'Signal Processing Toolbox'))
    warning('Signal Processing Toolbox manquante : findpeaks est utilise par process_buffer.');
end
