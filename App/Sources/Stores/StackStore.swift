import Foundation
import NutristackDomain
import Observation

/// Source de vérité de la stack de l’utilisateur : quels produits il prend,
/// dans quel format, à quel créneau, et ce qu’il en reste.
///
/// Tous les écrans lisent ici, si bien qu’un ajout depuis la fiche produit ou
/// depuis le scanner se voit immédiatement dans Aujourd’hui et dans Ma stack.
/// Le magasin ne calcule rien lui-même : coûts, prévisions et seuils viennent
/// du domaine. La persistance locale arrive au jalon M3 ; l’état vit en
/// mémoire d’ici là, ce qui n’a aucune incidence sur les écrans.
@Observable
@MainActor
final class StackStore {

    private(set) var entries: [StackEntry]

    /// Jour de référence, injecté pour que les prévisions restent déterministes.
    let today: Date

    init(entries: [StackEntry] = DemoCatalog.stackEntries,
         today: Date = DemoCatalog.referenceDate) {
        self.entries = entries
        self.today = today
    }

    // MARK: Lecture

    func contains(_ product: Product) -> Bool {
        entries.contains { $0.product.id == product.id }
    }

    /// Coût journalier cumulé, en centimes.
    var dailyCostCents: Int { StackCosts.dailyCostCents(entries) }
    /// Coût mensuel, sur une base de trente jours.
    var monthlyCostCents: Int { StackCosts.monthlyCostCents(entries) }
    /// Coût annuel en euros entiers.
    var yearlyCostEuros: Int { StackCosts.yearlyCostEuros(entries) }

    /// Prévisions de rachat, de la plus urgente à la plus lointaine.
    var forecasts: [RestockAlert] {
        RestockAlert.forecasts(for: entries, today: today)
    }

    /// Entrées sous le seuil d’alerte de rachat.
    var lowStock: [RestockAlert] {
        RestockAlert.lowStock(for: entries, today: today)
    }

    /// Prochaine rupture, qu’elle soit ou non sous le seuil d’alerte.
    var nextRestock: RestockAlert? { forecasts.first }

    /// Prévision d’une entrée précise. L’écran Ma stack affiche les produits
    /// dans l’ordre de la stack, pas par urgence : il lit donc ici plutôt que
    /// dans `forecasts`, qui est trié.
    func forecast(for entry: StackEntry) -> RestockForecast {
        RestockForecast(entry: entry, today: today)
    }

    // MARK: Écriture

    /// Ajoute un produit s’il n’y est pas déjà. L’entrée créée reprend la dose
    /// de l’étiquette et suppose un contenant neuf (règle du domaine).
    /// Renvoie vrai si la stack a changé, afin que l’appelant sache s’il doit
    /// confirmer l’action à l’utilisateur.
    @discardableResult
    func add(_ product: Product, slot: ScheduleSlot = .morning) -> Bool {
        guard !contains(product) else { return false }
        entries.append(StackEntry(adding: product, slot: slot))
        return true
    }
}
