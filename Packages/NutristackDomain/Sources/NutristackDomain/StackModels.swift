import Foundation

/// Créneau de prise d’une journée (PRD §5.4).
public enum ScheduleSlot: String, CaseIterable, Sendable {
    case morning = "Matin"
    case training = "Entraînement"
    case evening = "Soir"
    public var time: String {
        switch self {
        case .morning: return "08:00"
        case .training: return "18:30"
        case .evening: return "22:00"
        }
    }
}

/// Produit installé dans la stack de l’utilisateur.
public struct StackEntry: Identifiable, Hashable, Sendable {
    public let id: String
    public let product: Product
    /// Dose que l’utilisateur a réglée, indépendante de celle de l’étiquette.
    public let doseLabel: String
    /// Créneau de prise choisi.
    public let slot: ScheduleSlot
    /// Part restante du conditionnement, de 0 (vide) à 1 (neuf). Déclarée par
    /// l’utilisateur ou déduite des prises enregistrées au jalon M3.
    public let stockFraction: Double

    public init(id: String, product: Product, doseLabel: String,
                slot: ScheduleSlot, stockFraction: Double) {
        self.id = id
        self.product = product
        self.doseLabel = doseLabel
        self.slot = slot
        self.stockFraction = stockFraction
    }

    /// Entrée créée à l’ajout d’un produit à la stack : la dose reprend celle
    /// de l’étiquette, le contenant est supposé neuf. Ces valeurs par défaut
    /// sont une décision de produit, elles vivent donc dans le domaine et non
    /// dans l’écran qui déclenche l’ajout.
    public init(adding product: Product, slot: ScheduleSlot = .morning) {
        self.init(id: "stack-\(product.id)",
                  product: product,
                  doseLabel: product.servingLabel,
                  slot: slot,
                  stockFraction: 1)
    }

    /// Doses restantes estimées à partir de la jauge de stock.
    public var servingsLeft: Double {
        stockFraction * Double(product.servingsPerContainer)
    }
}

/// Prédiction de rachat (PRD §5.4) : à une prise par jour, la date où le
/// contenant sera vide. Le calcul reçoit la date du jour pour rester testable.
public struct RestockForecast: Hashable, Sendable {
    /// Nombre de jours de la dernière dose incluse.
    public let daysLeft: Int
    /// Date de rupture estimée.
    public let date: Date

    /// Seuil unique du produit : en dessous, l’interface passe en ambre et
    /// propose le rachat. Défini ici pour qu’aucun écran ne le redéfinisse.
    public static let lowStockThresholdDays = 10

    public init(entry: StackEntry, today: Date, calendar: Calendar = .current) {
        let days = Int(entry.servingsLeft.rounded(.up))
        daysLeft = days
        date = calendar.date(byAdding: .day, value: days, to: today) ?? today
    }

    /// Vrai sous le seuil d’alerte de rachat.
    public var isLow: Bool { daysLeft < Self.lowStockThresholdDays }
}

/// Association d’une entrée et de sa prévision de rachat, pour les écrans qui
/// affichent les deux ensemble. Un type nommé plutôt qu’un couple : il porte
/// une identité, donc il traverse `ForEach` sans détour.
public struct RestockAlert: Identifiable, Hashable, Sendable {
    public let entry: StackEntry
    public let forecast: RestockForecast
    public var id: String { entry.id }

    public init(entry: StackEntry, forecast: RestockForecast) {
        self.entry = entry
        self.forecast = forecast
    }

    /// Prévisions de toutes les entrées, de la plus urgente à la plus lointaine.
    ///
    /// `sorted` n’étant pas stable en Swift, le rang d’origine sert de second
    /// critère : deux produits qui s’épuisent le même jour restent dans
    /// l’ordre de la stack au lieu de permuter d’un appel à l’autre.
    public static func forecasts(for entries: [StackEntry],
                                 today: Date,
                                 calendar: Calendar = .current) -> [RestockAlert] {
        // Écrit en boucle explicite et non en chaîne map/sorted sur tuples :
        // la première compilation réelle (Swift 6.0.3) a montré que la version
        // en chaîne faisait exploser l’inférence de types du fichier entier
        // (délai de vérification supérieur à sept minutes, mesuré). Le
        // comportement est identique et verrouillé par le test de tri stable.
        var indexed: [(rank: Int, alert: RestockAlert)] = []
        indexed.reserveCapacity(entries.count)
        for (rank, entry) in entries.enumerated() {
            let forecast = RestockForecast(entry: entry, today: today,
                                           calendar: calendar)
            indexed.append((rank, RestockAlert(entry: entry, forecast: forecast)))
        }
        indexed.sort { lhs, rhs in
            if lhs.alert.forecast.daysLeft != rhs.alert.forecast.daysLeft {
                return lhs.alert.forecast.daysLeft < rhs.alert.forecast.daysLeft
            }
            return lhs.rank < rhs.rank
        }
        return indexed.map(\.alert)
    }

    /// Entrées passées sous le seuil d’alerte, de la plus urgente à la moins.
    public static func lowStock(for entries: [StackEntry],
                                today: Date,
                                calendar: Calendar = .current) -> [RestockAlert] {
        forecasts(for: entries, today: today, calendar: calendar)
            .filter { $0.forecast.isLow }
    }
}

/// Agrégats de coût de la stack (écran Ma stack).
///
/// Convention de nommage du projet : toute grandeur monétaire porte `Cost`
/// puis son unité, `Cents` ou `Euros`, de sorte qu’aucun appelant ne puisse
/// confondre un montant en centimes avec un montant en euros.
public enum StackCosts {
    /// Somme des coûts journaliers, en centimes.
    public static func dailyCostCents(_ entries: [StackEntry]) -> Int {
        entries.reduce(0) { $0 + $1.product.dailyCostCents }
    }

    /// Coût mensuel, sur une base de 30 jours (convention produit).
    public static func monthlyCostCents(_ entries: [StackEntry]) -> Int {
        dailyCostCents(entries) * 30
    }

    /// Coût annuel en euros entiers : 12 mois de 30 jours.
    public static func yearlyCostEuros(_ entries: [StackEntry]) -> Int {
        monthlyCostCents(entries) * 12 / 100
    }
}

/// Règle de l’usage vérifié (PRD §7.2) : seuils par défaut du MVP,
/// paramétrables par catégorie en base.
public struct VerificationRule: Sendable {
    public let minIntakes: Int
    public let minDays: Int
    public init(minIntakes: Int = 20, minDays: Int = 21) {
        self.minIntakes = minIntakes
        self.minDays = minDays
    }
    public func isVerified(intakes: Int, spanDays: Int) -> Bool {
        intakes >= minIntakes && spanDays >= minDays
    }
}
