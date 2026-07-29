import Foundation

/// Catalogue de démonstration du jalon M1 : marques fictives, valeurs alignées
/// sur la maquette de référence (Prototype v1.0). Toutes les métriques
/// affichées par l’application sont dérivées de ces données par le domaine,
/// jamais codées en dur ; les tests verrouillent la correspondance.
///
/// Ce jeu de données est destiné à disparaître au jalon M3, au profit du
/// catalogue réel. Il vit encore dans le module de production faute de cible
/// séparée : la recommandation figure au README.
public enum DemoCatalog {

    /// Date de référence de la démonstration, seule origine des libellés de
    /// date (« 3 août », « ≈ 9 j »). Injectée partout où une date intervient.
    public static let referenceDate = date(25, 7)

    /// Fabrique une date du jeu de démonstration (année 2026 par défaut).
    /// Les dates du catalogue sont de vraies `Date`, jamais des libellés :
    /// la présentation les met en forme, le domaine les compare.
    static func date(_ day: Int, _ month: Int, _ year: Int = 2026) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }

    // MARK: Magnésium

    public static let albaMagnesium = Product(
        id: "alba-mg-bisgly", ean: "3701234567890",
        brand: Brand(name: "Alba Nutrition", shortName: "Alba"),
        name: "Magnésium bisglycinate", formLabel: "Bisglycinate",
        category: .magnesium, servingLabel: "2 gélules",
        variants: [
            ProductVariant(id: "alba-mg-120", label: "120 gélules",
                           priceCents: 1990, servingsPerContainer: 60),
            ProductVariant(id: "alba-mg-60", label: "60 gélules",
                           priceCents: 1190, servingsPerContainer: 30)
        ],
        ingredients: [
            IngredientDeclaration(compoundName: "Bisglycinate de magnésium",
                                  active: .magnesium,
                                  compoundMgPerServing: 2400,
                                  elementalMgPerServing: 300, isPrimary: true),
            IngredientDeclaration(compoundName: "Vitamine B6",
                                  formNote: "chlorhydrate de pyridoxine",
                                  active: .vitaminB6,
                                  compoundMgPerServing: 1.4,
                                  elementalMgPerServing: 1.4, isPrimary: false)
        ],
        ratings: Ratings(effectAverage: 4.3, effectVerifiedCount: 41,
                         experienceAverage: 4.5, experienceCount: 67),
        provenance: [
            FieldProvenance(field: "Composition", status: .verified,
                            source: "Étiquette", date: date(12, 7)),
            FieldProvenance(field: "Portions", status: .verified,
                            source: "Étiquette", date: date(12, 7)),
            FieldProvenance(field: "Prix", status: .recorded,
                            source: "Relevé équipe", date: date(21, 7)),
            FieldProvenance(field: "Certifications", status: .pending,
                            source: "En vérification")
        ],
        labelVerifiedOn: date(12, 7))

    public static let nordikaMagnesium = Product(
        id: "nordika-mg-citrate", ean: "3701234567891",
        brand: Brand(name: "Nordika"),
        name: "Magnésium citrate", formLabel: "Citrate",
        category: .magnesium, servingLabel: "3 gélules",
        variants: [
            ProductVariant(id: "nordika-mg-270", label: "270 gélules",
                           priceCents: 1490, servingsPerContainer: 90)
        ],
        ingredients: [
            IngredientDeclaration(compoundName: "Citrate de magnésium",
                                  active: .magnesium,
                                  compoundMgPerServing: 1610,
                                  elementalMgPerServing: 250, isPrimary: true)
        ],
        ratings: Ratings(effectAverage: 4.0, effectVerifiedCount: 28,
                         experienceAverage: 4.2, experienceCount: 45),
        provenance: [
            FieldProvenance(field: "Composition", status: .verified,
                            source: "Étiquette", date: date(9, 7)),
            FieldProvenance(field: "Prix", status: .recorded,
                            source: "Relevé équipe", date: date(21, 7))
        ],
        labelVerifiedOn: date(9, 7))

    // MARK: Créatine

    public static let halterraCreatine = Product(
        id: "halterra-creatine", ean: "3701234567892",
        brand: Brand(name: "Halterra"),
        name: "Créatine monohydrate Creapure", formLabel: "Monohydrate",
        category: .creatine, servingLabel: "5 g",
        variants: [
            ProductVariant(id: "halterra-crea-200", label: "200 g",
                           priceCents: 800, servingsPerContainer: 40),
            ProductVariant(id: "halterra-crea-500", label: "500 g",
                           priceCents: 1790, servingsPerContainer: 100)
        ],
        ingredients: [
            IngredientDeclaration(compoundName: "Créatine monohydrate",
                                  active: .creatine,
                                  compoundMgPerServing: 5000,
                                  elementalMgPerServing: 5000, isPrimary: true)
        ],
        ratings: Ratings(effectAverage: 4.6, effectVerifiedCount: 112,
                         experienceAverage: 4.6, experienceCount: 180),
        provenance: [
            FieldProvenance(field: "Composition", status: .verified,
                            source: "Étiquette", date: date(2, 7))
        ],
        labelVerifiedOn: date(2, 7))

    public static let albaCreatine = Product(
        id: "alba-creatine", ean: "3701234567895",
        brand: Brand(name: "Alba Nutrition", shortName: "Alba"),
        name: "Créatine monohydrate micronisée", formLabel: "Monohydrate",
        category: .creatine, servingLabel: "5 g",
        variants: [
            ProductVariant(id: "alba-crea-300", label: "300 g",
                           priceCents: 1490, servingsPerContainer: 60)
        ],
        ingredients: [
            IngredientDeclaration(compoundName: "Créatine monohydrate",
                                  active: .creatine,
                                  compoundMgPerServing: 5000,
                                  elementalMgPerServing: 5000, isPrimary: true)
        ],
        ratings: Ratings(effectAverage: 4.3, effectVerifiedCount: 34,
                         experienceAverage: 4.4, experienceCount: 52),
        provenance: [
            FieldProvenance(field: "Composition", status: .verified,
                            source: "Étiquette", date: date(15, 7)),
            FieldProvenance(field: "Prix", status: .recorded,
                            source: "Relevé équipe", date: date(21, 7))
        ],
        labelVerifiedOn: date(15, 7))

    // MARK: Protéines

    public static let halterraWhey = Product(
        id: "halterra-whey", ean: "3701234567893",
        brand: Brand(name: "Halterra"),
        name: "Whey isolate vanille", formLabel: "Isolate",
        category: .proteins, servingLabel: "30 g",
        variants: [
            ProductVariant(id: "halterra-whey-750", label: "750 g",
                           priceCents: 2100, servingsPerContainer: 25),
            ProductVariant(id: "halterra-whey-2000", label: "2 kg",
                           priceCents: 5200, servingsPerContainer: 66)
        ],
        ingredients: [
            IngredientDeclaration(compoundName: "Isolat de protéines de lactosérum",
                                  active: .wheyProtein,
                                  compoundMgPerServing: 30000,
                                  elementalMgPerServing: 26400, isPrimary: true)
        ],
        ratings: Ratings(effectAverage: 4.4, effectVerifiedCount: 58,
                         experienceAverage: 4.5, experienceCount: 96),
        provenance: [
            FieldProvenance(field: "Composition", status: .verified,
                            source: "Étiquette", date: date(5, 7))
        ],
        labelVerifiedOn: date(5, 7))

    public static let borealWhey = Product(
        id: "boreal-whey", ean: "3701234567896",
        brand: Brand(name: "Boreal"),
        name: "Whey concentrée vanille", formLabel: "Concentrée",
        category: .proteins, servingLabel: "30 g",
        variants: [
            ProductVariant(id: "boreal-whey-1000", label: "1 kg",
                           priceCents: 2190, servingsPerContainer: 33)
        ],
        ingredients: [
            IngredientDeclaration(compoundName: "Concentré de protéines de lactosérum",
                                  active: .wheyProtein,
                                  compoundMgPerServing: 30000,
                                  elementalMgPerServing: 24000, isPrimary: true)
        ],
        ratings: Ratings(effectAverage: 4.2, effectVerifiedCount: 41,
                         experienceAverage: 4.3, experienceCount: 58),
        provenance: [
            FieldProvenance(field: "Composition", status: .verified,
                            source: "Étiquette", date: date(17, 7))
        ],
        labelVerifiedOn: date(17, 7))

    // MARK: Oméga-3

    public static let borealOmega3 = Product(
        id: "boreal-omega3", ean: "3701234567894",
        brand: Brand(name: "Boreal"),
        name: "Oméga-3 forme triglycérides", formLabel: "Triglycérides",
        category: .omega3, servingLabel: "2 capsules",
        variants: [
            ProductVariant(id: "boreal-omega-120", label: "120 capsules",
                           priceCents: 2520, servingsPerContainer: 60)
        ],
        ingredients: [
            IngredientDeclaration(compoundName: "Huile de poisson (triglycérides)",
                                  active: .epaDha,
                                  compoundMgPerServing: 1200,
                                  elementalMgPerServing: 720, isPrimary: true)
        ],
        ratings: Ratings(effectAverage: 4.4, effectVerifiedCount: 63,
                         experienceAverage: 4.4, experienceCount: 90),
        provenance: [
            FieldProvenance(field: "Composition", status: .verified,
                            source: "Étiquette", date: date(8, 7))
        ],
        labelVerifiedOn: date(8, 7))

    public static let nordikaOmega3 = Product(
        id: "nordika-omega3", ean: "3701234567897",
        brand: Brand(name: "Nordika"),
        name: "Oméga-3 esters éthyliques", formLabel: "Esters éthyliques",
        category: .omega3, servingLabel: "2 capsules",
        variants: [
            ProductVariant(id: "nordika-omega-90", label: "90 capsules",
                           priceCents: 990, servingsPerContainer: 45)
        ],
        ingredients: [
            IngredientDeclaration(compoundName: "Huile de poisson (esters éthyliques)",
                                  active: .epaDha,
                                  compoundMgPerServing: 1000,
                                  elementalMgPerServing: 500, isPrimary: true)
        ],
        ratings: Ratings(effectAverage: 4.1, effectVerifiedCount: 22,
                         experienceAverage: 4.0, experienceCount: 31),
        provenance: [
            FieldProvenance(field: "Composition", status: .verified,
                            source: "Étiquette", date: date(14, 7)),
            FieldProvenance(field: "Prix", status: .recorded,
                            source: "Relevé équipe", date: date(21, 7))
        ],
        labelVerifiedOn: date(14, 7))

    /// Catalogue complet : deux produits par catégorie, de sorte que chaque
    /// fiche ait toujours une alternative à comparer sur le même actif.
    public static let all: [Product] = [
        albaMagnesium, nordikaMagnesium,
        halterraCreatine, albaCreatine,
        halterraWhey, borealWhey,
        borealOmega3, nordikaOmega3
    ]

    // MARK: Stack de démonstration

    public static let stackEntries: [StackEntry] = [
        StackEntry(id: "s-alba", product: albaMagnesium, doseLabel: "2 gélules",
                   slot: .evening, stockFraction: 0.76),
        StackEntry(id: "s-crea", product: halterraCreatine, doseLabel: "5\u{00A0}g",
                   slot: .training, stockFraction: 0.22),
        StackEntry(id: "s-omega", product: borealOmega3, doseLabel: "2 capsules",
                   slot: .morning, stockFraction: 0.58),
        StackEntry(id: "s-whey", product: halterraWhey, doseLabel: "30\u{00A0}g",
                   slot: .training, stockFraction: 0.34)
    ]

    // MARK: Avis

    private static let allReviews: [ProductReview] = [
        ProductReview(id: "r-alba-1", productID: albaMagnesium.id, author: "Karim L.",
                      intakes: 47, weeks: 8, conflictDisclosure: "Acheté moi-même",
                      text: "Gélules faciles à avaler, aucun inconfort digestif "
                        + "contrairement au citrate que je prenais avant. "
                        + "Effet ressenti sur le sommeil après trois semaines."),
        ProductReview(id: "r-alba-2", productID: albaMagnesium.id, author: "Sophie D.",
                      intakes: 26, weeks: 5, conflictDisclosure: "Acheté moi-même",
                      text: "Je le prends le soir depuis un mois. Moins de crampes "
                        + "nocturnes, mais je ne saurais dire si cela vient de là."),
        ProductReview(id: "r-alba-3", productID: albaMagnesium.id, author: "Mehdi T.",
                      intakes: 9, weeks: 2, conflictDisclosure: "Acheté moi-même",
                      text: "Trop tôt pour juger de l\u{2019}effet. Le format des gélules "
                        + "est correct et le flacon tient dans un sac."),
        ProductReview(id: "r-crea-1", productID: halterraCreatine.id, author: "Léa M.",
                      intakes: 84, weeks: 12, conflictDisclosure: "Acheté moi-même",
                      text: "Se dissout sans grumeaux, goût neutre. Progression "
                        + "régulière en force sur le cycle, sans prise de poids notable.")
    ]

    /// Avis d’un produit, du plus engagé au moins engagé en termes d’usage.
    public static func reviews(for productID: String) -> [ProductReview] {
        allReviews.filter { $0.productID == productID }
    }
}
