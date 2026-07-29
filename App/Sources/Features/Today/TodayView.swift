import NutristackDesignSystem
import NutristackDomain
import SwiftUI

/// Écran Aujourd’hui (gabarit DS §9) : résumé de routine au format prix
/// étiquette, progression segmentée, sections horodatées de prises,
/// « À surveiller », action discrète vers Explorer.
///
/// L’en-tête ne code aucune date : elle est dérivée du jour de référence du
/// magasin, si bien que le libellé reste juste quand ce jour change.
struct TodayView: View {
    @Environment(AppRouter.self) private var router
    @Environment(TodayStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(eyebrow: DSFormat.capitalizingFirstLetter(
                                 DSFormat.weekdayDayMonth(store.today)),
                             title: "Aujourd\u{2019}hui",
                             actionIcon: "clock",
                             actionLabel: "Historique des prises") {
                    router.show("L\u{2019}historique complet arrive avec la V1")
                }
                if store.plannedCount == 0 {
                    // État vide du PRD §5.4 : la stack peut être vide, la
                    // journée l’explique et mène au scanner plutôt que
                    // d’afficher un résumé à zéro.
                    EmptyState(systemImage: "square.stack.3d.up",
                               message: "Votre stack est vide. Scannez votre premier "
                                 + "produit pour construire votre routine.",
                               actionTitle: "Scanner un produit") {
                        router.openScanner()
                    }
                } else {
                    routineContent
                }
            }
            .padding(.horizontal, DSSpacing.screenMargin)
            .padding(.top, DSSpacing.s16)
            .padding(.bottom, DSSpacing.s28)
            .animation(DSMotion.state, value: store.takenCount)
        }
        .scrollIndicators(.hidden)
        .background(DSColor.bg)
    }

    /// Journée avec au moins une prise planifiée : résumé, progression,
    /// sections, veille de stock et sortie vers Explorer.
    @ViewBuilder private var routineContent: some View {
        summary
        SegmentedProgress(total: store.plannedCount, completed: store.takenCount)
            .padding(.top, DSSpacing.s16)
        if store.isRoutineComplete {
            Text("Routine terminée. À demain.")
                .font(DSFont.scaled(13.5, .bold))
                .foregroundStyle(DSColor.accent)
                .padding(.top, DSSpacing.s12)
                .transition(.opacity.combined(with: .offset(y: 4)))
        }
        intakeSections
        watchSection
        Button("Explorer les alternatives") { router.tab = .explore }
            .buttonStyle(DSButtonStyle(.quiet))
    }

    /// Résumé : prises à gauche, coût du jour à droite, tous deux au format
    /// prix étiquette, compteurs animés (DS §4 et §8).
    private var summary: some View {
        HStack(alignment: .bottom, spacing: DSSpacing.s16) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Routine").dsStyle(.label).foregroundStyle(DSColor.ink3)
                (Text("\(store.takenCount)")
                    .font(DSFont.scaled(29, .heavy, relativeTo: .largeTitle))
                 + Text("/\(store.plannedCount) prises")
                    .font(DSFont.scaled(29 * 0.58, .heavy, relativeTo: .largeTitle)))
                    .foregroundStyle(DSColor.ink)
                    .contentTransition(.numericText())
                    .accessibilityLabel("\(store.takenCount) prises sur \(store.plannedCount)")
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("Coût du jour").dsStyle(.label).foregroundStyle(DSColor.ink3)
                MoneyText(cents: store.consumedCostCents, size: 29)
                    .foregroundStyle(DSColor.ink)
                    .contentTransition(.numericText())
                Text("sur \(DSFormat.money(cents: store.plannedCostCents)) prévus")
                    .font(DSFont.scaled(12.5, .semibold))
                    .foregroundStyle(DSColor.ink3)
            }
        }
        .padding(.top, DSSpacing.s16)
    }

    private var intakeSections: some View {
        ForEach(store.sections) { section in
            SectionLabel(title: section.title, meta: section.time)
            let lastID = section.items.last?.id
            VStack(spacing: 0) {
                ForEach(section.items) { item in
                    IntakeRow(image: nil,
                              title: item.product.name,
                              subtitle: subtitle(for: item),
                              isDone: store.isDone(item)) {
                        store.toggle(item)
                    }
                    if item.id != lastID { DSHairline() }
                }
            }
        }
    }

    private func subtitle(for item: TodayStore.PlannedIntake) -> String {
        [item.product.brand.name,
         item.entry.doseLabel,
         DSFormat.money(cents: item.costCents)].joined(separator: " · ")
    }

    /// « À surveiller » : produit dont le stock s’épuise le premier, chip ambre
    /// de jours restants, jauge fine (DS §7). Tous les libellés viennent du
    /// domaine ; le seuil d’alerte est celui de `RestockForecast`.
    @ViewBuilder private var watchSection: some View {
        if let alert = store.watch {
            let entry = alert.entry
            let forecast = alert.forecast
            SectionLabel(title: "À surveiller",
                         meta: store.lowStockCount > 1
                             ? "\(store.lowStockCount) produits" : nil)
            Button {
                router.openProduct(entry.product)
            } label: {
                HStack(spacing: DSSpacing.s14) {
                    Packshot(image: nil, size: .list)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(entry.product.shortName) · \(entry.product.brand.shortName)")
                            .dsStyle(.rowTitle).foregroundStyle(DSColor.ink)
                        Text("Rachat conseillé le \(DSFormat.dayMonth(forecast.date))")
                            .dsStyle(.secondary).foregroundStyle(DSColor.ink2)
                        StockGauge(fraction: entry.stockFraction, isLow: forecast.isLow)
                            .padding(.top, 5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    DaysLeftChip(daysLeft: forecast.daysLeft)
                }
                .padding(.vertical, DSSpacing.s14)
                .contentShape(Rectangle())
            }
            .buttonStyle(RowPressStyle())
        }
    }

}

