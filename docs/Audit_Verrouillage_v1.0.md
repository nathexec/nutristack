# Audit de verrouillage · Nutristack app v0.1.2

**Date** 25 juillet 2026 · **Objet** dernière revue avant gel de la v1.0 · **Portée** 53 fichiers Swift, 5 022 lignes, 2 paquets, configuration de projet et intégration continue

---

## 1. La question de la compilation, sans détour

**Je ne peux pas certifier que le projet compile, et personne ne peut le faire depuis cet environnement.** Il n’existe ici aucun toolchain Swift : la commande est absente, le paquet système du même nom désigne un autre logiciel, et le miroir officiel des toolchains est hors de la liste des domaines autorisés, ce qui a été vérifié plutôt que supposé. Même avec un compilateur Linux, le SDK iOS et SwiftUI n’existent que sur macOS ; seul le paquet de domaine, purement Foundation, serait compilable.

Une revue statique ne remplace pas un compilateur. Elle attrape en revanche des classes d’erreurs précises, à condition de les chercher méthodiquement plutôt que de relire au fil du texte. J’ai donc écrit trois vérificateurs pour cette passe :

- **visibilité inter-modules** : tout symbole des paquets utilisé par l’application est-il déclaré `public` ? C’est l’erreur qui avait échappé à la relecture initiale, avec un initialiseur de couleur non exporté ;
- **cohérence des membres** : chaque accès `objet.membre` correspond-il à une déclaration réelle du projet, une fois écartées les API du système ?
- **complétude des prévisualisations** : chaque `#Preview` injecte-t-il toutes les dépendances d’environnement de la vue qu’il affiche ? Une prévisualisation incomplète plante à l’ouverture, puisque l’accès à un environnement non optionnel est forcé.

Le second vérificateur a trouvé une **erreur de compilation certaine**, décrite au §2. Les trois passent désormais sans signalement.

---

## 2. Erreur de compilation trouvée et corrigée

Lors de l’audit précédent, j’avais renommé les étiquettes du tuple retourné par `HexColor.parse` de `(r, g, b)` vers `(red, green, blue)`, pour satisfaire la règle de longueur minimale des identifiants. Le test `ComponentRuleTests.testHexParsing` continuait d’écrire `c.r`, `c.g`, `c.b` : trois références à des étiquettes qui n’existaient plus.

C’est un rappel utile sur la nature d’un refactoring de renommage : il ne se termine pas au dernier site de production. Le test est corrigé, et j’y ai ajouté un cas de bord, une chaîne vide, qui retombe sur le noir sans planter.

---

## 3. Modélisation : deux dates stockées comme du texte

Le contrôle de documentation a mis en évidence un défaut plus profond que son symptôme.

`Product.labelVerifiedOn` était déclaré `String` et contenait `"12 juil. 2026"`. `FieldProvenance.detail` était une `String` contenant `"Étiquette · 12 juil. 2026"`, c’est-à-dire une source, un séparateur et une date agglomérés dans un modèle de domaine.

Trois conséquences, dans l’ordre de gravité :

1. **La fraîcheur d’une donnée devient incalculable.** Le PRD §8.3 fonde la confiance sur la provenance et sa date ; avec une chaîne, aucune règle de type « signaler un prix relevé il y a plus de trente jours » n’est écrivable sans réanalyser du texte.
2. **La présentation fuit dans le domaine.** Le format, la langue et l’abréviation du mois sont figés dans les données, alors que le projet a précisément centralisé toute mise en forme dans `DSFormat`.
3. **Aucun tri ni comparaison** n’est possible entre deux relevés.

