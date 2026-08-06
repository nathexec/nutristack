# Compte rendu d'audit complet · Nutristack · 6 août 2026

État arrêté au commit `cbc3418` (branche `main`, arbre propre, étiquette `v0.3.2` sur
`946ee34`, version applicative 0.3.6). Ce rapport agrège les deux vagues de l'audit
multi-agents (4 août et 6 août 2026), les vérifications manuelles faites depuis ce
poste, et l'état réel du dépôt à la date du jour. Chaque affirmation est adossée à un
fichier et une ligne, ou à une commande rejouable.

---

## 1. L'essentiel en un coup d'œil

| Question | Réponse |
|---|---|
| Le dépôt est-il propre ? | **Oui.** `main` seule, arbre propre, 2 exécutions dans l'onglet Actions, aucune branche morte. |
| La CI est-elle verte ? | **Oui.** 17 étapes vertes sur `cbc3418`, 34 tests (20 domaine + 14 design system), 0 échec, 0 violation SwiftLint, 0 avertissement. |
| Le gel du code est-il respecté ? | **Oui.** Les 58 fichiers Swift portent l'empreinte `4a70bdd80a03d359d3395ddc5aa8e34d`, rejouée et exacte. Aucune correction n'a touché un fichier Swift. |
| Combien de défauts restent ouverts ? | **17** : 3 majeurs, 14 mineurs. **Aucun bloquant.** Détail complet en §4. |
| Combien touchent le code Swift gelé ? | **6** : 1 dans un fichier d'app (O-4), 3 dans les fichiers de test (M-3, O-6, O-7), 1 sur le protocole de données (O-5), 1 sur les deux manifestes de paquet (O-13). Les 11 autres se corrigent sans toucher un fichier gelé. |
| Combien de défauts ont déjà été corrigés ? | **12 constats clos** entre les versions 0.3.5 et 0.3.6 (commit `cbc3418` pour l'essentiel). Détail en §6. |
| Combien de constats ont été examinés et écartés ? | **42** (19 en vague 2, 9 du critique de complétude, 14 en vague 1, un même sujet pouvant apparaître deux fois). Chaque rejet est motivé en §5. Un 43ᵉ constat, jugé à la main, a été **retenu** — c'est le point O-4. |
| Qu'est-ce que ce rapport ne peut PAS dire ? | **Que l'application fonctionne.** L'audit est entièrement statique : l'app n'a jamais été compilée ni lancée depuis ce poste Windows. La CI prouve que tout compile et que les 34 tests passent sur macOS ; les étapes 9 à 22 du protocole (simulateur, iPhone, VoiceOver, Instruments) restent à exécuter sur un Mac. |

**En une phrase :** le projet est sain, documenté et vert de bout en bout ; il reste 17
points connus, listés, motivés et corrigeables — dont aucun n'empêche de générer le
projet, de le compiler ni de dérouler le protocole de validation, à une exception près
(la permission photos, qui ferait échouer l'étape du partage d'image sur appareil).

---

## 2. Méthode, et ce qu'elle vaut

**Vague 1 — 4 août 2026.** 193 agents lancés sur six dimensions (documentation, chaîne
d'intégration, configuration, concurrence, tests, avancement) : des chercheurs par
dimension, puis trois sceptiques indépendants par constat, chargés de le *réfuter*.
**65 agents sont morts en cours de route** (limite de session). Conséquence : les
verdicts des dimensions *documentation, chaîne d'intégration, configuration,
concurrence* sont valides ; ceux des dimensions *tests* et *avancement* ne l'étaient
pas (sceptiques morts, constats classés à tort), et le critique de complétude n'a
jamais tourné.

**Vague 2 — 6 août 2026.** Relance ciblée : les 26 constats des dimensions *tests* et
*avancement* re-jugés (77 agents, 3 sceptiques par constat majeur, 2 par mineur,
66 votes sur 66 rendus), puis le critique de complétude, puis la réfutation de ses
trouvailles. Résultat : 7 constats retenus, 19 rejetés, 10 constats de complétude dont
9 réfutés.

**Trois défauts de la méthode, assumés et compensés :**

1. **Un sceptique de vague 2 est mort** (celui du constat « recherche sensible aux
   diacritiques ») et le script de dépouillement comptait un verdict absent comme un
   rejet. Le constat a donc été silencieusement écarté au lieu d'être jugé — le résumé
   final du script affiche d'ailleurs « 0 constat sans verdict », ce qui est la trace
   même du défaut. Je l'ai repris **à la main** : il est **confirmé** (voir §4,
   point O-4).
2. **La dimension « chaîne d'intégration » de vague 1 a jugé une CI qui a changé
   depuis** (reconstruite entre 0.3.3 et 0.3.5). Chacun de ses constats a été
   re-vérifié à la main contre le dépôt à `cbc3418` ce jour ; les statuts de §4 et §6
   reflètent l'état actuel, pas l'état jugé.
3. **C'est moi qui ai écrit les corrections auditées** (commit `cbc3418`). Les
   sceptiques de vague 2 étaient indépendants et informés du commit, précisément pour
   pouvoir rejeter les constats devenus obsolètes — ils l'ont fait pour 4 d'entre eux.

---

## 3. Ce qui va — vérifié, avec preuves

### 3.1 La chaîne de validation complète est verte

- **CI sur `cbc3418`** : workflow « Intégration continue », job « Vérification
  complète », **17 étapes, toutes vertes**. Rapport xUnit téléchargé et parsé :
  `domaine.xml` = 20 tests, 0 échec, 0 erreur ; `design-system.xml` = 14 tests,
  0 échec, 0 erreur. **Total : 34 tests, 0 échec.**
- **Lint** : `swiftlint --strict` sur 55 fichiers : 0 violation.
- **Avertissements** : `SWIFT_TREAT_WARNINGS_AS_ERRORS = YES` — un build vert vaut
  panneau Issues vide.
- **Outillage épinglé et réel** : les archives visées par `.github/actions/toolchain`
  existent bien en ligne (vérifié par requête directe) : `xcodegen.zip` sur la release
  2.43.0 de yonaskolb/XcodeGen, `portable_swiftlint.zip` sur la 0.57.0 de
  realm/SwiftLint. La procédure d'installation documentée n'est pas creuse.
- **Baseline** : l'empreinte globale `4a70bdd80a03d359d3395ddc5aa8e34d`
  (docs/baseline/Baseline_Gel_v1.0.md:43) a été rejouée depuis ce poste : exacte. Les 58
  empreintes par fichier ont été recalculées une à une en vague 1 : les 58 concordent.

### 3.2 Les neuf points sains du protocole (critique de complétude, vague 2)

Le critique de complétude a aussi vérifié ce qui *devait* être vrai pour que les
étapes manuelles 9 à 22 aient une chance de passer. Neuf choses sont prouvées :

1. **Les cinq polices sont présentes et valides** — 100 à 101 Ko chacune, signature
   TrueType en tête, enregistrées depuis `Bundle.module` au démarrage
   (DSTypography.swift:27-41, NutristackApp.swift:19-20). L'étape 1 est acquise.
2. **Les deux jeux de couleurs portent leur variante sombre** — LaunchBackground
   (blanc / #0D0F10) et AccentColor (#175947 / #4EB08C). Le « flash blanc au
   lancement » (critère de FAIL de l'étape 21) et l'accent sombre exigé par l'étape 16
   sont couverts par construction.
3. **Le décompte des prévisualisations est exact** — 22 « Clair », 22 « Sombre »,
   22 « AX1 », précisément les nombres des étapes 15 et 16.
4. **Toutes les valeurs chiffrées des étapes 9 et 10 recalculées à la main tombent
   juste** — 0,33 et 0,40 €/j et 1,11 et 1,32 €/g pour Alba, 0,66 €/g Nordika, −40 %,
   0,58 €/g Boreal, stock créatine 9 jours donc rachat au 3 août, provenance 12 juil. /
   21 juil., 2 avis vérifiés sur 3, 6 cellules gagnantes sur 7.
5. **« Meilleur prix par actif » désigne bien le magnésium** — départage par
   `priceSpread` (CatalogRanking.swift:53-61) : 0,401 contre 0,246 / 0,195 / 0,131 ;
   Nordika s'affiche avant Alba, comme l'attend l'étape 10.4.
6. **Le piège de focus VoiceOver du scanner est traité** — RootView.swift:21
   `accessibilityHidden(isCovered)` et :36 `.isModal` (critère de FAIL de l'étape 14).
7. **Aucun `print`, `debugPrint` ni `NSLog`** dans les 2 727 lignes de l'app ni dans
   les paquets : la « console propre » de l'étape 9 ne dépendra que du bruit système.
8. **La date d'en-tête ne peut pas dériver d'un fuseau à l'autre** — construction et
   formatage compensés (DemoCatalog.swift:20-26, DSFormat.swift:104-113) :
   « Samedi 25 juillet » partout.
9. **Les deux motifs de rejet App Store les plus courants sont écartés** — chaîne
   d'usage caméra spécifique et `ITSAppUsesNonExemptEncryption: false`
   (project.yml:43-44).

### 3.3 Les 70 points sains de la vague 1

**Documentation (18).** L'empreinte globale de la baseline est exacte et rejouable ·
les 58 empreintes par fichier concordent toutes · l'empreinte v1.0
(`71dfcd98…`) est reproductible sur le commit d'import initial · le décompte de
5 858 lignes est juste selon la convention du document · la dérive v1.0 → v1.1 est
exactement celle annoncée (10 fichiers, +15 lignes nettes) · les 34 tests se
répartissent comme documenté (20 + 9 + 5) · les 66 prévisualisations sont conformes
(45 dans le paquet DS, 21 dans les écrans ; 22 par apparence) · « 0 violations in
55 files » est arithmétiquement cohérent (58 − 3 fichiers de test exclus) · toutes les
valeurs métier contractuelles recalculées concordent (179 c/j, 53,70 €/mois, 644 €/an…)
· le 25 juillet 2026 est bien un samedi · les tokens cités par la doc d'icône existent
aux valeurs annoncées (accent 175947/4EB08C) · les constantes de comportement citées
sont exactes (cascade 90 ms, toast 1,9 s) · aucun symbole Swift cité par les documents
n'est introuvable · « sept polices retirées sur douze » est exact · la règle
typographique (`Font.custom` confiné à deux lignes de DSTypography) est tenue ·
l'unicité du workflow et l'épinglage sont conformes · le commit `cf5f4c8` invoqué comme
preuve existe · les rapports d'audit datés se présentent honnêtement comme des états à
leur date.

**Chaîne d'intégration (13).** Le motif `| xcpretty && exit ${PIPESTATUS[0]}` est
correct (shell `bash -e` sans pipefail) · la condition de publication d'artefact
traite le piège du `success()` implicite · le décompte de tests annoncé par le
workflow est exact · `swift test` plutôt que `xcodebuild test` est le bon choix,
correctement justifié · le périmètre du lint est cohérent et mesurable (55 fichiers) ·
le risque de locale du runner est neutralisé dans le code (fr_FR fixé,
DSFormat.swift:110) · la destination épinglée OS=17.5 correspond au runtime d'Xcode
15.4 · la chaîne de versions est cohérente de bout en bout (Xcode 15.4 → Swift 5.10 →
`swift-tools-version` → xcconfig) · déclencheur `pull_request` (pas
`pull_request_target`), aucun secret : les PR de forks tournent au moindre privilège ·
`timeout-minutes: 45`, aucune étape interactive : pas de blocage possible · le
contrôle des polices vérifie des fichiers réellement versionnés · l'action composite
gère le PATH proprement (chemin absolu, priorité aux binaires épinglés) · les étapes
9 à 22 sont effectivement non automatisables au jalon M1, et le protocole le dit.

**Configuration (11).** Cibles de déploiement iOS 17.0 cohérentes sur les trois
sources · SWIFT_VERSION 5.10 cohérent partout · le chaînage des xcconfig fonctionne
(`#include "Base.xcconfig"`) · NSCameraUsageDescription spécifique et rédigée pour
l'utilisateur · l'Info.plist généré est placé hors des sources, raison inscrite sur
place · UILaunchScreen référence un asset qui existe · bootstrap.sh porte le bit
exécutable et résiste au répertoire d'appel · les exclusions SwiftLint couvrent
`.build` deux fois plutôt qu'une · aucune contradiction active entre .swiftformat et
.swiftlint.yml · le piège de `.process("Resources")` (aplatissement) est évité et le
code en tient compte · l'épinglage d'outillage est motivé par des mesures
(objectVersion 54/70/77), pas par précaution vague.

**Concurrence (9).** Les 23 annotations `@MainActor` sont toutes utiles (relues une à
une) · l'inventaire exhaustif des accès à l'état isolé (61 lignes) ne montre aucun
accès hors acteur · les types imbriqués des magasins n'héritent pas de l'isolation, ce
qui rend sûres les conformances manuelles d'AppRouter · la convention « aucun
`Task { @MainActor in … } » est respectée à la lettre · `nonisolated static let
demonstrationCode` est une correction juste, pas un contournement · NutristackDomain
tient sa promesse Sendable (tous les types publics annotés explicitement) ·
`DSFontFamily.isAvailable` est une propriété calculée, pas de l'état muable · le
risque `onPreferenceChange` de PushScaffold est déjà consigné et raisonné · le
périmètre gelé (58 fichiers) inclut bien les manifestes et les tests.

**Tests (10).** Le total de 34 est exact et sa répartition juste · FormatTests
contient bien deux classes XCTestCase (5 + 4 tests) · les décomptes de la CI
concordent avec le code · le tri stable de RestockAlert est réellement exercé (deux
produits à 9 jours) · le départage de topRated par nombre d'avis est réellement exercé
(deux produits à 4,4) · les seuils de VerificationRule sont testés exactement à la
frontière (20/21, 19/30, 25/20) · la branche nil de FieldProvenance.ageInDays est
couverte · la locale n'est pas un risque d'environnement (fixée dans le code de
production) · l'absence de cible de test Xcode est structurelle et correctement
contournée par SPM · les deux paquets déclarent `.macOS(.v14)` et gardent UIKit par
`#if canImport(UIKit)` : les tests tournent sur hôte, comme en CI.

**Avancement (9).** L'empreinte de gel est rejouable depuis ce poste Windows, exacte ·
le périmètre de lint est cohérent avec le chiffre publié · le décompte des 34 tests se
recoupe de bout en bout · les chiffres du tableau d'architecture du README sont exacts
(15 composants, 45 prévisualisations) · l'historique (18 commits, 105 chemins) ne
contient ni secret ni artefact · aucun binaire lourd (plus gros fichier suivi :
141 Ko ; les sept polices retirées ne subsistent pas à HEAD) · le projet Xcode n'est
jamais versionné, règle tenue · `DemoCatalogRepository` n'est nommé qu'à sa
déclaration et comme valeur par défaut de la clé d'environnement — brancher un vrai
catalogue reste un changement d'une ligne · la chaîne d'intégration est réellement
reproductible (Xcode 15.4, XcodeGen 2.43.0, SwiftLint 0.57.0, OS=17.5, justifications
chiffrées).

---

## 4. Ce qui ne va pas — les 17 points ouverts

Aucun n'est bloquant. « Réfut. » = votes de réfutation reçus / sceptiques. Le seuil de
rejet est de 2 voix sur un panel de 3, et de 1 voix sur un panel de 2 : un constat est
retenu en deçà. « Swift gelé » = la correction touche-t-elle un fichier de la baseline.

### 4.1 Les trois majeurs

**M-1 · Aucune licence : ni pour le projet, ni pour les cinq polices redistribuées
sous SIL OFL** — avancement, réfut. 1/3, Swift gelé : non.
La racine du dépôt n'a pas de fichier LICENSE, et le dossier
`Packages/NutristackDesignSystem/…/Resources/Fonts/` contient les cinq `.ttf` de
Schibsted Grotesk sans le texte de la licence. Or la SIL OFL 1.1 conditionne toute
redistribution — dans le dépôt comme dans le bundle de l'app — à l'accompagnement du
texte de licence et de la notice de copyright. Le dépôt cite la licence de nom
(README) mais ne l'embarque pas. **Correction** : déposer `OFL.txt` dans le dossier
des polices, ajouter la notice de copyright au README du paquet, poser un LICENSE à la
racine. Aucun code touché.

**M-2 · `NSPhotoLibraryAddUsageDescription` absent alors que le comparateur propose
le partage d'une image** — configuration (vague 1), réfut. 0/3, Swift gelé : non.
Le comparateur partage une image réellement rendue via `ImageRenderer`/`ShareLink`
(README.md:62-63). Si le testeur choisit « Enregistrer l'image » dans la feuille de
partage, iOS exige cette clé ; sans elle, l'app est tuée sur le coup. La seule clé
présente est `NSCameraUsageDescription` (project.yml:43). C'est le seul point ouvert
capable de faire échouer une étape du protocole par plantage. **Correction** : une
ligne dans `project.yml`, section `info.properties`, rédigée dans le même registre que
la clé caméra. Aucun code touché.

**M-3 · `testHeroWinnerUsesExactValues` ne teste pas la règle qu'il annonce** —
tests, réfut. 1/3, Swift gelé : oui (fichier de test).
Le test (DomainTests.swift:107-116) annonce vérifier que le départage se fait « sur
les valeurs exactes, même quand l'affichage arrondi est identique » — mais ses deux
produits affichent 111 et 66 c/g : les arrondis sont déjà distincts, le test se
contente d'inverser l'ordre des arguments. Remplacer le moteur exact
(ComparisonEngine.swift:87) par un comparateur d'entiers arrondis ne ferait échouer
**aucun** des 34 tests : la métrique fondatrice du produit (le prix au gramme d'actif)
n'est pas verrouillée. **Correction** : un cas où les valeurs exactes diffèrent
(110,4 contre 110,6) mais s'arrondissent au même centime, avec un vainqueur asserté.

### 4.2 Les quatorze mineurs

**Dans le code gelé (2) :**

**O-4 · La recherche est sensible aux accents** — complétude, jugé à la main
(sceptique mort), **confirmé** ; Swift gelé : oui (CatalogRepository.swift:36-43).
`matches` compare avec `localizedCaseInsensitiveContains`, qui ignore la casse mais
pas les diacritiques. Sept des huit produits portent un accent dans leur nom
(« Magnésium… », « Créatine… », « Oméga-3… »), les actifs aussi. Taper « omega »,
« creatine » ou « proteines » rend l'état vide. L'étape 10.3 du protocole dicte
« oméga » avec l'accent : elle passe par construction et ne détecterait jamais ce
défaut. **Correction** : `range(of:options:[.caseInsensitive, .diacriticInsensitive])`
— une méthode de 4 comparaisons dans un fichier gelé, donc à passer par la grille en
6 points et un refigeage documenté.

**O-5 · `CatalogRepository` ne peut pas porter une implémentation distante** —
avancement, réfut. 1/3, Swift gelé : oui à terme, non à court terme.
Les trois méthodes du protocole sont `async` non-`throws`, à valeurs totales : ni
erreur, ni pagination, ni annulation. Avec un catalogue en mémoire c'est invisible ;
à M3 (Supabase), une panne réseau devient indistinguable d'un « produit inconnu » — le
scanner affirmerait « Produit introuvable » sur une erreur de connexion. Le README
promet que brancher le vrai catalogue « se réduit à changer cette ligne » : c'est vrai
pour l'injection, faux pour le contrat de données. **Correction court terme (docs
seulement)** : rectifier les deux paragraphes du README. **À M3** : `async throws`,
signature paginée, `CancellationError`.

**Dans les fichiers de test gelés (2) :**

**O-6 · La branche d'égalité de `ComparisonEngine.winner` n'est exécutée par aucun
test** — tests, réfut. 0/3. `guard left != right else { return nil }`
(ComparisonEngine.swift:183) : les cinq paires du catalogue diffèrent toutes. Une
régression sur cette ligne laisserait les 34 tests verts. **Correction** : comparer un
produit à lui-même et asserter `winner == nil` partout.

**O-7 · Le chemin « produit sans actif normalisable » est entièrement sans
couverture** — tests, réfut. 1/3. Tous les guards de repli
(Models.swift:243-245, ComparisonEngine.swift:81-89, :125-127, :136-141,
CatalogRanking.swift:25-27, :40-42, :81) sont du code jamais exécuté par les tests :
les 8 produits de démonstration ont tous un actif primaire normalisable. Le catalogue
réel de M3 contiendra des formules multi-actifs sans actif primaire : premier contact
avec ces branches en production. **Correction** : fixtures locales aux tests.

À noter : l'objection « ajouter des tests casserait la baseline gelée » a été
**réfutée 3/3** — la baseline documente sa propre procédure de refigeage ; étendre les
tests est une opération normale, datée et documentée, pas une violation du gel.

**Dans la CI et l'outillage (6) :**

**O-8 · Le gel n'est vérifié par aucune automatisation** — avancement, réfut. 0/3,
re-confirmé en vague 2. La CI passe au vert sur un fichier Swift modifié : le
mécanisme central du projet repose sur la seule discipline humaine, alors que la
commande de contrôle est déjà écrite et déterministe (docs/baseline/Baseline_Gel_v1.0.md:24-27).
**Correction** : une étape de workflow qui rejoue la commande et compare à
`4a70bdd80a03d359d3395ddc5aa8e34d`.

**O-9 · Le contrôle des polices ne vérifie que la présence, jamais l'absence
d'intrus** — pipeline (vague 1), réfut. 0/3. Le bloc (build-and-test.yml:88-94)
vérifie les cinq graisses attendues mais pas le cardinal du dossier : une sixième
police ajoutée par erreur serait embarquée en silence — exactement le scénario que le
README du paquet met en garde. **Correction** : comparer la liste triée aux cinq noms.

**O-10 · L'action composite ne vérifie aucune empreinte des binaires téléchargés et
ne réessaie pas** — pipeline (vague 1), réfut. 0/3. `toolchain/action.yml` télécharge
XcodeGen et SwiftLint sans `shasum -c` ni `curl --retry`. **Correction** : figer les
sha256 attendus et les vérifier.

**O-11 · Le code de test n'est couvert ni par SwiftLint ni par « avertissements =
erreurs »** — pipeline (vague 1), réfut. 1/3. `.swiftlint.yml:5` exclut
`Packages/*/Tests`, et les deux `swift test` (build-and-test.yml:139, :144) tournent
sans `-Xswiftc -warnings-as-errors`. **Correction** : ajouter le drapeau aux deux
invocations — aucun fichier Swift touché.

**O-12 · `xcpretty` est une dépendance héritée de l'image du runner, ni installée ni
épinglée** — pipeline (vague 1), réfut. 1/3. Utilisé aux lignes 116 et 122 du
workflow ; le jour où l'image GitHub le retire, les deux étapes de build cassent pour
une raison étrangère au projet. **Correction** : l'installer à version fixe dans
l'action composite, ou le remplacer par `xcodebuild -quiet`.

**O-13 · L'affirmation « les paquets sont écrits pour passer le mode strict » n'est
compilée nulle part** — concurrence (vague 1), réfut. 0/3. Ni les `Package.swift` ni
la CI n'activent `StrictConcurrency` sur les paquets : la promesse de
Base.xcconfig:8-10 n'a aucune preuve d'exécution. **Correction** : `swiftSettings:
[.enableExperimentalFeature("StrictConcurrency")]` dans les deux manifestes — qui font
partie des 58 fichiers gelés : à passer par la grille et un refigeage.

**Dans la documentation et l'hygiène du dépôt (4) :**

**O-14 · Le `.gitignore` du dépôt n'ignore pas `.claude/`** — avancement,
réfut. 0/2. `git check-ignore` montre que l'exclusion vient du fichier global de
**cette machine** : sur tout autre poste, `git add .` peut commiter
`.claude/settings.local.json` (règles de permission locales, chemins absolus).
**Correction** : une ligne dans `.gitignore`.

**O-15 · Le README se contredit sur l'état des arbitrages de maquette** — docs
(vague 1), réfut. 0/3. La section (README.md:127-144) dit d'abord que les écarts sont
« résolus par le Prototype v1.1 … conservés ici pour mémoire », puis, au présent, que
le code « attend l'amendement du document de référence » ; et README.md:3 pointe
toujours la maquette v1-0. **Correction** : mettre le second paragraphe au passé,
pointer la v1.1.

**O-16 · Base.xcconfig affirme « aucun état global muable » dans les paquets, alors
que le design system contient trois `DateFormatter` statiques** — concurrence
(vague 1), réfut. 1/3. DSFormat.swift:104-106 : `shortDateFormatter`,
`dayMonthFormatter`, `weekdayFormatter` — des `static let` de classe non-Sendable,
sûrs en pratique (jamais mutés après création, usage confiné), mais la phrase de
Base.xcconfig:8-10 est factuellement fausse. **Correction** : rectifier la phrase pour
décrire l'existant. Docs seulement.

**O-17 · La documentation d'isolation nomme une méthode qui n'existe pas** —
concurrence (vague 1), réfut. 1/3. docs/audit/Audit_Verrouillage_v1.0.md:53 cite
`loadAlternative` — introuvable dans le code (la méthode réelle est `load`,
ProductDetailView.swift:297) — et omet `renderCard` (CompareShareSheet.swift:47), qui
fait pourtant partie de la même convention. **Correction** : remplacer un nom, en
ajouter un. Docs seulement.

---

## 5. Ce qui a été examiné et écarté — avec les motifs

Ces constats ont été formulés par des chercheurs puis **démolis par les sceptiques**.
Ils sont listés pour que rien ne disparaisse en silence — et parce que plusieurs
rejets sont en réalité des confirmations que le dépôt est plus solide que le constat
ne le croyait.

### 5.1 Vague 2 — les 19 rejetés (dimensions tests et avancement)

| Constat rejeté | Réfut. | Motif du rejet |
|---|---|---|
| Le comparateur n'impose pas sa précondition « même actif principal » | 3/3 | La précondition est imposée par construction un étage au-dessus : `CatalogRanking.swift:83` filtre déjà sur `active ==` ; aucun appel ne peut violer le contrat. |
| Le seuil de couverture de 85 % n'est pas mesurable par la CI | 3/3 | Citation tronquée qui inverse le sens : la ligne citée dit « à outiller au jalon M2 » — c'est une dette datée, publiée en quatre endroits, pas une découverte. |
| La couverture serait franchie par les données de démo, pas les règles | 3/3 | Constat contrefactuel : la mesure n'existe pas encore ; l'objection porte sur un outillage futur, dont le déploiement (M2) tranchera le périmètre. |
| Les trois fichiers de test appartiennent à la baseline : les étendre casse l'empreinte | 3/3 | L'impact est inventé : la baseline documente sa propre procédure de refigeage ; étendre les tests est une opération normale et datée, pas une violation. **Il n'y a pas de conflit gel/couverture.** |
| Ni la locale ni le fuseau ne sont épinglés par les tests | 2/2 | La sûreté est structurelle, pas fortuite : locale fixée dans le code de production (DSFormat.swift:110), arithmétique calendaire insensible au fuseau. |
| Le départage de `comparableGroup` est inatteignable avec le catalogue de démo | 2/2 | Exact sur les faits, mais aucun défaut : les quatre écarts de prix (0,401 / 0,246 / 0,195 / 0,131) sont distincts, le départage secondaire est un filet, pas un chemin mort. |
| `sameForm == true` n'est jamais testé | 1/2 | Le fait brut n'est pas contesté (la branche vraie n'est exercée nulle part) ; le rejet tient à l'absence d'erreur démontrée sur une ligne triviale (`==` entre deux chaînes) et au coût d'une correction dans un fichier gelé. |
| La paramétrisation de `VerificationRule` n'a aucune preuve d'exécution | 2/2 | Fausse : la conversion `weeks*7` est éprouvée par `testReviewVerification…`, la règle est instanciée et exécutée aux frontières exactes. |
| Les guards défensifs du domaine sont du code mort pour les tests | 1/2 | Titre partiellement faux : `StackCosts` n'a aucun guard, et la branche nil de `vnrPercent` tourne déjà dans le catalogue de démonstration ; les entrées nécessaires aux autres guards sont inatteignables au jalon M1. |
| Surface publique du domaine à couverture strictement nulle (certains symboles) | 1/2 | Le remède proposé ne détecterait aucun des impacts allégués ; les symboles cités sont exercés par les écrans et les prévisualisations. |
| La valeur de test de `yearlyCostEuros` ne distingue pas troncature et arrondi | 2/2 | Déjà couvert ailleurs sur le cas exact réclamé ; la division entière est le comportement documenté. |
| `bootstrap.sh` prescrit `brew install xcodegen` | 3/3 | **Périmé : corrigé à `cbc3418`** — le script épingle 2.43.0, contrôle la version installée et affiche la procédure exacte. |
| Le README renvoie à quatre documents de référence absents du dépôt | 2/3 | Le titre est faux (trois documents, pas quatre ; le PRD n'est cité nulle part) ; les références sont des documents de pilotage externes, datés et assumés comme tels. |
| La « Dette connue » omet que `StackStore` n'écrit rien au-delà de l'ajout | 3/3 | La conclusion est fausse : le README documente précisément cet état (M1 démo, persistance à M3 « derrière ce même magasin, sans toucher aux écrans »). |
| Les prises cochées ne portent pas de date ; l'historique de `VerificationRule` n'est produit nulle part | 3/3 | La preuve centrale est fausse : `Reviews.swift:33-34` alimente exactement `intakes` et `spanDays` ; la règle est branchée et testée. |
| Aucun `.gitattributes` alors que `core.autocrlf=true` a déjà mordu | 2/2 | Aucun octet CRLF n'est entré dans l'historique (vérifié) ; l'incident CRLF passé concernait un outil hors dépôt ; risque théorique sur un dépôt 100 % LF. |
| La version du bundle est restée à 0.1.0 | 2/2 | **Périmé : corrigé à `cbc3418`** — `CFBundleShortVersionString: "0.3.6"`, avec commentaire de traçabilité. |
| SwiftFormat annoncé mais jamais exécuté, et l'exécuter casserait la baseline | 2/2 | Sur-lecture : le README annonce des « configurations versionnées », pas une exécution en CI ; l'outil est un instrument de poste, à la demande. |
| Le document de baseline est nommé v1.0 mais son contenu est v1.1 | 2/2 | Préférence de nommage déguisée en défaut : le nom de fichier est un identifiant stable, le contenu s'auto-décrit v1.1 ; toutes les références internes concordent. |

### 5.2 Vague 2 — les 9 constats de complétude rejetés

Ces verdicts proviennent du journal d'exécution du workflow (résultats bruts des
sceptiques), le résumé final du script n'ayant conservé que le décompte agrégé.

| Constat rejeté | Motif du rejet |
|---|---|
| Refus caméra : l'app « fabrique » une détection d'Alba au lieu de le dire | Comportement spécifié, pas dérive : le moteur simulé est documenté en tête de `ScannerEngine.swift` et le protocole teste précisément ce mode de démonstration. |
| L'étape 10.6 attend un verdict que le code gelé ne peut pas produire | Les guillemets du protocole ne sont pas un contrat de chaîne littérale — le document lui-même cite un même élément de deux façons différentes. |
| Aucun manifeste de confidentialité (`.xcprivacy`) malgré l'usage d'UserDefaults | Hors périmètre M1 : exigé à la soumission App Store, pas au protocole de validation locale ; l'impact cité reposait sur deux affirmations fausses. |
| L'étape 14 attend un libellé VoiceOver que la cellule héros ne prononce pas | Le critère d'échec écrit de l'étape 14 est satisfait ; le constat inventait une exigence de formulation qui n'y figure pas. |
| Les prévisualisations n'enregistrent jamais les polices | Citation tronquée : les étapes 15 et 16 basculent **au simulateur**, où l'app enregistre ses polices au démarrage ; les prévisualisations ne sont pas le juge du rendu. |
| Le numéro de build est figé à 1 depuis la 0.1.0 | Aucune distribution TestFlight au jalon M1 ; `CFBundleVersion` ne contraint rien en local. Deviendra pertinent à la première distribution. |
| L'étape 22 s'appuie sur trois référentiels absents du dépôt | L'intrant de l'étape 22 est inscrit dans l'étape elle-même (les valeurs entre parenthèses) ; les documents externes sont une provenance, pas une dépendance. |
| Aucune langue de développement déclarée | Exact mais anodin : l'impact allégué était faux sur deux points sur trois ; à régler naturellement à la première localisation. |
| Le générateur haptique du scan est créé puis relâché dans la même expression | `notificationOccurred(_:)` transmet le motif au Taptic Engine à l'appel ; la durée de vie de l'objet n'affecte pas le retour haptique. Pas de défaut. |

### 5.3 Vague 1 — les 14 rejetés (dimensions valides)

Documentation : l'en-tête du workflow « annonce un ordre qu'il n'applique pas »
(l'ordre est délibéré, fail-fast — et le point a de toute façon été réglé en 0.3.5) ·
le nom de fichier v1.0/contenu v1.1 (identifiant stable, re-rejeté en vague 2).
Chaîne d'intégration : absence de `concurrency:` (ajouté en 0.3.5) · absence de cache
(coût assumé, deux runs au total) · actions tierces au tag majeur flottant (politique
GitHub standard, risque accepté) · l'artefact rouge qui masquerait la cause d'un échec
(la condition `if:` le gère) · le critère « zéro téléchargement réseau » de l'étape 3
non vérifié (invérifiable en CI, dit le protocole lui-même).
Configuration : les xcconfig ne gouvernent pas les paquets (exact, mais c'est la
sémantique SPM, documentée) · l'exclusion des tests de SwiftLint « sans
justification » (justifiée par le périmètre publié « 55 files ») · SwiftFormat
(re-rejeté en vague 2) · double déclaration d'`IPHONEOS_DEPLOYMENT_TARGET` (valeurs
identiques, aucun conflit actif) · `.gitignore` sans `build/` ni `.swiftpm`
(couverts par d'autres règles ou sans objet).
Concurrence : `ScannerView.backdrop` accèderait à un membre isolé sans annotation
(faux : le membre est immuable) · la dette Sendable de `CameraScannerEngine` serait
masquée (elle est consignée et raisonnée dans l'audit de verrouillage).

**Transparence :** l'un des constats démolis était le mien. J'avais annoncé un conflit
entre le gel et l'extension des tests ; les trois sceptiques l'ont réfuté. Je le
signale pour que le rapport ne me soit pas plus favorable qu'aux chercheurs
automatiques.

---

## 6. Ce qui a déjà été corrigé

**Commit `cbc3418` (0.3.6, 6 août 2026) — 7 fichiers, 113 insertions, 20
suppressions, zéro fichier Swift.** Clôt 10 constats de vague 1 :

1. **Le majeur de l'audit** : `scripts/bootstrap.sh`, le protocole de validation et la
   fiche Xcode prescrivaient tous trois `brew install xcodegen`, qui installe une
   version dont Xcode 15.4 refuse le format de projet — l'étape 2 du protocole
   échouait sur tout poste neuf, entraînant les étapes 9 à 22. Le script contrôle
   désormais `xcodegen --version`, refuse toute version ≠ 2.43.0 avec la procédure
   d'installation exacte, et les deux documents nomment les versions épinglées ; le
   README annonce ce refus.
   (3 constats : docs, pipeline, config.)
2. Le README du design system affirmait que les polices ne sont pas versionnées
   (elles le sont), prescrivait des tests sur simulateur iOS (ils tournent sur hôte
   macOS, comme en CI) et tolérait « Xcode 15 ou plus récent » (le projet exclut
   Xcode 16). (3 constats.)
3. `CFBundleShortVersionString` valait 0.1.0 alors que le CHANGELOG en était à 0.3.x :
   porté à 0.3.6, avec commentaire de traçabilité. (2 constats : docs, config.)
4. Le CHANGELOG annonçait 22 membres `@MainActor` : le compte exact est 23.
   (2 constats : docs, concurrence.)

**Version 0.3.5 (3 août 2026)** avait déjà clos 2 constats de vague 1 : le bloc
`permissions: contents: read` (moindre privilège du jeton) et l'en-tête du workflow
mis en cohérence avec l'ordre réel des étapes — plus `concurrency:`, qui répondait à
un constat par ailleurs rejeté.

**Vérification après correction** : CI verte sur `cbc3418` (17 étapes), artefact xUnit
re-téléchargé et re-parsé (34 tests, 0 échec), baseline md5 rejouée intacte, et les
sceptiques de vague 2 ont indépendamment classé « périmé : déjà corrigé » les quatre
constats qui visaient l'état d'avant.

---

## 7. Les limites honnêtes de ce rapport

1. **L'audit est entièrement statique.** Personne n'a compilé ni lancé l'application
   depuis ce poste (Windows, sans toolchain Swift). La CI prouve la compilation Debug
   et Release et les 34 tests sur macOS ; elle ne prouve ni le rendu, ni la
   navigation, ni le scanner, ni VoiceOver, ni les performances. **Les étapes 9 à 22
   du protocole restent à exécuter sur un Mac**, avec simulateur, iPhone physique et
   Instruments.
2. **La couverture de test est faible et connue comme telle.** 34 tests verrouillent
   les formats et les valeurs de la maquette ; les points O-6, O-7 et M-3 montrent que
   des branches entières du moteur de comparaison n'ont aucun témoin. Un vert de CI
   est une condition nécessaire, pas une preuve de correction.
3. **Le processus d'audit lui-même a eu des morts** : 65 agents en vague 1, 1 en
   vague 2. Tout ce qui n'a pas été jugé par un panel complet a été soit re-jugé
   (vague 2), soit jugé à la main et signalé comme tel (O-4). Le biais résiduel :
   un seul juge humain — moi — pour O-4 et pour la re-vérification des reliquats
   pipeline de §4 ; les preuves citées permettent de me contrôler.
4. **Périmètre** : le dépôt à `cbc3418`. Les documents de pilotage externes
   (Prototype, Design System, Plan, PRD) n'ont pas été audités — seules leurs
   citations internes au dépôt l'ont été.

---

## 8. La suite convenue

L'ordre arrêté : **corriger → tester → faire évoluer le catalogue.**

1. **Corriger les 17 points ouverts.** 11 se corrigent sans toucher un fichier gelé
   (M-1, M-2, O-8 à O-12, O-14 à O-17). Les 6 autres (M-3, O-4, O-5 à terme, O-6,
   O-7, O-13) touchent des fichiers de la baseline : chacun passera par la grille en
   six points, et un refigeage documenté conclura la série.
2. **Tester l'application** : dérouler les étapes 9 à 22 du protocole sur Mac —
   ce rapport établit que rien de connu ne s'y oppose, à condition de corriger M-2
   avant l'étape du partage d'image.
3. **Puis le catalogue à ~6 500 produits.** Les quatre murs déjà identifiés :
   le rendu non paresseux d'Explorer (`ForEach` dans un `VStack` simple), les
   classements recalculés à chaque frappe sans cache, la recherche non bornée et sans
   anti-rebond, et le mur de modélisation (4 catégories, 5 actifs). L'ordre
   recommandé reste : modèle (M2) → contrat de données (M3, règle O-5) → affichage.
