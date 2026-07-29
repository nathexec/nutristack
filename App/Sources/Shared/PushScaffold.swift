import NutristackDesignSystem
import SwiftUI

/// Clé de préférence du décalage de défilement (révélation du titre de la
/// barre de navigation à 60 pt, DS §7).
private struct ScrollOffsetKey: PreferenceKey {
    // `let` et non `var` : sous concurrence stricte, une propriété statique
    // muable serait un état global partagé non protégé.
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// Barre de navigation d’écran poussé (DS §7) : retour à gauche, titre centré
/// qui apparaît au défilement, fond translucide flouté.
struct PushNavBar: View {
    let title: String
    let backLabel: String
    let showsTitle: Bool
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 2) {
                Button(action: onBack) {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text(backLabel).dsStyle(.backLink)
                    }
                    .foregroundStyle(DSColor.accent)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Retour, \(backLabel)")

                Spacer()
            }
            .overlay {
                Text(title)
                    .font(DSFont.scaled(15, .bold))
                    .foregroundStyle(DSColor.ink)
                    .opacity(showsTitle ? 1 : 0)
                    .animation(.easeOut(duration: 0.25), value: showsTitle)
                    .accessibilityHidden(!showsTitle)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(DSColor.bg.opacity(0.88))
        .background(.ultraThinMaterial)
    }
}

/// Gabarit d’écran poussé (DS §9 et §12) : plein écran au-dessus de la barre
/// d’onglets, navigation collante en haut, contenu défilant, barre d’action
/// ancrée en bas via `safeAreaInset`. Le contenu défile sous les deux barres.
struct PushScaffold<Content: View, Actions: View>: View {
    let title: String
    let backLabel: String
    let onBack: () -> Void
    @ViewBuilder let content: () -> Content
    @ViewBuilder let actions: () -> Actions

    @State private var isScrolled = false

    var body: some View {
        ScrollView {
            content()
                .padding(.horizontal, DSSpacing.screenMargin)
                .padding(.bottom, DSSpacing.s28)
                .background {
                    GeometryReader { geo in
                        Color.clear.preference(key: ScrollOffsetKey.self,
                                               value: -geo.frame(in: .named("push")).minY)
                    }
                }
        }
        .coordinateSpace(name: "push")
        .onPreferenceChange(ScrollOffsetKey.self) { isScrolled = $0 > 60 }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top, spacing: 0) {
            PushNavBar(title: title, backLabel: backLabel,
                       showsTitle: isScrolled, onBack: onBack)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AnchoredActionBar { actions() }
        }
        .background(DSColor.bg.ignoresSafeArea())
    }
}
