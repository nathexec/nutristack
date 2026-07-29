import NutristackDesignSystem
import NutristackDomain
import SwiftUI

/// Fiche produit (gabarit DS §9) : en-tête packshot, conditionnements,
/// provenance, quatre tuiles dont le prix par actif en héros, composition avec
/// la jauge signature, avis, barre d’action ancrée.
///
/// Deux commandes sont réellement actives : le choix du conditionnement
/// recalcule les tuiles monétaires, et le filtre des avis restreint la liste
/// aux usages vérifiés. Aucune métrique n’est calculée ici.
struct ProductDetailView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.catalogRepository) private var repository
    @Environment(StackStore.self) private var stack
    let product: Product

    @State private var alternative: Product?
    /// `nil` tant que le dépôt n’a pas répondu, ce qui distingue le
    /// chargement d’une absence réelle d’avis.
    @State private var loadedReviews: [ProductReview]?
    @State private var variantIndex = 0
    @State private var reviewsFilterIndex = 0
    @State private var showsAllReviews = false
    @State private var activeSheet: Sheet?

    /// Règle d’usage vérifié en vigueur, transmise au badge et au filtre :
    /// une seule source pour les seuils, jamais de « 20 » recopié.
    private let verificationRule = VerificationRule()

    private enum Sheet: String, Identifiable {
        case provenance, labelExplainer
        var id: String { rawValue }
    }

    var body: some View {
        PushScaffold(title: product.name, backLabel: "Explorer",
                     onBack: { router.closePush() },
                     content: {
            VStack(alignment: .leading, spacing: 0) {
                header
                provenanceChip
                tiles
                composition
                reviews
            }
        }, actions: {
            Button(isInStack ? "Dans votre stack ✓" : "Ajouter à ma stack") { addToStack() }
                .buttonStyle(DSButtonStyle(isInStack ? .done : .primary))
                .disabled(isInStack)
            Button("Comparer") { compare() }
                .buttonStyle(DSButtonStyle(.secondary))
                .frame(maxWidth: 130)
                .disabled(alternative == nil)
        })
        .task { await load() }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .provenance: ProvenanceSheet(product: product)
            case .labelExplainer: LabelExplainerSheet(product: product)
            }
        }
    }

    /// Conditionnement sélectionné : il porte le prix et le nombre de doses,
    /// donc toutes les métriques monétaires de l’écran.
    private var variant: ProductVariant {
        product.variants[min(variantIndex, product.variants.count - 1)]
    }

    private var isInStack: Bool { stack.contains(product) }

    // MARK: En-tête

    private var header: some View {
        HStack(alignment: .center, spacing: DSSpacing.s16) {
            Packshot(image: nil, size: .productPage,
                     accessibilityLabel: "\(product.brand.name), \(product.name)")
            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand.name).dsStyle(.tileLabel).foregroundStyle(DSColor.accent)
                Text(product.name).dsStyle(.productName).foregroundStyle(DSColor.ink)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DSColor.accent)
                    Text("\(DSFormat.rating(product.ratings.effectAverage)) effet perçu"
                         + " · \(product.ratings.effectVerifiedCount) avis vérifiés")
                        .dsStyle(.secondary)
                        .foregroundStyle(DSColor.ink2)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Effet perçu "
                    + "\(DSFormat.rating(product.ratings.effectAverage)) sur 5, "
                    + "\(product.ratings.effectVerifiedCount) avis vérifiés")
                if product.variants.count > 1 {
                    FilterPills(options: product.variants.map(\.label),
                                selectedIndex: $variantIndex, scrollable: false)
                        .padding(.top, DSSpacing.s8)
                } else {
                    Text(variant.label)
                        .dsStyle(.tileLabel).foregroundStyle(DSColor.ink3)
                        .padding(.top, DSSpacing.s8)
                }
            }
        }
        .padding(.top, 4)
        .padding(.bottom, DSSpacing.s14)
    }

    private var provenanceChip: some View {
        ProvenanceChip(status: .verified,
                       text: "Étiquette · vérifiée le "
                           + DSFormat.shortDate(product.labelVerifiedOn)) {
            activeSheet = .provenance
        }
    }

    // MARK: Tuiles de métriques

    private var tiles: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible())],
                  spacing: 10) {
            MetricTile(moneyCents: variant.priceCents,
                       unit: "\(DSFormat.money(cents: variant.dailyCostCents)) par jour",
                       label: "Prix · \(variant.servingsPerContainer) jours")
            MetricTile(moneyCents: pricePerActiveGramCents,
                       unit: "/ g de \(activeShortName) élémentaire",
                       label: "Prix par actif", isHero: true)
            MetricTile(rating: product.ratings.effectAverage,
                       unit: "\(product.ratings.effectVerifiedCount) avis vérifiés",
                       label: "Effet perçu")
            MetricTile(rating: product.ratings.experienceAverage,
                       unit: "\(product.ratings.experienceCount) avis",
                       label: "Expérience")
        }
        .padding(.top, DSSpacing.s16)
        .animation(DSMotion.state, value: variantIndex)
    }

    private var pricePerActiveGramCents: Int {
        product.pricePerActiveGramCentsExact(for: variant)
            .map { Int($0.rounded()) } ?? 0
    }

    private var activeShortName: String {
        product.primaryIngredient?.active.shortName ?? "actif"
    }

    // MARK: Composition, jauge d’actif signature

    private var composition: some View {
        Group {
            SectionLabel(title: "Composition",
                         meta: "Dose journalière · \(product.servingLabel)")
            VStack(alignment: .leading, spacing: 0) {
                ForEach(product.ingredients) { ingredient in
                    ingredientRow(ingredient)
                    DSHairline()
                }
                Button("Comprendre cette étiquette") { activeSheet = .labelExplainer }
                    .buttonStyle(DSButtonStyle(.quiet))
            }
        }
    }

    @ViewBuilder private func ingredientRow(_ ingredient: IngredientDeclaration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                (Text(ingredient.compoundName).fontWeight(.bold)
                 + Text(ingredient.formNote.map { " (\($0))" } ?? "")
                    .foregroundStyle(DSColor.ink2))
                    .font(DSFont.scaled(14.5, .regular))
                    .foregroundStyle(DSColor.ink)
                Spacer(minLength: 10)
                Text(DSFormat.milligrams(ingredient.compoundMgPerServing))
                    .font(DSFont.scaled(14.5, .bold))
                    .foregroundStyle(DSColor.ink)
            }
            if ingredient.isPrimary {
                ActiveGauge(fraction: ingredient.elementalFraction)
                    .padding(.top, 9).padding(.bottom, 6)
                ActiveGaugeCaption(
                    leading: Text("soit ")
                        + Text(DSFormat.milligrams(ingredient.elementalMgPerServing)).bold()
                        + Text(" de \(ingredient.active.shortName) élémentaire"),
                    trailing: ingredient.vnrPercent.map { DSFormat.percentVNR($0) } ?? "")
            } else if let vnr = ingredient.vnrPercent {
                Text(DSFormat.percentVNR(vnr))
                    .dsStyle(.unit).foregroundStyle(DSColor.ink2)
                    .padding(.top, 3)
            }
        }
        .padding(.vertical, 13)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText(ingredient))
    }

    /// VoiceOver littéral (DS §11) : les valeurs, pas la géométrie.
    private func accessibilityText(_ ingredient: IngredientDeclaration) -> String {
        var parts = ["\(ingredient.compoundName), "
            + DSFormat.milligrams(ingredient.compoundMgPerServing)]
        if ingredient.isPrimary {
            parts.append("soit \(DSFormat.milligrams(ingredient.elementalMgPerServing))"
                + " de \(ingredient.active.name) élémentaire")
        }
        if let vnr = ingredient.vnrPercent { parts.append("\(vnr) pour cent des VNR") }
        return parts.joined(separator: ", ")
    }

    // MARK: Avis

    /// Avis affichés : tous, ou les seuls usages vérifiés selon le segment.
    /// Le tri « vérifiés » applique la règle du domaine, il ne lit pas un
    /// drapeau posé à la main.
    private var filteredReviews: [ProductReview] {
        let all = loadedReviews ?? []
        return reviewsFilterIndex == 0 ? all.usageVerified(rule: verificationRule) : all
    }

    private var visibleReviews: [ProductReview] {
        showsAllReviews ? filteredReviews : Array(filteredReviews.prefix(1))
    }

    private var reviews: some View {
        Group {
            SectionLabel(title: "Avis")
            DSSegmented(options: ["Vérifiés", "Tous"], selectedIndex: $reviewsFilterIndex)
                .padding(.top, DSSpacing.s8)
            if loadedReviews == nil {
                SkeletonBlock(height: 118).padding(.top, DSSpacing.s12)
            } else if filteredReviews.isEmpty {
                Text("Aucun avis ne remplit encore la règle d\u{2019}usage vérifié "
                     + "pour ce produit.")
                    .dsStyle(.subBody).foregroundStyle(DSColor.ink2)
                    .padding(.vertical, DSSpacing.s16)
            } else {
                ForEach(visibleReviews) { review in
                    reviewCard(review)
                }
                if filteredReviews.count > 1 {
                    Button(showsAllReviews
                           ? "Réduire les avis"
                           : "Voir les \(filteredReviews.count - 1) autres avis") {
                        withAnimation(DSMotion.state) { showsAllReviews.toggle() }
                    }
                    .buttonStyle(DSButtonStyle(.quiet))
                }
            }
        }
        .animation(DSMotion.state, value: reviewsFilterIndex)
    }

    private func reviewCard(_ review: ProductReview) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Text(review.author)
                    .font(DSFont.scaled(14, .bold))
                    .foregroundStyle(DSColor.ink)
                Spacer()
                if review.isUsageVerified() {
                    VerifiedBadge(intakes: review.intakes, weeks: review.weeks,
                                  ruleIntakes: verificationRule.minIntakes,
                                  ruleWeeks: verificationRule.minDays / 7)
                } else {
                    Text("\(review.intakes) prises / \(review.weeks) sem.")
                        .font(DSFont.scaled(12, .semibold))
                        .foregroundStyle(DSColor.ink3)
                }
            }
            Text(review.conflictDisclosure)
                .font(DSFont.scaled(11, .semibold))
                .foregroundStyle(DSColor.ink3)
                .padding(.vertical, 4).padding(.horizontal, 9)
                .overlay(Capsule().stroke(DSColor.hairline, lineWidth: DSSize.hairline))
            Text(review.text)
                .dsStyle(.subBody)
                .foregroundStyle(DSColor.ink.opacity(0.92))
                .lineSpacing(4)
        }
        .padding(EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16))
        .background(RoundedRectangle(cornerRadius: DSRadius.standard, style: .continuous)
            .stroke(DSColor.hairline, lineWidth: DSSize.hairline))
        .padding(.top, DSSpacing.s12)
    }

    // MARK: Actions

    private func addToStack() {
        guard stack.add(product) else { return }
        router.show("\(product.shortName) ajouté à votre stack")
    }

    /// Charge ce que la fiche ne peut pas déduire du produit lui-même :
    /// l’alternative comparable et les avis. L’alternative est le produit le
    /// moins cher au gramme portant le même actif principal ; la règle vit dans
    /// le domaine, la fiche ne fait que l’appliquer au résultat du dépôt.
    @MainActor private func load() async {
        let candidates = await repository.search(text: "", category: product.category)
        alternative = CatalogRanking.cheapestAlternative(to: product, in: candidates)
        loadedReviews = await repository.reviews(for: product.id)
    }

    private func compare() {
        guard let alternative else { return }
        router.openCompare(product, alternative)
    }

}

#Preview("Clair") {
    ProductDetailView(product: DemoCatalog.albaMagnesium)
        .environment(AppRouter())
        .environment(StackStore())
}

#Preview("Sombre") {
    ProductDetailView(product: DemoCatalog.albaMagnesium)
        .environment(AppRouter())
        .environment(StackStore())
        .preferredColorScheme(.dark)
}

#Preview("AX1") {
    ProductDetailView(product: DemoCatalog.albaMagnesium)
        .environment(AppRouter())
        .environment(StackStore())
        .environment(\.dynamicTypeSize, .accessibility1)
}
