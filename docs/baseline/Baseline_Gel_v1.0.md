# Baseline gelée · Nutristack · v1.1 · 29 juillet 2026

**Statut : CODE GELÉ.** Aucune modification n’est autorisée sans la grille de
contrôle ci-dessous. Ce document fige l’empreinte exacte de l’état validé ;
toute dérive est détectable en recalculant les sommes md5.

## Méthode de calcul

md5 de la concaténation des contenus, dans l’ordre alphabétique des chemins,
de tous les `*.swift` du dépôt hors `.build`.

**Les empreintes portent sur le contenu versionné, donc à fins de ligne LF.**
Ce n’est pas un détail : sur un poste Windows, `core.autocrlf=true` matérialise
les fichiers en CRLF, et un recalcul naïf depuis l’arbre de travail renvoie une
tout autre valeur — `9530133823221b742a0fb41fc8a40352` au lieu de
`4a70bdd80a03d359d3395ddc5aa8e34d`, à code rigoureusement identique. On
conclurait à une dérive qui n’existe pas. Le contrôle se fait donc sur le
contenu Git, jamais sur les octets du disque.

Commande de vérification, indépendante de la plateforme et du réglage
`autocrlf` puisqu’elle lit les objets Git :

```sh
git ls-tree -r --name-only HEAD \
  | grep '\.swift$' | grep -v '^\.build/' | LC_ALL=C sort \
  | while read -r f; do git show "HEAD:$f"; done | md5sum
```

Elle doit rendre `4a70bdd80a03d359d3395ddc5aa8e34d` sur la v1.1. Appliquée au
commit du gel v1.0, elle rend `71dfcd98d41c476318e94b9085a615b1`, valeur
publiée le 26 juillet : **c’est cette concordance qui valide la méthode**, et
non l’inverse. Les empreintes par fichier suivent la même règle.

Le décompte de lignes vaut, lui, nombre de `\n` plus un par fichier, les
fichiers ne se terminant pas tous par un saut de ligne.

## Empreinte globale

| | v1.0 · 26 juillet | v1.1 · 29 juillet |
|---|---|---|
| Fichiers Swift (hors `.build`) | 58 | **58** |
| Lignes totales | 5843 | **5858** |
| Empreinte globale | `71dfcd98d41c476318e94b9085a615b1` | **`4a70bdd80a03d359d3395ddc5aa8e34d`** |

## Dérive v1.0 → v1.1, exhaustive

Dix fichiers ont changé, aucun n’a été ajouté ni supprimé. **+15 lignes nettes**,
qui sont des annotations d’isolation et les commentaires qui les justifient :
aucune ligne de logique n’a été ajoutée, déplacée ni retirée.

| Fichier | md5 v1.0 | md5 v1.1 |
|---|---|---|
| `App/Sources/Features/Explore/ExploreView.swift` | `d6f013ff…` | `66217dbe…` |
| `App/Sources/Features/Product/ProductDetailView.swift` | `edeea8bb…` | `a37edf8b…` |
| `App/Sources/Features/Profile/ProfileView.swift` | `ebbba2e7…` | `326a1e7a…` |
| `App/Sources/Features/Scanner/CameraScannerEngine.swift` | `bf51f011…` | `9777e876…` |
| `App/Sources/Features/Scanner/ScannerEngine.swift` | `ad6a91ee…` | `52eef1b8…` |
| `App/Sources/Features/Scanner/ScannerView.swift` | `53facc93…` | `925df810…` |
| `App/Sources/Features/Stack/StackScreen.swift` | `1c26f07e…` | `a8e2cf0d…` |
| `App/Sources/Features/Today/TodayView.swift` | `743ff375…` | `b272051b…` |
| `App/Sources/NutriTabBar.swift` | `52628039…` | `e011f18e…` |
| `App/Sources/RootView.swift` | `7af01efb…` | `65e2afe9…` |

Motif unique, sous grille de contrôle : la concurrence stricte de Swift 6
n’étend pas l’isolation de `body` aux autres membres d’une vue. Détail complet
au CHANGELOG 0.3.2 et dans la pull request #2.

## Statut des tests, formulation contractuelle

