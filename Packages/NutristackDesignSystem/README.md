# NutristackDesignSystem

Package Swift du système de design **Nutristack**. Il implémente la référence
verrouillée **Design System v2.0.1** : tokens, 15 composants, prévisualisations
et tests des règles. C’est la première brique du jalon M1 du Plan d’exécution.

## Contenu

| Dossier | Rôle |
|---|---|
| `Tokens/` | Couleur (§3), typographie (§4), espace et formes (§5), motion (§8), formats de microcopie (§10) |
| `Foundation/` | Couleurs hexadécimales dynamiques, formes (hachures, coche, contenant générique), primitives (filet, retour tactile de rangée) |
| `Components/` | Les 15 composants du DS §12, chacun avec 3 prévisualisations (clair, sombre, AX1) |
| `Tests/` | Règles vérifiées : formats (prix, masses, VNR, notes), bornes des jauges, libellés de provenance et du badge vérifié |

Composants : `Packshot` · `DSButtonStyle` / `PrimaryButton` · `MetricTile` (+ `MoneyText`) ·
`ActiveGauge` (+ `ActiveGaugeCaption`) · `SegmentedProgress` · `ProvenanceChip` ·
`VerifiedBadge` · `IntakeRow` · `ProductRow` · `AttentionBanner` · `VerdictCard` ·
`AnchoredActionBar` · `EmptyState` · `SkeletonBlock` · `dsToast`.

## Prérequis

Xcode 15.x — **pas 16** : les variantes d’icône sombre et teintée ne sont
volontairement pas déclarées, et le projet est généré par XcodeGen 2.43.0, dont
le format est celui que lit Xcode 15.4. iOS 17 minimum (cible du PRD §12).

## Installation

Le package s’ajoute au projet de l’application en dépendance locale
(File → Add Package Dependencies → Add Local), ou par son dépôt Git une fois publié.
Une seule cible produit : `NutristackDesignSystem`.

```swift
import NutristackDesignSystem
```

## Polices (condition du rendu exact)

La famille unique est **Schibsted Grotesk** (licence SIL OFL). Les cinq graisses
statiques que le code emploie — Regular, Medium, SemiBold, Bold, ExtraBold —
**sont versionnées** dans `Sources/NutristackDesignSystem/Resources/Fonts/` :
rien à télécharger. `DSFontRegistrar` enregistre tout `.ttf` de ce dossier ; y
ajouter des italiques ou d’autres graisses les embarquerait dans le binaire sans
qu’aucun style ne les demande, la hiérarchie typographique du DS §4 se
construisant par la graisse et jamais par un changement de famille.

Au démarrage de l’application, appelez :

```swift
DSFontRegistrar.registerBundledFonts()
```

Sans ces fichiers, SwiftUI retombe silencieusement sur la police système :
tout fonctionne, mais le rendu n’est pas contractuel. `DSFontFamily.isAvailable`
permet de le vérifier à l’exécution (et en test d’interface).

## Usage

Tuiles de la fiche produit (montants en centimes, règle du PRD §13) :

```swift
MetricTile(moneyCents: 1990, unit: "0,33\u{00A0}€ par jour", label: "Prix · 60 jours")
MetricTile(moneyCents: 111, unit: "/ g de Mg élémentaire",
           label: "Prix par actif", isHero: true)
```

Écran poussé avec barre d’action ancrée (structure du DS §12) :

```swift
ScrollView {
    // contenu de la fiche
}
.safeAreaInset(edge: .bottom) {
    AnchoredActionBar {
        PrimaryButton("Ajouter à ma stack") { }
        Button("Comparer") { }.buttonStyle(DSButtonStyle(.secondary))
    }
}
```

Jauge d’actif, toujours accompagnée de ses valeurs (DS §7) :

```swift
ActiveGauge(fraction: 0.125)
ActiveGaugeCaption(
    leading: Text("soit ") + Text("300\u{00A0}mg").bold() + Text(" de Mg élémentaire"),
    trailing: DSFormat.percentVNR(80)
)
```

## Règles portées par le code

- Les montants circulent en **centimes**, les masses en **milligrammes** ;
  `DSFormat` produit les chaînes conformes (espaces insécables, virgule
  française, dates en français) et reste le seul endroit où un nombre devient
  du texte.
- `DSFont.scaled(_:_:relativeTo:)` est le seul chemin autorisé vers une taille
  de police non encore nommée dans `DSTextStyle` : il garantit le `relativeTo:`
  sans lequel le texte ignorerait Dynamic Type. `Font.custom(_:size:)` est
  proscrit.
- `DSColor` porte aussi les trois tokens de l’exception caméra du scanner, pour
  qu’aucune valeur hexadécimale ne subsiste dans un écran.
- `VerifiedBadge` impose le décompte : la mention « vérifié » n’existe jamais
  accolée à une note seule (DS §10).
- `ActiveGauge` et `SegmentedProgress` bornent leurs entrées et respectent
  `Réduire les animations`.
- La géométrie des jauges est masquée de VoiceOver ; les valeurs sont annoncées
  en clair (DS §11).

## Tests

`swift test --package-path Packages/NutristackDesignSystem`, sur hôte macOS,
comme en CI : `Package.swift` déclare `.iOS(.v17)` **et** `.macOS(.v14)`
précisément pour que la suite tourne sans simulateur. Aucune cible de test Xcode
n’existe — XcodeGen n’en génère pas pour les paquets locaux — et `⌘U` sur le
schéma `Nutristack` répondrait « Scheme Nutristack is not currently configured
for the test action ». Ces tests vérifient les règles, pas les pixels ; les
tests d’instantanés arrivent avec l’app hôte (Plan §4).

## Gouvernance

Toute évolution visuelle passe d’abord par un amendement versionné du
Design System (procédure du §0), puis se répercute ici. Ce package ne contient
aucune valeur qui ne soit pas dans le document de référence.