Corrigé : `labelVerifiedOn` est une `Date` ; `FieldProvenance` porte une `source`, une `date` optionnelle, la mention en attente n’ayant pas de date, et une méthode `ageInDays(from:)` qui rend la fraîcheur calculable. Le catalogue de démonstration construit ses dates par une fabrique interne. `DSFormat.shortDate` produit le libellé abrégé avec année, et la feuille de provenance compose « source · date » à l’affichage. Un test verrouille l’ensemble, y compris l’ancienneté de treize jours de l’étiquette d’Alba au jour de référence et l’absence de date pour la donnée en attente.

---

## 4. Concurrence : une décision plutôt qu’un pari

Le projet activait `SWIFT_STRICT_CONCURRENCY = complete` avec les avertissements traités en erreurs. Sous le SDK iOS 17, ce réglage produit des diagnostics sur du code de vue parfaitement idiomatique, parce que SwiftUI n’y est pas encore entièrement annotée pour l’isolation d’acteur. Les corps de `.task` en sont l’exemple typique : la fermeture est `Sendable` et non isolée, si bien que tout accès à un état de vue ou à un objet isolé demande un franchissement explicite.

Il y avait deux façons de traiter le sujet. Deviner quelles annotations satisfont un compilateur que je ne peux pas exécuter, au risque d’un échec de construction difficile à diagnostiquer. Ou prendre la décision documentée qui est aussi la trajectoire recommandée d’adoption de la concurrence Swift.

J’ai choisi la seconde, en deux mouvements :

**Le code exprime son isolation.** Les corps de `.task` sont remplacés par des appels à des méthodes marquées `@MainActor` : `startScanning`, `stopScanning`, `handle`, `reload`, `loadAlternative`, `revealSequence`. Le point de bascule vers l’acteur principal devient visible dans la signature au lieu d’être implicite dans une fermeture, ce qui est meilleur quel que soit le réglage du compilateur.

**Le réglage descend d’un cran sur la seule couche concernée.** `SWIFT_STRICT_CONCURRENCY` vaut `targeted` pour la cible applicative, avec le raisonnement et l’échéance inscrits dans `Config/Base.xcconfig` : passage au mode langage Swift 6 avec l’adoption du SDK iOS 18. Les deux paquets de logique ne sont pas concernés ; ils ne contiennent que des types valeur `Sendable` et aucun état global muable, ce qui a été vérifié.

C’est un assouplissement réel et je le signale comme tel plutôt que de le taire. Il reste que « complete » sur du code SwiftUI compilé avec un SDK qui n’est pas encore annoté relève de la posture plus que de la sûreté.

---

## 5. Résultats des contrôles outillés

| Contrôle | Résultat |
|---|---|
| Délimiteurs équilibrés, 53 fichiers | 0 déséquilibre |
| Lignes de plus de 120 caractères | 0 |
| Polices sans `relativeTo:` | 0 |
| Chemins de clé vers un composant de tuple | 0 |
| Propriétés statiques muables | 0 |
| Déclarations privées inutilisées | 0 |
| Symboles de paquet non exportés mais utilisés | 0 |
| Prévisualisations aux dépendances incomplètes | 0 |
| Ordre des imports | conforme |
| Apostrophes droites, cadratins | 0 |
| Chaînes de prototype ou marqueurs `TODO` | 0 |
| Désactivations de règle de lint | 1, ciblée sur une ligne et justifiée |

L’unique désactivation restante encadre la conversion forcée de `layer` vers `AVCaptureVideoPreviewLayer` dans l’aperçu caméra. Elle est sûre par construction, puisque la classe redéfinit `layerClass`, et c’est le motif que documente Apple ; la contourner demanderait de gérer la géométrie du calque à la main, pour un gain nul.

---

## 6. Recalcul indépendant du métier

Toutes les métriques ont été recalculées hors du code Swift, à partir des seules données brutes du catalogue, et confrontées aux valeurs de la maquette.

