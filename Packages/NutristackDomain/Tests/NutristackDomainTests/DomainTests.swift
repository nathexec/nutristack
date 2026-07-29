import XCTest
@testable import NutristackDomain

/// Verrouille la correspondance entre le moteur et la maquette de référence :
/// chaque valeur affichée dans le Prototype v1.0 doit être reproduite par le
/// domaine à partir des données brutes, jamais codée en dur.
final class DomainTests: XCTestCase {

    // MARK: Métriques produit (fiche Alba)

    func testAlbaDerivedMetricsMatchMockup() {
        let p = DemoCatalog.albaMagnesium
        XCTAssertEqual(p.dailyCostCents, 33)                    // 0,33 € par jour
        XCTAssertEqual(p.pricePerActiveGramCents, 111)          // 1,11 €/g Mg
        XCTAssertEqual(p.primaryIngredient?.vnrPercent, 80)     // 80 % VNR
        XCTAssertEqual(p.primaryIngredient?.elementalFraction ?? 0, 0.125, accuracy: 0.0001)
        XCTAssertEqual(p.ingredients[1].vnrPercent, 100)        // B6 100 % VNR
    }

    func testCatalogPerGramPricesMatchMockup() {
        XCTAssertEqual(DemoCatalog.nordikaMagnesium.pricePerActiveGramCents, 66)   // 0,66 €/g
        XCTAssertEqual(DemoCatalog.nordikaMagnesium.dailyCostCents, 17)            // 0,17 €
        XCTAssertEqual(DemoCatalog.nordikaMagnesium.primaryIngredient?.vnrPercent, 67)
        XCTAssertEqual(DemoCatalog.halterraCreatine.pricePerActiveGramCents, 4)    // 0,040 €/g
        XCTAssertEqual(DemoCatalog.halterraCreatine.dailyCostCents, 20)
        // 25,20 € pour 43,2 g d’EPA+DHA font 0,58 €/g. La maquette v1.0
        // affichait « 0,058 €/g » (facteur dix) ; amendée en v1.1 sur ce point.
        XCTAssertEqual(DemoCatalog.borealOmega3.pricePerActiveGramCents, 58)       // 0,58 €/g
        XCTAssertEqual(DemoCatalog.borealOmega3.dailyCostCents, 42)
        XCTAssertEqual(DemoCatalog.halterraWhey.dailyCostCents, 84)
    }

    // MARK: Comparateur (Alba contre Nordika)

    func testComparisonVerdictMatchesMockup() {
        let result = ComparisonEngine.compare(DemoCatalog.albaMagnesium,
                                              DemoCatalog.nordikaMagnesium)
        XCTAssertFalse(result.sameForm)
        XCTAssertEqual(result.rows.count, 7)
        XCTAssertEqual(ComparisonEngine.savingsPercent(DemoCatalog.albaMagnesium,
                                                       DemoCatalog.nordikaMagnesium), 40)
        XCTAssertTrue(result.verdict.title.contains("Nordika Citrate"))
        XCTAssertTrue(result.verdict.title.contains("−40\u{00A0}%"))
        XCTAssertTrue(result.verdict.subtitle.contains("4,3 contre 4,0"))
        XCTAssertTrue(result.verdict.subtitle.contains("dose par prise"))
        let hero = result.rows.first(where: \.isHero)
        XCTAssertEqual(hero?.label, "Prix / g de Mg")
        XCTAssertEqual(hero?.winner, .right)
    }

    // MARK: Stack et rachat

    func testStackCostsMatchMockup() {
        let entries = DemoCatalog.stackEntries
        XCTAssertEqual(StackCosts.dailyCostCents(entries), 179)     // 1,79 € prévus
        XCTAssertEqual(StackCosts.monthlyCostCents(entries), 5370)  // 53,70 €
        XCTAssertEqual(StackCosts.yearlyCostEuros(entries), 644)    // 644 €/an
    }

    func testRestockForecastMatchesMockup() {
        let creatine = DemoCatalog.stackEntries.first { $0.id == "s-crea" }!
        let forecast = RestockForecast(entry: creatine, today: DemoCatalog.referenceDate)
        XCTAssertEqual(forecast.daysLeft, 9)                    // « ≈ 9 j »
        XCTAssertTrue(forecast.isLow)
        let cal = Calendar(identifier: .gregorian)
        let comps = cal.dateComponents([.day, .month], from: forecast.date)
        XCTAssertEqual(comps.day, 3)                            // « 3 août »
        XCTAssertEqual(comps.month, 8)
    }

    // MARK: Usage vérifié

    func testVerificationRuleThresholds() {
        let rule = VerificationRule()
        XCTAssertTrue(rule.isVerified(intakes: 20, spanDays: 21))
        XCTAssertTrue(rule.isVerified(intakes: 47, spanDays: 56))
        XCTAssertFalse(rule.isVerified(intakes: 19, spanDays: 30))
        XCTAssertFalse(rule.isVerified(intakes: 25, spanDays: 20))
    }

