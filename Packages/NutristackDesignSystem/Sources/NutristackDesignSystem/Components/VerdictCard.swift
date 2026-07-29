import SwiftUI

/// Carte de verdict du comparateur (DS §7) : fond encre, texte du fond,
/// titre 17/800 et sous-ligne à 72 %. Apparaît en ressort après la cascade
/// des cellules gagnantes ; utilisez la transition fournie.
public struct VerdictCard: View {
    private let title: String
    private let subtitle: String?

    public init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    /// Transition recommandée pour la révélation (DS §8).
    public static let revealTransition: AnyTransition =
        .move(edge: .bottom).combined(with: .opacity)

    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).dsStyle(.verdictTitle).foregroundStyle(DSColor.bg)
            if let subtitle {
                Text(subtitle)
                    .dsStyle(.secondary)
                    .foregroundStyle(DSColor.bg.opacity(0.72))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18))
        .background(DSColor.ink)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.standard, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview("Clair") {
    VerdictCard(title: "Le moins cher par gramme de magnésium : Nordika Citrate (−40\u{00A0}%).",
                subtitle: "Alba conserve l’avantage sur l’effet perçu vérifié (4,3 contre 4,0).")
        .padding().background(DSColor.bg)
}
#Preview("Sombre") {
    VerdictCard(title: "Le moins cher par gramme de créatine : Halterra (−23\u{00A0}%).")
        .padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    VerdictCard(title: "Verdict", subtitle: "Sous-ligne")
        .padding().environment(\.dynamicTypeSize, .accessibility1)
}
