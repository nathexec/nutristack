import NutristackDesignSystem
import SwiftUI

/// Point d’entrée de l’application Nutristack.
///
/// Le type est isolé sur l’acteur principal : les magasins observables le sont
/// aussi, et sous concurrence stricte leur construction dans `init()` doit se
/// faire depuis un contexte principal.
/// Enregistre les polices du Design System (repli système silencieux si les
/// fichiers OFL ne sont pas encore déposés) puis installe l’écran racine.
@main
@MainActor
struct NutristackApp: App {
    @State private var router = AppRouter()
    @State private var appearance = AppearanceStore()
    @State private var stack: StackStore
    @State private var today: TodayStore

    init() {
        DSFontRegistrar.registerBundledFonts()
        // La journée dérive de la stack : les deux magasins sont construits
        // ici pour que la dépendance soit explicite plutôt que devinée.
        let stack = StackStore()
        _stack = State(initialValue: stack)
        _today = State(initialValue: TodayStore(stack: stack))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .environment(appearance)
                .environment(stack)
                .environment(today)
                .preferredColorScheme(appearance.colorScheme)
                .tint(DSColor.accent)
        }
    }
}
