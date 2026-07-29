# Dossier de validation Xcode · Nutristack v1.0

**Date** 26 juillet 2026 · **Objet** fermeture des réserves de l’audit final : ce document contient tout ce qu’il faut pour que la session Xcode ne réserve, idéalement, aucune surprise. **Règle de lecture** : « validé » signifie démontré dans cet environnement ; tout le reste est classé non vérifiable ici, avec la procédure exacte de vérification.

---

## 0. Résultats d’exécution réelle · 26 juillet 2026

Un toolchain **Swift 6.0.3** (distribution SwiftWasm, hôte Linux) a été obtenu
et a permis d’exécuter réellement une partie de cette checklist. Résultats
bruts, journaux conservés :

| Vérification | Résultat réel |
|---|---|
| Résolution SPM des deux paquets | **PASS** (rc = 0) |
| Build Debug du domaine | **PASS** · « Build complete! », 0 avertissement |
| Build Release du domaine | **PASS** · « Build complete! » |
| Tests du domaine (XCTest) | **PASS** · « Executed 20 tests, with 0 failures », relancés verts après chaque édition |
| Tests de formats (harnais Linux, source `DSFormat` identique au md5) | **PASS** · 9/9 |
| SwiftLint 0.57 `--strict` | **FAIL puis PASS** · 43 violations sérieuses → 0 après correctifs |
| Point chaud de compilation | **FAIL puis PASS** · inférence pathologique dans `RestockAlert.forecasts` (> 7 min), réécrite, module vérifié en 7 s |

**L’épisode SwiftLint mérite d’être retenu.** Trente et une violations venaient
de fichiers générés par SwiftPM dans `.build` (exclusion de configuration
manquante, ajoutée). Douze étaient réelles et invisibles à mes balayages :
liaisons d’une lettre dans des motifs `case .count(let n)` et fermetures
`{ a, b in }`, doubles fermetures à étiqueter sur `PushScaffold`, un
`for…where`, un tuple à trois membres devenu structure nommée, un token `y`
renommé `offsetY`, et une désactivation justifiée (`layerClass` : un override
exige `class`). Après correctifs : 0 violation sur 55 fichiers, et les 29 tests
relancés verts. Les étapes 4a, 5a, 6a, 6b, 7 et 8 du tableau ci-dessous sont
donc réellement PASS ; le reste demeure à exécuter dans Xcode.

## 1. Les corrections d’anomalies, revérifiées une à une

Rectification d’abord : le tableau de synthèse précédent annonçait « 8 corrigées, 1 arbitrage ». Le compte exact est **7 corrections de code** (A1 à A6, A9) et **2 points consignés** (A7, A8). La présente passe en ajoute une huitième : **A10**, une erreur de compilation que j’avais moi-même introduite (`await` superflu sur `renderCard()`, synchrone et même acteur ; avec les avertissements traités en erreurs, le build aurait échoué). Trouvée et corrigée ici, c’est précisément le rôle de cette passe.

| ID | Correctif | Preuve dans le code livré |
|---|---|---|
| A1 | Toast : effacement seulement si le délai va au bout | `AppToast.swift` : `do/catch` + `return` sur annulation |
| A2 | Cascade du comparateur annulable | `CompareView.swift:237` : `catch { return }` |
| A3 | Code inconnu signalé une seule fois | `ScannerView.swift` : `lastUnknownCode` (3 sites) |
| A4 | Tooltip = la règle, seuils venus du domaine | `VerifiedBadge` : `\(ruleIntakes) prises` ; fiche et charte lisent `VerificationRule` |
| A5 | État vide d’Aujourd’hui | `TodayView.swift:25` : `plannedCount == 0` → `EmptyState` |
| A6 | Vainqueur verbalisé pour VoiceOver | `CompareView` : `accessibilitySummary`, « meilleure valeur » |
| A9 | Masses décimales dans le comparateur | `CompareView:150` : `DSFormat.milligrams(mg)` |
| A10 | `await` superflu retiré | `CompareShareSheet` : `.task { renderCard() }` commenté |

Régression après A10 et le test ajouté : délimiteurs 0, lignes longues 0, apostrophes 0, sommeils non gardés 0, vérificateurs de visibilité et de prévisualisations à 0 problème.

