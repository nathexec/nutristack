import XCTest
@testable import NutristackDesignSystem

/// Vérifie les règles portées par les composants (DS v2.0.1, §7 et §10).
final class ComponentRuleTests: XCTestCase {

    func testSegmentedProgressClamp() {
        XCTAssertEqual(SegmentedProgress.clamp(-1, total: 4), 0)
        XCTAssertEqual(SegmentedProgress.clamp(9, total: 4), 4)
        XCTAssertEqual(SegmentedProgress.clamp(2, total: 4), 2)
    }

    func testProvenanceAccessibilityNames() {
        XCTAssertEqual(ProvenanceStatus.verified.accessibilityName, "Donnée vérifiée")
        XCTAssertEqual(ProvenanceStatus.recorded.accessibilityName, "Donnée relevée")
        XCTAssertEqual(ProvenanceStatus.pending.accessibilityName, "Donnée en vérification")
    }

    func testVerifiedBadgeLabel() {
        let badge = VerifiedBadge(intakes: 47, weeks: 8)
        XCTAssertEqual(badge.label, "Usage vérifié · 47 prises / 8 sem.")
        XCTAssertTrue(badge.explainer.contains("pas d\u{2019}une mesure clinique"))
        // PRD §7.6 : le tooltip énonce la règle, pas les chiffres du relecteur.
        XCTAssertTrue(badge.explainer.contains("au moins 20 prises sur 3 semaines"))
        XCTAssertFalse(badge.explainer.contains("47"))
        XCTAssertFalse(badge.explainer.contains("efficacité prouvée"))
    }

    func testHexParsing() {
        let rgb = HexColor.parse("175947")
        XCTAssertEqual(rgb.red, 0x17)
        XCTAssertEqual(rgb.green, 0x59)
        XCTAssertEqual(rgb.blue, 0x47)
    }

    /// Le vert officinal en mode sombre reste analysable, et une chaîne vide
    /// retombe sur le noir sans planter.
    func testHexParsingEdgeCases() {
        XCTAssertEqual(HexColor.parse("4EB08C").green, 0xB0)
        let empty = HexColor.parse("")
        XCTAssertEqual(empty.red, 0)
        XCTAssertEqual(empty.blue, 0)
    }
}
