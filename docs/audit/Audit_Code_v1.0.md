# Audit de code · Nutristack app v0.1.0

**Date** 25 juillet 2026 · **Périmètre** 53 fichiers Swift, 2 paquets, configuration de projet et chaîne d’intégration continue · **Références** PRD v1.0.1, Design System v2.0.1, Plan d’exécution v1.0.1, Prototype v1.0 (maquette verrouillée)

**Méthode** Lecture intégrale du code, extraction automatisée des textes et des styles de la maquette HTML pour comparaison ligne à ligne, recalcul indépendant de toutes les métriques du catalogue, contrôles outillés (équilibre des délimiteurs, longueurs de ligne, ordre des imports, conformité aux règles SwiftLint activées, recherche des chemins de clé invalides, des états globaux muables et des franchissements de frontière de module).

**Verdict** L’architecture est saine et la logique métier exacte. Trois défauts empêchaient toutefois la compilation, une étape d’intégration continue sur cinq était inexécutable, et six écarts de fidélité avec la maquette subsistaient. Vingt-sept constats ont été relevés ; vingt-quatre sont corrigés dans cette passe, trois relèvent d’un arbitrage documentaire décrit au §7. Fait notable : l’audit a également mis au jour trois erreurs dans la maquette verrouillée elle-même, dont une erreur arithmétique d’un facteur dix.

---

## 1. Défauts bloquants de compilation

Ces trois constats interdisaient la construction du projet. Aucun n’était détectable sans lecture attentive, faute de compilateur Swift dans l’environnement de rédaction.

### 1.1 Chemins de clé vers des composantes de tuple · critique

`TodayStore` exposait ses sections sous forme de tableau de tuples, consommé par `ForEach(store.slots, id: \.slot)` et `slots.flatMap(\.items)`. Swift n’autorise pas les chemins de clé vers les composantes d’un tuple ; le compilateur émet `key path cannot refer to tuple elements`.

Au-delà de l’erreur, un tuple était le mauvais outil : une section d’écran possède une identité, un titre et une heure, c’est-à-dire un type. Corrigé par l’introduction de `TodayStore.DaySection: Identifiable`, qui porte désormais `title` et `time` et rend l’appel `ForEach(store.sections)` naturel.

### 1.2 Initialiseur de couleur non exporté · critique

`ScannerView` construisait ses trois couleurs de fond avec `Color(light:dark:)`, un initialiseur déclaré sans `public` dans le paquet du Design System, donc invisible depuis le module de l’application.

La correction ne consiste pas seulement à exporter l’initialiseur. Le fond du scanner est l’unique exception documentée à la palette (DS §3) : elle devait être **nommée**, pas dispersée en littéraux hexadécimaux dans un écran. `DSColor` porte maintenant `scannerBackdropTop`, `scannerBackdropBottom` et `scannerScanline`, et l’initialiseur hexadécimal est public avec une note restreignant son usage à la définition des tokens.

### 1.3 État global muable sous concurrence stricte · critique

`ScrollOffsetKey.defaultValue` était déclaré `static var`. Avec `SWIFT_STRICT_CONCURRENCY = complete` et les avertissements traités en erreurs, une propriété statique muable est un état global partagé non protégé, donc un échec de compilation. Passé en `static let`.

### 1.4 Construction de magasins isolés depuis un contexte non isolé · majeur

`NutristackApp.init()` initialisait trois magasins marqués `@MainActor` depuis un initialiseur qui ne l’est pas. Le type de l’application porte désormais `@MainActor`, ce qui aligne le contexte et documente l’intention.

---

## 2. Écarts de fidélité avec la maquette

Chaque écart a été établi en extrayant le texte et les styles de la maquette, puis en le confrontant au rendu produit par le code.

### 2.1 Masses décimales tronquées · majeur

`DSFormat.milligrams` n’acceptait qu’un entier, et la fiche produit arrondissait avant l’appel. La vitamine B6 d’Alba, déclarée à 1,4 mg dans la maquette, s’affichait donc **« 1 mg »** : une composition faussée sur l’écran le plus scruté du produit, alors que le calcul de VNR restait juste à 100 %.

Ajout d’une surcharge `milligrams(_ mg: Double)` qui conserve le dixième quand il porte du sens et retombe sur l’entier sinon. Quatre sites d’appel corrigés, comportement verrouillé par test.

### 2.2 Nom de marque non abrégé · mineur

La maquette écrit « Alba » dans le verdict du comparateur et sur la fiche de résultat du scanner, « Alba Nutrition » dans les listes. Le code n’avait qu’un seul champ et produisait « Alba Nutrition conserve l’avantage ». Ajout de `Brand.shortName`, qui vaut le nom complet par défaut : une marque sans abréviation ne demande aucune donnée supplémentaire.

### 2.3 Décompte d’avis entre parenthèses · mineur

