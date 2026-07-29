import NutristackDesignSystem
import NutristackDomain
import SwiftUI

/// Écran Profil (gabarit DS §9) : apparence (auto, clair, sombre), état vide
/// du profil public, charte de confiance en feuille.
struct ProfileView: View {
    @Environment(AppearanceStore.self) private var appearance
    @State private var isCharterPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(eyebrow: "Compte", title: "Profil")
                SectionLabel(title: "Apparence")
                appearancePicker
                DSHairline().padding(.top, DSSpacing.s28)
                EmptyState(systemImage: "person",
                           message: "Votre profil public arrive avec les avis. "
                             + "Vos stacks restent privées par défaut.",
                           actionTitle: "Lire la charte de confiance") {
                    isCharterPresented = true
                }
            }
            .padding(.horizontal, DSSpacing.screenMargin)
            .padding(.top, DSSpacing.s16)
            .padding(.bottom, DSSpacing.s28)
        }
        .scrollIndicators(.hidden)
        .background(DSColor.bg)
        .sheet(isPresented: $isCharterPresented) { CharterSheet() }
    }

    private var appearancePicker: some View {
        let modes = AppearanceStore.Mode.allCases
        return DSSegmented(options: modes.map(\.label),
                           selectedIndex: Binding(
                               get: { modes.firstIndex(of: appearance.mode) ?? 0 },
                               set: { appearance.mode = modes[$0] }))
            .padding(.top, DSSpacing.s8)
    }
}

/// Charte de confiance (PRD §8.1), en feuille native aux réglages du DS §7.
struct CharterSheet: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Charte de confiance")
                .dsStyle(.sheetTitle).foregroundStyle(DSColor.ink)
                .padding(.bottom, DSSpacing.s8)
            charterRow("Aucune marque ne peut payer pour influencer une note, "
                + "un classement ou une suggestion.")
            DSHairline()
            charterRow("Chaque donnée affiche sa provenance et sa date.")
            DSHairline()
            charterRow(verificationRow)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DSSpacing.screenMargin)
        .padding(.top, DSSpacing.s16)
        .presentationDetents([.height(320)])
        .presentationCornerRadius(DSRadius.sheet)
        .presentationDragIndicator(.visible)
        .background(DSColor.bg)
    }

    /// Phrase de la charte dérivée de la règle du domaine : si les seuils
    /// changent, la charte suit sans réécriture.
    private var verificationRow: String {
        let rule = VerificationRule()
        return "Les avis « usage vérifié » exigent au moins \(rule.minIntakes) prises "
            + "enregistrées sur \(rule.minDays / 7) semaines."
    }

    private func charterRow(_ text: String) -> some View {
        Text(text)
            .font(DSFont.scaled(14, .regular))
            .foregroundStyle(DSColor.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, DSSpacing.s12)
    }
}

#Preview("Clair") {
    ProfileView().environment(AppearanceStore())
}

#Preview("Sombre") {
    ProfileView().environment(AppearanceStore()).preferredColorScheme(.dark)
}

#Preview("AX1") {
    ProfileView().environment(AppearanceStore())
        .environment(\.dynamicTypeSize, .accessibility1)
}
