import NutristackDesignSystem
import SwiftUI

/// Écran racine : les quatre onglets sous la barre d’onglets personnalisée,
/// les écrans poussés plein écran au-dessus (ils recouvrent la barre, DS §9),
/// le scanner en recouvrement, le toast au sommet.
struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        let isCovered = router.push != nil || router.isScannerPresented
        return ZStack {
            tabContent
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    NutriTabBar()
                }
                // Un recouvrement plein écran doit aussi masquer l’arrière-plan
                // à VoiceOver, sinon la barre d’onglets reste atteignable
                // derrière la fiche ou le scanner (DS §11).
                .accessibilityHidden(isCovered)

            if let push = router.push {
                pushedScreen(push)
                    .accessibilityAddTraits(.isModal)
                    .transition(.asymmetric(
                        insertion: AnyTransition.offset(x: 56).combined(with: .opacity),
                        removal: AnyTransition.offset(x: 56).combined(with: .opacity)))
                    .zIndex(1)
            }

            if router.isScannerPresented {
                ScannerView()
                    .transition(.opacity)
                    .zIndex(2)
                    .accessibilityAddTraits(.isModal)
            }
        }
        .background(DSColor.bg.ignoresSafeArea())
        .animation(DSMotion.nav, value: router.push)
        .animation(.easeOut(duration: 0.3), value: router.isScannerPresented)
        .dsToast($router.toast)
    }

    /// Contenu de l’onglet courant, avec la transition de navigation du DS §8
    /// (fondu + léger décalage vertical).
    @MainActor @ViewBuilder private var tabContent: some View {
        Group {
            switch router.tab {
            case .today: TodayView()
            case .explore: ExploreView()
            case .stack: StackScreen()
            case .profile: ProfileView()
            }
        }
        .id(router.tab)
        .transition(.opacity.combined(with: .offset(y: 6)))
        .animation(DSMotion.nav, value: router.tab)
    }

    @ViewBuilder private func pushedScreen(_ route: AppRouter.PushRoute) -> some View {
        switch route {
        case .product(let product):
            ProductDetailView(product: product)
        case .compare(let left, let right):
            CompareView(left: left, right: right)
        }
    }
}
