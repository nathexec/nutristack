import Foundation

/// Comparateur (PRD §9) : produit les lignes du tableau, les cellules
/// gagnantes et le verdict, à partir des métriques dérivées des produits.
///
/// Deux règles structurent le moteur :
/// 1. Le verdict se calcule sur les valeurs **exactes**, avant tout arrondi
///    d’affichage, sinon deux produits proches pourraient afficher le même
///    prix au centime et un écart de pourcentage incohérent.
/// 2. L’ordre des lignes est celui de la maquette verrouillée ; il n’est pas
///    dérivé des données, pour que la lecture reste stable d’un produit à
///    l’autre.
public enum ComparisonEngine {

    /// Colonne d’un tableau à deux produits.
    public enum Side: Sendable { case left, right }

    /// Valeur d’une cellule, avec sa nature d’origine pour que la présentation
    /// choisisse le format (le moteur ne fabrique aucune chaîne d’affichage).
    public enum CellValue: Hashable, Sendable {
        case money(cents: Int)
        case milligrams(Double, vnrPercent: Int?)
        case count(Int)
        case text(String)
        case rating(Double, count: Int)
    }

    /// Ligne du tableau. `winner` vaut `nil` quand la comparaison n’a pas de
    /// sens (la forme galénique) ou en cas d’égalité stricte.
    public struct Row: Hashable, Sendable {
        public let label: String
        public let left: CellValue
        public let right: CellValue
        public let winner: Side?
        /// Vrai pour la ligne du prix par gramme d’actif, métrique fondatrice
        /// mise en avant visuellement (DS §7).
        public let isHero: Bool
    }

    /// Conclusion du comparateur : une affirmation chiffrée, et la nuance qui
    /// l’empêche d’être un slogan. La sous-ligne peut être vide quand le moins
    /// cher gagne sur tous les tableaux.
    public struct Verdict: Hashable, Sendable {
        public let title: String
        public let subtitle: String
    }

    /// Tout ce dont l’écran du comparateur a besoin, calculé en une passe.
    public struct Result: Sendable {
        /// Faux quand les formes diffèrent : la présentation doit alors afficher
        /// le bandeau d’attention (PRD §9.2).
        public let sameForm: Bool
        public let rows: [Row]
        public let verdict: Verdict
    }

    // MARK: Construction du tableau

    /// Compare deux produits portant le même actif principal.
    public static func compare(_ lhs: Product, _ rhs: Product) -> Result {
        var rows: [Row] = []

        rows.append(moneyRow(label: "Prix",
                             left: lhs.priceCents, right: rhs.priceCents))

        rows.append(moneyRow(label: "Prix par jour",
                             left: lhs.dailyCostCents, right: rhs.dailyCostCents))

        if let left = lhs.primaryIngredient, let right = rhs.primaryIngredient {
            rows.append(Row(label: "\(left.active.shortName) par dose",
                            left: .milligrams(left.elementalMgPerServing,
                                              vnrPercent: left.vnrPercent),
                            right: .milligrams(right.elementalMgPerServing,
                                               vnrPercent: right.vnrPercent),
                            winner: winner(left.elementalMgPerServing,
                                           right.elementalMgPerServing,
                                           lowerWins: false),
                            isHero: false))
        }

        if let leftPerGram = lhs.pricePerActiveGramCents,
           let rightPerGram = rhs.pricePerActiveGramCents,
           let activeShort = lhs.primaryIngredient?.active.shortName {
            rows.append(Row(label: "Prix / g de \(activeShort)",
                            left: .money(cents: leftPerGram),
                            right: .money(cents: rightPerGram),
                            winner: exactPerGramWinner(lhs, rhs),
                            isHero: true))
        }

        rows.append(Row(label: "Doses par boîte",
                        left: .count(lhs.servingsPerContainer),
                        right: .count(rhs.servingsPerContainer),
                        winner: winner(Double(lhs.servingsPerContainer),
                                       Double(rhs.servingsPerContainer),
                                       lowerWins: false),
                        isHero: false))

        rows.append(Row(label: "Forme",
                        left: .text(lhs.formLabel),
                        right: .text(rhs.formLabel),
                        winner: nil,
                        isHero: false))

        rows.append(Row(label: "Effet perçu vérifié",
                        left: .rating(lhs.ratings.effectAverage,
                                      count: lhs.ratings.effectVerifiedCount),
                        right: .rating(rhs.ratings.effectAverage,
                                       count: rhs.ratings.effectVerifiedCount),
                        winner: winner(lhs.ratings.effectAverage,
                                       rhs.ratings.effectAverage,
                                       lowerWins: false),
                        isHero: false))

        return Result(sameForm: lhs.formLabel == rhs.formLabel,
                      rows: rows,
                      verdict: verdict(lhs, rhs))
    }

