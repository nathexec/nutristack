# Icône d’application · Nutristack v1.1

**Statut** proposée, en attente de versement au Design System · **Livrée le** 25 juillet 2026
**Sources** `docs/icon/` · **Export en production** `App/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`

---

## 1. Le parti pris

L’icône est la jauge d’actif, répétée trois fois.

C’est l’élément signature déclaré au Design System §1 et §7 : une piste hachurée à 45° qui représente le composé déclaré, et un remplissage plein qui représente la part d’actif élémentaire réellement apportée. Le même dessin porte ici trois sens à la fois :

- **la signature visuelle du produit**, celle que l’on retrouve sur chaque fiche ;
- **le nom**, puisque trois jauges empilées sont littéralement une *stack* ;
- **l’argument fondateur**, puisque la surface hachurée est exactement ce que l’étiquette pèse sans le délivrer.

Aucune gélule, aucune feuille, aucun monogramme. La catégorie est saturée de ces trois motifs, et le Design System interdit par ailleurs l’illustration décorative. Le risque assumé est celui d’une icône faite uniquement de l’instrument de mesure du produit : elle ne dit pas *ce qu’on vend*, elle dit *comment on juge*.

## 2. Les trois fractions sont vraies

De haut en bas, les remplissages reprennent les fractions élémentaires du catalogue :

| Bande | Fraction | Produit correspondant |
|---|---|---|
| Haute | 12,5 % | bisglycinate de magnésium, 300 mg d’actif pour 2 400 mg de composé |
| Milieu | 60 % | oméga-3 en triglycérides, 720 mg d’EPA et DHA pour 1 200 mg d’huile |
| Basse | 100 % | créatine monohydrate, rien de perdu |

La bande basse n’a donc aucune hachure visible : c’est le seul des trois composés qui ne gaspille rien, et l’icône le montre au lieu de le dire. L’ordre croissant vers le bas donne au groupe une assise stable et se lit comme une progression.

## 3. Géométrie

Canevas de 1024 points, dessin vectoriel, aucune transparence.

| Grandeur | Valeur | Raison |
|---|---|---|
| Largeur de piste | 672 | 65,6 % du canevas |
| Marges latérales | 176 | 17,2 %, respiration volontairement large |
| Hauteur de bande | 84 | rapport de **8 pour 1** avec la piste |
| Intervalle | 100 | supérieur à la bande, pour aérer le groupe |
| Hauteur totale du dessin | 452 | 44,1 % du canevas |
| Marge haute | 278 | 27,1 %, centrage optique huit points au-dessus du centre géométrique |
| Rayon | 42 | capsule pleine, comme la jauge du Design System |
| Hachures | 45°, pas de 26, épaisseur 5 | trame gravée, continue d’une bande à l’autre |

Le rapport de 8 pour 1 n’est pas arbitraire : il fait qu’une fraction de 12,5 % vaut exactement la hauteur de la bande, si bien que la bande haute se dessine en **disque parfait** plutôt qu’en losange écrasé. La contrainte de dessin et la donnée du produit tombent juste au même endroit.

## 4. La matière, en trois dispositifs

Le premier jet était un aplat. Cette version cherche la profondeur, sans effet ni skeuomorphisme, par trois moyens purement vectoriels.

**Une source de lumière.** Le fond combine un dégradé linéaire légèrement incliné et une lueur radiale décentrée en haut à gauche. Mesuré sur l’export : luminance de 97 dans le coin haut gauche contre 85 dans le coin haut droit et 42 dans le coin bas droit. L’objet est éclairé, pas dégradé.

**Une rainure, pas un aplat.** Chaque piste reçoit un ombrage de creux, sombre sur son bord haut et clair sur son bord bas. Mesuré : la piste est plus claire que le fond de 27 points en son milieu mais de 7 points seulement sur son bord supérieur, ce qui la fait lire comme une gorge creusée dans la surface et non comme un rectangle posé dessus.

**Une ombre douce sous chaque remplissage.** Les capsules blanches portent une ombre obtenue en empilant huit capsules de plus en plus larges et de plus en plus pâles. Mesuré : assombrissement de 10 à 13 points juste sous chaque barre. Les rasteriseurs légers, cairosvg par exemple, ignorent les filtres SVG ; cette technique reste du dessin vectoriel pur et rend donc identiquement partout.

