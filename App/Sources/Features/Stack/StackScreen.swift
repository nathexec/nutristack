import NutristackDesignSystem
import NutristackDomain
import SwiftUI

/// Écran Ma stack (gabarit DS §9) : tuiles de synthèse, rangées avec coût par
/// jour et jauge de stock, ajout par le scanner.
///
/// Tout provient de `StackStore`, si bien qu’un produit ajouté depuis une fiche
/// ou depuis le scanner apparaît ici sans autre intervention. Aucun agrégat
/// n’est calculé dans la vue.
struct StackScreen: View {
    @Environment(AppRouter.self) private var router
    @Environment(StackStore.self) private var stack

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(eyebrow: eyebrow, title: "Ma stack")
                if stack.entries.isEmpty {
                    EmptyState(systemImage: "square.stack.3d.up",
                               message: "Votre stack est vide. Scannez un produit "
                                 + "pour commencer à suivre vos prises et vos coûts.",
                               actionTitle: "Scanner un produit") {
                        router.openScanner()
                    }
                } else {
                    tiles
                    SectionLabel(title: "Produits", meta: "Coût / jour")
                    rows
                    Button("Ajouter un produit") { router.openScanner() }
                        .buttonStyle(DSButtonStyle(.secondary))
                        .padding(.top, DSSpacing.s16)
                }
            }
            .padding(.horizontal, DSSpacing.screenMargin)
            .padding(.top, DSSpacing.s16)
            .padding(.bottom, DSSpacing.s28)
            .animation(DSMotion.state, value: stack.entries.count)
        }
        .scrollIndicators(.hidden)
        .background(DSColor.bg)
    }

    private var eyebrow: String {
        let count = stack.entries.count
        return "\(count) produit\(count > 1 ? "s" : "") actif\(count > 1 ? "s" : "")"
    }

    private var tiles: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible())],
                  spacing: 10) {
            MetricTile(moneyCents: stack.monthlyCostCents,
                       unit: "par mois · \(stack.yearlyCostEuros)\u{00A0}€/an",
                       label: "Coût de la stack")
            MetricTile(unit: nextRestockUnit, label: "Prochain rachat") {
                Text(stack.nextRestock.map { DSFormat.dayMonth($0.forecast.date) } ?? "·")
                    .font(DSFont.scaled(25, .heavy, relativeTo: .title2))
            }
        }
        .padding(.top, DSSpacing.s16)
    }

    private var nextRestockUnit: String {
        guard let next = stack.nextRestock else { return "aucun suivi" }
        return "\(next.entry.product.shortName) · ≈ \(next.forecast.daysLeft)\u{00A0}j"
    }

    /// Les rangées suivent l’ordre de la stack, comme la maquette, et non
    /// l’ordre d’urgence des rachats.
    private var rows: some View {
        let lastID = stack.entries.last?.id
        return VStack(spacing: 0) {
            ForEach(stack.entries) { entry in
                row(for: RestockAlert(entry: entry,
                                      forecast: stack.forecast(for: entry)))
                if entry.id != lastID { DSHairline() }
            }
        }
    }

    private func row(for alert: RestockAlert) -> some View {
        Button {
            router.openProduct(alert.entry.product)
        } label: {
            HStack(spacing: DSSpacing.s14) {
                Packshot(image: nil, size: .list)
                VStack(alignment: .leading, spacing: 3) {
                    Text(alert.entry.product.name)
                        .dsStyle(.rowTitle).foregroundStyle(DSColor.ink)
                    Text("\(alert.entry.doseLabel) · \(alert.entry.slot.rawValue.lowercased())")
                        .dsStyle(.secondary).foregroundStyle(DSColor.ink2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .trailing, spacing: 8) {
                    Text(DSFormat.money(cents: alert.entry.product.dailyCostCents))
                        .font(DSFont.scaled(13.5, .bold))
                        .foregroundStyle(DSColor.ink)
                    StockGauge(fraction: alert.entry.stockFraction,
                               isLow: alert.forecast.isLow)
                }
                .frame(width: 72)
            }
            .padding(.vertical, DSSpacing.s14)
            .contentShape(Rectangle())
        }
        .buttonStyle(RowPressStyle())
    }

}

#Preview("Clair") {
    StackScreen().environment(AppRouter()).environment(StackStore())
}

#Preview("Sombre") {
    StackScreen().environment(AppRouter()).environment(StackStore())
        .preferredColorScheme(.dark)
}

#Preview("AX1") {
    StackScreen().environment(AppRouter()).environment(StackStore())
        .environment(\.dynamicTypeSize, .accessibility1)
}