// MARK: Éléments partagés du suivi de stock

/// Jauge de stock de 4 pt : accent au-dessus du seuil de rachat, ambre en
/// dessous. Définie une seule fois pour les deux écrans qui l’affichent
/// (Aujourd’hui et Ma stack) ; à verser au Design System lors du prochain
/// amendement, puisqu’elle constitue un composant à part entière.
struct StockGauge: View {
    let fraction: Double
    let isLow: Bool

    var body: some View {
        GeometryReader { geometry in
            Capsule()
                .fill(DSColor.surface2)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(isLow ? DSColor.amber : DSColor.accent)
                        .frame(width: geometry.size.width * DSFormat.clamp01(fraction))
                }
        }
        .frame(height: DSSize.gaugeThin)
        .accessibilityLabel("Stock restant \(Int(DSFormat.clamp01(fraction) * 100))\u{00A0}%")
    }
}

/// Pastille ambre du nombre de jours restants (« ≈ 9 j »).
struct DaysLeftChip: View {
    let daysLeft: Int

    var body: some View {
        Text("≈ \(daysLeft)\u{00A0}j")
            .font(DSFont.scaled(12, .heavy))
            .foregroundStyle(DSColor.amber)
            .padding(.vertical, 6)
            .padding(.horizontal, 11)
            .background(Capsule().fill(DSColor.amberBg))
            .accessibilityLabel("Environ \(daysLeft) jours restants")
    }
}

/// Environnement complet d’une prévisualisation d’écran.
@MainActor private func previewStores() -> (StackStore, TodayStore) {
    let stack = StackStore()
    return (stack, TodayStore(stack: stack))
}

#Preview("Clair") {
    let (stack, today) = previewStores()
    return TodayView()
        .environment(AppRouter())
        .environment(stack)
        .environment(today)
}

#Preview("Sombre") {
    let (stack, today) = previewStores()
    return TodayView()
        .environment(AppRouter())
        .environment(stack)
        .environment(today)
        .preferredColorScheme(.dark)
}

#Preview("AX1") {
    let (stack, today) = previewStores()
    return TodayView()
        .environment(AppRouter())
        .environment(stack)
        .environment(today)
        .environment(\.dynamicTypeSize, .accessibility1)
}