- 20/20 tests domaine : **exécutés réellement, PASS**.
- 9/9 tests formats : **exécutés réellement, PASS**.
- 5/5 tests composants : **exécutés réellement, PASS** — la réserve de la v1.0
  est levée. Ils l’ont été sur runner macOS 14 sous Xcode 15.4, et non dans un
  Xcode de poste ; l’environnement diffère de celui qu’annonçait l’étape 6 du
  protocole, le SDK SwiftUI/iOS y est bien présent, qui était la seule cause du
  blocage.
- **Total : 34/34 exécutés avec succès, 0 échec.**

Preuve : exécution [30462450376](https://github.com/nathexec/nutristack/actions/runs/30462450376)
sur `main` au commit `cf5f4c8`, 15 étapes vertes, dont build Debug, build
Release, `swiftlint --strict` (`0 violations, 0 serious in 55 files`) et les
deux suites de tests. Rapport xUnit publié en artefact `resultats-tests`.

**La réserve « 29/34 » de la v1.0 est close.** Toute présentation du projet
qui la reprendrait serait désormais fausse.

## Grille de contrôle avant toute modification

Aucun changement de code sans avoir établi, par écrit et dans cet ordre :
le problème constaté ; la preuve du problème (journal, capture, test rouge) ;
l’impact ; la correction minimale nécessaire ; le risque de régression ;
le test qui prouvera que la correction fonctionne. Après toute correction :
relancer les étapes 3 à 8 du protocole au minimum, plus l’étape corrigée,
et consigner l’entrée au CHANGELOG.

## Empreintes par fichier

| Fichier | md5 |
|---|---|
| `App/Sources/AppRouter.swift` | `dbf3c49de986cae028ec4e87e0d9dea7` |
| `App/Sources/DataKit/CatalogRepository.swift` | `34ce936de50fb8e45d2dcf466bb27724` |
| `App/Sources/DataKit/CatalogRepositoryKey.swift` | `031eb3598e2f0ee0086e97e42dca1153` |
| `App/Sources/Features/Compare/CompareShareSheet.swift` | `bae26f32a0521126b807b8e5fd7fb01b` |
| `App/Sources/Features/Compare/CompareView.swift` | `a736db3847e2f61b4eb2eee9b34bc331` |
| `App/Sources/Features/Explore/ExploreView.swift` | `66217dbe5658c33d45ee4cc03f85a8b0` |
| `App/Sources/Features/Product/ProductDetailView.swift` | `a37edf8b0cdb5fd476a228c92b652257` |
| `App/Sources/Features/Product/ProductSheets.swift` | `1a778e05b7942fe99fb39e38b6259245` |
| `App/Sources/Features/Profile/ProfileView.swift` | `326a1e7adc5eb4c306173665dae38ae8` |
| `App/Sources/Features/Scanner/CameraScannerEngine.swift` | `9777e876765794afe0bc3eb74fb646b1` |
| `App/Sources/Features/Scanner/ScannerEngine.swift` | `52eef1b85a1a8737d34e34f4ce4e68da` |
| `App/Sources/Features/Scanner/ScannerView.swift` | `925df81042e7d72b60ff0cfdd6ba0238` |
| `App/Sources/Features/Stack/StackScreen.swift` | `a8e2cf0d69a3f82f669c8354f01ae2e0` |
| `App/Sources/Features/Today/TodayView.swift` | `b272051bd8f7232c7c2e0967ebe62468` |
| `App/Sources/NutriTabBar.swift` | `e011f18e764bd2c76ee756e0f307c957` |
| `App/Sources/NutristackApp.swift` | `a196d5166ad376f14c3a73e528702feb` |
| `App/Sources/RootView.swift` | `65e2afe9946236a33024c5c6592ed8df` |
| `App/Sources/Shared/Controls.swift` | `0b934b664f51e540a07a60d3437659ff` |
| `App/Sources/Shared/ProductDisplay.swift` | `0e3ad8d287ec98523a5b625d9250262d` |
| `App/Sources/Shared/PushScaffold.swift` | `ec71a40a31fef7b907b4447f62380f16` |
| `App/Sources/Shared/ScreenChrome.swift` | `cf44311ea684e03964fe2bbb77c769dd` |
| `App/Sources/Stores/AppearanceStore.swift` | `a486b88a919f8ac07e6526949389c99f` |
| `App/Sources/Stores/StackStore.swift` | `1c0a9eba47fe1b9722c56abc26b69c0b` |
| `App/Sources/Stores/TodayStore.swift` | `1758ed9073fc9dac66f72474fe572c1f` |
| `Packages/NutristackDesignSystem/Package.swift` | `156bd4e8cde1760b1ace99cf096fd6a1` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/ActiveGauge.swift` | `cfcde00a728039555e0e886e9ced0256` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/AnchoredActionBar.swift` | `65d8dde816663d1deb205e1e38269057` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/AppToast.swift` | `09b3476552eabf6c9b6d43827c6cf4a8` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/AttentionBanner.swift` | `aa0d50e8645203c0168263c28ebfffb6` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/DSButton.swift` | `f21bbdfe5860b74d0d0ed0b11372fe24` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/EmptyState.swift` | `ac1dcf4aae6ad4578f79d648bdfc8d7a` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/IntakeRow.swift` | `af1679d49f307f3d8932f848939362a0` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/MetricTile.swift` | `3a4667b8df455032830248b7290625d6` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/Packshot.swift` | `9550155b738861d7f5a2c66c01a608b1` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/ProductRow.swift` | `c79200977c6e42488c89b6db6404efbe` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/ProvenanceChip.swift` | `d173ca4ab3eb154b9d03cf03c7c2ee9f` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/SegmentedProgress.swift` | `cfdffcc903d80c196215edafa4d83a19` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/SkeletonBlock.swift` | `8998a658dc7f0e4d534d363f8b4899fe` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/VerdictCard.swift` | `8395a37790edee6e8b0f84152fc1f3ed` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Components/VerifiedBadge.swift` | `08788ec80f7f0a7e154917c3ba5e3399` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Foundation/ColorHex.swift` | `bde28a80edc4f54dab001f7e3db4c8f2` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Foundation/Primitives.swift` | `b02fac6e32d1d1ef8db977863b7bf792` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Foundation/Shapes.swift` | `ab9a118fab2213939bf4a738419a1b72` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Tokens/DSColor.swift` | `bae5cc8e2ad54e9daa1e5f7fa6f80e47` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Tokens/DSFormat.swift` | `275a82c8f5b8c164d1b3e9fecbee22f1` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Tokens/DSMotion.swift` | `b5eb11e001d4a5b7fae574ce27e9aaa4` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Tokens/DSSpacing.swift` | `eaef5d3e261f2cc1965f9df09b6b7ef0` |
| `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Tokens/DSTypography.swift` | `57207f29e85e52be96d22e6cbd5f2510` |
| `Packages/NutristackDesignSystem/Tests/NutristackDesignSystemTests/ComponentRuleTests.swift` | `fe94e1da068d5eae407f922689f7843a` |
| `Packages/NutristackDesignSystem/Tests/NutristackDesignSystemTests/FormatTests.swift` | `dbd641afeb7ac393c4c63445f5d01937` |
| `Packages/NutristackDomain/Package.swift` | `a261c92c449bc5c6001ef4564978efd2` |
| `Packages/NutristackDomain/Sources/NutristackDomain/CatalogRanking.swift` | `1fd3977ee3f8f92511b7f5f3d4cdc7df` |
| `Packages/NutristackDomain/Sources/NutristackDomain/ComparisonEngine.swift` | `0484f32d7a29ff3d13c56309e8137355` |
| `Packages/NutristackDomain/Sources/NutristackDomain/DemoCatalog.swift` | `2fbdf13ce2d3fae689d03c7088a7c376` |
| `Packages/NutristackDomain/Sources/NutristackDomain/Models.swift` | `6fd55690ce7496cf8553268459a9fb91` |
| `Packages/NutristackDomain/Sources/NutristackDomain/Reviews.swift` | `930b65ac15d37130ec90be68d4ef9b6b` |
| `Packages/NutristackDomain/Sources/NutristackDomain/StackModels.swift` | `f3809d89de88bfdc4c3dea7b32b841a8` |
| `Packages/NutristackDomain/Tests/NutristackDomainTests/DomainTests.swift` | `10c2ab2ee77b92771b7ccda1a88490cc` |
