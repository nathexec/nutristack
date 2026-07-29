import Foundation

// Règles transverses (PRD §13) : les montants circulent en centimes,
// les masses en milligrammes. Aucune valeur flottante n’est stockée pour
// l’argent ; les fractions n’apparaissent que dans les calculs dérivés.

/// Marque du catalogue.
///
/// `shortName` sert les contextes compacts où la maquette abrège la raison
/// sociale : verdict du comparateur, fiche de résultat du scanner, ligne
/// « À surveiller ». Il vaut `name` par défaut, si bien qu’une marque sans
/// abréviation ne demande aucune donnée supplémentaire.
public struct Brand: Hashable, Sendable {
    public let name: String
    public let shortName: String

    public init(name: String, shortName: String? = nil) {
        self.name = name
        self.shortName = shortName ?? name
    }
}

/// Catégories du MVP (PRD §4).
public enum ProductCategory: String, CaseIterable, Sendable {
    case proteins = "Protéines"
    case creatine = "Créatine"
    case omega3 = "Oméga-3"
    case magnesium = "Magnésium"
}

/// Actif de référence et sa valeur nutritionnelle de référence (VNR) en mg,
/// lorsqu’elle existe (PRD §6.2).
public struct ActiveSubstance: Hashable, Sendable {
    public let name: String        // « Magnésium »
    public let shortName: String   // « Mg », utilisé dans les métriques
    public let vnrMg: Double?
    public init(name: String, shortName: String, vnrMg: Double? = nil) {
        self.name = name
        self.shortName = shortName
        self.vnrMg = vnrMg
    }
    public static let magnesium = ActiveSubstance(name: "Magnésium", shortName: "Mg", vnrMg: 375)
    public static let vitaminB6 = ActiveSubstance(name: "Vitamine B6", shortName: "B6", vnrMg: 1.4)
    public static let creatine = ActiveSubstance(name: "Créatine", shortName: "créatine")
    public static let epaDha = ActiveSubstance(name: "EPA+DHA", shortName: "EPA+DHA")
    public static let wheyProtein = ActiveSubstance(name: "Protéines", shortName: "protéines")
}

/// Ligne d’étiquette normalisée (PRD §6) : le composé déclaré et la part
/// d’actif élémentaire réellement utilisable, en milligrammes par dose.
public struct IngredientDeclaration: Identifiable, Hashable, Sendable {
    /// Le nom du composé identifie la ligne : une étiquette ne déclare pas deux
    /// fois le même composé. Préférable à `id: \.self` côté vue, qui reposerait
    /// sur l’égalité de toutes les valeurs.
    public var id: String { compoundName }

    public let compoundName: String      // « Bisglycinate de magnésium »
    public let formNote: String?         // « chlorhydrate de pyridoxine »
    public let active: ActiveSubstance
    public let compoundMgPerServing: Double
    public let elementalMgPerServing: Double
    public let isPrimary: Bool           // porte la métrique héros

    public init(compoundName: String, formNote: String? = nil, active: ActiveSubstance,
                compoundMgPerServing: Double, elementalMgPerServing: Double, isPrimary: Bool) {
        self.compoundName = compoundName
        self.formNote = formNote
        self.active = active
        self.compoundMgPerServing = compoundMgPerServing
        self.elementalMgPerServing = elementalMgPerServing
        self.isPrimary = isPrimary
    }

    /// Fraction élémentaire du composé, pour la jauge d’actif (0...1).
    public var elementalFraction: Double {
        guard compoundMgPerServing > 0 else { return 0 }
        return min(1, elementalMgPerServing / compoundMgPerServing)
    }

    /// Pourcentage de VNR arrondi, si l’actif en possède une.
    public var vnrPercent: Int? {
        guard let vnr = active.vnrMg, vnr > 0 else { return nil }
        return Int((elementalMgPerServing / vnr * 100).rounded())
    }
}

/// Notes agrégées (PRD §7) : l’effet perçu ne compte que les avis vérifiés.
public struct Ratings: Hashable, Sendable {
    /// Moyenne de l’effet perçu, sur les seuls avis à usage vérifié.
    public let effectAverage: Double
    /// Nombre d’avis vérifiés fondant `effectAverage` ; jamais affiché seul.
    public let effectVerifiedCount: Int
    /// Moyenne de l’expérience produit (goût, tolérance, conditionnement).
    public let experienceAverage: Double
    public let experienceCount: Int
    public init(effectAverage: Double, effectVerifiedCount: Int,
                experienceAverage: Double, experienceCount: Int) {
        self.effectAverage = effectAverage
        self.effectVerifiedCount = effectVerifiedCount
        self.experienceAverage = experienceAverage
        self.experienceCount = experienceCount
    }
}

/// Provenance d’un champ de la fiche (PRD §8.3).
///
/// La date est un `Date` et non une chaîne pré-formatée : elle doit pouvoir
/// être comparée, triée et confrontée à un seuil de fraîcheur. La composition
/// du libellé (« Étiquette · 12 juil. 2026 ») appartient à la présentation.
public struct FieldProvenance: Identifiable, Hashable, Sendable {
    /// Le nom du champ identifie la provenance : un champ n’en a qu’une.
    public var id: String { field }

    /// Degré de confiance dans la donnée.
    public enum Status: Sendable {
        /// Contrôlée par l’équipe, preuve conservée.
        case verified
        /// Relevée sans recoupement.
        case recorded
        /// Contribution en cours de vérification.
        case pending
    }