## 2. Pourquoi A7 et A8 ne sont pas « corrigées »

**A7** oppose deux sources de vérité entre elles : la maquette verrouillée affiche 53,70 €/mois, le PRD §6.6 impose un calcul exact arrondi à l’affichage, soit 53,75 €. Corriger l’un revient à contredire l’autre ; la gouvernance du projet (DS §0) réserve ce choix à un amendement documentaire, pas à un correctif de code. Détail au §4.

**A8** est un écart d’outillage, pas un défaut : le PRD §5.8 nomme VisionKit, l’implémentation utilise AVFoundation, fonctionnellement équivalent et offrant le contrôle de la torche que la maquette exige. Le ratifier ou revenir à VisionKit est une décision d’architecture à inscrire au PRD, pas un bug.

## 3. Registre des cinq arbitrages

| # | Sujet | Implémenté (code) | Prévu (référence) | Source de vérité en conflit | Impact fonctionnel | Recommandation | Décision à prendre |
|---|---|---|---|---|---|---|---|
| 1 | Prix au gramme Boreal | **0,58 €/g** (25,20 € ÷ 43,2 g, recalculé) | 0,058 €/g (maquette) | Maquette contre arithmétique | Métrique fondatrice fausse d’un facteur 10 si on suit la maquette | Amender la maquette : l’arithmétique n’est pas négociable | Publier Prototype v1.1 corrigé |
| 2 | Jour de l’en-tête | **Dérivé de la date** → « Samedi 25 juillet » | « Vendredi 25 juillet » (maquette) | Maquette contre calendrier | Cosmétique, mais une date fausse mine la confiance | Amender la maquette | Idem |
| 3 | Jauge whey | **Ambre** (8,5 doses = 9 j < seuil 10 j) | Verte (maquette) | Maquette contre règle PRD §10 | L’alerte de rachat manquerait un produit | Garder la règle en jours, amender la maquette | Idem, ou changer la règle (déconseillé) |
| 4 | Ordre « Meilleur prix par actif » | **Prix croissant** (Nordika puis Alba) | Alba en premier (maquette) | Maquette contre le titre de la section | Un « meilleur prix » qui ouvre sur le plus cher est trompeur | Garder le tri croissant | Amender la maquette |
| 5 | Coût mensuel de la stack | **53,70 €** (somme des coûts/jour arrondis × 30) | 53,75 € (PRD §6.6 : exact, arrondi à l’affichage) | Maquette contre PRD | 5 centimes/mois, mais un principe comptable | Voir §4 : trancher pour la cohérence affichée, amender le PRD | Amendement PRD §6.6 (exception agrégats) |

## 4. La divergence 53,70 € / 53,75 €, tranchée

**Mécanique.** Coûts journaliers exacts : 33,17 + 20 + 42 + 84 = 179,17 c. Le PRD §6.6 (« tout en centimes, arrondi à l’affichage seulement ») donne 179,17 × 30 = 5 375 c → **53,75 €**. La maquette, verrouillée par les tests, arrondit chaque coût journalier (33 + 20 + 42 + 84 = 179 c) puis multiplie → **53,70 €**.

**Quelle valeur est canonique ?** Ma recommandation : **53,70 €, donc le comportement de la maquette, en amendant le PRD**. La raison n’est pas l’antériorité de la maquette mais un principe plus fort que §6.6 : *la somme de ce que l’écran montre doit égaler le total que l’écran montre*. L’utilisateur voit quatre lignes à 0,33, 0,20, 0,42 et 0,84 € ; il peut poser 1,79 €/j × 30 = 53,70 €. Afficher 53,75 € rendrait le produit inauditable par son propre lecteur, ce qui, pour une application dont la promesse est la vérifiabilité des prix, est pire qu’un écart de cinq centimes par rapport au réel. L’amendement à écrire dans le PRD : « les agrégats de la stack se calculent sur les coûts journaliers arrondis tels qu’affichés, afin que le total soit la somme exacte des lignes ». Jusqu’à cet amendement, la valeur canonique **de fait** est 53,70 € : le code et les tests l’appliquent.

## 5. Les 34 tests : correspondance aux exigences, et leur statut réel

