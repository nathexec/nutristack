import SwiftUI

/// Tokens de couleur du Design System Nutristack (référence : DS v2.0.1, §3).
///
/// Règles d’usage :
/// - `accent` est l’unique couleur d’action, de positif et de vérifié.
/// - `amber` est une couleur de fait d’attention, jamais d’action.
/// - `danger` est réservée aux erreurs système.
/// - `pack` est constante : un packshot ne s’inverse jamais en mode sombre.
/// Toute couleur hors de cette liste est interdite, à deux exceptions documentées :
/// l’imagerie des packshots et l’écran scanner (contexte caméra).
public enum DSColor {

    /// Fond d’écran et des tuiles.
    public static let bg = Color(light: "FFFFFF", dark: "0D100F")
    /// Champs, segments, pistes de jauges.
    public static let surface2 = Color(light: "F4F6F5", dark: "171B1A")
    /// Filets 1 pt et bordures de tuiles.
    public static let hairline = Color(light: "E6E9E7", dark: "262B29")
    /// Anneaux de coche à l’état repos.
    public static let ring = Color(light: "D3D9D6", dark: "3A423F")
    /// Texte principal ; fond de la carte de verdict.
    public static let ink = Color(light: "171B19", dark: "F1F3F1")
    /// Texte secondaire.
    public static let ink2 = Color(light: "5C6461", dark: "A6ADA9")
    /// Tertiaire : étiquettes, icônes inactives.
    public static let ink3 = Color(light: "969D99", dark: "6E7572")
    /// Unique couleur d’action, de positif et de vérifié (vert officinal).
    public static let accent = Color(light: "175947", dark: "4EB08C")
    /// État pressé du bouton primaire.
    public static let accentPress = Color(light: "114536", dark: "63C29E")
    /// Fonds de badge « usage vérifié » et de bouton secondaire.
    public static let accentTint = Color(light: "175947", dark: "4EB08C",
                                         lightAlpha: 0.09, darkAlpha: 0.13)
    /// Texte posé sur `accent` (blanc en clair, encre du fond en sombre).
    public static let onAccent = Color(light: "FFFFFF", dark: "0D100F")
    /// Faits d’attention : bandeaux, chips, stock bas.
    public static let amber = Color(light: "A9691E", dark: "D69A4E")
    /// Fond des bandeaux et chips d’attention.
    public static let amberBg = Color(light: "F8EEDC", dark: "2A2116")
    /// Erreurs système uniquement.
    public static let danger = Color(light: "A63D2F", dark: "D97B6C")
    /// Pastille packshot : blanc constant, liseré en sombre géré par `Packshot`.
    public static let pack = Color(light: "FFFFFF", dark: "FFFFFF")

    // MARK: Exception documentée · contexte caméra (DS §3)
    //
    // L’écran scanner est le seul à sortir de la palette : le fond sombre sert
    // la lisibilité du flux vidéo et reste identique dans les deux apparences.
    // Ces trois tokens existent pour que l’exception soit nommée et unique,
    // plutôt que dispersée en valeurs hexadécimales dans l’écran.

    /// Haut du dégradé de fond du scanner.
    public static let scannerBackdropTop = Color(light: "121715", dark: "121715")
    /// Bas du dégradé de fond du scanner.
    public static let scannerBackdropBottom = Color(light: "070A09", dark: "070A09")
    /// Ligne de balayage du cadre de visée.
    public static let scannerScanline = Color(light: "6FD4AE", dark: "6FD4AE")
}
