# Journal des versions · Nutristack (app)

## 0.3.7 · 6 août 2026 · la documentation est rangée et son nommage unifié

Aucune modification de code Swift.

**Publication du compte rendu d’audit.** Le bilan consolidé des deux vagues
d’audit multi-agents est livré : 17 points ouverts dont 3 majeurs, 79 points
sains, 42 constats écartés avec motifs, 12 clos. Désormais dans
`docs/audit/Compte_Rendu_Audit_v1.0.md`.

**Rangement de `docs/`.** Les huit documents en vrac rejoignent quatre dossiers
thématiques — `audit/`, `baseline/`, `icon/`, `validation/`, en anglais et en
minuscules comme les autres dossiers du dépôt — sur le modèle du dossier
d’icône. Un index `docs/README.md` énonce la convention de nommage ;
le suffixe redondant `_Nutristack` disparaît de trois noms de fichiers
(`Audit_Code`, `Icone`, `Validation_Xcode`) qui l’avaient quand cinq autres ne
l’avaient pas. Toutes les références croisées — README, journal, chaîne
d’intégration, protocole, documents entre eux — sont mises à jour.

**Deux défauts réels corrigés dans l’outillage d’icône.** `build_icon.py`
écrivait dans `/home/claude/icon/out`, chemin absolu de la machine où il a été
écrit : la commande de régénération documentée ne pouvait donc pas reproduire
les assets dans le dépôt (sur macOS, `/home` n’est même pas inscriptible). Il
écrit désormais à côté de lui, sur place. Et il produit
`Nutristack_AppIcon_default.svg` là où le dépôt suivait `Nutristack_AppIcon.svg`
sans suffixe : une régénération aurait créé un doublon en orphelinant le fichier
suivi. Le nom versionné est aligné sur la sortie du script. Accessoirement, la
commande d’installation documentée ne citait que `cairosvg` alors que le script
importe aussi `pillow` et `numpy` ; l’export clair de 1024, dont la copie de
production vit dans le catalogue d’assets, est explicitement ignoré par
`.gitignore`.

## 0.3.6 · 6 août 2026 · le chemin d’installation documenté ne bloque plus la validation

**Défaut principal.** `scripts/bootstrap.sh`, `docs/validation/Protocole_Validation_Finale_v1.0.md`
et `docs/validation/Validation_Xcode_v1.0.md` prescrivaient tous trois
`brew install xcodegen`. Le dépôt documente pourtant ailleurs — `README.md`,
`.github/actions/toolchain/action.yml` — que Homebrew pose la version courante,
et qu’à partir de 2.44.0 XcodeGen écrit un `objectVersion` (70, puis 77) que
Xcode 15.4 refuse d’ouvrir. Sur un poste neuf, suivre le protocole faisait donc
échouer son étape 2, et avec elle les étapes 9 à 22, celles qui restent à
exécuter à la main. Le script contrôle désormais `xcodegen --version` avant de
générer et affiche la procédure d’installation exacte ; les deux documents
nomment les versions épinglées au lieu de renvoyer à Homebrew.

**Contradictions de documentation levées.** Le README du design system
affirmait que les polices ne sont pas versionnées : les cinq graisses le sont
depuis la version 0.3.2. Il disait ses tests dépendants d’un simulateur iOS et
le paquet limité à iOS, alors que `Package.swift` déclare `.macOS(.v14)`
précisément pour que `swift test` tourne sur hôte, comme en CI. Il tolérait
enfin « Xcode 15 ou plus récent », là où le projet exclut Xcode 16.

**Décomptes.** L’entrée 0.3.1 annonçait 22 membres annotés `@MainActor` ; le
diff de la PR #2 en compte 23 — `ExploreView.openDefaultComparison` porte son
annotation sur une ligne séparée et avait échappé au comptage.

