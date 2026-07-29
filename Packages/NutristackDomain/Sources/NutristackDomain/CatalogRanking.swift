import Foundation

/// Classements du catalogue (PRD §6.1 et §9).
///
/// Ces règles vivaient dans les écrans, où elles n’étaient ni testables ni
/// partagées. Elles appartiennent au domaine : ce sont des décisions de produit,
/// pas des détails d’affichage.
///
/// La règle qui gouverne tout : **un prix au gramme ne se compare qu’à actif
/// identique**. Classer ensemble un gramme de protéines et un gramme de
/// magnésium n’aurait aucun sens, et le ferait croire au lecteur.
public enum CatalogRanking {

    /// Ensemble de produits partageant un même actif principal, classés du
    /// moins cher au plus cher par gramme d’actif.
    public struct ActiveGroup: Hashable, Sendable {
        public let active: ActiveSubstance
        public let products: [Product]

        /// Écart relatif entre le moins cher et le plus cher, de 0 à 1.
        /// Mesure l’intérêt de la comparaison : plus il est grand, plus le
        /// choix du produit change la facture.
        public var priceSpread: Double {
            let prices = products.compactMap(\.pricePerActiveGramCentsExact)
            guard let cheapest = prices.min(), let dearest = prices.max(),
                  dearest > 0 else { return 0 }
            return 1 - cheapest / dearest
        }
    }

    /// Regroupe les produits par actif principal et retient celui qui mérite
    /// le plus d’être montré.
    ///
    /// Départage, dans l’ordre : le groupe le plus fourni, puis celui dont
    /// l’écart de prix est le plus instructif, puis l’ordre alphabétique de
    /// l’actif. Le second critère n’est pas cosmétique : entre deux actifs
    /// également représentés, celui où le prix varie le plus est celui où
    /// notre classement rend le plus grand service.
    public static func comparableGroup(in products: [Product]) -> ActiveGroup? {
        let grouped = Dictionary(grouping: products.filter {
            $0.primaryIngredient != nil && $0.pricePerActiveGramCentsExact != nil
        }) { $0.primaryIngredient?.active }

        let candidates: [ActiveGroup] = grouped.compactMap { active, items in
            guard let active, items.count > 1 else { return nil }
            let sorted = items.sorted {
                ($0.pricePerActiveGramCentsExact ?? .infinity)
                    < ($1.pricePerActiveGramCentsExact ?? .infinity)
            }
            return ActiveGroup(active: active, products: sorted)
        }

        return candidates.sorted { lhs, rhs in
            if lhs.products.count != rhs.products.count {
                return lhs.products.count > rhs.products.count
            }
            if lhs.priceSpread != rhs.priceSpread {
                return lhs.priceSpread > rhs.priceSpread
            }
            return lhs.active.name < rhs.active.name
        }.first
    }

    /// Meilleures notes d’effet perçu. Le départage par nombre d’avis vérifiés
    /// évite qu’une égalité de note dépende de l’ordre du catalogue.
    public static func topRated(in products: [Product], limit: Int = 2) -> [Product] {
        products.sorted {
            ($0.ratings.effectAverage, $0.ratings.effectVerifiedCount)
                > ($1.ratings.effectAverage, $1.ratings.effectVerifiedCount)
        }
        .prefix(limit)
        .map { $0 }
    }

    /// Alternative à proposer face à un produit : le moins cher au gramme parmi
    /// ceux qui portent le même actif principal. Renvoie `nil` quand le
    /// catalogue n’a rien de comparable, auquel cas l’interface doit désactiver
    /// la comparaison plutôt que d’opposer deux actifs différents.
    public static func cheapestAlternative(to product: Product,
                                           in products: [Product]) -> Product? {
        guard let active = product.primaryIngredient?.active else { return nil }
        return products
            .filter { $0.id != product.id && $0.primaryIngredient?.active == active }
            .min {
                ($0.pricePerActiveGramCentsExact ?? .infinity)
                    < ($1.pricePerActiveGramCentsExact ?? .infinity)
            }
    }
}
