import NutristackDomain
import Observation
import SwiftUI

/// Navigation de l’application (gabarits du DS §9) :
/// quatre onglets, des écrans poussés plein écran qui recouvrent la barre
/// d’onglets, le scanner en recouvrement, et le toast unique.
@Observable
@MainActor
final class AppRouter {

    /// Les quatre onglets de la barre inférieure. Le scanner n’en est pas un :
    /// c’est un recouvrement, conformément au gabarit du DS §9.
    enum Tab: Hashable {
        case today, explore, stack, profile
    }

    /// Écrans poussés (fiche produit, comparateur).
    ///
    /// L’égalité et le hachage reposent sur l’identifiant seul. La synthèse
    /// automatique comparerait des `Product` entiers, donc leurs ingrédients,
    /// leurs provenances et leurs conditionnements, à chaque évaluation
    /// d’animation : coûteux et sans intérêt, puisque deux routes désignant le
    /// même écran sont la même route.
    enum PushRoute: Hashable, Identifiable {
        case product(Product)
        case compare(Product, Product)

        var id: String {
            switch self {
            case .product(let product):
                return "product-\(product.id)"
            case .compare(let left, let right):
                return "compare-\(left.id)-\(right.id)"
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    var tab: Tab = .today
    var push: PushRoute?
    var isScannerPresented = false
    var toast: String?

    // MARK: Intentions de navigation

    func openProduct(_ product: Product) { push = .product(product) }
    func openCompare(_ left: Product, _ right: Product) { push = .compare(left, right) }
    func closePush() { push = nil }
    func openScanner() { isScannerPresented = true }
    func closeScanner() { isScannerPresented = false }
    func show(_ message: String) { toast = message }
}
