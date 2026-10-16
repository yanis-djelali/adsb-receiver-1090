# Historique des versions

## v2 (révision personnelle après le projet)

Ajouts et corrections faits après le rendu. Aucun ne vient du cadre école.

### Tâches de l'objectif initial terminées

- **CPR autonome** : `cpr2LatLon`, `cprNL` et `cprMod` écrits d'après les équations 2 à 8 de l'annexe C. La version école appelait les corrigés compilés (`.p`) fournis par l'encadrement. Vérifié sur une trame publique de référence : 52,2572° N, 3,9194° E.
- **Tâche 1.6** : la courbe théorique Pb = Q(√(Eb/N0)) est superposée à la simulation et chaque point continue jusqu'à 100 erreurs, comme le demande le sujet.
- **Tâche 2** : l'expression analytique de la DSP est superposée à l'estimation de Welch, comme le demande la vérification du sujet. La comparaison avec la fonction de Welch fournie par l'école est retirée.

### Corrections

- **Tâche 1.6** : la décision lisait le filtre adapté à Ts/4 et 3Ts/4. Avec `conv(..., 'same')`, ces instants ne correspondent pas aux deux moitiés du symbole : le TEB restait proche de 0,3 même à 10 dB. Les instants corrects sont la fin de chaque demi-symbole, (k-1)Fse + Fse/2 et kFse, comme dans le script sans bruit de la tâche 1.
- **Tâche 2** : la forme d'onde valait ±1 au lieu de ±0,5, ce qui plaçait la DSP 6 dB au-dessus de la théorie. Le signal est maintenant produit par la même modulation PPM que les autres tâches.
- **Tâche 4** : le préambule était un créneau simplifié et les données une forme biphase. Le script utilise maintenant le préambule ADS-B réel (4 impulsions) et le signal PPM, et la synchronisation est dans une fonction dédiée, comme le conseille le sujet.
- **Tâche 6** : le script testait `isempty(registre)`, toujours faux car `bit2registre` renvoie une structure. Une trame au CRC invalide n'était donc jamais signalée. Le test porte maintenant sur `registre.adresse`.
- **Tâche 8** : la position de référence de la carte (44,84 ; -0,70) différait de celle du décodage CPR (44,806884 ; -0,606957). `bit2registre` reçoit désormais la référence en argument, comme dans le prototype du sujet.
- **CRC** : `crc.detector` et `crc.generator`, imposés par le sujet, ont été retirés de MATLAB en R2023b (la version école affichait déjà un avertissement d'obsolescence à chaque trame). Le CRC est maintenant calculé par division polynomiale modulo 2 dans `crc_reste`. `bi2de`, déconseillé depuis R2021b, est remplacé par `bits2entier`. Seule la Signal Processing Toolbox reste nécessaire.
- **Tâche 4** : la boucle de corrélation s'arrêtait une fenêtre trop tôt (`length(y)-Np` au lieu de `length(y)-Np+1`).

### Qualité

- Structure `src/phy`, `src/mac`, `src/app`, `scripts`, `tests`. Fonctions courtes, une seule implémentation de la modulation PPM, du préambule et de la démodulation.
- `process_buffer`, `mettre_a_jour_avions`, `tracer_avions` et `resumer_avions` extraits du script de la tâche 8, algorithme inchangé.
- Messages de débogage de `bit2registre` retirés.
- `setup.m` (chemins et boîtes à outils), `demo.m`, `tests/run_tests.m`.
- Données et fichiers de l'école exclus du dépôt.

## v1-ecole

Code rendu pendant le projet, en binôme avec Thomas Ferreira, conservé sans modification dans le dossier `original/`.
