import NutristackDesignSystem
import SwiftUI

/// Barre d’onglets (DS §7) : cinq emplacements, bouton Scan central surélevé,
/// fond translucide flouté, filet supérieur. Icônes SF Symbols (DS §6).
struct NutriTabBar: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(spacing: 0) {
            DSHairline()
            HStack(alignment: .top, spacing: 0) {
                tab(.today, icon: "calendar", label: "Aujourd\u{2019}hui")
                tab(.explore, icon: "magnifyingglass", label: "Explorer")
                scanButton
                tab(.stack, icon: "square.stack.3d.up", label: "Stack")
                tab(.profile, icon: "person", label: "Profil")
            }
            .padding(.top, 10)
            .padding(.horizontal, 8)
        }
        .frame(height: DSSize.tabBar, alignment: .top)
        .background(DSColor.bg.opacity(0.86))
        .background(.ultraThinMaterial)
    }

    private func tab(_ target: AppRouter.Tab, icon: String, label: String) -> some View {
        let isOn = router.tab == target
        return Button {
            router.tab = target
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(isOn ? DSColor.accent : DSColor.ink3)
                Text(label)
                    .font(DSFont.scaled(10.5, .bold))
                    .foregroundStyle(isOn ? DSColor.ink : DSColor.ink3)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isOn ? [.isSelected] : [])
    }

    /// Bouton Scan : disque 56 accent surélevé de 22, seule ombre autorisée
    /// de la barre (DS §5).
    private var scanButton: some View {
        Button {
            router.openScanner()
        } label: {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(DSColor.onAccent)
                .frame(width: DSSize.scanButton, height: DSSize.scanButton)
                .background(Circle().fill(DSColor.accent))
                .shadow(color: DSShadow.color, radius: DSShadow.radius, y: DSShadow.offsetY)
        }
        .buttonStyle(ScanPressStyle())
        .offset(y: -22)
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Scanner un produit")
    }
}

/// Retour tactile du bouton Scan (échelle 0,93, DS §8).
private struct ScanPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(DSMotion.tap, value: configuration.isPressed)
    }
}
