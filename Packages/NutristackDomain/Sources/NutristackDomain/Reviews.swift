import Foundation

/// Avis d’un utilisateur sur un produit (PRD §7).
///
/// La distinction porte sur l’usage, jamais sur la qualité de l’avis : un avis
/// « vérifié » atteste que son auteur a enregistré assez de prises sur assez de
/// temps pour que son ressenti porte sur un usage réel. Il ne dit rien de
/// l’efficacité du produit, et le vocabulaire de l’interface doit le refléter.
public struct ProductReview: Identifiable, Hashable, Sendable {
    public let id: String
    public let productID: String
    public let author: String
    /// Nombre de prises enregistrées dans l’application.
    public let intakes: Int
    /// Durée sur laquelle ces prises se répartissent, en semaines.
    public let weeks: Int
    /// Déclaration d’intérêt obligatoire (« Acheté moi-même »), PRD §7.4.
    public let conflictDisclosure: String
    public let text: String

    public init(id: String, productID: String, author: String, intakes: Int,
                weeks: Int, conflictDisclosure: String, text: String) {
        self.id = id
        self.productID = productID
        self.author = author
        self.intakes = intakes
        self.weeks = weeks
        self.conflictDisclosure = conflictDisclosure
        self.text = text
    }

    /// Vrai quand l’usage déclaré franchit les seuils de la règle en vigueur.
    public func isUsageVerified(rule: VerificationRule = VerificationRule()) -> Bool {
        rule.isVerified(intakes: intakes, spanDays: weeks * 7)
    }
}

public extension Array where Element == ProductReview {
    /// Avis à usage vérifié, dans leur ordre d’origine.
    func usageVerified(rule: VerificationRule = VerificationRule()) -> [ProductReview] {
        filter { $0.isUsageVerified(rule: rule) }
    }
}
