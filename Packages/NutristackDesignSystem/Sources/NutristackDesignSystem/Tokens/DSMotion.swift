import SwiftUI

/// Tokens d’animation (référence : DS v2.0.1, §8).
/// Chaque animation confirme une action ou révèle une structure ; jamais décorative.
/// `Réduire les animations` : les composants concernés lisent
/// `accessibilityReduceMotion` et remplacent leurs révélations par des fondus.
public enum DSMotion {
    /// Retour tactile des éléments pressés (échelles 0,97 / 0,93 / 0,992).
    public static let tap = Animation.easeOut(duration: 0.12)
    /// Coche, segments, pilules, dessin du trait.
    public static let state = Animation.spring(response: 0.30, dampingFraction: 0.85)
    /// Onglets et écrans poussés.
    public static let nav = Animation.spring(response: 0.38, dampingFraction: 0.88)
    /// Feuilles, fiche de résultat du scanner, toast.
    public static let sheet = Animation.spring(response: 0.42, dampingFraction: 0.82)
    /// Jauge d’actif et cellules gagnantes du comparateur.
    public static let reveal = Animation.easeOut(duration: 0.45)
    /// Décalage de cascade entre éléments révélés.
    public static let revealStagger: Double = 0.09
    /// Délai d’apparition de la jauge d’actif après l’entrée d’écran.
    public static let gaugeDelay: Double = 0.15
}
