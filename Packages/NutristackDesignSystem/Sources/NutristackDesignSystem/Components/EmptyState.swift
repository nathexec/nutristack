import SwiftUI

/// État vide (DS §7) : un symbole tertiaire, une phrase, une action.
/// Jamais d’illustration décorative.
public struct EmptyState: View {
    private let systemImage: String
    private let message: String
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(systemImage: String, message: String,
                actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.systemImage = systemImage
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DSSpacing.s14) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(DSColor.ink3)
            Text(message)
                .dsStyle(.body)
                .foregroundStyle(DSColor.ink2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(DSFont.scaled(14, .bold))
                        .foregroundStyle(DSColor.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 56, leading: 24, bottom: 56, trailing: 24))
    }
}

#Preview("Clair") {
    EmptyState(systemImage: "person",
               message: "Votre profil public arrive avec les avis. Vos stacks restent privées par défaut.",
               actionTitle: "Lire la charte de confiance", action: {})
        .background(DSColor.bg)
}
#Preview("Sombre") {
    EmptyState(systemImage: "barcode.viewfinder",
               message: "Scannez votre premier produit pour démarrer votre stack.")
        .background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    EmptyState(systemImage: "magnifyingglass", message: "Aucun résultat. Scannez-le ou demandez son ajout.")
        .environment(\.dynamicTypeSize, .accessibility1)
}
