import Foundation
import NutristackDomain

/// Accès au catalogue. Le MVP réel branche GRDB (cache local) et l’API
/// Supabase derrière ce protocole au jalon M3 ; l’app ne dépend que de lui.
protocol CatalogRepository: Sendable {
    /// Recherche un produit par code-barres (scanner).
    func product(ean: String) async -> Product?
    /// Recherche plein texte, éventuellement restreinte à une catégorie.
    /// Le texte porte sur le nom, la marque et les ingrédients déclarés, comme
    /// l’annonce le libellé du champ de recherche.
    func search(text: String, category: ProductCategory?) async -> [Product]
    /// Avis déposés sur un produit, vérifiés ou non.
    func reviews(for productID: String) async -> [ProductReview]
}

/// Implémentation de démonstration : catalogue en mémoire, latence nulle.
struct DemoCatalogRepository: CatalogRepository {
    func product(ean: String) async -> Product? {
        DemoCatalog.all.first { $0.ean == ean }
    }

    func search(text: String, category: ProductCategory?) async -> [Product] {
        DemoCatalog.all.filter { product in
            let matchesCategory = category.map { product.category == $0 } ?? true
            return matchesCategory && matches(product, text: text)
        }
    }

    func reviews(for productID: String) async -> [ProductReview] {
        DemoCatalog.reviews(for: productID)
    }

    private func matches(_ product: Product, text: String) -> Bool {
        guard !text.isEmpty else { return true }
        if product.name.localizedCaseInsensitiveContains(text)
            || product.brand.name.localizedCaseInsensitiveContains(text) {
            return true
        }
        return product.ingredients.contains { ingredient in
            ingredient.compoundName.localizedCaseInsensitiveContains(text)
                || ingredient.active.name.localizedCaseInsensitiveContains(text)
        }
    }
}