S’y ajoute un dégradé imperceptible sur le remplissage lui-même, de 254 à 243 de luminance du haut vers le bas, qui suffit à lui ôter l’aspect autocollant.

## 5. Couleurs

| Rôle | Valeur | Origine |
|---|---|---|
| Fond, haut | `#1E7360` | éclaircissement du vert officinal |
| Fond, milieu | `#175947` | **token `DSColor.accent`** |
| Fond, bas | `#0A342B` | assombrissement profond du vert officinal |
| Lueur | blanc à 7,5 %, radiale décentrée | |
| Remplissage | `#FFFFFF` vers `#EEF4F1` | |
| Piste | blanc à 13 % | |
| Hachures | blanc à 7,5 % | |
| Creux de rainure | `#03201A` à 16 % en haut, blanc à 8 % en bas | |
| Ombre | `#04211B` à 5 % par couche, huit couches | |

Les deux teintes extrêmes du fond sont des variations du token d’accent et **doivent être versées au Design System par amendement** (procédure §0) avant tout autre usage : ce sont aujourd’hui les seules couleurs du produit qui ne figurent pas dans la palette.

## 6. Contrôle de lisibilité

`docs/icon/Nutristack_AppIcon_apercu.png` présente l’icône masquée en superellipse, à toutes les tailles d’usage réelles, sur fond clair et sur fond sombre : 1024 pour l’App Store, 180 pour l’écran d’accueil, 120 pour Spotlight, 80 pour les réglages, 60 et 40 pour les notifications.

Le registre le plus exigeant a été mesuré plutôt que jugé à l'œil. Réduite à 40 points, l’image contient exactement trois bandes claires distinctes, hautes de trois pixels et séparées de quatre, larges respectivement de 3, 16 et 26 pixels. La progression reste donc lisible à la plus petite taille d’usage, même si les hachures y disparaissent : à ce format, l’icône se lit comme un graphique et non comme une jauge, ce qui est la limite acceptée du dessin.

## 7. Variantes livrées, non encore actives

`docs/icon/` contient également une variante sombre, fond presque noir et jauges en `#4EB08C`, le vert d’accent du mode sombre, et une variante monochrome pour le mode teinté d’iOS 18.

Elles ne sont **pas** déclarées dans le catalogue d’assets : les emplacements d’apparence claire, sombre et teintée exigent Xcode 16, alors que le projet cible Xcode 15 comme l’indique `project.yml`. Le catalogue ne contient donc qu’une image universelle de 1024, format valide et suffisant. Les variantes sont prêtes pour le jour où la chaîne de construction montera de version.

## 8. Régénérer

`docs/icon/build_icon.py` produit l’ensemble depuis les paramètres des §3 à §5 : les trois SVG maîtres, les trois exports de 1024 et la planche de contrôle. Le script rasterise le SVG plutôt que de redessiner en bitmap, ce qui garantit que la source vectorielle et le fichier livré ne peuvent pas diverger. Il aplatit ensuite le canal alpha, l’App Store refusant la transparence.

Les fichiers sont écrits sur place, dans `docs/icon/`. Seul l’export clair de
1024 n’y est pas versionné : sa copie de production vit dans le catalogue
d’assets (chemin en en-tête) et le doublon est ignoré par `.gitignore`.

```bash
pip install cairosvg pillow numpy
python3 docs/icon/build_icon.py
```

## 9. Reste à faire

L’icône n’a pas été vue sur un appareil ni sur une fiche App Store réelle. Trois vérifications avant la soumission : le rendu sur écran physique, où un vert profond se comporte différemment selon la calibration ; la cohabitation avec les icônes voisines sur un écran d’accueil chargé, seul test valable de la présence d’une icône ; et un regard humain sur la planche de contrôle, la dernière itération ayant été validée par mesure de luminance plutôt qu’à l'œil.

## 10. Registre des versions

| Version | Changement |
|---|---|
| 1.0 | Premier dessin : piste de 768, marges de 12,5 %, aplats et dégradé de fond simple |
| **1.1** | **Marges portées à 17,2 %, emprise réduite à 65,6 % par 44,1 % ; ajout des trois dispositifs de matière du §4 ; hachures affinées de 7 à 5 d’épaisseur** |