La cellule de note du comparateur affichait `★ 4,3 (41)` là où la maquette écrit `★ 4,3` puis « 41 avis » en seconde ligne. La règle du DS §10 exige un décompte lisible, non une abréviation entre parenthèses. Cellule réécrite en deux niveaux.

### 2.4 Étoile de note en glyphe de texte · mineur

Sur la fiche produit et dans le résultat du scanner, l’étoile était le caractère `★` intégré à une chaîne, héritant donc de la couleur du texte secondaire. La maquette la colore en vert d’action, et VoiceOver annonce « étoile noire » pour ce glyphe. Remplacée par le symbole `star.fill` en couleur d’accent, avec libellé d’accessibilité explicite.

### 2.5 Date d’en-tête figée · majeur

`TodayView` affichait la chaîne littérale « Vendredi 25 juillet ». Deux problèmes : la valeur ne dérivait d’aucune donnée, contredisant le principe affiché dans le README, et **le 25 juillet 2026 est un samedi**. L’en-tête est maintenant dérivée du jour de référence du magasin par `DSFormat.weekdayDayMonth`.

### 2.6 Jauge de stock de la whey · voir arbitrage §7.3

---

## 3. Cohérence avec les fondations du PRD

### 3.1 Classement de prix mêlant des actifs différents · majeur

`ExploreView` triait la section « Meilleur prix par actif » sur l’ensemble des résultats. En catégorie « Tous », elle comparait donc un gramme de protéines de lactosérum à un gramme de magnésium et affichait la whey en tête à 0,032 €/g. C’est précisément ce que le PRD §6.1 interdit : la normalisation n’a de sens qu’à actif identique, et la maquette le respecte en annonçant « Magnésium » en métadonnée.

La section retient désormais l’actif le mieux représenté parmi les résultats, classe ses produits par prix au gramme croissant, annonce le nom de l’actif, et disparaît quand aucun actif n’a au moins deux produits, plutôt que d’afficher un palmarès trompeur.

### 3.2 Comparaison vers un produit sans rapport · majeur

Le bouton « Comparer » de la fiche produit ouvrait invariablement le comparateur contre le magnésium citrate de Nordika, y compris depuis une fiche de whey ou de créatine : un tableau opposant des protéines à du magnésium. Le bouton cherche maintenant, via le dépôt de catalogue, l’alternative la moins chère au gramme portant le **même actif principal**, et se désactive s’il n’en existe aucune.

### 3.3 Recherche ne tenant pas sa promesse · mineur

Le champ annonçait « Produit, marque, ingrédient… » mais le dépôt ne cherchait que dans le nom et la marque. La recherche couvre désormais les composés déclarés et les actifs.

### 3.4 Départages d’égalité implicites · mineur

La section « Les mieux notés » prenait les deux premiers d’un tri par note. La créatine et la whey partageant 4,4 et 4,6, le résultat dépendait de l’ordre du catalogue et divergeait de la maquette. Départage explicite par nombre d’avis vérifiés. De même, le choix de l’élément « À surveiller » repose maintenant sur un tri stable, et `TodayStore` expose `lowStockCount` pour signaler qu’un second produit est concerné au lieu de le taire.

### 3.5 Seuil de stock dupliqué · mineur

Le seuil des dix jours vivait dans le corps de `RestockForecast.isLow` sans être nommé. Il est désormais exposé comme `RestockForecast.lowStockThresholdDays`, ce qui permet aux écrans et aux tests de s’y référer sans le réécrire.

---

## 4. Accessibilité

### 4.1 Polices échappant à Dynamic Type · critique

**Trente-six appels** à `Font.custom(DSFontFamily.name, size:)` sans paramètre `relativeTo:` parsemaient l’application et le paquet du Design System. Cette forme produit une taille **fixe** : les textes concernés ignoraient purement et simplement les réglages de taille du système, alors que les prévisualisations AX1 du paquet donnaient l’illusion inverse en ne couvrant que les composants correctement stylés.

Deux corrections complémentaires. `DSFont.scaled(_:_:relativeTo:)` a été ajouté au Design System comme unique porte d’entrée vers une taille non encore nommée dans `DSTextStyle`, avec interdiction documentée d’appeler `Font.custom` directement. Les trente-six sites d’appel ont été convertis. Contrôle final : plus aucune police non dimensionnable dans le projet.

### 4.2 Cibles tactiles sous le minimum · majeur

Les boutons d’icône de l’en-tête d’écran et de fermeture du scanner mesuraient 38 pt, en deçà des 44 pt requis. Le disque visible reste à 38 pt, conformément à la maquette, mais la zone tactile est étendue à 44 pt par `frame(minWidth:minHeight:)` et `contentShape`.

### 4.3 Arrière-plan atteignable sous un recouvrement · majeur

