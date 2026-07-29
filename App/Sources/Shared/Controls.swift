import NutristackDesignSystem
import SwiftUI

/// Champ de recherche (DS §7) : fond `surface2`, loupe, libellé d’attente
/// terminé par des points de suspension.
struct SearchField: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(DSColor.ink3)
            TextField(placeholder, text: $text)
                .font(DSTextStyle.rowTitle.font.weight(.regular))
                .foregroundStyle(DSColor.ink)
                .autocorrectionDisabled()
        }
        .padding(EdgeInsets(top: 13, leading: 14, bottom: 13, trailing: 14))
        .background(DSColor.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.standard, style: .continuous))
    }
}

/// Pilules de filtre et de variante (DS §7) : la sélection n’est pas une
/// action, donc fond encre, jamais de vert.
struct FilterPills: View {
    let options: [String]
    @Binding var selectedIndex: Int
    var scrollable = true

    var body: some View {
        Group {
            if scrollable {
                ScrollView(.horizontal) { row }
                    .scrollIndicators(.hidden)
                    .padding(.horizontal, -DSSpacing.screenMargin)
            } else {
                row
            }
        }
    }

    private var row: some View {
        HStack(spacing: 8) {
            ForEach(options.indices, id: \.self) { index in
                let isOn = index == selectedIndex
                Button {
                    withAnimation(DSMotion.state) { selectedIndex = index }
                } label: {
                    Text(options[index])
                        .font(DSFont.scaled(13.5, .bold))
                        .foregroundStyle(isOn ? DSColor.bg : DSColor.ink2)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 15)
                        .background(Capsule().fill(isOn ? DSColor.ink : DSColor.bg))
                        .overlay(Capsule().stroke(isOn ? DSColor.ink : DSColor.hairline,
                                                  lineWidth: DSSize.hairline))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, scrollable ? DSSpacing.screenMargin : 0)
    }
}

/// Sélecteur segmenté (DS §7) : conteneur `surface2`, option active sur fond
/// d’écran avec ombre légère.
struct DSSegmented: View {
    let options: [String]
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                let isOn = index == selectedIndex
                Button {
                    withAnimation(DSMotion.state) { selectedIndex = index }
                } label: {
                    Text(options[index])
                        .font(DSFont.scaled(13.5, .bold))
                        .foregroundStyle(isOn ? DSColor.ink : DSColor.ink2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            if isOn {
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .fill(DSColor.bg)
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, y: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? [.isSelected] : [])
            }
        }
        .padding(3)
        .background(DSColor.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