| Produit | Coût / jour | Prix / g d’actif | Fraction élémentaire | VNR |
|---|---|---|---|---|
| Alba, bisglycinate | 33 c | 1,106 € | 12,5 % | 80 % |
| Nordika, citrate | 17 c | 0,662 € | 15,5 % | 67 % |
| Halterra, créatine | 20 c | 0,040 € | 100 % | · |
| Halterra, whey | 84 c | 0,032 € | 88 % | · |
| Boreal, oméga-3 | 42 c | 0,583 € | 60 % | · |

Écart Alba contre Nordika : 40 %. Agrégats de la stack : 1,79 € par jour, 53,70 € par mois, 644 € par an. Rachat de la créatine au neuvième jour, soit le 3 août. Vitamine B6 à 1,4 mg pour 100 % des VNR. Tout concorde avec le code et avec les tests, qui comptent maintenant vingt-cinq cas.

Les trois erreurs de la maquette relevées au premier audit sont confirmées par ce recalcul et restent en attente d’amendement documentaire : le prix au gramme de Boreal y est écrit dix fois trop faible, le 25 juillet 2026 est un samedi et non un vendredi, et la jauge de stock de la whey devrait être ambre puisqu’il ne reste que 8,5 doses.

---

## 7. Architecture : ce qui tient, et la seule réserve

**Ce qui tient.** La séparation en trois couches est nette et vérifiée par la construction elle-même : le paquet de domaine ne dépend d’aucune interface, ce qui permet ses tests sur l’hôte ; le paquet du Design System ne connaît rien du métier ; l’application ne contient aucun calcul de métrique. Le dépôt de catalogue est derrière un protocole, si bien que l’arrivée de GRDB et de Supabase au jalon M3 ne touchera aucun écran. Les magasins observables portent l’état, les vues n’en dérivent que de l’affichage. Chaque grandeur a exactement un format, dans un seul fichier.

**La réserve.** `DemoCatalog` réside dans le paquet de domaine, donc dans le binaire de production, avec ses cinq marques fictives. C’est cohérent au jalon M1, où les écrans en tirent tout leur contenu, mais avant toute mise en production il faut le déplacer dans une cible distincte du même paquet, exposée comme un produit séparé. L’application déclarerait alors deux dépendances, et à la suppression du jeu de démonstration le compilateur signalerait chaque dépendance résiduelle au lieu de la laisser passer silencieusement. Je n’applique pas ce changement ici : il modifie le graphe de construction, la seule chose que je ne peux pas valider. La recommandation est consignée dans le README avec le nom du produit à créer.

---

## 8. Ce qu’il reste à faire avant de verrouiller

Par ordre de priorité, et sans lequel « v1.0 verrouillée » n’aurait pas de sens :

1. **Compiler.** Ouvrir le projet dans Xcode après `./scripts/bootstrap.sh`, construire la cible et lancer `swift test` sur les deux paquets. Attendez-vous à quelques ajustements : un audit statique réduit la probabilité d’erreur, il ne l’annule pas. Les points les plus susceptibles de demander une retouche sont l’isolation d’acteur des vues et les macros de prévisualisation.
2. **Déposer les cinq graisses de Schibsted Grotesk.** Sans elles, le rendu n’est pas contractuel, et rien ne le signale à l’exécution hormis `DSFontFamily.isAvailable`.
3. **Vérifier les soixante-six prévisualisations**, en particulier les vingt-et-une des écrans en taille AX1 : le comparateur à trois colonnes et les grilles de tuiles à deux colonnes sont les deux endroits où la conversion des polices ne garantit pas à elle seule une mise en page tenable.
4. **Trancher les quatre points documentaires** du premier audit, puis publier un Design System v2.0.2 et un Prototype v1.1 corrigés, en y versant au passage `StockGauge` et `DaysLeftChip`, deux composants qui existent dans le code sans figurer dans le document de référence.
5. **Séparer les données de démonstration** avant la première soumission.

Le reste, à savoir la couverture mesurée, les tests d’instantanés et le passage au mode langage Swift 6, appartient aux jalons M2 et suivants et n’a pas à retarder le gel.