    // MARK: Régressions relevées à l’audit

    /// Le verdict cite la marque sous sa forme courte, comme la maquette :
    /// « Alba conserve l’avantage », non « Alba Nutrition conserve ».
    func testVerdictUsesShortBrandName() {
        let result = ComparisonEngine.compare(DemoCatalog.albaMagnesium,
                                              DemoCatalog.nordikaMagnesium)
        XCTAssertTrue(result.verdict.subtitle.hasPrefix("Alba conserve"))
        XCTAssertFalse(result.verdict.subtitle.contains("Alba Nutrition"))
        XCTAssertEqual(DemoCatalog.albaMagnesium.brand.shortName, "Alba")
        XCTAssertEqual(DemoCatalog.albaMagnesium.brand.name, "Alba Nutrition")
        // Une marque sans abréviation garde son nom complet.
        XCTAssertEqual(DemoCatalog.nordikaMagnesium.brand.shortName, "Nordika")
    }

    /// L’ordre des lignes est celui de la maquette et ne dépend pas des données.
    func testComparisonRowOrderMatchesMockup() {
        let result = ComparisonEngine.compare(DemoCatalog.albaMagnesium,
                                              DemoCatalog.nordikaMagnesium)
        XCTAssertEqual(result.rows.map(\.label),
                       ["Prix", "Prix par jour", "Mg par dose", "Prix / g de Mg",
                        "Doses par boîte", "Forme", "Effet perçu vérifié"])
        XCTAssertEqual(result.rows.map(\.winner),
                       [.right, .right, .left, .right, .right, nil, .left])
    }

    /// Le vainqueur de la ligne héros se départage sur les valeurs exactes,
    /// même quand l’affichage arrondi est identique.
    func testHeroWinnerUsesExactValues() {
        let dearer = DemoCatalog.albaMagnesium
        let cheaper = DemoCatalog.nordikaMagnesium
        XCTAssertEqual(ComparisonEngine.compare(dearer, cheaper)
            .rows.first { $0.isHero }?.winner, .right)
        XCTAssertEqual(ComparisonEngine.compare(cheaper, dearer)
            .rows.first { $0.isHero }?.winner, .left)
    }

    /// Le seuil de stock bas est unique et vit dans le domaine.
    func testLowStockThresholdIsCentralised() {
        XCTAssertEqual(RestockForecast.lowStockThresholdDays, 10)
        let whey = DemoCatalog.stackEntries.first { $0.id == "s-whey" }!
        let forecast = RestockForecast(entry: whey, today: DemoCatalog.referenceDate)
        // 0,34 × 25 doses = 8,5, arrondi à 9 jours : la whey est en alerte.
        // La maquette v1.1 l’affiche désormais en ambre (amendement d’audit).
        XCTAssertEqual(forecast.daysLeft, 9)
        XCTAssertTrue(forecast.isLow)
    }

    /// Toutes les entrées de la stack de démonstration exposent une prévision
    /// cohérente : aucune dose négative, aucune date antérieure au jour.
    func testAllForecastsAreCoherent() {
        for entry in DemoCatalog.stackEntries {
            let forecast = RestockForecast(entry: entry, today: DemoCatalog.referenceDate)
            XCTAssertGreaterThan(forecast.daysLeft, 0, entry.id)
            XCTAssertGreaterThanOrEqual(forecast.date, DemoCatalog.referenceDate, entry.id)
        }
    }

    /// Les dates du catalogue sont comparables et cohérentes : une étiquette
    /// est toujours vérifiée avant le jour de référence, et la provenance sait
    /// dire son ancienneté.
    func testProvenanceDatesAreRealAndCoherent() {
        let product = DemoCatalog.albaMagnesium
        XCTAssertLessThan(product.labelVerifiedOn, DemoCatalog.referenceDate)
        let composition = product.provenance.first { $0.field == "Composition" }
        XCTAssertEqual(composition?.source, "Étiquette")
        XCTAssertEqual(composition?.ageInDays(from: DemoCatalog.referenceDate,
                                              calendar: Calendar(identifier: .gregorian)), 13)
        // Une donnée en attente n’a pas de date, et son ancienneté est indéfinie.
        let pending = product.provenance.first { $0.status == .pending }
        XCTAssertNil(pending?.date)
        XCTAssertNil(pending?.ageInDays(from: DemoCatalog.referenceDate))
        for other in DemoCatalog.all {
            XCTAssertLessThanOrEqual(other.labelVerifiedOn, DemoCatalog.referenceDate, other.id)
        }
    }

    // MARK: Conditionnements

