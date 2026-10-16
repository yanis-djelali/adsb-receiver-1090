# Projet TS229 : version rendue à l'école

Code MATLAB tel qu'il a été écrit pendant le projet (septembre à octobre 2025), en binôme avec Thomas Ferreira, sans modification.

Ces scripts dépendent de fichiers fournis par l'école et non inclus ici : `adsb_msgs.mat`, `buffers.mat`, `affiche_carte.m`, `fond.png`, et les fonctions compilées `cpr2LatLon_`, `cprNL_`, `cprMod_`, `Mon_Welch_`.

| Fichier | Tâche |
|---|---|
| `tache1.m`, `tache1_6_3.m` | Signaux émis et reçus, TEB en fonction de Eb/N0 |
| `test2_4.m`, `tache2_6.m`, `tache2_7.m`, `Welch.m` | Forme d'onde biphase, densité spectrale de puissance, périodogramme de Welch |
| `tache3_1.m` | Codage et détection CRC 24 bits |
| `tache4_5_6.m`, `tache4_7.m` | Synchronisation temporelle par corrélation, TEB avec synchronisation |
| `bit2registre.m`, `bit2registre2.m`, `test6.m`, `test6_2.m` | Décodage des trames (couche MAC) et trajectoire d'un avion |
| `tache8.m`, `tache8_2.m` | Détection et décodage des trames dans les enregistrements réels, carte des avions |
