import NutristackDesignSystem
import NutristackDomain
import SwiftUI

/// Écran Explorer (gabarit DS §9) : recherche, pilules de catégories,
/// section « Meilleur prix par actif » et section « Les mieux notés ».
///
/// Règle fondatrice appliquée ici (PRD §6.1) : un prix par gramme ne se compare
/// qu’à actif identique. La première section se restreint donc toujours à un
/// seul actif et l’annonce en métadonnée ; classer ensemble un gramme de whey
/// et un gramme de magnésium n’aurait aucun sens.
struct ExploreView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.catalogRepository) private var repository

    @State private var searchText = ""
    @State private var categoryIndex = 0
    @State private var products: [Product] = []

    /// Le premier élément représente « Tous » ; l’ordre suit celui des pilules.
    private let categories: [ProductCategory?] =
        [nil] + ProductCategory.allCases.map { Optional($0) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(eyebrow: "Catalogue · \(ProductCategory.allCases.count) catégories",
                             title: "Explorer",
                             actionIcon: "arrow.left.arrow.right",
                             actionLabel: "Ouvrir le comparateur") {
                    openDefaultComparison()
                }
                SearchField(text: $searchText,
                            placeholder: "Produit, marque, ingrédient\u{2026}")
                    .padding(.top, DSSpacing.s16)
                FilterPills(options: ["Tous"] + ProductCategory.allCases.map(\.rawValue),
                            selectedIndex: $categoryIndex)
                    .padding(.top, DSSpacing.s14)
                results
            }
            .padding(.horizontal, DSSpacing.screenMargin)
            .padding(.top, DSSpacing.s16)
            .padding(.bottom, DSSpacing.s28)
        }
        .scrollIndicators(.hidden)
        .background(DSColor.bg)
        .task(id: "\(searchText)|\(categoryIndex)") { await reload() }
    }

    @ViewBuilder private var results: some View {
        let group = comparableGroup
        let topRated = topRatedPicks
        if group == nil && topRated.isEmpty {
            EmptyState(systemImage: "magnifyingglass",
                       message: "Aucun résultat. Scannez le produit ou demandez son ajout.",
                       actionTitle: "Scanner un produit") {
                router.openScanner()
            }
        } else {
            if let group {
                section(title: "Meilleur prix par actif",
                        meta: group.active.name,
                        items: group.products)
            }
            if !topRated.isEmpty {
                section(title: "Les mieux notés", meta: "Usage vérifié", items: topRated)
            }
        }
    }

    /// Recharge les résultats pour la recherche et la catégorie courantes.
    /// Méthode isolée plutôt que corps de fermeture : la mutation d’état de vue
    /// appartient à l’acteur principal, et l’écrire ainsi le documente.
    @MainActor private func reload() async {
        products = await repository.search(text: searchText,
                                           category: categories[categoryIndex])
    }

    // MARK: Sélections dérivées

    /// Les deux classements viennent du domaine : ce sont des règles de
    /// produit, testées, et non des détails d’affichage (voir `CatalogRanking`).
    private var comparableGroup: CatalogRanking.ActiveGroup? {
        CatalogRanking.comparableGroup(in: products)
    }

    private var topRatedPicks: [Product] {
        CatalogRanking.topRated(in: products)
    }

    /// Comparaison par défaut de l’action d’en-tête : les deux premiers produits
    /// comparables affichés, jamais une paire codée en dur.
    private func openDefaultComparison() {
        guard let group = comparableGroup, group.products.count > 1 else {
            router.show("Sélectionnez une catégorie pour comparer deux produits")
            return
        }
        router.openCompare(group.products[0], group.products[1])
    }

    private func section(title: String, meta: String, items: [Product]) -> some View {
        let lastID = items.last?.id
        return Group {
            SectionLabel(title: title, meta: meta)
            VStack(spacing: 0) {
                ForEach(items) { product in
                    ProductRow(image: nil,
                               brand: product.brand.name,
                               name: product.name,
                               tag: pricePerGramTag(product),
                               rating: product.ratings.effectAverage,
                               ratingCount: "\(product.ratings.effectVerifiedCount) avis") {
                        router.openProduct(product)
                    }
                    if product.id != lastID { DSHairline() }
                }
            }
        }
    }

    private func pricePerGramTag(_ product: Product) -> String? {
        guard let exact = product.pricePerActiveGramCentsExact,
              let short = product.primaryIngredient?.active.shortName else { return nil }
        return DSFormat.pricePerGram(centsExact: exact, activeShort: short)
    }
}

#Preview("Clair") {
    ExploreView().environment(AppRouter())
}

#Preview("Sombre") {
    ExploreView().environment(AppRouter()).preferredColorScheme(.dark)
}

#Preview("AX1") {
    ExploreView().environment(AppRouter())
        .environment(\.dynamicTypeSize, .accessibility1)
}
