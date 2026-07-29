# Protocole de validation finale · Xcode et appareil réel · Nutristack v1.0

**Date** 26 juillet 2026 · **Préalable** code gelé (empreinte : `docs/Baseline_Gel_v1.0.md`) · **Objectif** prouver que le code actuel fonctionne comme prévu, pas l’améliorer.

**Statut des tests à l’entrée du protocole** : 20/20 domaine exécutés réellement, PASS · 9/9 formats exécutés réellement, PASS · 5/5 composants NON EXÉCUTÉS, BLOCKED (SDK SwiftUI/iOS absent de l’environnement de préparation) · total 29/34 exécutés avec succès, 5/34 restent à exécuter. Les 34 ne seront déclarés validés qu’après l’étape 6.

> **Addendum du 29 juillet 2026 — les étapes 2 à 8 sont PASS.** Le texte
> ci-dessus décrit l’état d’entrée du 26 juillet et n’est pas réécrit : c’est un
> état daté, pas un état courant. Ce qui a changé depuis figure au CHANGELOG
> 0.3.2 et dans `docs/Baseline_Gel_v1.0.md`, refigé en v1.1.
>
> Les étapes 2 à 8 ont été exécutées sur runner macOS 14 / Xcode 15.4 plutôt
> que sur un Mac de poste, et sont automatisées par
> `.github/workflows/build-and-test.yml`. **Résultat : PASS pour les sept**,
> exécution [30462450376](https://github.com/nathexec/nutristack/actions/runs/30462450376).
> **Le total est désormais 34/34 exécutés, 0 échec**, réserve close.
>
> Cette première exécution a levé 49 erreurs de compilation, toutes traitées
> sous grille de contrôle avant correction. Les étapes 4 et 5 avaient d’ailleurs
> anticipé le bon domaine de risque en nommant l’isolation d’acteur, mais pas la
> bonne forme : le repli proposé (`Task { @MainActor in … }`) aurait été un
> contresens ici, la correction juste étant l’annotation `@MainActor` des
> membres privés de vue.
>
> **Deux points de procédure à rectifier pour une prochaine version du
> protocole.** L’étape 7 dit « ⌘U sur les deux paquets » et l’étape 8 mentionne
> un « schéma de test » : il n’existe aucune cible ni aucun schéma de test dans
> `project.yml`, XcodeGen n’en générant pas pour les paquets locaux. La
> formulation exacte est celle que l’étape 6 donne déjà entre parenthèses,
> `swift test --package-path <paquet>`. Les étapes 9 à 22 restent à exécuter :
> elles exigent un simulateur piloté à la main, un appareil physique ou
> Instruments, qu’aucune automatisation ne remplace.

**Matériel requis** : Mac (macOS 14+), Xcode 15.x (pas 16 : les variantes d’icône sombre/teintée ne sont volontairement pas déclarées), `brew install xcodegen swiftlint`, simulateur iPhone 15 (iOS 17), un iPhone physique sous iOS 17, les polices Schibsted Grotesk (Google Fonts, licence SIL OFL, fichiers statiques).

**Règles transverses** :
- *Régression (définition générale)* : tout élément antérieurement PASS (y compris les 29 tests déjà verts et les valeurs de la maquette v1.1) qui devient FAIL après une action corrective.
- *Après toute correction* : appliquer la grille de contrôle de la baseline (problème, preuve, impact, correction minimale, risque, test), puis réexécuter au minimum les étapes 3 à 8 et l’étape corrigée, et consigner au CHANGELOG.
- *Journal* : tenir un tableau Étape / Date / Statut / Preuve (capture ou sortie) / Notes. Le verdict 🟢 exige 22 PASS ; tout autre état reste 🟡 avec liste.

---

## Étape 1 · Déposer les 5 polices exactes

**Procédure.** Télécharger la famille Schibsted Grotesk depuis Google Fonts, prendre les fichiers **statiques** (pas le fichier variable), copier exactement : `SchibstedGrotesk-Regular.ttf`, `SchibstedGrotesk-Medium.ttf`, `SchibstedGrotesk-SemiBold.ttf`, `SchibstedGrotesk-Bold.ttf`, `SchibstedGrotesk-ExtraBold.ttf` dans `Packages/NutristackDesignSystem/Sources/NutristackDesignSystem/Resources/Fonts/`. Supprimer le fichier d’attente `AJOUTER_LES_POLICES_ICI.txt` (ressource, pas code : autorisé).
**Attendu.** Le dossier contient exactement cinq `.ttf` aux noms ci-dessus (le code emploie cinq graisses, mesuré : regular, medium, semibold, bold, heavy où heavy correspond à ExtraBold 800).
**PASS.** `ls` du dossier = les 5 noms exacts, rien d’autre.
**FAIL.** Nom différent, graisse manquante, fichier variable unique.
**Régression.** Sans objet (première exécution).
**Si FAIL.** Reprendre l’archive Google Fonts, dossier `static/` ; ne pas renommer à la main un fichier d’une autre graisse.

## Étape 2 · Générer et ouvrir le projet

**Procédure.** À la racine : `./scripts/bootstrap.sh` (installe rien, appelle `xcodegen generate`), puis ouvrir `Nutristack.xcodeproj`.
**Attendu.** Génération sans erreur ; le navigateur montre l’app et les deux paquets locaux, aucun fichier en rouge.
**PASS.** Projet ouvert, zéro référence manquante.
**FAIL.** Erreur `xcodegen` ou fichier introuvable.
**Régression.** Un `project.yml` qui générait et ne génère plus.
**Si FAIL.** Lire l’erreur (chemin en cause), corriger `project.yml` seulement (configuration, sous grille), régénérer.

## Étape 3 · Résoudre les dépendances

**Procédure.** Laisser Xcode résoudre ; sinon File → Packages → Resolve Package Versions.
**Attendu.** Deux paquets locaux résolus, **aucun téléchargement réseau** (zéro dépendance externe, vérifié).
**PASS.** Résolution < 10 s, hors ligne possible.
**FAIL.** Toute tentative de récupération distante.
**Régression.** Apparition d’une dépendance tierce dans un `Package.swift`.
**Si FAIL.** Comparer les `Package.swift` à la baseline (md5), restaurer.

## Étape 4 · Compiler Debug, cible complète

**Procédure.** Schéma Nutristack, destination iPhone 15 (simulateur), ⌘B.
**Attendu.** « Build Succeeded ». Les avertissements sont traités en erreurs par les `.xcconfig` : un build vert vaut zéro avertissement.
**PASS.** 0 erreur, navigateur Issues vide.
**FAIL.** Toute erreur. Risques résiduels connus, dans l’ordre de probabilité : `onPreferenceChange` sous isolation (repli : envelopper la mutation dans `Task { @MainActor in … }`) ; `#Preview` contenant `let` + `return` (repli : extraire une petite vue conteneur).
**Régression.** Un fichier du domaine (déjà compilé vert sous Linux) qui échoue ici : incident d’intégration à tracer avant tout correctif.
**Si FAIL.** Grille de contrôle, correctif minimal, puis réexécuter 4 → 8.

## Étape 5 · Compiler Release, cible complète

**Procédure.** Product → Scheme → Edit Scheme → Run → Release (ou Build For Profiling), ⌘B.
**Attendu / PASS / FAIL.** Identiques à l’étape 4, optimisations comprises.
**Régression.** Un symbole éliminé par l’optimiseur révélant un usage douteux.
**Si FAIL.** Grille ; comparer le journal Debug/Release pour isoler l’effet d’optimisation.

## Étape 6 · Exécuter les 5 tests composants

**Procédure.** ⌘U sur le paquet NutristackDesignSystem (ou `swift test --package-path Packages/NutristackDesignSystem` sur le Mac) ; suite `ComponentRuleTests`.
**Attendu.** « Executed 5 tests, with 0 failures ». Contenu notable : le tooltip du badge doit citer « au moins 20 prises sur 3 semaines » et ne plus contenir « 47 » (correctif A4).
**PASS.** 5/5 verts. **C’est ici, et seulement ici, que le total devient « 34/34 exécutés, PASS ».**
**FAIL.** Tout rouge : noter le nom exact du test et le message.
**Régression.** Sans objet (première exécution) ; ensuite, tout re-run doit rester 5/5.
**Si FAIL.** Déterminer si l’écart est dans le composant ou dans l’attente du test ; dans les deux cas, grille avant modification.

## Étape 7 · Relancer les 34 tests au complet

**Procédure.** ⌘U sur les deux paquets.
**Attendu.** 20 + 9 + 5 = 34, zéro échec.
**PASS.** 34/34.
**FAIL.** Tout rouge.
**Régression.** Un des 29 tests verts sous Linux qui casse sous macOS : suspects connus, la locale du runner (`fr_FR` requis par les tests de formats) et le fuseau du calendrier courant (test 24 des prévisions).
**Si FAIL plateforme.** Fixer la locale/région du schéma de test ou injecter un calendrier UTC dans le test concerné (modification sous grille, test à l’appui).

## Étape 8 · Vérifier l’absence d’avertissements critiques

**Procédure.** Après 4 et 5 : navigateur Issues sur les trois cibles ; option : Product → Analyze.
**Attendu.** Panneau vide (rappel : warnings = erreurs, donc un build vert suffit ; l’Analyze est un bonus).
**PASS.** 0 issue, 0 résultat d’analyse bloquant.
**FAIL.** Tout avertissement résiduel (schéma de test compris).
**Régression.** Avertissement apparu après un correctif.
**Si FAIL.** Grille.

## Étape 9 · Lancer sur simulateur

**Procédure.** ⌘R, iPhone 15, iOS 17.
**Attendu.** Lancement sans crash ; Aujourd’hui affiche « Samedi 25 juillet », 4 prises, coût du jour 1,79 €, veille « Créatine ≈ 9 j ».
**PASS.** Aucun crash, console propre (hors bruit système), et la police rendue est bien Schibsted Grotesk : contrôle visuel (dessin caractéristique du « a », chiffres du coût), et en cas de doute, pause puis `p DSFontFamily.isAvailable` dans lldb → `true`.
**FAIL.** Crash, écran vide, ou police système apparente (repli silencieux).
**Régression.** Tout écart avec la maquette v1.1.
**Si FAIL police.** Refaire l’étape 1 ; vérifier que les `.ttf` sont dans le bundle du paquet (Build Phases du paquet, ressources traitées).

## Étape 10 · Parcours critiques

**Procédure et attendus, dans l’ordre.**
1. Aujourd’hui : tout cocher → 4/4, « Routine terminée. À demain. », coût consommé 1,79 € ; décocher une → le message disparaît.
2. Veille : « Créatine · ≈ 9 j · 3 août » ; toucher → fiche.
3. Explorer : « oméga » → 2 résultats ; chip Protéines → 2 ; effacer → tout.
4. « Meilleur prix par actif · Magnésium » : **Nordika avant Alba** (v1.1) ; écart affiché −40 %.
5. Fiche Alba : pastilles 120/60 gélules → 0,33 ↔ 0,40 €/j et 1,11 ↔ 1,32 €/g ; avis Vérifiés = 2, Tous = 3 ; « Voir les 2 autres avis » déplie ; feuille de provenance : Étiquette 12 juil. 2026, Prix 21 juil. 2026.
6. Comparer : cascade de 6 cellules puis verdict « Nordika revient 40 % moins cher au gramme de magnésium » avec la nuance Alba ; bandeau « Formes différentes » présent sur la comparaison des oméga-3 (fiche Boreal → Comparer).
7. Ajouter Nordika à la stack → toast, bouton « Dans votre stack ✓ » ; **propagation immédiate** : Ma stack passe à 5 produits, coût 58,80 €/mois · 705 €/an (179 + 17 = 196 c/j) ; Aujourd’hui affiche 5 prises (Matin : oméga + Nordika).
8. Scanner (mode simulé) : détection automatique d’Alba ; « Déjà suivi » désactivé ; « Voir la fiche » ouvre la fiche.
**PASS.** Chaque valeur exacte, aucune incohérence entre écrans.
**FAIL.** Toute valeur fausse ou propagation manquante.
**Régression.** Les valeurs 1,79 € / 53,70 € / 9 j / 3 août / −40 % sont contractuelles (maquette v1.1 + tests).
**Si FAIL.** Consigner observé vs attendu, grille.

## Étape 11 · Tester la caméra

**Procédure.** Appareil physique uniquement (le simulateur n’a pas de caméra : y exécuter cette étape = NOT APPLICABLE, la reporter à l’étape 20). Accorder la permission ; viser un EAN réel du commerce ; torche on/off ; fermer/rouvrir le scanner cinq fois.
**Attendu.** Flux visible < 1 s ; détection < 2 s ; le produit du commerce est inconnu du catalogue de démonstration → **un seul** toast « Produit introuvable » par code (correctif A3), pas de rafale ; la torche répond ; aucune dégradation après les cycles. Note honnête : les EAN de la démo n’ont pas de clé de contrôle valide, un code-barres imprimé depuis ces valeurs ne sera pas décodé ; le chemin « succès caméra » n’est donc pas testable au jalon M1, le chemin succès étant couvert par le moteur simulé (étape 10.8). Permission refusée : l’app doit rester stable et informative ; le comportement précis n’a jamais été spécifié, consigner l’observé.
**PASS.** Détection réelle + unicité du toast + torche + cycles sans incident.
**FAIL.** Rafale de toasts (retour A3), gel du flux, crash au refus de permission.
**Régression.** Retour du spam corrigé.
**Si FAIL.** Grille.

## Étape 12 · Toast et interactions rapides

**Procédure.** Fiche : « Ajouter à ma stack » puis, immédiatement, une seconde action produisant un toast (bascule du filtre d’avis, second ajout depuis une autre fiche). Puis, sur Aujourd’hui : dix bascules rapides d’une même coche.
**Attendu.** Le second toast **remplace** le premier et reste ≈ 1,9 s (correctif A1 : avant, il disparaissait aussitôt) ; jamais deux pilules empilées ; après dix bascules, l’état final est cohérent (pair = décoché) et les compteurs justes.
**PASS.** Comportements ci-dessus observés.
**FAIL.** Toast fantôme, empilement, compteur désynchronisé.
**Régression.** Retour du bug A1.
**Si FAIL.** Grille.

## Étape 13 · États vides et erreurs

**Procédure.** Les états vides ne sont pas atteignables en usage (pas de suppression au jalon M1) : les vérifier par une prévisualisation jetable injectant `StackStore(entries: [])` dans `TodayView` et `StackScreen`. Autorisation encadrée : ce fichier de preview temporaire est hors baseline, jamais commité, supprimé après contrôle (diff final vide). Erreurs au simulateur : la caméra absente doit basculer proprement sur le moteur simulé.
**Attendu.** Les deux écrans montrent l’EmptyState (« Votre stack est vide… ») et leur bouton ouvre le scanner (correctif A5) ; le scanner au simulateur affiche le mode simulé sans erreur.
**PASS.** EmptyState des deux écrans opérationnels, bascule simulée propre.
**FAIL.** Résumé à zéro affiché (retour A5), écran noir du scanner.
**Régression.** Retour A5.
**Si FAIL.** Grille.

## Étape 14 · VoiceOver

**Procédure.** Activer VoiceOver (appareil de préférence). Parcourir : une rangée de prise (nom, dose, état, bouton), la composition de la fiche (« Bisglycinate de magnésium, 2 400 mg, soit 300 mg de magnésium élémentaire, 80 pour cent des VNR »), le comparateur (« 0,66 €/g de magnésium, meilleure valeur » sur les cellules gagnantes, correctif A6), les jauges (« Stock restant 22 % », « Environ 9 jours restants »), le recouvrement du scanner (le fond doit être inatteignable).
**Attendu.** Chaque élément listé est lu comme spécifié ; aucun élément muet ; aucun piège de focus.
**PASS.** Lecture conforme sur les cinq points.
**FAIL.** Cellule muette, vainqueur non annoncé, fond atteignable sous le scanner.
**Régression.** Retour A6.
**Si FAIL.** Grille.

## Étape 15 · Dynamic Type

**Procédure.** Ouvrir les 22 prévisualisations AX1 ; puis, au simulateur, Réglages → Accessibilité → Taille du texte au maximum ; parcourir Aujourd’hui, la fiche (grille de tuiles 2×2), le comparateur (trois colonnes), la barre d’onglets.
**Attendu.** Tout est relatif (aucune taille de police figée, vérifié statiquement) : les textes grandissent, rien ne se superpose, aucune valeur monétaire ni nom de produit tronqués, cibles ≥ 44 pt.
**PASS.** Aucune troncature critique, aucune superposition.
**FAIL.** « … » sur une métrique héros ou chevauchement de colonnes.
**Régression.** Écart avec les prévisualisations AX1 livrées.
**Si FAIL.** Grille (correctif probable : passage des grilles en une colonne aux tailles d’accessibilité).

## Étape 16 · Dark Mode

**Procédure.** Les 22 prévisualisations Sombre ; bascule en direct dans Profil (Auto/Clair/Sombre) ; réglage système.
**Attendu.** Palette sombre du DS partout : aucun aplat blanc résiduel, hairlines visibles, packshots et toast lisibles, l’accent sombre `#4EB08C` appliqué.
**PASS.** Aucun défaut de contraste sur le parcours complet.
**FAIL.** Un élément illisible ou resté clair.
**Régression.** Écart avec les prévisualisations Sombre.
**Si FAIL.** Grille (ajustement de token DSColor).

## Étape 17 · Animations et Reduce Motion

**Procédure.** Observer : cascade du comparateur (six cellules ≈ 90 ms puis verdict), **retour arrière pendant la cascade**, apparition/disparition du toast, coche de prise, transitions d’onglets, ligne de balayage du scanner. Puis Réglages → Accessibilité → Réduire les animations, et refaire le parcours.
**Attendu.** Aucune animation ne continue après la disparition d’une vue (correctif A2) ; avec Réduire les animations, la ligne de balayage du scanner est désactivée (codé) ; consigner le comportement observé des autres animations sous Reduce Motion, la politique fine n’étant spécifiée que pour le scanner.
**PASS.** Pas d’animation orpheline ; scanline coupée sous Reduce Motion ; rien de saccadé à l'œil.
**FAIL.** Cascade qui continue après retour (retour A2), scanline active malgré le réglage.
**Régression.** Retour A2.
**Si FAIL.** Grille.

## Étape 18 · Performances (Instruments)

**Procédure.** Product → Profile (Release) → Time Profiler + Animation Hitches. Scénarios : défilement continu de la fiche et d’Explorer, cascade du comparateur, ouverture du scanner.
**Attendu.** Aucune mesure n’existe encore : **cette session crée la baseline de performance.**
**PASS.** Zéro hitch sévère récurrent ; travail du thread principal < 8 ms par frame en défilement stationnaire ; cascade fluide à l'œil et à l’instrument.
**FAIL.** Hitch systématique reproductible sur un scénario.
**Régression.** Sans objet à la première mesure ; ensuite, toute dégradation par rapport aux valeurs consignées ici.
**Si FAIL.** Pile d’appels d’Instruments à l’appui, grille.

## Étape 19 · Mémoire (Instruments)

**Procédure.** Instruments → Leaks + Allocations. Scénarios : scanner ouvert/fermé ×10, dix fiches, dix comparateurs, retour à l’accueil.
**Attendu.** Zéro fuite ; allocations stables après retour à l’état initial (delta < 5 Mo, pas de croissance monotone) ; la session caméra se libère à la fermeture.
**PASS.** Les trois conditions.
**FAIL.** Fuite détectée ou croissance continue.
**Régression.** Sans objet à la première mesure ; baseline créée ici.
**Si FAIL.** Graphe d’allocations à l’appui, grille.

## Étape 20 · Appareil physique

**Procédure.** Signer avec une équipe personnelle, ⌘R sur iPhone iOS 17. Rejouer en condensé les étapes 9, 10, 12 à 17, plus l’étape 11 en entier, plus le retour haptique du scan (perceptible uniquement sur appareil).
**Attendu.** Parité avec le simulateur ; caméra conforme ; haptique de succès ressentie au scan simulé-vers-réel (détection d’un code) ; aucune différence de rendu des polices ni des verts profonds.
**PASS.** Parité complète + caméra + haptique.
**FAIL.** Tout écart simulateur/appareil.
**Régression.** Tout PASS des étapes 9 à 17 qui ne se reproduit pas sur appareil.
**Si FAIL.** Grille, en notant la spécificité appareil.

## Étape 21 · Icône et ressources finales

**Procédure.** Sur appareil : écran d’accueil (clair et sombre d’iOS), Spotlight, Réglages ; placer l’icône au milieu d’autres applications ; lancement à froid pour l’écran de démarrage.
**Attendu.** Trois jauges distinctes à toutes les tailles (à 40 pt les hachures disparaissent, c’est la limite documentée et acceptée : trois barres croissantes doivent rester lisibles) ; pas de banding visible du dégradé sur OLED ; écran de lancement sans flash blanc en mode sombre ; AccentColor appliquée aux contrôles système éventuels.
**PASS.** Lisibilité aux trois tailles + zéro flash + zéro banding gênant.
**FAIL.** Icône illisible à 60 pt ou flash blanc au lancement sombre.
**Régression.** Sans objet (première observation physique).
**Si FAIL.** Régénérer l’asset via `docs/icon/build_icon.py` (ressource, sous grille).

## Étape 22 · Validation finale des cinq arbitrages

**Procédure.** Relire les trois référentiels amendés : Prototype v1.1 (0,58 €/g Boreal ; Samedi 25 juillet ; jauge whey ambre ; Meilleur prix en ordre croissant), PRD v1.0.2 (§6.6 : agrégats sur coûts journaliers arrondis, 53,70 € canonique ; §5.8 : AVFoundation ratifié), Design System v2.0.2 (§13 : StockGauge, DaysLeftChip, teintes d’icône). Confronter chacun à l’application réelle vue aux étapes 9 et 10. Signer chaque arbitrage, ou motiver un veto.
**Attendu.** Cinq signatures ; plus aucun écart code/référentiel non signé.
**PASS.** 5/5 signés.
**FAIL.** Un veto.
**Régression.** Sans objet ; un veto rouvre l’amendement concerné.
**Si FAIL.** L’amendement retourne en révision ; si le veto exige un changement de code, grille complète puis réexécution des étapes 4 à 10.

---

## Sortie du protocole

Verdict 🟢 PRÊT (pour le gel v1.0 de démonstration) si et seulement si les 22 étapes sont PASS. Tout FAIL non corrigé ou toute étape non exécutée maintient 🟡 PRÊT SOUS RÉSERVE, avec la liste exacte des restes. Le passage du périmètre démonstration au MVP commercial reste, lui, l’affaire des jalons M2-M3 et n’entre pas dans ce protocole.