Un 34ᵉ test a été ajouté par cette passe : `testShortDateForProvenance`, qui verrouille « 12 juil. 2026 », format du jugement de fraîcheur (PRD §8.3), jusqu’ici non couvert.

**Statut réel, sans détour : aucun de ces 34 tests n’a jamais été exécuté par XCTest.** Ce qui est démontré ici : (a) leurs valeurs attendues sont justes, 39 assertions recalculées indépendamment hors Swift ; (b) chaque API qu’ils référencent existe et est exportée (vérificateur de symboles). « Écrit et cohérent » n’est pas « passant » ; la ligne 6 de la checklist du §8 est ce qui transforme l’un en l’autre.

| Tests | Exigence couverte | Faiblesse connue |
|---|---|---|
| 1-5, 6-8, 34 (formats) | DS §10, PRD §6.6 : monnaie, masses, %VNR, dates fr | Dépendent de la locale `fr_FR` du runner (présente sur macOS) |
| 9-10 (progression, provenance) | DS §7, PRD §8.3 | Règles de composant, pas de rendu |
| 11 (badge) | PRD §7.6 : libellé + tooltip = la règle | Renforcé par A4 |
| 12-13 (hexadécimal) | Fondation couleurs | Aucune |
| 14-18 (métriques, verdict, coûts, rachat) | PRD §6.4, §9, §10 + invariants maquette | Verrouillent la maquette, donc l’arbitrage 5 |
| 19, 31 (règle d’usage) | PRD §7.2-7.3 : 20/21, 2 avis sur 3 | Granularité par critère = M3 |
| 20-22 (verdict nom court, ordre, exact) | Maquette + PRD §9 | Aucune |
| 23-25 (seuil, cohérence, dates) | PRD §10, §8.3 | 24 utilise le calendrier courant (fuseau du runner ; assertions en jours entiers, robuste) |
| 26 (conditionnements) | PRD §5.6 variantes | Aucune |
| 27-30 (classements, alternative) | PRD §6.1 : actif identique | Aucune |
| 32-33 (ajout, tri des alertes) | PRD §5.4/§10 + stabilité | Aucune |

Aucun test n’est compté « valide » : ils sont comptés **écrits, cohérents, aux valeurs prouvées**. Fonctionnalités critiques encore sans test : rendu des vues (aucun test d’instantané), navigation, scanner. Assumé pour M2.

## 6. Risques de compilation et d’exécution, par ordre de probabilité

| # | Risque | Localisation | Probabilité | Si ça casse |
|---|---|---|---|---|
| R1 | ~~`await` superflu~~ | CompareShareSheet | **Éliminé (A10)** | · |
| R2 | `onPreferenceChange` et isolation stricte | PushScaffold | Faible (SDK 17, `targeted`) | Envelopper dans `Task { @MainActor in }` |
| R3 | `#Preview` avec `let` + `return` | 6 écrans | Faible (fermeture simple, pas un result builder) | Extraire une vue conteneur |
| R4 | Macro `@Observable` + `@Environment(Type.self)` | magasins | Très faible (iOS 17 standard) | · |
| R5 | `MainActor.assumeIsolated` dans le délégué caméra | CameraScannerEngine | Très faible : file `.main` vérifiée ligne à ligne | Basculer sur `DispatchQueue.main.async` |
| R6 | Locale `fr_FR` des tests sur le runner | FormatTests | Très faible sur macOS | Fixer la locale du schéma de test |
| R7 | Fuseau horaire du runner (test 24) | DomainTests | Très faible (jours entiers) | Injecter un calendrier UTC |

## 7. Dépendances et ressources : état exact

**Vérifié présent** : catalogue d’assets complet (AppIcon 1024 RGB sans alpha, AccentColor, LaunchBackground, Contents racine) ; Info.plist généré avec `NSCameraUsageDescription`, `UILaunchScreen`, portrait seul ; deux paquets **sans aucune dépendance externe** (SPM vide de tiers, vérifié dans les deux Package.swift) ; ressources du DS déclarées `.process("Resources")` ; scripts `bootstrap.sh` et CI ; `Config/*.xcconfig` référencés existants.

