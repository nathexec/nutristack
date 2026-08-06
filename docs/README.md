# Documentation · Nutristack

Quatre dossiers thématiques, un fichier par sujet, versionné dans son nom.

## Convention de nommage

- **Dossiers** : un mot anglais, minuscules, ASCII — `audit`, `baseline`,
  `icon`, `validation` — comme les autres dossiers d'infrastructure du dépôt
  (`docs`, `scripts`).
- **Documents Markdown** : `Sujet_Precision_vX.Y.md`, titre français en
  capitales initiales séparé par des tirets bas, ASCII sans accents, sans
  mention redondante du projet (tout est déjà dans le dépôt Nutristack).
- **Scripts** : anglais, minuscules et tirets bas (`build_icon.py`), comme
  `scripts/bootstrap.sh`.
- **Assets d'icône** : `Nutristack_AppIcon_<variante>.<ext>`, la variante étant
  `default`, `dark` ou `tinted` — les mêmes clés que dans `build_icon.py`, si
  bien qu'une régénération retombe exactement sur les fichiers versionnés.

## Contenu

### [audit/](audit/) — ce qui a été vérifié

| Fichier | Contenu |
|---|---|
| [Audit_Code_v1.0.md](audit/Audit_Code_v1.0.md) | Premier audit en profondeur du code (juillet 2026) |
| [Audit_Verrouillage_v1.0.md](audit/Audit_Verrouillage_v1.0.md) | Second audit, avant gel de la v1.0 |
| [Audit_Final_Production_v1.0.md](audit/Audit_Final_Production_v1.0.md) | Audit final en 16 phases, matrice PRD → code → tests |
| [Compte_Rendu_Audit_v1.0.md](audit/Compte_Rendu_Audit_v1.0.md) | **Bilan consolidé des deux vagues d'audit multi-agents** : 17 points ouverts, 79 sains, 42 écartés, 12 clos |

### [baseline/](baseline/) — l'état de référence du code

| Fichier | Contenu |
|---|---|
| [Baseline_Gel_v1.0.md](baseline/Baseline_Gel_v1.0.md) | Les 58 fichiers Swift gelés, leurs empreintes md5, l'empreinte globale et la grille obligatoire avant tout changement |

### [icon/](icon/) — l'icône d'application

| Fichier | Contenu |
|---|---|
| [Icone_v1.1.md](icon/Icone_v1.1.md) | Parti pris, géométrie, couleurs, contrôle de lisibilité |
| [build_icon.py](icon/build_icon.py) | Régénère SVG, exports 1024 et planche de contrôle, sur place |
| `Nutristack_AppIcon_default.svg` · `_dark.svg` · `_tinted.svg` | Les trois sources vectorielles |
| `Nutristack_AppIcon_1024_dark.png` · `_1024_tinted.png` | Exports des variantes non déclarées au catalogue (exigeraient Xcode 16) |
| `Nutristack_AppIcon_apercu.png` | Planche de contrôle, toutes tailles d'usage sur fond clair et sombre |

L'export clair de 1024 n'est pas versionné ici : sa copie de production est
`App/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`.

### [validation/](validation/) — comment prouver que ça marche

| Fichier | Contenu |
|---|---|
| [Protocole_Validation_Finale_v1.0.md](validation/Protocole_Validation_Finale_v1.0.md) | Les 22 étapes de validation, critères PASS/FAIL ; étapes 2 à 8 passées, 9 à 22 en attente d'un Mac |
| [Validation_Xcode_v1.0.md](validation/Validation_Xcode_v1.0.md) | Registre des 5 arbitrages, correspondance des 34 tests, checklist Xcode |
