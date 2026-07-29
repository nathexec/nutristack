# Audit final avant verrouillage · Nutristack v1.0

**Date** 25 juillet 2026 · **Périmètre** 58 fichiers Swift (5 762 lignes), 2 paquets, configuration, icône, documentation · **Référentiels** PRD v1.0.1 (lu, sections 5 à 10 extraites), Plan d’exécution v1.0.1 (jalons), Design System v2.0.1, Prototype v1.0 (maquette verrouillée)

**Méthode** Seize phases du protocole imposé. Chaque conclusion s’appuie sur une vérification citée au §6 ; ce qui n’a pas pu être vérifié est marqué NON VÉRIFIÉ et rassemblé aux §7 et §8. Aucun résultat des audits précédents n’a été tenu pour acquis : toutes les batteries ont été relancées, et trois vérificateurs nouveaux ont été construits pour cette passe.

---

## 1. Résumé exécutif

Le projet est un **jalon M1 enrichi** : l’application complète des sept écrans de la maquette, sur catalogue de démonstration en mémoire, avec la logique métier réelle dans un paquet de domaine testé. Ce n’est pas le MVP du PRD : cinq lots entiers (onboarding, rédaction d’avis, détail d’élément de stack et rappels, flux produit introuvable, persistance et réseau) relèvent des jalons M2-M3 du Plan et n’existent pas. La matrice du §3 le montre exigence par exigence.

Sur son périmètre, l’audit a trouvé **neuf anomalies réelles que huit passes précédentes avaient manquées**, dont un bug fonctionnel reproductible (un second toast s’effaçait à peine affiché), un manquement au PRD §7.6 (le tooltip du badge citait les chiffres du relecteur au lieu de la règle), un état vide spécifié mais absent, et une information transmise par la couleur seule dans le comparateur. Les neuf sont corrigées, la non-régression est vérifiée par les mêmes batteries, et 39 assertions métier ont été recalculées hors de Swift sans écart.

La limite de fond n’a pas changé : **aucune compilation réelle n’a jamais eu lieu**. Le verdict en tient compte.

---

## 2. Scores de qualité

Chaque score est donné au référentiel du périmètre livré (démo M1) ; la conformité au PRD-MVP complet figure en seconde lecture là où elle diverge.

| Axe | /100 | Justification |
|---|---|---|
| Conformité fonctionnelle | **90** | Au périmètre démo : matrice §3, 39 recalculs conformes, 5 arbitrages maquette ouverts (§9). Au PRD-MVP complet : **≈ 40**, cinq lots M3 absents, tous planifiés. |
| Qualité du code | **93** | 12 balayages à zéro anomalie (§6), 759 lignes de documentation, vocabulaire et conventions unifiés, aucune valeur magique monétaire. Réserve : jamais compilé. |
| Architecture | **92** | Trois couches étanches vérifiées par leurs dépendances (le domaine n’importe que Foundation), dépôt injecté par l’environnement, source de vérité unique par état. Dette assumée : `DemoCatalog` dans le module de production (§9). |
| Robustesse | **78** | États vide, chargement, annulation et répétition traités, dont quatre corrigés par cette passe. `precondition` sur les variantes = arrêt volontaire sur données invalides, à déplacer côté dépôt en M3. Comportement caméra réel NON VÉRIFIÉ. |
| Tests | **80** | 33 cas ciblant les risques (calculs, classements, seuils, tris) ; 39 assertions recalculées indépendamment. **Jamais exécutés par XCTest ici** ; aucun test d’instantané ni d’interface. |
| Performance | **82** | Dérivations en O(n) sur n ≤ 8, identités hors des boucles, égalité des routes sur l’identifiant, aucune E/S ; aucun travail dans `body` au-delà des projections. **Aucune mesure réelle possible.** |
| Fluidité | **NON MESURÉE** | Conception saine (animations sur tokens, `reduceMotion` honoré, annulation propre). Estimation de conception : 85. Aucune exécution sur appareil. |
| Accessibilité | **88** | Dynamic Type systématique, cibles 44 pt, recouvrements `isModal`, jauges annoncées en clair, vainqueur du comparateur désormais verbalisé. Non testé avec VoiceOver réel. |
| Sécurité | **95** | Aucun secret, aucun appel réseau, `UserDefaults` limité à l’apparence, permission caméra motivée. Pas d’analyse binaire possible. |
| Maintenabilité | **93** | Un seul endroit par décision (formats, seuils, classements, dépôt) ; documentation au niveau des intentions ; CHANGELOG tenu. |