**Vérifié absent, à fournir** : les **cinq graisses** de Schibsted Grotesk. Le code emploie exactement cinq poids (mesuré : regular ×7, medium ×1, semibold ×7, bold ×18, heavy ×10). Fichiers à déposer dans `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Resources/Fonts/` : `SchibstedGrotesk-Regular.ttf`, `-Medium.ttf`, `-SemiBold.ttf`, `-Bold.ttf`, `-ExtraBold.ttf` (Google Fonts, licence SIL OFL ; « heavy » SwiftUI ↔ ExtraBold 800). Sans eux : **compilation OK, rendu non contractuel** (repli système silencieux ; contrôle : `DSFontFamily.isAvailable`).

**Outils de poste** : Xcode 15.x (pas 16 : les variantes d’icône sombre/teintée ne sont volontairement pas déclarées), `brew install xcodegen swiftlint`.

## 8. Checklist de validation Xcode, dans l’ordre

Format par étape : **Déjà validé ici** / **À faire dans Xcode** / **Attendu** / **PASS si…**

1. **Ouverture** · Validé : `project.yml` cohérent, chemins existants. · Faire : `./scripts/bootstrap.sh` puis ouvrir `Nutristack.xcodeproj`. · Attendu : projet généré, 1 app + 2 paquets locaux. · PASS : Xcode ouvre sans « missing file ».
2. **Résolution des dépendances** · Validé : zéro dépendance externe. · Faire : laisser SPM résoudre les 2 paquets locaux. · PASS : résolution < 10 s, aucun téléchargement.
3. **Ressources** · Validé : assets et plist (§7). · Faire : déposer les 5 polices, vérifier leur apparition dans le bundle du paquet. · PASS : `DSFontRegistrar.registerBundledFonts()` retourne 5 (point d’arrêt ou log au démarrage).
4. **Build Debug** · Validé : 14 batteries statiques à zéro. NON VÉRIFIABLE ICI : la compilation elle-même. · Faire : ⌘B sur simulateur iPhone 15. · Attendu : 0 erreur ; risques résiduels §6. · PASS : « Build Succeeded », **0 avertissement** (ils sont traités en erreurs).
5. **Build Release** · Faire : schéma Release, ⌘B. · PASS : identique, optimisations comprises.
6. **Les 34 tests XCTest** · Validé : valeurs recalculées, API cohérentes. NON VÉRIFIABLE ICI : l’exécution. · Faire : `swift test --package-path Packages/NutristackDomain` puis idem DesignSystem (ou ⌘U). · PASS : **34/34 verts** ; tout rouge = régression réelle à traiter avant le gel.
7. **Avertissements** · PASS : panneau Issues vide après build des 3 cibles.
8. **Lint** · **PASS réel** : SwiftLint 0.57 exécuté ici, 43 violations trouvées puis corrigées, 0 restante sur 55 fichiers. Dans Xcode : simple confirmation.
9. **Simulateur** · Faire : ⌘R iPhone 15. · Attendu : Aujourd’hui s’affiche, « Samedi 25 juillet ». · PASS : lancement sans crash ni log d’erreur.
10. **Parcours critiques** · Faire, dans l’ordre : cocher/décocher une prise (compteur et coût animés) ; Explorer → recherche « oméga » → fiche Nordika ; fiche : changer de conditionnement (Alba : 0,33↔0,40 €/j), filtre d’avis Vérifiés↔Tous (2↔3), « Voir les autres avis » ; Comparer depuis la fiche (bandeau formes différentes sur les oméga-3) ; Ajouter à ma stack → vérifier la propagation immédiate dans Ma stack ET Aujourd’hui ; scanner simulé → « Déjà suivi » sur Alba. · PASS : chaque comportement conforme, aucune incohérence inter-écrans.
11. **Toast (A1)** · Faire : « Ajouter à ma stack » puis immédiatement basculer le filtre d’avis. · PASS : le second toast reste ~2 s (avant correction : il disparaissait aussitôt).
12. **Caméra (appareil réel obligatoire)** · NON VÉRIFIABLE ICI : tout AVFoundation. · Faire : lancer sur iPhone, accorder la permission, scanner un EAN réel (inconnu → un seul toast, pas de rafale : A3), torche, fermeture/réouverture. · PASS : flux visible, détection < 2 s, aucun toast répété.
13. **Accessibilité VoiceOver** · Validé : labels, traits, `isModal`, vainqueur verbalisé (A6). NON VÉRIFIABLE ICI : la lecture réelle. · Faire : VoiceOver sur fiche (composition lue en clair) et comparateur (« 0,66 €, meilleure valeur »). · PASS : aucune cellule muette, arrière-plan inatteignable sous un recouvrement.
14. **Dynamic Type AX1** · Validé : previews AX1 présentes partout, tailles toutes relatives. · Faire : ouvrir les 22 previews AX1 + réglage appareil ; regarder comparateur (3 colonnes) et grilles de tuiles. · PASS : aucun texte tronqué, aucune superposition.
15. **Mode sombre** · Faire : les 22 previews Sombre + bascule en direct dans Profil. · PASS : aucun aplat blanc résiduel, packshots lisibles.
16. **Animations** · Faire : cascade du comparateur (6 cellules puis verdict), retour en arrière **pendant** la cascade (A2), toast, transitions d’onglets, Réduire les animations activé. · PASS : aucune animation après disparition, respect de Reduce Motion.
17. **États vides** · Faire : preview `StackScreen` et `TodayView` avec `StackStore(entries: [])`. · PASS : les deux EmptyState mènent au scanner (A5).
18. **Erreurs** · Faire : scanner un code inconnu (simulateur : modifier `demonstrationCode`). · PASS : un seul toast, l’app reste stable.
19. **Performances** · NON VÉRIFIABLE ICI : toute mesure. · Faire : Instruments Time Profiler sur le parcours 10 ; viser 60 ips sur la cascade et le défilement. · PASS : aucun accroc visible, pas de travail principal > 8 ms/frame.
20. **Mémoire** · Faire : Instruments Leaks sur ouverture/fermeture ×10 du scanner et des fiches. · PASS : zéro fuite, la session caméra se libère.
21. **Icône** · Validé : PNG 1024 RGB sans alpha câblé, lisibilité mesurée jusqu’à 40 pt. NON VÉRIFIABLE ICI : le rendu physique. · Faire : écran d’accueil réel, voisinage d’autres icônes, réglages/Spotlight. · PASS : jauges distinctes aux trois tailles, vert non écrasé.
22. **Arbitrages** · Faire : décider les 5 points du §3, publier DS v2.0.2 + Prototype v1.1 + amendement PRD §6.6, y verser `StockGauge`, `DaysLeftChip` et les 2 teintes de l’icône. · PASS : plus aucun écart code/référentiels non signé.

