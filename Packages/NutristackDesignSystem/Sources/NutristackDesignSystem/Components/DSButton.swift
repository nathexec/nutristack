import SwiftUI

/// Genres de bouton (DS §7). Un seul primaire au plus par écran visible.
public enum DSButtonKind {
    case primary    // fond accent, texte onAccent
    case secondary  // teinte accent, texte accent
    case quiet      // texte accent seul, aligné à gauche
    case done       // état accompli, inactif visuellement
}

/// Style de bouton du Design System : hauteur 50 (46 en compact), rayon 13,
/// contenu centré, pressé à l’échelle 0,97.
public struct DSButtonStyle: ButtonStyle {
    private let kind: DSButtonKind
    private let compact: Bool

    public init(_ kind: DSButtonKind, compact: Bool = false) {
        self.kind = kind
        self.compact = compact
    }

    public func makeBody(configuration: Configuration) -> some View {
        let height = compact ? DSSize.buttonCompact : DSSize.button
        return configuration.label
            .font(DSTextStyle.button.font)
            .frame(maxWidth: kind == .quiet ? nil : .infinity,
                   minHeight: kind == .quiet ? 44 : height)
            .padding(.horizontal, kind == .quiet ? 0 : 16)
            .foregroundStyle(foreground)
            .background(background(pressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.standard, style: .continuous))
            .scaleEffect(configuration.isPressed && kind != .quiet ? 0.97 : 1)
            .animation(DSMotion.tap, value: configuration.isPressed)
    }

    private var foreground: Color {
        switch kind {
        case .primary: return DSColor.onAccent
        case .secondary, .quiet: return DSColor.accent
        case .done: return DSColor.ink2
        }
    }
    private func background(pressed: Bool) -> Color {
        switch kind {
        case .primary: return pressed ? DSColor.accentPress : DSColor.accent
        case .secondary: return DSColor.accentTint
        case .quiet: return .clear
        case .done: return DSColor.surface2
        }
    }
}

/// Bouton primaire prêt à l’emploi.
public struct PrimaryButton: View {
    private let title: String
    private let action: () -> Void
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    public var body: some View {
        Button(title, action: action).buttonStyle(DSButtonStyle(.primary))
    }
}

#Preview("Clair") {
    VStack(spacing: 12) {
        PrimaryButton("Ajouter à ma stack") {}
        Button("Comparer") {}.buttonStyle(DSButtonStyle(.secondary))
        Button("Explorer les alternatives") {}.buttonStyle(DSButtonStyle(.quiet))
        Button("Dans votre stack ✓") {}.buttonStyle(DSButtonStyle(.done)).disabled(true)
    }.padding().background(DSColor.bg)
}
#Preview("Sombre") {
    VStack(spacing: 12) {
        PrimaryButton("Ajouter à ma stack") {}
        Button("Comparer") {}.buttonStyle(DSButtonStyle(.secondary))
    }.padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    PrimaryButton("Ajouter à ma stack") {}
        .padding().environment(\.dynamicTypeSize, .accessibility1)
}