---

## 3. Matrice de traçabilité PRD → code → tests

Statuts : ✅ conforme · 🟠 partiel · ⏳ non implémenté, planifié (jalon indiqué) · ✳ implémenté différemment, documenté. Les tests cités sont dans `DomainTests` (D), `FormatTests`/`FormatAuditTests` (F), `ComponentRuleTests` (C).

| Exigence (PRD) | Implémentation | Test | État |
|---|---|---|---|
| 5.3 Onboarding | · | · | ⏳ M3 |
| 5.4 Date + salutation | `TodayView` en-tête dérivé de `store.today` | F (formats) | ✅ |
| 5.4 Checklist par moments, coche 1 tap | `TodayStore.sections/toggle`, `IntakeRow` | D (ajout) | ✅ |
| 5.4 Undo 5 s, swipe « sauté », appui long | bascule réversible seule | · | 🟠 M3 |
| 5.4 Carte « À surveiller » (< 10 j) | `watchSection`, seuil du domaine | D (seuil, tri) | ✅ |
| 5.4 Coût du jour | `consumedCostCents/plannedCostCents` | D (coûts) | ✅ |
| 5.4 État stack vide | `EmptyState` → scanner | · | ✅ **(corrigé A5)** |
| 5.4 Fuseaux, rattrapage 72 h, produit en pause | · | · | ⏳ M3 |
| 5.5 Recherche instantanée nom+marque+ingrédient | `DemoCatalogRepository.search` | · | ✅ (tolérance aux fautes ⏳ M3) |
| 5.5 Chips catégories | `FilterPills` | · | ✅ |
| 5.5 « Meilleur prix par actif » à actif unique | `CatalogRanking.comparableGroup` | D (groupe, écart) | ✅ |
| 5.5 « Les mieux notés » (vérifié) | `CatalogRanking.topRated` | D | ✅ (seuil n ≥ 5 non appliqué : 🟠) |
| 5.5 « Ajoutés récemment », filtres/tris avancés | · | · | ⏳ M3 |
| 5.5 Sans résultat → scanner/demande d’ajout | `EmptyState` | · | ✅ (création de tâche ⏳ M3) |
| 5.6 Header : photo, marque, nom, variantes | `ProductDetailView.header`, variantes actives | D (variantes) | ✅ (badges certifs ⏳ M2) |
| 5.6 Quatre tuiles, héros prix/g élémentaire | `tiles`, recalcul par conditionnement | D (exact/arrondi) | ✅ |
| 5.6 Provenance + date, détail par champ | `ProvenanceChip`, `ProvenanceSheet`, dates réelles | D (dates, ancienneté) | ✅ |
| 5.6 Composition normalisée, % VNR, sheet pédagogique | `composition`, `ActiveGauge`, `LabelExplainerSheet` | D (fractions, VNR) F (masses) | ✅ (toggle portion/jour ⏳ M3) |
| 5.6 Avis : Vérifiés/Tous, règle réelle | filtre par `VerificationRule` | D (2/3 vérifiés) | ✅ |
| 5.6 « Donner mon avis », signaler, complétude | · | · | ⏳ M3 |
| 5.6 Barre d’action : Ajouter · Comparer (même actif) | `StackStore.add`, `cheapestAlternative` | D (alternative) | ✅ |
| 5.7 2 produits même actif, contrainte ferme | seuls chemins d’entrée à actif identique | D (ordre lignes) | ✅ (3 produits 🟠 M3) |
| 5.7 Tableau, meilleure valeur surlignée | `CompareView`, cellules gagnantes | D (gagnants) | ✅ (+ verbalisation **A6**) |
| 5.7 Verdict généré par règles | `ComparisonEngine.verdict` | D (nom court, écart) | ✅ |
| 5.7 Bandeau formes différentes | `AttentionBanner` si `!sameForm` | · (déclenché par nomega) | ✅ |
| 5.7 Image de partage | `CompareShareSheet` (ImageRenderer ×3) | · | ✅ NON VÉRIFIÉ visuellement |
| 5.8 Scanner plein écran, torche | `ScannerView`, `CameraScannerEngine` | · | ✳ AVFoundation (PRD : VisionKit) §9 |
| 5.8 Succès → sheet compacte, Ajouter/Voir | fiche de résultat | · | ✅ (2 métriques sur 3 : 🟠) |
| 5.8 Saisie manuelle, 5 derniers scans, flux J2 | · | · | ⏳ M3 |
| 5.9 Liste stack : dose, moments, coût/j, jauge | `StackScreen`, `StockGauge` | D (prévisions) | ✅ |
| 5.9 Header coût €/j·€/mois·an, prochain rachat | agrégats du domaine | D (179/5370/644) | ✅ |
| 5.9 Détail d’élément, rappels, économie, totaux EFSA | · | · | ⏳ M3 |
| 5.10 Rédaction d’avis (5 étapes, déclaration) | déclaration affichée sur avis existants | · | ⏳ M3 |
| 6.6 Calculs en centimes/mg, arrondi à l’affichage | tout le domaine | D + 39 recalculs | ✅ (mensuel : arbitrage §9.5) |
| 7.3 Seuils 20 prises / 21 jours | `VerificationRule` | D, C | ✅ (granularité critères ⏳ M3) |
| 7.6 « Effet perçu », tooltip = la règle, n avec la note | wording vérifié partout, badge corrigé | C (**renforcé A4**) | ✅ |
| 9 Verdict nuancé (avantages conservés) | sous-titre du verdict | D | ✅ |
| 10 Prédiction de rachat (1 dose/j) | `RestockForecast` | D (9 j, 3 août) | ✅ (adhérence 14 j ⏳ M3) |

