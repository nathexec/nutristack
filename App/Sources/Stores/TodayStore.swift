import Foundation
import NutristackDomain
import Observation

/// Journée en cours : le plan de prises dérivé de la stack, et ce qui a déjà
/// été coché.
///
/// Ce magasin ne possède pas la composition de la stack, il la lit dans
/// `StackStore`. Séparer les deux garde une responsabilité par objet : l’un
/// répond à « que prend cette personne », l’autre à « qu’a-t-elle fait
/// aujourd’hui ». Les sections sont calculées et non stockées, si bien qu’un
/// ajout de produit apparaît immédiatement dans la journée.
@Observable
@MainActor
final class TodayStore {

    /// Prise planifiée du jour.
    struct PlannedIntake: Identifiable, Hashable {
        let id: String
        let entry: StackEntry
        var product: Product { entry.product }
        var costCents: Int { entry.product.dailyCostCents }
    }

    /// Section horodatée de l’écran. Un type nommé plutôt qu’un couple :
    /// `ForEach` a besoin d’une identité, et Swift n’autorise pas les chemins
    /// de clé vers les composantes d’un tuple.
    struct DaySection: Identifiable, Hashable {
        let slot: ScheduleSlot
        let items: [PlannedIntake]
        var id: ScheduleSlot { slot }
        /// Heure affichée en métadonnée de section (« 08:00 »).
        var time: String { slot.time }
        /// Nom du créneau (« Matin »).
        var title: String { slot.rawValue }
    }

    private let stack: StackStore
    private(set) var doneIDs: Set<String> = []

    init(stack: StackStore) {
        self.stack = stack
    }

    // MARK: Lecture

    /// Jour de référence, seule origine de la date affichée en en-tête.
    var today: Date { stack.today }

    /// Prises du jour, une par entrée de la stack.
    ///
    /// C’est la dérivation de base : les sections en découlent, et non
    /// l’inverse. Les compteurs lisent donc une simple projection plutôt que de
    /// reconstruire le regroupement par créneau à chaque accès.
    var allItems: [PlannedIntake] {
        stack.entries.map { PlannedIntake(id: $0.id, entry: $0) }
    }

    /// Prises regroupées par créneau, dans l’ordre des créneaux de la journée.
    /// Les créneaux vides ne produisent pas de section.
    var sections: [DaySection] {
        let items = allItems
        return ScheduleSlot.allCases.compactMap { slot in
            let slotItems = items.filter { $0.entry.slot == slot }
            return slotItems.isEmpty ? nil : DaySection(slot: slot, items: slotItems)
        }
    }

    /// Produit dont le stock s’épuise le premier, s’il est sous le seuil.
    var watch: RestockAlert? { stack.lowStock.first }
    /// Nombre total d’entrées sous le seuil, pour signaler qu’il en reste.
    var lowStockCount: Int { stack.lowStock.count }

    /// Tous les compteurs dérivent de `allItems`, jamais de `stack.entries`
    /// directement : si la projection changeait de règle, aucun compteur ne
    /// pourrait diverger d’elle en silence.
    var plannedCount: Int { allItems.count }
    var takenCount: Int { allItems.filter { doneIDs.contains($0.id) }.count }
    var plannedCostCents: Int { allItems.reduce(0) { $0 + $1.costCents } }
    var consumedCostCents: Int {
        allItems.filter { doneIDs.contains($0.id) }.reduce(0) { $0 + $1.costCents }
    }
    var isRoutineComplete: Bool { plannedCount > 0 && takenCount == plannedCount }
    func isDone(_ item: PlannedIntake) -> Bool { doneIDs.contains(item.id) }

    // MARK: Actions

    /// Bascule réversible d’une prise (DS §7, rangée de prise).
    func toggle(_ item: PlannedIntake) {
        if doneIDs.contains(item.id) {
            doneIDs.remove(item.id)
        } else {
            doneIDs.insert(item.id)
        }
    }
}
