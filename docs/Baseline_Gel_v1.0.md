# Baseline gelée · Nutristack v1.0 · 26 juillet 2026

**Statut : CODE GELÉ.** Aucune modification n’est autorisée sans la grille de
contrôle ci-dessous. Ce document fige l’empreinte exacte de l’état validé ;
toute dérive est détectable en recalculant les sommes md5.

## Empreinte globale

- Fichiers Swift : **58** (hors artefacts `.build`)
- Lignes totales : **5843**
- Empreinte globale (md5 concaténé, ordre alphabétique) : `71dfcd98d41c476318e94b9085a615b1`

## Statut des tests, formulation contractuelle

- 20/20 tests domaine : **exécutés réellement, PASS** (XCTest, Swift 6.0.3 Linux).
- 9/9 tests formats : **exécutés réellement, PASS** (harnais, source `DSFormat` identique au md5).
- 5/5 tests composants : **NON EXÉCUTÉS, BLOCKED** par l’absence du SDK SwiftUI/iOS.
- **Total : 29/34 exécutés avec succès ; 5/34 restent à exécuter.**

Les 34 tests ne pourront être présentés comme entièrement validés qu’après
l’exécution réelle des 5 tests composants dans Xcode (protocole, étape 6).

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
| `App/Sources/Features/Explore/ExploreView.swift` | `d6f013ffef21c86ac259bc128288b754` |
| `App/Sources/Features/Product/ProductDetailView.swift` | `edeea8bbf0d31ecb164bda6150011fa6` |
| `App/Sources/Features/Product/ProductSheets.swift` | `1a778e05b7942fe99fb39e38b6259245` |
| `App/Sources/Features/Profile/ProfileView.swift` | `ebbba2e7403224df9b4a2d7cff6df435` |
| `App/Sources/Features/Scanner/CameraScannerEngine.swift` | `bf51f011608d1f62d58f432119891f36` |
| `App/Sources/Features/Scanner/ScannerEngine.swift` | `ad6a91ee326c859ccaf66740481a366e` |
| `App/Sources/Features/Scanner/ScannerView.swift` | `53facc937de23832248b357ff07ce7ca` |
| `App/Sources/Features/Stack/StackScreen.swift` | `1c26f07e44cf878309c869af0eb3921c` |
| `App/Sources/Features/Today/TodayView.swift` | `743ff3754816d43ed868f02debbe9165` |
| `App/Sources/NutriTabBar.swift` | `526280391b151d9883702846195c0dde` |
| `App/Sources/NutristackApp.swift` | `a196d5166ad376f14c3a73e528702feb` |
| `App/Sources/RootView.swift` | `7af01efb1dc9945c4ea09dc318ee4088` |
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