**Version du bundle.** `CFBundleShortVersionString` valait `0.1.0` alors que ce
journal en est à 0.3.x ; l’app se serait présentée aux testeurs sous un numéro
ne désignant aucune version livrée.

**Aucun fichier Swift modifié.** La baseline `4a70bdd80a03d359d3395ddc5aa8e34d`
est intacte.

## 0.3.5 · 3 août 2026 · noms d’étapes et garde-fous du workflow

**Nommage.** Les étapes suivent désormais une seule forme : un verbe à
l’infinitif suivi de son complément. Trois défauts sont levés. Les numéros du
protocole apparaissaient dans le désordre — « Contrôler le style » est l’étape 8
et s’exécute avant les étapes 4 et 5, parce qu’il échoue en 3 secondes là où un
build en prend 24 : la liste se lisait comme un bug alors que l’ordre est
délibéré. La correspondance passe dans l’en-tête du fichier, donnée une fois.
Les décomptes figés disparaissent : « Tests du domaine, 20 tests » affirmait un
chiffre qu’aucune étape ne vérifiait et qui serait devenu faux en silence au
premier test ajouté ; le compte réel est dans le rapport xUnit. Les formes
grammaticales sont unifiées, la liste mêlant infinitifs et groupes nominaux
(« Build Debug », « Lint strict »).

**Aucun changement de comportement.** Commandes, actions et arguments sont
identiques au caractère près, vérifié par comparaison des lignes `run:` et
`uses:` avant et après. `id: tests-domaine` est préservé, la condition de
publication de l’artefact s’y référant.

**Deux garde-fous ajoutés.** `permissions: contents: read` applique le moindre
privilège au jeton du workflow, qui ne fait que lire. `concurrency` annule une
exécution de pull request rendue obsolète par une poussée ultérieure, mais
jamais sur `main` : une exécution sur `main` est un enregistrement.

**Le fichier n’est pas renommé.** Une entrée de l’onglet Actions est identifiée
par le chemin du workflow ; le renommer créerait une entrée neuve et laisserait
l’ancienne en fantôme avec ses exécutions — exactement le résidu purgé à
l’entrée 0.3.3. Le nom affiché passe en revanche de « Build et tests
Nutristack » à « Intégration continue », et le job de la clé `build-and-test`
au libellé « Vérification complète » ; ni protection de branche ni ruleset ne
référençait l’ancien nom, vérifié avant la bascule.

## 0.3.4 · 3 août 2026 · réarmement de l’intégration continue

Le workflow retiré à l’entrée précédente est restauré **à l’identique** depuis
`946ee34`, sans une ligne d’écart : c’est la version dont les 17 étapes ont été
mesurées vertes. En réécrire une neuve aurait rouvert un risque déjà fermé.
README §Qualité reprend son état d’origine, la CI existant de nouveau.

L’onglet Actions repart de zéro. Les 42 exécutions purgées ne reviennent pas :
l’historique visible commence à la première exécution de ce commit. Le code
Swift est inchangé depuis `946ee34` — seuls `.github/`, `README.md` et ce
journal ont bougé — de sorte qu’une exécution verte ici rétablit la preuve
perdue à l’entrée 0.3.3 sur exactement la même baseline, par mesure et non par
récupération.

## 0.3.3 · 3 août 2026 · retrait de l’intégration continue

**Décision du mainteneur, prise en connaissance des conséquences.** Le workflow
`.github/workflows/build-and-test.yml` est supprimé et les 42 exécutions
enregistrées sur GitHub Actions sont effacées : les 23 de « Build et tests
Nutristack », les 13 de l’ancienne « CI » dont le fichier avait déjà disparu, et
les 6 des deux entrées créées par Copilot sur la PR #1. Une entrée de workflow
ne peut pas être supprimée directement — elle ne quitte l’onglet Actions qu’une
fois son dernier run effacé — d’où la purge complète.