    // MARK: Écart de prix

    /// Écart de prix par gramme d’actif, en pourcentage arrondi, calculé sur
    /// les valeurs exactes (Alba contre Nordika donne −40 %).
    public static func savingsPercent(_ lhs: Product, _ rhs: Product) -> Int? {
        guard let leftExact = lhs.pricePerActiveGramCentsExact,
              let rightExact = rhs.pricePerActiveGramCentsExact,
              leftExact > 0, rightExact > 0 else { return nil }
        let cheapest = min(leftExact, rightExact)
        let dearest = max(leftExact, rightExact)
        return Int(((1 - cheapest / dearest) * 100).rounded())
    }

    // MARK: Verdict

    private static func verdict(_ lhs: Product, _ rhs: Product) -> Verdict {
        guard let leftExact = lhs.pricePerActiveGramCentsExact,
              let rightExact = rhs.pricePerActiveGramCentsExact,
              let percent = savingsPercent(lhs, rhs),
              let activeName = lhs.primaryIngredient?.active.name.lowercased() else {
            return Verdict(title: "Comparaison sur l’actif élémentaire.", subtitle: "")
        }
        let cheaper = leftExact <= rightExact ? lhs : rhs
        let other = leftExact <= rightExact ? rhs : lhs

        let title = "Le moins cher par gramme de \(activeName) : "
            + "\(cheaper.brand.shortName) \(cheaper.formLabel) (−\(percent)\u{00A0}%)."

        // Le verdict nomme systématiquement ce que le moins cher ne gagne pas :
        // sans cette nuance, la métrique de prix écraserait le reste de la fiche
        // et le comparateur cesserait d’être honnête (PRD §9.3).
        var advantages: [String] = []
        if other.ratings.effectAverage > cheaper.ratings.effectAverage {
            advantages.append("sur l’effet perçu vérifié ("
                + frenchRating(other.ratings.effectAverage) + " contre "
                + frenchRating(cheaper.ratings.effectAverage) + ")")
        }
        if let otherDose = other.primaryIngredient?.elementalMgPerServing,
           let cheaperDose = cheaper.primaryIngredient?.elementalMgPerServing,
           otherDose > cheaperDose {
            advantages.append("sur la dose par prise")
        }
        let subtitle = advantages.isEmpty
            ? ""
            : "\(other.brand.shortName) conserve l’avantage "
                + advantages.joined(separator: " et ") + "."
        return Verdict(title: title, subtitle: subtitle)
    }

    // MARK: Outils internes

    /// Ligne monétaire : le moins cher gagne toujours.
    private static func moneyRow(label: String, left: Int, right: Int) -> Row {
        Row(label: label,
            left: .money(cents: left),
            right: .money(cents: right),
            winner: winner(Double(left), Double(right), lowerWins: true),
            isHero: false)
    }

    /// Vainqueur d’une paire de valeurs comparables, `nil` si égalité.
    private static func winner(_ left: Double, _ right: Double,
                               lowerWins: Bool) -> Side? {
        guard left != right else { return nil }
        let leftWins = lowerWins ? left < right : left > right
        return leftWins ? .left : .right
    }

    /// Vainqueur de la ligne héros, déterminé sur les valeurs exactes : deux
    /// produits peuvent afficher le même prix arrondi tout en étant départagés.
    private static func exactPerGramWinner(_ lhs: Product, _ rhs: Product) -> Side? {
        guard let leftExact = lhs.pricePerActiveGramCentsExact,
              let rightExact = rhs.pricePerActiveGramCentsExact else { return nil }
        return winner(leftExact, rightExact, lowerWins: true)
    }

    /// Note à la française. Le domaine reste sans dépendance à l’interface ;
    /// ce formatage local est le prix de cette indépendance (la version de
    /// présentation vit dans `DSFormat`, DS §10).
    private static func frenchRating(_ value: Double) -> String {
        String(format: "%.1f", value).replacingOccurrences(of: ".", with: ",")
    }
}