Fiche produit, comparateur et scanner se superposent aux onglets dans une pile, sans retirer le contenu inférieur de l’arbre d’accessibilité : VoiceOver pouvait atteindre la barre d’onglets derrière un écran plein. Ajout de `accessibilityHidden` conditionnel sur le contenu d’onglet et du trait `isModal` sur les recouvrements.

### 4.4 Tableau du comparateur aux grandes tailles · mineur

La colonne des libellés était fixée à 116 pt, largeur intenable à partir d’AX1 sur un tableau à trois colonnes. Elle se réduit désormais à 92 pt aux tailles d’accessibilité, avec `minimumScaleFactor` de secours.

### 4.5 Absence de prévisualisations d’écran · majeur

Le paquet du Design System comptait 45 prévisualisations, l’application **zéro** : aucun écran ne pouvait être inspecté en mode sombre ou en taille AX1 sans lancer le simulateur, ce qui explique que les deux constats précédents soient passés inaperçus. Vingt-une prévisualisations ajoutées, à raison de trois par écran (clair, sombre, AX1).

---

## 5. Qualité de code et duplications

| Constat | Détail | Correction |
|---|---|---|
| Formateur de date dupliqué | `DateFormatter` en `fr_FR` recréé dans deux écrans | `DSFormat.dayMonth` et `weekdayDayMonth`, formateurs uniques |
| Jauge de stock dupliquée | Composant de 4 pt réécrit à l’identique dans deux écrans, hors du Design System | Type `StockGauge` partagé, à verser au DS au prochain amendement |
| Format de prix au gramme dupliqué | `PriceTag` dans l’app doublait la logique de `DSFormat` | Fusionné dans `DSFormat.pricePerGram`, `PriceTag` supprimé |
| Style de pression dupliqué | `RowPressStyle` du DS restait interne, l’app le réimplémentait | `RowPressStyle` exporté, `ScalePressStyle` restreint aux boutons d’icône et documenté comme tel |
| Code mort | `CatalogRepository.allProducts()` jamais appelé | Retiré du protocole |
| Microcopie de prototype | Trois messages contenant « Prototype : » ou « (V1) » atteignables par l’utilisateur | Réécrits dans la voix du produit |
| Identifiants d’une lettre | Neuf occurrences (`a`, `b`, `c`, `p`, `x`), en infraction avec `identifier_name: min_length: 2` | Renommés en `lhs`/`rhs` et en noms explicites |
| Ordre des imports | `DSTypography.swift` violait la règle `sorted_imports` activée | Réordonné |
| Ligne trop longue | 141 caractères dans une prévisualisation, au-delà du seuil de 120 | Reformatée |

Les quatre dernières lignes méritent un mot : `swiftlint --strict` transforme tout avertissement en erreur, et la configuration livrée était **plus stricte que le code qu’elle gardait**. L’étape de lint aurait échoué au premier passage.

---

## 6. Configuration, construction et intégration continue

### 6.1 Étape de test inexécutable · majeur

La chaîne d’intégration continue lançait `xcodebuild test -scheme NutristackDesignSystem`. XcodeGen ne génère pas de schéma pour les paquets locaux : ce schéma n’existe pas dans le projet produit, et l’étape aurait échoué. Or la porte du jalon M1 exige une chaîne verte.

Le paquet du Design System était par ailleurs déclaré pour iOS seul, ce qui interdisait `swift test`. Il est désormais multiplateforme (iOS 17 et macOS 14) : ses gardes `canImport(UIKit)` étaient déjà en place, et ses tests ne portent que sur des règles. Les deux paquets se testent maintenant par `swift test` sur l’hôte, plus rapidement et sans dépendre d’un schéma.

### 6.2 Info.plist généré dans un dossier de sources · mineur

Le fichier était généré dans `App/Resources`, dossier déclaré comme source de la cible : il risquait d’être copié une seconde fois comme ressource du bundle. Déplacé sous `Config/` et ajouté au fichier d’exclusion Git, puisqu’il s’agit d’un artefact généré.

### 6.3 Point de vigilance conservé

`onPreferenceChange` dans `PushScaffold` mute un état isolé sur l’acteur principal. Sous le SDK d’Xcode 15 visé, la fermeture n’est pas `Sendable` et le code est correct ; les SDK ultérieurs ont annoté cette interface et exigeront un ajustement. Consigné plutôt que corrigé à l’aveugle, la cible actuelle étant explicite dans `project.yml`.

---

## 7. Arbitrages en attente : trois erreurs dans la maquette verrouillée

La gouvernance du Design System (§0) fait de la maquette la référence. L’audit a pourtant établi que trois de ses valeurs sont fausses. Le code applique la version juste et attend l’amendement formel du document.

### 7.1 Erreur arithmétique sur le prix au gramme de Boreal