---

## 4. Anomalies détectées (toutes corrigées sauf mention)

| ID | Sévérité | Fichier | Problème | Impact | Correction |
|---|---|---|---|---|---|
| A1 | **Majeure** | `AppToast.swift` | `.task(id:)` : l’annulation par un second message était avalée par `try?`, puis `message = nil` s’exécutait quand même | Le second toast disparaissait à peine affiché (reproductible : « Ajouter » puis bascule du filtre) | Sortie sur annulation ; l’effacement n’a lieu que si le délai va au bout |
| A2 | Mineure | `CompareView.swift` | Même motif dans la cascade de révélation | Boucle déroulée sans délais sur une vue disparue | `try await` + sortie sur annulation |
| A3 | Moyenne | `ScannerView.swift` | La caméra ré-émet le même EAN à chaque image ; un code inconnu déclenchait un toast en rafale | Spam d’avertissements sur appareil | Mémoire du dernier code refusé |
| A4 | Moyenne | `VerifiedBadge.swift`, `ProfileView` | Tooltip « au moins 47 prises » : chiffres du relecteur au lieu de la règle (PRD §7.6), formulation logiquement fausse | Wording de confiance non conforme | Tooltip cite la règle ; seuils transmis depuis `VerificationRule` (badge + charte) ; test renforcé |
| A5 | Moyenne | `TodayView.swift` | État vide du PRD §5.4 absent (résumé à zéro affiché) | Écran incohérent si stack vide | `EmptyState` → scanner |
| A6 | Moyenne | `CompareView.swift` | Vainqueur signalé par la couleur seule | VoiceOver ignorait l’information centrale du tableau | Valeur verbalisée + « meilleure valeur » |
| A7 | Consignée | maquette vs PRD §6.6 | Coût mensuel : somme des coûts/jour **arrondis** ×30 (53,70 €) vs calcul exact arrondi à l’affichage (53,75 €) | Divergence spec/maquette | **Non corrigé** : arbitrage §9.5, tests verrouillent la maquette |
| A8 | Consignée | `CameraScannerEngine` | PRD §5.8 spécifie VisionKit ; implémentation AVFoundation | Écart d’outillage, fonctionnellement équivalent (+ torche) | **Non corrigé** : documenté, à trancher M3 |
| A9 | Mineure | `CompareView.swift` | Masses arrondies à l’entier dans les cellules (`Int(mg.rounded())`), défaut déjà corrigé sur la fiche mais resté ici | « 1,4 mg » deviendrait « 1 mg » | Surcharge décimale de `DSFormat` |
| F1 | Outillage | `check_call_sites.py` | Le vérificateur d’appels a produit 23 alertes, toutes fausses (extensions et propriétés annotées hors de portée de son analyseur) | Risque de « correction » de code sain | Les 23 tranchées par lecture directe des déclarations ; limite documentée ici |

## 5. Corrections effectuées

A1 à A6 et A9 ci-dessus, plus : test `ComponentRuleTests` renforcé (le tooltip doit citer « au moins 20 prises sur 3 semaines » et ne plus contenir les chiffres du relecteur), charte du profil dérivée de `VerificationRule`, `TodayView` restructuré en `routineContent` + état vide. Aucune donnée du catalogue, aucun format et aucune métrique n’ont changé : les invariants de la maquette sont intacts (vérifié §6).

