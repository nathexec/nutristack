import NutristackDesignSystem
import NutristackDomain
import SwiftUI

/// Comparateur (gabarit DS §9) : bandeau de formes différentes, en-têtes
/// packshot, tableau du moteur avec cascade des cellules gagnantes
/// (décalage 90 ms), verdict en ressort, partage en image rendue.
struct CompareView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let left: Product
    let right: Product
    private let result: ComparisonEngine.Result

    @State private var revealedWins = 0
    @State private var verdictShown = false
    @State private var isSharePresented = false

    /// Largeur fixe de la colonne des libellés (≈ 36 % d’un écran de 375 pt).
    private let labelWidth: CGFloat = 116

    init(left: Product, right: Product) {
        self.left = left
        self.right = right
        result = ComparisonEngine.compare(left, right)
    }

    var body: some View {
        PushScaffold(title: "Comparateur", backLabel: "Retour",
                     onBack: { router.closePush() },
                     content: {
            VStack(alignment: .leading, spacing: 0) {
                header
                if !result.sameForm {
                    AttentionBanner("Formes différentes : la comparaison porte sur le "
                        + "\(activeName) élémentaire. La forme peut influencer "
                        + "l\u{2019}assimilation.")
                        .padding(.bottom, DSSpacing.s14)
                }
                heads
                table
                if verdictShown {
                    VerdictCard(title: result.verdict.title,
                                subtitle: result.verdict.subtitle.isEmpty
                                    ? nil : result.verdict.subtitle)
                        .padding(.top, DSSpacing.s14)
                        .transition(VerdictCard.revealTransition)
                }
            }
        }, actions: {
            Button("Partager en image") { isSharePresented = true }
                .buttonStyle(DSButtonStyle(.primary))
        })
        .sheet(isPresented: $isSharePresented) {
            CompareShareSheet(left: left, right: right, result: result)
        }
        .task { await revealSequence() }
    }

    private var activeName: String {
        left.primaryIngredient?.active.name.lowercased() ?? "actif"
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(left.primaryIngredient?.active.name ?? "") · 2 produits")
                .dsStyle(.label).foregroundStyle(DSColor.ink3)
            Text("Deux produits, un même actif")
                .dsStyle(.productName).foregroundStyle(DSColor.ink)
        }
        .padding(.top, 4)
        .padding(.bottom, DSSpacing.s14)
    }

    /// En-têtes de colonnes : packshot 46, forme, marque.
    private var heads: some View {
        HStack(alignment: .top, spacing: 0) {
            Color.clear.frame(width: scaledLabelWidth, height: 1)
            productHead(left)
            productHead(right)
        }
        .padding(.bottom, DSSpacing.s8)
    }

    private func productHead(_ product: Product) -> some View {
        VStack(spacing: 6) {
            Packshot(image: nil, size: .compare,
                     accessibilityLabel: "\(product.brand.name), \(product.formLabel)")
            Text(product.formLabel)
                .font(DSFont.scaled(13, .bold))
                .foregroundStyle(DSColor.ink)
            Text(product.brand.name)
                .dsStyle(.tileLabel).foregroundStyle(DSColor.ink3)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Tableau

    private var table: some View {
        let indexed = winIndexedRows
        return VStack(spacing: 0) {
            ForEach(Array(indexed.enumerated()), id: \.offset) { position, item in
                tableRow(item.row, winIndex: item.winIndex)
                if position != indexed.count - 1 { DSHairline() }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: DSRadius.standard, style: .continuous)
            .stroke(DSColor.hairline, lineWidth: DSSize.hairline))
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.standard, style: .continuous))
    }

    /// Associe à chaque ligne gagnante son rang dans la cascade de révélation.
    private var winIndexedRows: [(row: ComparisonEngine.Row, winIndex: Int?)] {
        var next = 0
        return result.rows.map { row in
            guard row.winner != nil else { return (row, nil) }
            defer { next += 1 }
            return (row, next)
        }
    }

    private func tableRow(_ row: ComparisonEngine.Row, winIndex: Int?) -> some View {
        let highlighted = winIndex.map { $0 < revealedWins } ?? false
        return HStack(alignment: .center, spacing: 0) {
            Text(row.label)
                .font(DSFont.scaled(12.5, .medium))
                .foregroundStyle(DSColor.ink2)
                .frame(width: scaledLabelWidth - 12, alignment: .leading)
                .padding(.leading, 12)
                .minimumScaleFactor(0.8)
            cell(row.left, isWinner: row.winner == .left && highlighted, isHero: row.isHero)
            cell(row.right, isWinner: row.winner == .right && highlighted, isHero: row.isHero)
        }
        .padding(.vertical, row.isHero ? 13 : 10)
        .background(row.isHero ? DSColor.accentTint.opacity(0.5) : Color.clear)
        .animation(DSMotion.state, value: revealedWins)
    }

    @ViewBuilder private func cell(_ value: ComparisonEngine.CellValue,
                                   isWinner: Bool, isHero: Bool) -> some View {
        Group {
            switch value {
            case .money(let cents):
                Text(DSFormat.money(cents: cents))
                    .font(DSFont.scaled(isHero ? 16 : 15, .heavy))
            case .milligrams(let mg, let vnr):
                VStack(spacing: 1) {
                    Text(DSFormat.milligrams(mg))
                        .font(DSFont.scaled(15, .heavy))
                    if let vnr {
                        Text(DSFormat.percentVNR(vnr))
                            .font(DSFont.scaled(10.5, .semibold))
                            .foregroundStyle(DSColor.ink3)
                    }
                }
            case .count(let count):
                Text("\(count)")
                    .font(DSFont.scaled(15, .heavy))
            case .text(let label):
                Text(label)
                    .font(DSFont.scaled(13.5, .bold))
            case .rating(let value, let count):
                // La maquette écrit le décompte en clair (« 41 avis ») : une note
                // ne paraît jamais sans le nombre d’avis qui la fonde (DS §10).
                VStack(spacing: 1) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(DSColor.accent)
                        Text(DSFormat.rating(value))
                            .font(DSFont.scaled(15, .heavy))
                    }
                    Text("\(count) avis")
                        .font(DSFont.scaled(10.5, .semibold))
                        .foregroundStyle(DSColor.ink3)
                }
            }
        }
        .foregroundStyle(isWinner ? DSColor.accent : DSColor.ink)
        .padding(.vertical, 4).padding(.horizontal, 6)
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(isWinner ? DSColor.accentTint : Color.clear))
        .frame(maxWidth: .infinity)
        // Le surlignage seul est une information par la couleur : VoiceOver
        // reçoit la valeur en clair et la mention « meilleure valeur » (DS §11).
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary(for: value, isWinner: isWinner))
    }

    /// Valeur d’une cellule en toutes lettres, pour les lecteurs d’écran.
    private func accessibilitySummary(for value: ComparisonEngine.CellValue,
                                      isWinner: Bool) -> String {
        let core: String
        switch value {
        case .money(let cents):
            core = DSFormat.money(cents: cents)
        case .milligrams(let mg, let vnr):
            core = DSFormat.milligrams(mg)
                + (vnr.map { ", \($0) pour cent des VNR" } ?? "")
        case .count(let count):
            core = "\(count)"
        case .text(let text):
            core = text
        case .rating(let value, let count):
            core = "note \(DSFormat.rating(value)) sur 5, \(count) avis"
        }
        return isWinner ? core + ", meilleure valeur" : core
    }

    /// Libellé de la colonne des étiquettes, réduit quand les corps de texte
    /// grossissent : sans cela, le tableau à trois colonnes se tronque aux
    /// tailles d’accessibilité (DS §11).
    private var scaledLabelWidth: CGFloat {
        dynamicTypeSize >= .accessibility1 ? 92 : labelWidth
    }

    /// Cascade de révélation (DS §8) : cellules gagnantes toutes les 90 ms,
    /// puis verdict en ressort. Sans animation si le réglage système l’exige.
    @MainActor private func revealSequence() async {
        let wins = result.rows.filter { $0.winner != nil }.count
        guard !reduceMotion else {
            revealedWins = wins
            verdictShown = true
            return
        }
        // La tâche est annulée si la vue disparaît pendant la cascade ; il
        // faut alors s’arrêter, pas dérouler la boucle sans délais sur un
        // écran qui n’existe plus.
        do {
            try await Task.sleep(for: .milliseconds(400))
            for step in 1...max(wins, 1) {
                withAnimation(DSMotion.state) { revealedWins = step }
                try await Task.sleep(for: .milliseconds(Int(DSMotion.revealStagger * 1000)))
            }
        } catch {
            return
        }
        withAnimation(DSMotion.sheet) { verdictShown = true }
    }
}

#Preview("Clair") {
    CompareView(left: DemoCatalog.albaMagnesium, right: DemoCatalog.nordikaMagnesium)
        .environment(AppRouter())
}

#Preview("Sombre") {
    CompareView(left: DemoCatalog.albaMagnesium, right: DemoCatalog.nordikaMagnesium)
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}

#Preview("AX1") {
    CompareView(left: DemoCatalog.albaMagnesium, right: DemoCatalog.nordikaMagnesium)
        .environment(AppRouter())
        .environment(\.dynamicTypeSize, .accessibility1)
}
