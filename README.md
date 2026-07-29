# Nutristack · Application iOS

Application SwiftUI du MVP Nutristack, construite au pixel sur la maquette de
référence verrouillée (`Prototype_Nutristack_v1-0.html`) et sur le
Design System v2.0.1. Jalon **M1** du Plan d’exécution v1.0.1.

## Démarrage

Prérequis : macOS avec **Xcode 15** ou plus récent, et **XcodeGen**
(`brew install xcodegen`). Le projet Xcode est généré, jamais versionné.

```bash
./scripts/bootstrap.sh        # génère Nutristack.xcodeproj et l’ouvre
```

Polices (rendu contractuel) : téléchargez la famille **Schibsted Grotesk**
(Google Fonts, licence SIL OFL) et déposez les cinq graisses dans
`Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Resources/Fonts/`.
Sans elles, l’app fonctionne avec la police système (repli silencieux).

Cible : iOS 17, iPhone, portrait. Compilez le schéma `Nutristack` sur un
simulateur ou un appareil.

## Architecture

| Module | Rôle | Tests |
|---|---|---|
| `Packages/NutristackDesignSystem` | Tokens et 15 composants du DS v2.0.1, 45 prévisualisations | Règles de format et de composants |
| `Packages/NutristackDomain` | Logique pure : normalisation par actif, comparateur, coûts, rachat, règle de vérification, catalogue de démonstration | `swift test` (hôte macOS, comme en CI) |
| `App/Sources` | Navigation (`AppRouter`), magasins observables (`StackStore` source de vérité, `TodayStore` dérivé), dépôt de catalogue, écrans | Couverts par les paquets |

Principes appliqués (Plan §4) : MVVM léger avec `@Observable`, montants en
centimes et masses en milligrammes de bout en bout, et **aucune métrique
calculée dans une vue** : chaque valeur affichée (1,11 €/g, −40 %, 3 août,
53,70 €...) est dérivée du paquet de domaine, que les tests `DomainTests`
verrouillent sur la maquette. Les seules chaînes littérales des écrans sont
la microcopie ; dates, masses, montants et notes passent tous par `DSFormat`.
Concurrence stricte (`complete`) et avertissements traités en erreurs
(`Config/Base.xcconfig`).

## Correspondance avec la maquette

Aujourd’hui (résumé au format étiquette, progression segmentée, prises
réversibles, « À surveiller ») · Explorer (recherche et filtres réels sur le
dépôt) · Ma stack (agrégats du domaine, jauges de stock) · Profil (apparence
persistée, charte) · Fiche produit (jauge d’actif signature, provenance,
feuille pédagogique, barre ancrée) · Comparateur (cascade des cellules
gagnantes à 90 ms, verdict en ressort, **partage d’une image réellement
rendue** via `ImageRenderer`) · Scanner (cadre fixe de 240 pt, torche,
moteur caméra AVFoundation EAN-13/EAN-8 sur appareil, moteur simulé en
simulateur, appui sur le cadre pour une détection de démonstration).

## Icône

L’icône d’application est la jauge d’actif empilée trois fois, ses remplissages
reprenant les fractions élémentaires réelles du catalogue. Source vectorielle,
variantes sombre et teintée, planche de contrôle des tailles et script de
régénération dans `docs/icon/` ; le parti pris et la géométrie sont documentés
dans `docs/Icone_Nutristack_v1.1.md`. Les deux teintes de fond dérivées du vert
officinal restent à verser au Design System par amendement.

## Conventions de code

**Concurrence.** Les vues isolent explicitement sur l’acteur principal les
méthodes appelées depuis un contexte asynchrone (`@MainActor private func`),
plutôt que d’écrire la logique dans le corps d’un `.task`. Le point de bascule
devient visible et le compilateur peut le vérifier. Le réglage
`SWIFT_STRICT_CONCURRENCY` vaut `targeted` sur la cible applicative et le
raisonnement est consigné dans `Config/Base.xcconfig` ; les deux paquets de
logique sont écrits pour passer le mode strict.

**Nombres et dates.** Le domaine ne stocke que des types comparables : montants
en centimes, masses en milligrammes, dates en `Date`. Aucune chaîne
pré-formatée n’entre dans un modèle. La conversion en texte se fait au seul
endroit prévu, `DSFormat`, ce qui garantit un format unique par grandeur.