## 6. Vérifications réellement exécutées

Toutes relancées après corrections (phase 15) : équilibre des délimiteurs (58 fichiers : 0), lignes > 120 (0), polices non dimensionnables (0), apostrophes droites et cadratins (0), `Continuation!` (0), placeholders (0), sommeils sans garde d’annulation (0 restant), privés inutilisés (0), collisions propriété/méthode (0), imports triés (conforme), visibilité inter-modules (0 problème), complétude des prévisualisations (0 incomplète), symboles non déclarés (0 réel après tri des faux positifs), secrets/URL non chiffrées/`UserDefaults` (rien de sensible), file du délégué caméra = principale (`assumeIsolated` sûr), **39 assertions métier recalculées hors Swift, zéro écart**, extraction de la maquette HTML pour les libellés, lecture du PRD §5-§10 et du Plan §2 pour la matrice.

## 7. Vérifications impossibles à exécuter ici

`swift build` / `swift test` / `xcodebuild` / SwiftLint réel : **aucun toolchain Swift** dans l’environnement (constaté), miroir officiel bloqué par la politique réseau (`host_not_allowed`, constaté), et le SDK iOS n’existe que sur macOS. Mesures de performance (Instruments), VoiceOver réel, rendu sur appareil, comportement AVFoundation réel : exigent un appareil. **Aucune de ces validations n’est remplacée par les contrôles statiques ci-dessus.**

## 8. Points non vérifiables restants

Rendu visuel exact des 66 prévisualisations (dont AX1 sur comparateur et grilles de tuiles) ; l’icône sur écran physique ; le chargement des cinq graisses Schibsted Grotesk (fichiers absents, repli système silencieux) ; l’égalité au pixel avec la maquette (vérifiée sur les textes et les valeurs, pas sur la géométrie rendue).

## 9. Dette technique et arbitrages assumés

1. `DemoCatalog` dans le module de production → cible SPM séparée avant soumission (README). 2. `precondition` variantes → validation côté dépôt en M3. 3-4. Erreurs de la maquette (0,058 €/g Boreal ; vendredi/samedi ; jauge whey) : le code applique la version juste, amendement documentaire à publier. 5. **Nouveau** : PRD §6.6 vs maquette sur le coût mensuel (53,70 vs 53,75 €) : à trancher, les tests verrouillent la maquette. 6. `StockGauge`/`DaysLeftChip` et les deux teintes de l’icône à verser au DS. 7. Concurrence `targeted` sur la cible app, passage Swift 6 planifié avec le SDK iOS 18.

## 10. Verdict

### 🟡 PRÊT SOUS RÉSERVE

**Prêt** : à être gelé comme v1.0 de démonstration du jalon M1. Le périmètre livré est fidèle à la maquette (matrice §3, 39 recalculs), le code passe l’intégralité des contrôles statiques, les neuf anomalies trouvées par cette passe sont corrigées sans régression mesurable.

**Sous réserve, dans l’ordre** : (1) ouvrir dans Xcode, compiler, exécuter les 33 tests, rien ici ne remplaçant le compilateur ; (2) déposer les polices ; (3) contrôler à l'œil les prévisualisations AX1 et l’icône sur appareil ; (4) trancher les cinq arbitrages du §9.

**Et sans ambiguïté** : au sens « production App Store grand public », la réponse est **non** : non par défaut de qualité, mais parce que le MVP du PRD (persistance, réseau, onboarding, avis, flux d’enrichissement) est le contenu planifié des jalons M2-M3.

### Les trois questions du protocole

1. **L’application fait-elle exactement ce qui était prévu ?** Au périmètre démo : oui, démontré par la matrice et les recalculs, à cinq arbitrages documentés près. Au périmètre PRD-MVP : non, et c’est planifié.
2. **Le code est-il réellement propre, robuste et maintenable ?** Sur tout ce qui est vérifiable statiquement : oui, preuves au §6. Sa robustesse *à l’exécution* : NON VÉRIFIÉE, faute de toute exécution possible ici.
3. **L’application est-elle réellement fluide et prête pour une utilisation réelle ?** NON VÉRIFIÉ. La conception ne contient aucun des anti-motifs coûteux recherchés (§2 des scores), mais aucune mesure sur appareil n’existe.
