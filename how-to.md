# Notions prérequises

## Les slugs
Un slug est une sorte d'identifiant pour une resource (une console ou un jeu par exemple) constitué uniquement de caractères minuscules non accentués et de tirets.
Les slugs sont notamment utilisés dans les URLs et pour associer des images à des resources.

Par exemple, le slug de la GameCube est `gc`, donc :
- l'url pour afficher la gamecube sur le site est `/consoles/gc/`
- l'image du logo de la gamecube est rangée dans `/images/consoles/gc/logo.svg`

Autre exemple, le jeu *The Legend of Zelda: Majora's Mask*. Notez que les deux points et l'apostrophes sont des caractères indésirables pour un slugs, et que les majuscules devront êtres converties en minuscules.
Un bon slug pour ce jeu est donc `the-legend-of-zelda-majora-s-mask`. L'image de sa boîte est alors rangée dans `/images/consoles/n64/games/the-legend-of-zelda-majora-s-mask.webp`.
Notez que le slug de la Nintendo 64 est également utilisé dans ce chemin, comme quoi les slugs sont indispensables pour relier les resources entre elles.

## Les formats d'image
Ce site utilise utilise deux formats d'images : le **svg** (pour les logos des consoles), et le **webp** (pour le reste). Ce sont deux formats qui ont l'avantage d'être très légers donc rapides à charger.
Les logos en `svg` doivent être trouvés directement sur le web et peuvent éventuellement être recoupés via certaines sites gratuits.
Quand aux images trouvées en `jpg` ou `png`, elle peuvent être converties en `webp` à l'aide du script présent dans le dossier `scripts`. 

# Consoles
Les consoles sont définies dans des fichiers html rangés dans `src/_consoles/\<slug\>.html`. Par exemple, la GameCube est définie dans `src/_consoles/gc.html`.

Pour en savoir plus sur les slugs, [lisez la section dédiée](#les-slugs).

Contrairement à ce que laisse penser l'extension, ces fichiers ne contiennent pas de HTML mais uniquement des données au format YAML délimitée par deux `---`.
Par exemple, le contenu du fichier `src/_consoles/gc.html` pourrait ressembler à ceci :
```
---
title: GameCube
full_title: Nintendo GameCube
quantity: 3
---
```
Chaque console comprend les champs suivant :
|Champ|Description|
|-----|-----------|
|title|Titre au plus simple de la console (par exemple GameCube)|
|full_title|Titre complet de la console, avec la marque (par exemple Nintendo GameCube)|
|quantity|Nombre d'exemplaires disponibles|

Chaque console doit également avoir une image de son logo, ainsi qu'une image de la console elle-même. L'image du logo doit être placée dans `src/images/consoles/\<slug\>/logo.svg`,
et celle de la console dans `src/images/consoles/\<slug\>/console.webp`.

# Jeux
Les jeux sont définis dans des fichiers de données au format YAML rangés dans `src/_data/\<slug de la console\>.yml`. Par exemple, les jeux de Nintendo 64 sont définis dans `src/_data/n64.yml`.

Chaque fichier représente une *collection* de jeux, avec les champs suivants :
|Champ|Description|
|-----|-----------|
|version|Version de la liste, **doit être incrémentée à chaque modification de la liste**|
|games|Liste des jeux|

Chaque jeu comprend les champs suivants :
|Champ|Description|
|-----|-----------|
|slug|[Voir les explications sur les slugs](#les-slugs)|
|title|Titre du jeu|
|players|Nombre de joueurs|

**Astuce :** pour générer rapidement un slug à partir d'un titre de jeu, il est possible de lancer la console avec la commande `bin/bridgetown console`, puis d'exécuter :
```
"titre du jeu".parameterize
```
Chaque jeu doit également avoir une image de sa boîte, qui doit être placée dans `src/images/consoles/\<slug de la console\>/games/<slug du jeu>.webp`.

# Resources

## Pour les images des consoles
Wikipedia est tout indiqué. Ne pas hésiter à utiliser google images avec le filtre `site:wikipedia.org`.

## Pour les images des jeux

### Nintendo
https://gamesdb.launchbox-app.com/platforms/games/25-nintendo-64
https://gamesdb.launchbox-app.com/platforms/games/31-nintendo-gamecube

### Playstation
https://psxdatacenter.com/pal_list.html
https://psxdatacenter.com/psx2/pal_list2.html
https://github.com/xlenore/ps2-covers/