**Ce que le dépôt perd.** Plus aucune vérification automatique sur les pull
requests : ni génération du projet, ni lint strict, ni build Debug ou Release,
ni exécution des 34 tests. La porte M1 « zéro avertissement » n’est plus tenue
que par la discipline de qui pousse le code.

**Preuve perdue.** Le run `30464623275` attestait sur `946ee34` — le commit que
porte la balise `v0.3.2` — build Debug et Release au vert, 0 avertissement,
`swiftlint --strict` 0 violation sur 55 fichiers, 34 tests sans échec. Il est
effacé avec les autres. Le message de la balise et l’entrée 0.3.2 ci-dessous
continuent d’énoncer ces chiffres ; plus aucun journal ne les corrobore. Ils
restent rejouables à la main par la séquence donnée au README §Qualité.

**Récupération.** Le fichier du workflow est restaurable depuis l’historique
git : `git show 946ee34:.github/workflows/build-and-test.yml`. Les runs, non :
la suppression est définitive côté GitHub. `.github/actions/toolchain` est
conservé pour son raisonnement sur les versions épinglées, bien qu’il n’ait
plus d’appelant.

## 0.3.2 · 29 juillet 2026 · première compilation réelle sur macOS

Première exécution du protocole sur un vrai toolchain iOS (runner macOS 14,
Xcode 15.4). Elle a montré que **rien ne compilait** : 49 erreurs bloquantes, et
une chaîne d’intégration qui échouait avant même d’y arriver. Les deux sont
corrigées ; la baseline est refigée en v1.1
(`docs/baseline/Baseline_Gel_v1.0.md` : 58 fichiers inchangés en nombre, 10 modifiés,
empreinte globale `4a70bdd80a03d359d3395ddc5aa8e34d`).

