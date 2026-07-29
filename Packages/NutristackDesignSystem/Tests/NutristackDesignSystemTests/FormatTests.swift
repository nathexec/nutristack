import XCTest
@testable import NutristackDesignSystem

/// Vérifie les formats de référence de la microcopie (DS v2.0.1, §10).
final class FormatTests: XCTestCase {
    let nbsp = "\u{00A0}"

    func testGrouping() {
        XCTAssertEqual(DSFormat.grouped(2400), "2\(nbsp)400")
        XCTAssertEqual(DSFormat.grouped(999), "999")
        XCTAssertEqual(DSFormat.grouped(1_234_567), "1\(nbsp)234\(nbsp)567")
    }

    func testMoneyParts() {
        let parts = DSFormat.moneyParts(cents: 1990)
        XCTAssertEqual(parts.integer, "19")
        XCTAssertEqual(parts.fraction, ",90\(nbsp)€")
        XCTAssertEqual(DSFormat.money(cents: 1990), "19,90\(nbsp)€")
        XCTAssertEqual(DSFormat.money(cents: 111), "1,11\(nbsp)€")
        XCTAssertEqual(DSFormat.money(cents: 5), "0,05\(nbsp)€")
        XCTAssertEqual(DSFormat.money(cents: 5370), "53,70\(nbsp)€")
    }

    func testMilligramsAndVNR() {
        XCTAssertEqual(DSFormat.milligrams(2400), "2\(nbsp)400\(nbsp)mg")
        XCTAssertEqual(DSFormat.percentVNR(80), "80\(nbsp)%\(nbsp)VNR")
    }

    func testRatingFrench() {
        XCTAssertEqual(DSFormat.rating(4.3), "4,3")
        XCTAssertEqual(DSFormat.rating(4.0), "4,0")
    }

    func testClamp01() {
        XCTAssertEqual(DSFormat.clamp01(1.4), 1)
        XCTAssertEqual(DSFormat.clamp01(-0.2), 0)
        XCTAssertEqual(DSFormat.clamp01(0.125), 0.125)
    }
}

/// Formats ajoutés après l’audit : masses décimales, prix par gramme, dates.
final class FormatAuditTests: XCTestCase {
    let nbsp = "\u{00A0}"

    func testDecimalMilligramsKeepsTenths() {
        // La vitamine B6 de la maquette se lit « 1,4 mg », jamais « 1 mg ».
        XCTAssertEqual(DSFormat.milligrams(1.4), "1,4\(nbsp)mg")
        XCTAssertEqual(DSFormat.milligrams(300.0), "300\(nbsp)mg")
        XCTAssertEqual(DSFormat.milligrams(2400.0), "2\(nbsp)400\(nbsp)mg")
        XCTAssertEqual(DSFormat.milligrams(0.75), "0,8\(nbsp)mg")
    }

    func testPricePerGramPrecisionSwitchesUnderTenCents() {
        XCTAssertEqual(DSFormat.pricePerGram(centsExact: 110.55, activeShort: "Mg"),
                       "1,11\(nbsp)€/g Mg")
        XCTAssertEqual(DSFormat.pricePerGram(centsExact: 66.22, activeShort: "Mg"),
                       "0,66\(nbsp)€/g Mg")
        XCTAssertEqual(DSFormat.pricePerGram(centsExact: 4.0, activeShort: "créatine"),
                       "0,040\(nbsp)€/g créatine")
        XCTAssertEqual(DSFormat.pricePerGram(centsExact: 58.33, activeShort: "EPA+DHA"),
                       "0,58\(nbsp)€/g EPA+DHA")
    }

    /// La feuille de provenance affiche « source · 12 juil. 2026 » : ce format
    /// abrégé avec année n’était couvert par aucun test, alors qu’il porte le
    /// jugement de fraîcheur d’une donnée (PRD §8.3).
    func testShortDateForProvenance() {
        var components = DateComponents()
        components.year = 2026; components.month = 7; components.day = 12
        let date = Calendar(identifier: .gregorian).date(from: components)!
        XCTAssertEqual(DSFormat.shortDate(date), "12 juil. 2026")
    }

    func testFrenchDateFormatting() {
        var components = DateComponents()
        components.year = 2026; components.month = 8; components.day = 3
        let date = Calendar(identifier: .gregorian).date(from: components)!
        XCTAssertEqual(DSFormat.dayMonth(date), "3 août")
        XCTAssertEqual(DSFormat.weekdayDayMonth(date), "lundi 3 août")
        XCTAssertEqual(DSFormat.capitalizingFirstLetter("samedi 25 juillet"),
                       "Samedi 25 juillet")
    }
}
