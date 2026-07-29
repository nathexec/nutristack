import SwiftUI

/// Espacements de la grille 4 pt (référence : DS v2.0.1, §5).
public enum DSSpacing {
    /// Marge horizontale d’écran.
    public static let screenMargin: CGFloat = 20
    public static let s4: CGFloat = 4
    public static let s8: CGFloat = 8
    /// Interligne interne des composants.
    public static let s12: CGFloat = 12
    /// Interligne des rangées de liste.
    public static let s14: CGFloat = 14
    /// Espace entre blocs.
    public static let s16: CGFloat = 16
    /// Espace entre sections.
    public static let s28: CGFloat = 28
}

/// Rayons (continus) du Design System (DS §5).
public enum DSRadius {
    /// Petits contrôles, pastille de comparateur.
    public static let small: CGFloat = 10
    /// Standard : tuiles, boutons, bandeaux, pastilles de liste.
    public static let standard: CGFloat = 13
    /// Pastille packshot de fiche.
    public static let packLarge: CGFloat = 16
    /// Fiche de résultat du scanner.
    public static let scanResult: CGFloat = 18
    /// Feuilles.
    public static let sheet: CGFloat = 20
    /// Pilules et chips.
    public static let pill: CGFloat = 999
}

/// Dimensions structurelles (DS §5 et §7).
public enum DSSize {
    /// Hauteur des boutons standard / compacts (fiche de résultat).
    public static let button: CGFloat = 50
    public static let buttonCompact: CGFloat = 46
    /// Coche de prise (cible tactile portée par la rangée entière).
    public static let check: CGFloat = 30
    /// Hauteur de la barre d’onglets (hors zone sûre).
    public static let tabBar: CGFloat = 78
    /// Bouton Scan central.
    public static let scanButton: CGFloat = 56
    /// Cadre de visée du scanner, carré à dimensions fixes.
    public static let scanFrame: CGFloat = 240
    /// Épaisseur des filets.
    public static let hairline: CGFloat = 1
    /// Hauteurs des jauges : actif 6, progression 4, stock 4.
    public static let gaugeActive: CGFloat = 6
    public static let gaugeThin: CGFloat = 4
}

/// Ombre unique du système, réservée au bouton Scan et aux feuilles (DS §5).
public enum DSShadow {
    public static let color = Color.black.opacity(0.12)
    public static let radius: CGFloat = 12
    /// Décalage vertical de l’ombre.
    public static let offsetY: CGFloat = 8
}