**Concurrence stricte, 49 erreurs, une seule cause (PR #2).** Le protocole
`View` impose `@MainActor` à `body`, mais **cette isolation ne se propage à
aucun autre membre** : une `private var` ou une `private func` voisine reste un
membre ordinaire d’une `struct` non isolée, et ne peut donc pas lire `AppRouter`,
`TodayStore` ni `StackStore`. 23 membres étaient dans ce cas, sur 8 fichiers
(`TodayView`, `StackScreen`, `ScannerView`, `ProductDetailView`, `NutriTabBar`,
`ExploreView`, `RootView`, `ProfileView`). Correctif : l’annotation `@MainActor`
explicite, exactement la convention que la baseline appliquait déjà à
`ScannerView.startScanning`, `ProductDetailView.load` et `ExploreView.reload` —
ces 23 membres avaient simplement été omis. Risque de régression nul : ce code
s’exécutait déjà sur le fil principal, l’annotation décrit l’existant.
Deux erreurs restantes, distinctes : `ScannerEngineFactory.demonstrationCode`
passe `nonisolated`, une valeur par défaut d’argument étant évaluée chez
l’appelant et non dans l’acteur ; `CameraScannerEngine` importe AVFoundation en
`@preconcurrency`, `nonisolated(unsafe)` ne couvrant pas la capture dans les
fermetures `@Sendable` implicites de `DispatchQueue.async`.

**Rectification d’un décompte.** Le brief de correction annonçait deux erreurs.
Il y en avait 49, découvertes en trois vagues, le compilateur ne rapportant les
suivantes qu’une fois les précédentes levées.

**Chaîne d’intégration, huit défauts (PR #3), aucun fichier Swift touché.**
XcodeGen s’installait en dernière version et produisait un projet au format 77,
que Xcode 15.4 refuse (`exit code 74`) : épinglé à **2.43.0**, seule version
mesurée lisible (`objectVersion 54`). L’étape « 34 tests » ne pouvait pas
fonctionner, `project.yml` ne déclarant aucune cible de test
(`Scheme Nutristack is not currently configured for the test action`, exit 66) :
les deux suites passent par `swift test` sur les paquets, avec `--parallel`, sans
quoi SwiftPM 5.10 n’écrit jamais le rapport `--xunit-output`. L’artefact de
rapport n’avait donc jamais existé, l’absence de fichier n’étant qu’un
avertissement : `if-no-files-found: error` ferme la porte. Le workflow ne
tournait que sur `push: main` et ne protégeait aucune revue : `pull_request`
ajouté. Destination de simulateur épinglée à `OS=17.5`, faute de quoi xcodebuild
retenait un runtime arbitraire. `ci.yml` supprimé, il rejouait le lint, la
génération et la compilation déjà faits ailleurs. SwiftLint épinglé à 0.57.0,
Xcode sélectionné explicitement, `timeout-minutes` posé sur le job, versions
d’outils regroupées dans une action composite.

**Cohérence du dépôt.** Trois affirmations fausses du README corrigées : il
annonçait une concurrence stricte `complete` là où `Config/Base.xcconfig` dit
`targeted` — et se contredisait lui-même une section plus bas —, renvoyait à
`.github/workflows/ci.yml` qui n’existe plus, et décrivait des tests de design
system « sur simulateur » alors qu’ils tournent par `swift test` sur l’hôte. Le
prérequis Xcode est précisé, 15.x et non « 15 ou plus récent », le projet
excluant délibérément Xcode 16. **Sept fichiers de police retirés** : le dossier
en comptait douze, italiques et graisse Black comprises, quand le code n’emploie
que cinq graisses et que `DSFontRegistrar` enregistre indistinctement tout
`.ttf` du dossier — 719 Ko embarqués dans le binaire sans qu’aucun style ne les
demande, et une porte ouverte à l’italique que le DS §4 proscrit. L’étape 1 du
protocole exige « les 5 noms exacts, rien d’autre » : elle est désormais PASS.

**Statut des tests, désormais sans réserve : 34/34 exécutés, 0 échec** (20
domaine, 9 formats, 5 composants). Build Debug et Release verts, zéro
avertissement compilateur (ils sont traités en erreurs), `swiftlint --strict`
à `0 violations, 0 serious in 55 files`. La réserve « 29/34 » des versions
0.3.0 et 0.3.1 est close.

## 0.3.1 · 26 juillet 2026 · gel du code
Aucune modification de code. Baseline figée par empreinte
(`docs/baseline/Baseline_Gel_v1.0.md` : 58 fichiers, empreinte globale md5, grille de
contrôle obligatoire avant tout changement) et publication du protocole de
validation finale (`docs/validation/Protocole_Validation_Finale_v1.0.md` : 22 étapes,
chacune avec procédure, attendu, critères PASS et FAIL, définition de la
régression et action corrective). Statut contractuel des tests : 29/34
exécutés réellement et PASS, 5/34 BLOCKED jusqu’à l’exécution des tests de
composants dans Xcode (étape 6 du protocole).

## 0.3.0 · 26 juillet 2026 · validation réelle
Premier toolchain Swift réel de la vie du projet (6.0.3, hôte Linux). Exécuté :
résolution SPM des deux paquets, build Debug et Release du domaine (0
avertissement), **20/20 tests XCTest du domaine**, **9/9 tests de formats** via
harnais à source identique, **SwiftLint strict**. Deux FAIL réels trouvés et
corrigés : une explosion d’inférence de types dans `RestockAlert.forecasts`
(compilation impossible, réécrite en boucle explicite, module vérifié en 7 s)
et 43 violations de lint (31 : exclusion `.build` manquante en configuration ;
12 réelles : liaisons d’une lettre, fermetures de `PushScaffold` étiquetées,
`for…where`, `HexColor.RGB` au lieu d’un tuple, `DSShadow.offsetY`, une
désactivation justifiée sur `layerClass`). Tous les tests relancés verts après
chaque correctif. Les cinq arbitrages sont tranchés et publiés : Prototype
v1.1, PRD v1.0.2 (53,70 € canonique), Design System v2.0.2.

## 0.2.4 · 26 juillet 2026 · fermeture des réserves
Les 7 correctifs de l’audit final revérifiés un à un dans le code livré, plus
un 8ᵉ trouvé par cette passe : un `await` superflu dans le partage, qui aurait
fait échouer le build (avertissements en erreurs). Test ajouté sur le format de
provenance « 12 juil. 2026 » (34 cas). Rectification d’un décompte : 7
corrections et 2 consignations, non 8 et 1. Livrable :
`docs/validation/Validation_Xcode_v1.0.md`, registre des 5 arbitrages avec
recommandations (dont 53,70 € canonique de fait, amendement PRD proposé),
correspondance des 34 tests aux exigences, 7 risques de compilation classés,
liste exacte des 5 polices, checklist Xcode en 22 étapes avec critères
PASS/FAIL, conclusion stricte en 5 volets.

## 0.2.3 · 25 juillet 2026 · audit final (protocole 16 phases)
Neuf anomalies trouvées et huit corrigées, dont : le toast effaçait un second
message à peine affiché (annulation avalée), le tooltip du badge citait les
chiffres du relecteur au lieu de la règle du PRD §7.6, l’état vide
d’Aujourd’hui manquait, le vainqueur du comparateur n’était signalé que par
la couleur, un code-barres inconnu déclenchait un toast par image caméra, la
cascade et les masses décimales du comparateur. Matrice de traçabilité PRD →
code → tests établie, 39 assertions recalculées hors Swift. Rapport complet :
`docs/audit/Audit_Final_Production_v1.0.md`. Verdict : prêt sous réserve, la réserve
première restant la compilation, impossible dans cet environnement.

## 0.2.2 · 25 juillet 2026 · homogénéité et coût de calcul

Passe consacrée à deux angles non encore mesurés : la cohérence du vocabulaire
et des conventions d’écriture, et le coût des dérivations.

**Vocabulaire monétaire unifié.** `StackCosts` et `StackStore` disaient
`dailyCents` là où les modèles disaient `dailyCostCents`. Toute grandeur porte
désormais `Cost` puis son unité : `dailyCostCents`, `monthlyCostCents`,
`yearlyCostEuros`. La tuile de la fiche suit la même règle avec
`pricePerActiveGramCents`.

**Conventions d’écriture alignées.** Un repère `// MARK: -` isolé parmi
trente-cinq `// MARK:`, et trois prévisualisations nommées « Simulé · clair »
parmi soixante-six nommées « Clair », « Sombre » et « AX1 ».

**Identité des lignes explicitée.** `IngredientDeclaration` et
`FieldProvenance` deviennent `Identifiable`, avec pour identifiant le nom du
composé et le nom du champ. Les `ForEach` correspondants abandonnent
`id: \.self`, qui reposait sur l’égalité de toutes les valeurs. La progression
segmentée itère sur un tableau plutôt que sur une plage variable, que `ForEach`
suppose constante.

**Égalité des routes ramenée à l’identifiant.** `AppRouter.PushRoute`
comparait des `Product` entiers, donc leurs ingrédients, provenances et
conditionnements, à chaque évaluation d’animation. Deux routes désignant le
même écran sont la même route : `==` et `hash` reposent sur `id`.

**Dérivations de la journée remises à plat.** `allItems` découlait de
`sections`, et cinq compteurs découlaient de `allItems` : un seul rendu
reconstruisait le regroupement par créneau une demi-douzaine de fois. Le sens
est inversé, `sections` découle de `allItems`, et tous les compteurs partent de
la même projection. Le gain de temps est négligeable à cette échelle ; le gain
de lisibilité ne l’est pas.

**Trois séparateurs de liste** recalculaient la dernière identité de la
collection à chaque rangée ; elle est désormais évaluée une fois.

**Sept types gagnent leur commentaire de documentation.** Plus aucune
déclaration de type du projet n’est muette.

**Mesures rectifiées.** Ma première mesure des tokens inemployés était fausse
d’un cran et accusait quatre couleurs et six espacements à tort. Après
correction, seuls `DSColor.danger` et `DSSpacing.s4` ne servent nulle part, et
tous deux relèvent du vocabulaire déclaré du Design System. Les quinze
composants sont employés par l’application.

## 0.2.1 · 25 juillet 2026 · passe de propreté

Relecture du code écrit lors de l’ajout de la stack partagée, avec deux
vérificateurs statiques nouveaux : détection des types référencés mais jamais
déclarés, et détection des collisions entre nom de propriété et nom de méthode.

**Collision de noms corrigée.** `DemoCatalog` déclarait une propriété privée
`reviews` et une méthode publique `reviews(for:)`, la seconde lisant la
première. Swift l’accepte, le lecteur non : la propriété devient `allReviews`.

**Invariant du produit vérifié à la construction.** `defaultVariant` lisait
`variants[0]` sans garantie. L’initialiseur refuse désormais un produit sans
conditionnement, avec un message qui explique pourquoi.

**Plus aucun optionnel implicitement déballé.** Les deux moteurs de scanner
reliaient leur flux et sa continuation par un `Continuation!` transitoire ;
`AsyncStream.makeStream()`, disponible depuis iOS 17, les fournit d’un seul
tenant. Il ne reste qu’une conversion forcée, celle du calque d’aperçu vidéo,
sûre par construction et signalée comme telle.

**Le dépôt de catalogue passe par l’environnement.** Trois écrans nommaient
`DemoCatalogRepository`. Ils lisent maintenant `\.catalogRepository` : le type
concret n’apparaît plus qu’une fois dans tout le projet, ce qui réduit le
branchement de GRDB et Supabase à une ligne.

**Les avis passent par le dépôt** au lieu d’être lus dans le catalogue de
démonstration depuis la fiche, et un état de chargement distinct de l’absence
évite d’afficher « aucun avis » pendant la requête. Le squelette du Design
System, jusqu’ici inutilisé dans l’application, y trouve son emploi.

**Le nom abrégé d’un produit** était calculé à l’identique dans deux écrans ;
il devient une extension unique de la couche applicative.

**43 assertions de test recalculées** hors de Swift, à partir des seules données
brutes, pour vérifier que les valeurs attendues restent exactes après
l’introduction des conditionnements.

## 0.2.0 · 25 juillet 2026 · derniers points avant verrouillage

**Icône d’application.** La jauge d’actif empilée trois fois, ses remplissages
reprenant les fractions élémentaires réelles du catalogue. Source vectorielle,
variantes sombre et teintée, planche de contrôle et script de régénération dans
`docs/icon/` ; parti pris et géométrie dans `docs/icon/Icone_v1.1.md`.

**La stack devient un état partagé.** Nouveau `StackStore`, source de vérité de
la composition, des coûts et des prévisions de rachat. `TodayStore` en dérive au
lieu de posséder sa propre copie. Un ajout depuis la fiche ou le scanner se voit
désormais dans Aujourd’hui et dans Ma stack.

**Le catalogue compte huit produits**, deux par catégorie, si bien que le bouton
« Comparer » a toujours une alternative de même actif à proposer. Les trois
ajouts sont choisis pour être instructifs : deux créatines monohydrate au prix
au gramme différent, des oméga-3 en esters éthyliques face aux triglycérides, et
une whey concentrée face à un isolat. Les classements d’Explorer et le contenu
de la maquette restent inchangés.

**Trois commandes décoratives deviennent réelles.** Les conditionnements sont
désormais un type du domaine qui porte le prix et le nombre de doses : changer
de pastille recalcule le prix par jour et le prix par gramme d’actif. Le filtre
des avis s’appuie sur la règle d’usage vérifié et non sur un drapeau posé à la
main. Le bouton d’avis supplémentaires déplie réellement la liste.

**Les classements quittent les vues.** `CatalogRanking` porte le choix de
l’actif à mettre en avant, le palmarès des mieux notés et la recherche
d’alternative comparable. Ces règles sont maintenant testées ; le départage à
égalité de représentation se fait sur l’écart de prix, c’est-à-dire sur
l’intérêt réel de la comparaison.

**Tri des rachats rendu déterministe.** `sorted` n’étant pas stable en Swift,
deux produits qui s’épuisent le même jour pouvaient permuter d’un appel à
l’autre ; le rang d’origine sert désormais de second critère.

## 0.1.2 · 25 juillet 2026 · audit de verrouillage
Second audit avant gel de la v1.0 (voir `docs/audit/Audit_Verrouillage_v1.0.md`).

**Compilation.** Une erreur résiduelle de la passe précédente corrigée : le test
d’analyse hexadécimale utilisait encore les anciennes étiquettes de tuple
`.r`/`.g`/`.b` après leur renommage en `.red`/`.green`/`.blue`.

**Modélisation.** Les dates quittent le format chaîne : `Product.labelVerifiedOn`
devient une `Date`, et `FieldProvenance` porte désormais une source et une date
distinctes plus une méthode d’ancienneté, au lieu d’un libellé pré-composé.
`DSFormat.shortDate` assure la mise en forme unique.

**Concurrence.** Les corps de `.task` sont remplacés par des méthodes isolées
explicitement sur l’acteur principal. Le réglage de concurrence stricte est
ramené à `targeted` sur la cible applicative, décision et échéance consignées
dans `Config/Base.xcconfig`.

**Documentation.** Sémantique des champs des modèles documentée au fil du code,
conventions de projet consignées dans le README, dette connue explicitée.

## 0.1.1 · 25 juillet 2026 · suite de l’audit interne
Correctifs issus de l’audit en profondeur (voir `docs/audit/Audit_Code_v1.0.md`) :

**Compilation.** Trois défauts bloquants levés : initialiseur de couleur du
Design System rendu public via des tokens nommés pour le scanner, chemins de clé
vers des composantes de tuple remplacés par un type `DaySection` identifiable,
propriété statique muable de la clé de préférence passée en constante.

**Fidélité à la maquette.** Masses décimales préservées (vitamine B6 « 1,4 mg »
et non « 1 mg »), nom court de marque dans le verdict et le résultat du scanner
(« Alba »), décompte d’avis en clair dans le comparateur (« 41 avis »), étoile de
note en symbole accent sur la fiche et le scanner, date d’en-tête dérivée du jour
de référence au lieu d’un libellé figé.

**Cohérence produit.** La section « Meilleur prix par actif » se restreint à un
actif unique, conformément à la règle fondatrice ; le bouton « Comparer » propose
une alternative de même actif au lieu d’un produit codé en dur ; les départages
d’égalité sont explicites et stables.

**Accessibilité.** Toutes les polices suivent Dynamic Type (36 appels convertis),
cibles tactiles portées à 44 pt, arrière-plan retiré de l’arbre d’accessibilité
sous recouvrement, colonne de libellés du comparateur adaptative.

**Qualité.** Seuil de stock bas et formateurs de date centralisés, jauge de stock
factorisée, `PriceTag` fusionné dans `DSFormat`, code mort supprimé, 21
prévisualisations ajoutées aux écrans, chaîne d’intégration continue rendue
exécutable, `Info.plist` sorti des dossiers de sources.

## 0.1.0 · 25 juillet 2026
Jalon M1 : application complète au pixel sur la maquette v1.0.
Sept écrans, navigation par recouvrements conforme au DS §9, paquet de
domaine testé (métriques, comparateur, rachat, vérification), scanner à
double moteur (caméra AVFoundation, simulé), partage d’image rendue,
CI et configurations de qualité.