    /// Le prix au gramme d’actif dépend du conditionnement : le petit format
    /// d’Alba est plus cher au gramme que le grand, ce que la fiche doit
    /// montrer quand on change de pastille.
    func testVariantsChangeThePerGramPrice() {
        let product = DemoCatalog.albaMagnesium
        XCTAssertEqual(product.variants.count, 2)
        let large = product.variants[0]
        let small = product.variants[1]
        XCTAssertEqual(product.defaultVariant, large)
        XCTAssertEqual(large.dailyCostCents, 33)
        XCTAssertEqual(small.dailyCostCents, 40)
        XCTAssertEqual(product.pricePerActiveGramCentsExact(for: large)
            .map { Int($0.rounded()) }, 111)
        XCTAssertEqual(product.pricePerActiveGramCentsExact(for: small)
            .map { Int($0.rounded()) }, 132)
    }

    // MARK: Classements du catalogue

    /// La section « Meilleur prix par actif » reste celle du magnésium, et ses
    /// produits sont classés du moins cher au plus cher.
    func testComparableGroupMatchesMockupContent() {
        let group = CatalogRanking.comparableGroup(in: DemoCatalog.all)
        XCTAssertEqual(group?.active, ActiveSubstance.magnesium)
        XCTAssertEqual(group?.products.map(\.id),
                       [DemoCatalog.nordikaMagnesium.id, DemoCatalog.albaMagnesium.id])
        // Chaque catégorie compte deux produits : c’est l’écart de prix qui
        // départage, et le magnésium est de loin le plus instructif.
        XCTAssertEqual(group.map { Int(($0.priceSpread * 100).rounded()) }, 40)
    }

    /// Les mieux notés restent la créatine puis les oméga-3 de Boreal, malgré
    /// l’égalité de note entre Boreal et la whey d’Halterra.
    func testTopRatedMatchesMockup() {
        XCTAssertEqual(CatalogRanking.topRated(in: DemoCatalog.all).map(\.id),
                       [DemoCatalog.halterraCreatine.id, DemoCatalog.borealOmega3.id])
    }

    /// Chaque produit du catalogue possède une alternative de même actif :
    /// le bouton « Comparer » n’est jamais inactif au jalon M1.
    func testEveryProductHasAComparableAlternative() {
        for product in DemoCatalog.all {
            let alternative = CatalogRanking.cheapestAlternative(to: product,
                                                                 in: DemoCatalog.all)
            XCTAssertNotNil(alternative, product.id)
            XCTAssertEqual(alternative?.primaryIngredient?.active,
                           product.primaryIngredient?.active, product.id)
            XCTAssertNotEqual(alternative?.id, product.id)
        }
    }

    /// L’alternative proposée face à Alba reste Nordika, comme la maquette.
    func testAlternativeToAlbaIsNordika() {
        XCTAssertEqual(CatalogRanking.cheapestAlternative(to: DemoCatalog.albaMagnesium,
                                                          in: DemoCatalog.all)?.id,
                       DemoCatalog.nordikaMagnesium.id)
    }

    // MARK: Avis

    /// Le filtre des avis repose sur la règle d’usage, pas sur un drapeau posé
    /// à la main : deux des trois avis d’Alba franchissent les seuils.
    func testReviewVerificationFollowsTheRule() {
        let reviews = DemoCatalog.reviews(for: DemoCatalog.albaMagnesium.id)
        XCTAssertEqual(reviews.count, 3)
        XCTAssertEqual(reviews.usageVerified().count, 2)
        XCTAssertEqual(reviews.usageVerified().first?.author, "Karim L.")
        let unverified = reviews.first { !$0.isUsageVerified() }
        XCTAssertEqual(unverified?.intakes, 9)
    }

    // MARK: Ajout à la stack

    /// L’entrée créée à l’ajout reprend la dose de l’étiquette et suppose un
    /// contenant neuf, donc une prévision de rachat égale au nombre de doses.
    func testAddingAProductBuildsACoherentEntry() {
        let entry = StackEntry(adding: DemoCatalog.nordikaOmega3)
        XCTAssertEqual(entry.doseLabel, DemoCatalog.nordikaOmega3.servingLabel)
        XCTAssertEqual(entry.stockFraction, 1)
        XCTAssertEqual(entry.slot, .morning)
        let forecast = RestockForecast(entry: entry, today: DemoCatalog.referenceDate)
        XCTAssertEqual(forecast.daysLeft, 45)
        XCTAssertFalse(forecast.isLow)
    }

    /// Les prévisions groupées sont triées de la plus urgente à la plus
    /// lointaine, et l’alerte de la maquette reste la créatine.
    func testRestockAlertsAreSortedByUrgency() {
        let alerts = RestockAlert.forecasts(for: DemoCatalog.stackEntries,
                                            today: DemoCatalog.referenceDate,
                                            calendar: Calendar(identifier: .gregorian))
        XCTAssertEqual(alerts.map(\.forecast.daysLeft).sorted(), alerts.map(\.forecast.daysLeft))
        XCTAssertEqual(alerts.first?.entry.id, "s-crea")
        let low = RestockAlert.lowStock(for: DemoCatalog.stackEntries,
                                        today: DemoCatalog.referenceDate,
                                        calendar: Calendar(identifier: .gregorian))
        XCTAssertEqual(low.map(\.entry.id), ["s-crea", "s-whey"])
    }
}
