# Consoles

Chaque console comprend les champs suivant :
|Champ|Description|
|-----|-----------|
|title|Titre au plus simple de la console (par exemple GameCube)|
|publisher|L'entreprise ayant vendu la console (par exemple Nintendo)|
|generation|La génération de la console sous forme de chiffre (par exemple 6 pour la GameCube)|
|quantity|Nombre d'exemplaires disponibles|

# Jeux

Chaque jeu comprend les champs suivants :
|Champ|Description|
|-----|-----------|
|title|Titre du jeu|
|players|Nombre de joueurs|
|pegi|PEGI (facultatif)|

# Import du contenu

Les consoles, jeux, événements et photos sont gérés avec [bridgetown-prep](../bridgetown-prep), déclaré dans `config/prep.rb`. Le gem n'est pas publié : il doit être cloné à côté de ce projet. Il crée les ressources (`src/_game_consoles`, `src/_games`, `src/_photo_events`, `src/_photos`) et optimise leurs images dans `src/assets`.

Le dossier source est organisé ainsi :

```
consoles/
├── import.yml                  # collection: game_consoles
└── n64/
    ├── data.yml                # name, publisher, generation, quantity
    ├── images/
    │   ├── image.png           # photo de la console (png, jpg ou webp)
    │   └── logo.svg            # logo (svg ou webp), copié tel quel
    └── games/
        ├── import.yml          # collection: games
        └── 007 GoldenEye/
            ├── data.yml        # title, players
            └── images/
                └── cover.jpg
photos/
├── import.yml                  # collection: photo_events
└── ribérac - jeux m'amuse/
    ├── data.yml                # title
    ├── images/
    │   └── logo.png
    └── photos/                 # seulement s'il y a des photos
        ├── import.yml          # collection: photos
        └── IMG_20241019_155144.jpg
```

Les noms des dossiers sont libres : les slugs (et donc les URLs) découlent du `name` des consoles et du `title` des jeux et événements.

Les jeux d'une console vont dans `src/_games/<console>`, dont le `_defaults.yml` (créé par l'import) indique la console : `game_console: nintendo-64`. De même pour les photos d'un événement, dans `src/_photos/<événement>`. Les `data.yml` n'ont donc pas à indiquer la console ou l'événement.

```sh
bin/bridgetown "prep:import[../retrosmash_src_prep/consoles]"            # importer (DRY_RUN=1 pour simuler)
bin/bridgetown "prep:attach[games,nintendo-64/f-zero-x,~/cover.png]"     # remplacer une image
bin/bridgetown "prep:reslug[games,nintendo-64/f-zero-x]"                 # renommer après un changement de titre
bin/bridgetown "prep:remove[games,nintendo-64/f-zero-x]"                 # supprimer un jeu et ses images
```

Un import refuse d'écraser une ressource existante : pour tout réimporter, supprimer d'abord les ressources et `src/assets`, en gardant `src/_game_consoles/_defaults.yml` et `src/_photo_events/_defaults.yml` (les `_defaults.yml` des sous-dossiers sont recréés par l'import).

# Resources

## Pour les images des consoles
Wikipedia. Ne pas hésiter à utiliser google images avec le filtre `site:wikipedia.org`.

## Pour les images des jeux

### Nintendo
https://gamesdb.launchbox-app.com/platforms/games/25-nintendo-64

https://gamesdb.launchbox-app.com/platforms/games/31-nintendo-gamecube

### Playstation
https://psxdatacenter.com/pal_list.html

https://psxdatacenter.com/psx2/pal_list2.html

https://github.com/xlenore/ps2-covers/

