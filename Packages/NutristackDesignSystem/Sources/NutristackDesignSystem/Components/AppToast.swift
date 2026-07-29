import SwiftUI

/// Toast (DS §7) : pilule encre sur fond, unique, 1,9 s, réarmé à chaque
/// message. Se pose sur l’écran racine via `.dsToast($message)`.
public extension View {
    func dsToast(_ message: Binding<String?>) -> some View {
        modifier(DSToastModifier(message: message))
    }
}

/// Implémentation du toast. Un seul message à la fois : un nouveau texte
/// remplace le précédent et réarme le délai, plutôt que d’empiler des pilules.
struct DSToastModifier: ViewModifier {
    @Binding var message: String?

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if let text = message {
                Text(text)
                    .font(DSFont.scaled(14, .bold))
                    .foregroundStyle(DSColor.bg)
                    .padding(.vertical, 11)
                    .padding(.horizontal, 18)
                    .background(DSColor.ink)
                    .clipShape(Capsule())
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: text) {
                        // Un nouveau message annule cette tâche pendant le
                        // sommeil. Avaler l’annulation puis effacer quand même
                        // supprimerait le message *suivant* à peine affiché :
                        // on ne retire le toast que si le délai est allé au bout.
                        do {
                            try await Task.sleep(nanoseconds: 1_900_000_000)
                        } catch {
                            return
                        }
                        withAnimation(DSMotion.sheet) { message = nil }
                    }
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .animation(DSMotion.sheet, value: message)
    }
}

#Preview("Clair") {
    /// Vue de démonstration, nécessaire pour piloter un état dans la prévisualisation.
    struct Demo: View {
        @State private var toast: String? = "Magnésium ajouté à votre stack"
        var body: some View {
            VStack {
                Button("Afficher un toast") { toast = "Magnésium ajouté à votre stack" }
                    .buttonStyle(DSButtonStyle(.secondary))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DSColor.bg)
            .dsToast($toast)
        }
    }
    return Demo()
}
#Preview("Sombre") {
    Text("Fond").frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.bg)
        .dsToast(.constant("Comparaison partagée"))
        .preferredColorScheme(.dark)
}
#Preview("AX1") {
    Color.clear.dsToast(.constant("Message"))
        .environment(\.dynamicTypeSize, .accessibility1)
}