La maquette affiche **0,058 €/g d’EPA+DHA**. Le produit coûte 25,20 € et apporte 720 mg par dose sur 60 doses, soit 43,2 g d’actif : le prix réel est **0,58 €/g**, dix fois plus. La maquette se trompe d’un facteur dix sur la métrique fondatrice du produit.

Aggravant : le test du domaine verrouillait bien la valeur exacte de 58 centimes, mais son commentaire annonçait « 0,058 €/g ». Un commentaire faux à côté d’une assertion juste est plus dangereux qu’une absence de commentaire, puisqu’il autorise le lecteur suivant à « corriger » le calcul. Commentaire rectifié et écart documenté dans le test.

### 7.2 Jour de la semaine

La maquette écrit « Vendredi 25 juillet » ; le 25 juillet 2026 est un samedi, et la date de référence est cohérente par ailleurs, puisque le rachat calculé au neuvième jour tombe bien le 3 août. C’est le jour de la semaine qui est faux. Le code le dérive maintenant de la date.

### 7.3 Jauge de stock de la whey

La maquette montre la jauge de la whey en vert, à 34 % de stock. Or 34 % de 25 doses font 8,5 doses, soit neuf jours, en dessous du seuil d’alerte de dix jours qui fait passer la créatine en ambre. Les deux produits devraient donc être en ambre.

Le code applique la règle du domaine et signale la whey. Trois issues possibles : amender la maquette, ou fonder l’alerte sur la fraction de stock restante plutôt que sur les jours, ou introduire un seuil dépendant du format du contenant. La règle en jours étant la seule qui reflète l’usage réel, je recommande l’amendement de la maquette, mais la décision appartient au produit.

### 7.4 Ordre de la section « Meilleur prix par actif »

La maquette place Alba (1,11 €/g) avant Nordika (0,66 €/g) sous un titre qui promet le meilleur prix. Le code classe par prix croissant. Point à trancher, sans conséquence sur la logique.

---

## 8. Ce qui a résisté à l’audit

Le recalcul indépendant de toutes les métriques confirme le moteur : coûts journaliers de 33, 17, 20, 84 et 42 centimes, prix au gramme de 110,55 et 66,22 centimes pour les deux magnésiums, écart de 40 % sur les valeurs exactes, fractions élémentaires de 12,5 % pour le bisglycinate et 15,5 % pour le citrate, VNR de 80 % et 100 %, agrégats de stack à 1,79 €, 53,70 € et 644 €, rachat au neuvième jour le 3 août. Aucune valeur fausse.

L’ordre des sept lignes du comparateur et la position des six cellules gagnantes correspondent exactement à la maquette, y compris le choix contestable mais assumé de désigner un vainqueur sur le prix absolu. La séparation des modules est respectée : le paquet de domaine ne dépend d’aucune interface, ce qui permet ses tests sur l’hôte, et l’unique duplication qui subsiste, le formatage d’une note en français dans le verdict, est le prix explicitement documenté de cette indépendance. La navigation par recouvrements, le double moteur de scanner et le rendu d’image du partage sont corrects.

Le jeu de tests du domaine a été porté de six à onze cas, avec verrouillage de l’ordre des lignes, du vainqueur calculé sur les valeurs exactes, du nom court de marque, du seuil de stock centralisé et de la cohérence de toutes les prévisions de rachat. Le paquet du Design System gagne trois cas sur les nouveaux formats.

---

## 9. Recommandations pour la suite

**Avant la fusion.** Ouvrir le projet dans Xcode et compiler : l’audit est statique, et seul le compilateur peut confirmer l’absence de résidus. Vérifier le rendu des trois prévisualisations de chaque écran, en particulier en AX1 sur le comparateur et sur les tuiles à deux colonnes, dont le comportement aux très grandes tailles n’est pas garanti par la seule conversion des polices.

**Amendements documentaires.** Trancher les quatre points du §7, puis publier un Design System v2.0.2 et un Prototype v1.1 corrigés. Y verser au passage `StockGauge` et `DaysLeftChip`, composants réels qui vivent aujourd’hui dans le code applicatif sans exister dans le document, ce qui contrevient à la procédure du §0.

**Dette assumée.** L’ajout d’un produit à la stack reste un état local de la fiche, non partagé avec les autres écrans : c’est cohérent avec l’absence de persistance au jalon M1, mais à traiter dès l’arrivée de GRDB. Aucun test d’instantané n’existe encore, et la couverture du domaine n’est pas mesurée alors que le Plan §4 fixe un seuil de 85 % : à outiller au jalon M2. Enfin, les tailles de police nommées dans `DSTextStyle` ne couvrent pas encore toutes celles employées par les écrans, d’où le recours à `DSFont.scaled` ; l’absorption progressive de ces tailles dans des styles nommés réduira la surface d’improvisation.
