import SwiftUI

/// Bandeau d’attention (DS §7) : réservé aux faits, jamais aux actions
/// (formes différentes, ambiguïté d’étiquette, mélange non détaillé, stock).
/// L’ambre s’accompagne toujours d’une icône et d’un texte (DS §11).
public struct AttentionBanner: View {
    private let text: String
    public init(_ text: String) { self.text = text }

    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DSColor.amber)
                .padding(.top, 1)
            Text(text)
                .dsStyle(.secondary)
                .foregroundStyle(DSColor.ink)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
        .background(DSColor.amberBg)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.standard, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview("Clair") {
    AttentionBanner("Formes différentes : la comparaison porte sur le magnésium "
        + "élémentaire. La forme peut influencer l’assimilation.")
        .padding().background(DSColor.bg)
}
#Preview("Sombre") {
    AttentionBanner("Le fabricant ne détaille pas les dosages de ce mélange. Comparaison par actif impossible.")
        .padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    AttentionBanner("Stock bas : rachat conseillé le 3 août.")
        .padding().environment(\.dynamicTypeSize, .accessibility1)
}