## 9. Conclusion stricte

**A. Réellement validé aujourd’hui** : les 8 correctifs présents dans le code (preuves §1) ; 39 valeurs métier recalculées indépendamment ; cohérence statique totale (visibilité, prévisualisations, symboles, conventions, 0 avertisseur sur 14 batteries) ; ressources et configuration complètes hors polices ; absence de secrets et de réseau ; icône conforme aux contraintes App Store (format).

**B. Probablement correct mais non prouvé** : la compilation des 3 cibles (risques résiduels listés §6, tous faibles) ; le passage des 34 tests (valeurs prouvées, exécution jamais faite) ; le rendu fidèle des 66 previews ; la tenue AX1 du comparateur et des grilles.

**C. Encore inconnu** : tout le comportement caméra réel ; la fluidité et la mémoire mesurées ; la lecture VoiceOver effective ; le rendu de l’icône et du vert profond sur écran physique ; l’image de partage rendue.

**D. Ce qui bloque réellement le gel v1.0 de démonstration** : rien d’autre que l’exécution des étapes 1 à 9 de la checklist (dont dépôt des polices) et la signature des 5 arbitrages. Aucun défaut connu n’est en attente de correction.

**E. Nécessaire seulement pour passer de la démo au MVP (M2-M3)** : persistance GRDB + API Supabase derrière les protocoles déjà en place ; onboarding ; rédaction d’avis ; détail d’élément de stack, rappels et notifications ; flux produit introuvable (photos, file de traitement) ; séparation de `DemoCatalog` en cible SPM ; validation des données côté dépôt (remplaçant la `precondition`) ; tests d’instantanés et couverture mesurée ≥ 85 %.
