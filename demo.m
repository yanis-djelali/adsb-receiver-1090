% DEMO  Lance les tests, les simulations des taches 1 a 4, puis les taches 6 et 8
%       si data/adsb_msgs.mat et data/buffers.mat sont presents. Figures : docs/figures.
setup;
run_tests;
simulations = {'tache1_signaux', 'tache1_teb', 'tache2_dsp', 'tache3_crc', 'tache4_synchro'};
for k = 1:numel(simulations)
    executer(simulations{k});
end
if exist('adsb_msgs.mat', 'file')
    executer('tache6_trajectoire');
end
if exist('buffers.mat', 'file')
    executer('tache8_buffers');
end

function executer(nom)
% chaque script tourne dans l'espace de travail de cette fonction (ils commencent par clear)
fprintf('\n===== %s =====\n', nom);
run(nom);
end