**Nommage des grandeurs.** Toute grandeur monétaire porte son unité dans son
nom : `priceCents`, `dailyCostCents`, `monthlyCostCents`, `yearlyCostEuros`.
Aucun appelant ne peut confondre des centimes avec des euros, et la relecture
d’un calcul se fait sans remonter à la déclaration.

**Typographie.** `DSTextStyle` pour les styles nommés, `DSFont.scaled` pour les
tailles qui n’en ont pas encore. `Font.custom(_:size:)` est proscrit : sans
`relativeTo:`, le texte ignore Dynamic Type.

**Couleurs.** Uniquement des tokens de `DSColor`, y compris pour l’exception
caméra du scanner. Aucune valeur hexadécimale dans un écran.

## Accessibilité

Toutes les tailles de texte passent par `DSTextStyle` ou `DSFont.scaled`, qui
imposent le `relativeTo:` sans lequel une police personnalisée ignorerait
Dynamic Type. Les écrans possèdent chacun une prévisualisation en taille AX1.
Les cibles tactiles atteignent 44 pt même quand le disque visible mesure 38 pt,
la géométrie des jauges est masquée au profit de valeurs annoncées en clair, et
un recouvrement plein écran retire l’arrière-plan de l’arbre d’accessibilité.

## Qualité

`swiftlint --strict` et SwiftFormat avec configurations versionnées ;
CI GitHub Actions (`.github/workflows/ci.yml`) : lint, tests du domaine,
compilation de l’app, tests du design system sur simulateur. Porte M1 :
zéro avertissement vérifié dans Xcode avant fusion.

## Écarts avec la maquette · résolus par le Prototype v1.1

Les quatre écarts ci-dessous, relevés à l’audit, ont été tranchés le
26 juillet 2026 : la maquette v1.1 les intègre, le code était déjà conforme
aux décisions. Conservés ici pour mémoire.

L’audit du code a relevé trois erreurs dans la maquette verrouillée elle-même.
Le code applique la version juste et attend l’amendement du document de
référence (procédure DS §0) :

| Écart | Maquette | Code |
|---|---|---|
| Prix par gramme de Boreal | `0,058 €/g` | `0,58 €/g` (25,20 € pour 43,2 g) |
| Jour de l’en-tête d’Aujourd’hui | « Vendredi 25 juillet » | dérivé de la date, soit « Samedi 25 juillet » |
| Jauge de stock de la whey | verte | ambre : 8,5 doses restantes, sous le seuil de 10 jours |

Le classement de la section « Meilleur prix par actif » suit le prix croissant,
là où la maquette place le produit le plus cher en premier sous ce titre.

## Injection du catalogue

Les écrans lisent `\.catalogRepository` dans l’environnement et ne nomment
jamais d’implémentation. `DemoCatalogRepository` n’apparaît qu’une seule fois
dans le projet, comme valeur par défaut de la clé d’environnement : brancher
GRDB et Supabase au jalon M3 se réduit à changer cette ligne.

## État partagé

`StackStore` est la source de vérité de la stack : composition, coûts, jauges
et prévisions de rachat. `TodayStore` n’en possède rien, il la lit et calcule
la journée à partir d’elle. Conséquence directe : un produit ajouté depuis une
fiche ou depuis le scanner apparaît immédiatement dans Aujourd’hui et dans Ma
stack, sans qu’aucun écran n’ait à en être informé. La persistance locale
arrivera au jalon M3 derrière ce même magasin, sans toucher aux écrans.

## Dette connue et assumée

**Données de démonstration dans le module de production.** `DemoCatalog` vit
dans le paquet de domaine et sera donc compilé dans le binaire de production.
C’est voulu au jalon M1, puisque les écrans en tirent tout leur contenu, mais
la séparation en cible distincte est recommandée avant la mise en production :
un produit `NutristackDemoData` déclaré dans le même paquet permettrait au
compilateur de signaler toute dépendance résiduelle à la suppression du jeu de
démonstration au jalon M3.

**Tests d’instantanés absents** et couverture du domaine non mesurée, alors que
le Plan §4 fixe un seuil de 85 %. À outiller au jalon M2.

## Prochaines étapes (Plan §1)

M2 : squelette de données GRDB et migrations. M3 : catalogue réel
(Supabase UE) derrière `CatalogRepository`, persistance des prises et de la
stack. Les protocoles sont déjà en place ; aucun écran ne change.
