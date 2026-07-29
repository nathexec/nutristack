import SwiftUI

/// Badge « Usage vérifié » (DS §7). La mention n’est jamais accolée à une note
/// seule : elle apparaît avec un décompte de prises et de semaines (DS §10).
public struct VerifiedBadge: View {
    private let intakes: Int
    private let weeks: Int

    /// Seuils de la règle en vigueur, affichés par le tooltip. Le Design System
    /// ne dépend pas du domaine : l’appelant transmet les valeurs de
    /// `VerificationRule`, les défauts reflétant la règle du PRD §7.3.
    private let ruleIntakes: Int
    private let ruleWeeks: Int

    public init(intakes: Int, weeks: Int, ruleIntakes: Int = 20, ruleWeeks: Int = 3) {
        self.ruleIntakes = ruleIntakes
        self.ruleWeeks = ruleWeeks
        self.intakes = intakes
        self.weeks = weeks
    }

    /// Libellé affiché (testé) : « Usage vérifié · 47 prises / 8 sem. »
    var label: String {
        "Usage vérifié · \(intakes) prises / \(weeks) sem."
    }

    /// Explication d’accessibilité obligatoire (PRD §7.6) : le tooltip énonce
    /// la règle, « au moins 20 prises sur 3 semaines », et non les chiffres du
    /// relecteur, que le libellé du badge donne déjà. La formulation
    /// précédente, « au moins 47 prises », mêlait les deux et devenait fausse.
    var explainer: String {
        "Cet utilisateur a enregistré au moins \(ruleIntakes) prises "
        + "sur \(ruleWeeks) semaines dans l’application. "
        + "Cela atteste d’un usage déclaré et suivi, "
        + "pas d’une mesure clinique d’efficacité."
    }

    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .bold))
            Text(label)
                .font(DSFont.scaled(12, .bold))
        }
        .foregroundStyle(DSColor.accent)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(DSColor.accentTint)
        .clipShape(Capsule())
        .accessibilityLabel(label)
        .accessibilityHint(explainer)
    }
}

#Preview("Clair") {
    VerifiedBadge(intakes: 47, weeks: 8).padding().background(DSColor.bg)
}
#Preview("Sombre") {
    VerifiedBadge(intakes: 47, weeks: 8)
        .padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    VerifiedBadge(intakes: 20, weeks: 3)
        .padding().environment(\.dynamicTypeSize, .accessibility1)
}