    /// Champ concerné, tel qu’il apparaît sur la fiche (« Composition »).
    public let field: String
    public let status: Status
    /// Origine de la donnée (« Étiquette », « Relevé équipe »).
    public let source: String
    /// Date du relevé ou du contrôle, absente pour une donnée en attente.
    public let date: Date?

    public init(field: String, status: Status, source: String, date: Date? = nil) {
        self.field = field
        self.status = status
        self.source = source
        self.date = date
    }

    /// Ancienneté du relevé en jours, pour les règles de fraîcheur (PRD §8.3).
    public func ageInDays(from reference: Date,
                          calendar: Calendar = .current) -> Int? {
        guard let date else { return nil }
        return calendar.dateComponents([.day], from: date, to: reference).day
    }
}

/// Conditionnement d’un produit : c’est lui qui porte le prix et le nombre de
/// doses, puisque le même produit se vend en plusieurs formats dont le prix au
/// gramme d’actif diffère. Le premier conditionnement de la liste est celui que
/// la fiche décrit par défaut.
public struct ProductVariant: Identifiable, Hashable, Sendable {
    public let id: String
    /// Libellé du conditionnement (« 120 gélules »).
    public let label: String
    /// Prix public relevé, en centimes.
    public let priceCents: Int
    /// Nombre de doses journalières contenues.
    public let servingsPerContainer: Int

    public init(id: String, label: String, priceCents: Int, servingsPerContainer: Int) {
        self.id = id
        self.label = label
        self.priceCents = priceCents
        self.servingsPerContainer = servingsPerContainer
    }

    /// Coût d’une dose journalière, en centimes arrondis.
    public var dailyCostCents: Int {
        guard servingsPerContainer > 0 else { return 0 }
        return Int((Double(priceCents) / Double(servingsPerContainer)).rounded())
    }
}

/// Produit du catalogue et ses métriques dérivées.
public struct Product: Identifiable, Hashable, Sendable {
    public let id: String
    /// Code-barres EAN-13 ou EAN-8, clé d’entrée du scanner.
    public let ean: String
    public let brand: Brand
    public let name: String
    /// Forme galénique ou chimique (« Bisglycinate », « Citrate ») : elle sert
    /// de titre de colonne au comparateur et déclenche le bandeau d’attention
    /// quand deux produits ne partagent pas la même.
    public let formLabel: String
    public let category: ProductCategory
    /// Composition d’une dose journalière (« 2 gélules », « 5 g »).
    public let servingLabel: String
    /// Conditionnements disponibles, le premier étant celui décrit par défaut.
    public let variants: [ProductVariant]
    public let ingredients: [IngredientDeclaration]
    public let ratings: Ratings
    public let provenance: [FieldProvenance]
    /// Date du dernier contrôle de l’étiquette par l’équipe.
    public let labelVerifiedOn: Date

    public init(id: String, ean: String, brand: Brand, name: String, formLabel: String,
                category: ProductCategory, servingLabel: String,
                variants: [ProductVariant],
                ingredients: [IngredientDeclaration], ratings: Ratings,
                provenance: [FieldProvenance], labelVerifiedOn: Date) {
        self.id = id
        self.ean = ean
        self.brand = brand
        self.name = name
        self.formLabel = formLabel
        self.category = category
        precondition(!variants.isEmpty,
                     "Un produit sans conditionnement n’a ni prix ni nombre de doses : "
                       + "l’invariant est vérifié à la construction plutôt que subi "
                       + "à la lecture.")
        self.servingLabel = servingLabel
        self.variants = variants
        self.ingredients = ingredients
        self.ratings = ratings
        self.provenance = provenance
        self.labelVerifiedOn = labelVerifiedOn
    }

    /// Ligne principale de l’étiquette (métrique héros).
    public var primaryIngredient: IngredientDeclaration? {
        ingredients.first(where: \.isPrimary)
    }

    /// Conditionnement décrit par défaut, c’est-à-dire le premier déclaré.
    /// L’initialiseur garantit qu’il en existe toujours un.
    public var defaultVariant: ProductVariant {
        variants[0]
    }

    /// Prix du conditionnement par défaut, en centimes.
    public var priceCents: Int { defaultVariant.priceCents }

    /// Doses du conditionnement par défaut. Le MVP suppose une dose par jour,
    /// ce qui fait de ce nombre une durée en jours.
    public var servingsPerContainer: Int { defaultVariant.servingsPerContainer }

    /// Coût d’une dose journalière du conditionnement par défaut.
    public var dailyCostCents: Int { defaultVariant.dailyCostCents }

    /// Prix par gramme d’actif élémentaire d’un conditionnement donné, en
    /// centimes exacts. C’est la métrique fondatrice (PRD §6.4, §9) : elle se
    /// calcule sans arrondi, l’arrondi n’intervenant qu’à l’affichage.
    public func pricePerActiveGramCentsExact(for variant: ProductVariant) -> Double? {
        guard let primary = primaryIngredient, primary.elementalMgPerServing > 0,
              variant.servingsPerContainer > 0 else { return nil }
        let totalGrams = primary.elementalMgPerServing
            * Double(variant.servingsPerContainer) / 1000
        return Double(variant.priceCents) / totalGrams
    }

    /// Prix par gramme d’actif du conditionnement par défaut.
    public var pricePerActiveGramCentsExact: Double? {
        pricePerActiveGramCentsExact(for: defaultVariant)
    }

    /// Prix par gramme d’actif arrondi au centime, pour l’affichage.
    public var pricePerActiveGramCents: Int? {
        pricePerActiveGramCentsExact.map { Int($0.rounded()) }
    }
}
