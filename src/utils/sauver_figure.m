function sauver_figure(nom)
% SAUVER_FIGURE  Enregistre la figure courante dans docs/figures/<nom>.png.
racine = fileparts(fileparts(fileparts(mfilename('fullpath'))));
dossier = fullfile(racine, 'docs', 'figures');
if ~exist(dossier, 'dir')
    mkdir(dossier);
end
exportgraphics(gcf, fullfile(dossier, [nom '.png']), 'Resolution', 150);
end
