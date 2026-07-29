import NutristackDesignSystem
import SwiftUI

/// En-tête d’onglet (gabarits du DS §9) : sur-titre en capitales, titre 32,
/// action circulaire optionnelle à droite.
struct ScreenHeader: View {
    let eyebrow: String
    let title: String
    var actionIcon: String?
    var actionLabel: String = ""
    var action: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(eyebrow).dsStyle(.label).foregroundStyle(DSColor.ink3)
            HStack(alignment: .bottom) {
                Text(title).dsStyle(.screenTitle).foregroundStyle(DSColor.ink)
                Spacer()
                if let actionIcon, let action {
                    Button(action: action) {
                        Image(systemName: actionIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(DSColor.ink2)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(DSColor.surface2))
                            // Le disque mesure 38 pt comme la maquette, mais la
                            // zone tactile atteint les 44 pt minimum requis.
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(ScalePressStyle())
                    .accessibilityLabel(actionLabel)
                }
            }
        }
    }
}

/// Libellé de section avec métadonnée à droite (DS §9).
struct SectionLabel: View {
    let title: String
    var meta: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).dsStyle(.label).foregroundStyle(DSColor.ink3)
            Spacer()
            if let meta {
                Text(meta)
                    .font(DSFont.scaled(11, .semibold))
                    .tracking(0.44)
                    .textCase(.uppercase)
                    .monospacedDigit()
                    .foregroundStyle(DSColor.ink3)
            }
        }
        .padding(.top, DSSpacing.s28)
        .padding(.bottom, 4)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

/// Retour tactile des commandes circulaires (échelle 0,92).
///
/// Les rangées de liste utilisent `RowPressStyle` du Design System : ce style
/// ne couvre que les boutons d’icône, pour ne pas dupliquer un token existant.
struct ScalePressStyle: ButtonStyle {
    var scale: CGFloat = 0.92
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(DSMotion.tap, value: configuration.isPressed)
    }
}
