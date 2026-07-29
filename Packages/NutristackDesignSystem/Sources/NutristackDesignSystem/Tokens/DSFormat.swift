import Foundation

/// Formats de référence de la microcopie (DS v2.0.1, §10).
/// Tous les montants circulent en centimes, toutes les masses en milligrammes.
/// Espaces insécables avant € et %, et comme séparateur de milliers.
public enum DSFormat {

    /// Espace insécable.
    public static let nbsp = "\u{00A0}"

    /// Borne une fraction dans [0 ; 1] (jauges).
    public static func clamp01(_ value: Double) -> Double {
        min(1, max(0, value))
    }

    /// Groupe un entier par milliers avec espaces insécables : 2400 → « 2 400 ».
    public static func grouped(_ value: Int) -> String {
        let digits = String(abs(value))
        var out = ""
        for (position, digit) in digits.reversed().enumerated() {
            if position != 0 && position % 3 == 0 { out.append(nbsp) }
            out.append(digit)
        }
        return (value < 0 ? "-" : "") + String(out.reversed())
    }

    /// Décompose un montant en centimes pour l’affichage « prix étiquette » :
    /// 1990 → (« 19 », «,90 € »). La fraction inclut le symbole.
    public static func moneyParts(cents: Int) -> (integer: String, fraction: String) {
        let sign = cents < 0 ? "-" : ""
        let amount = abs(cents)
        return (sign + grouped(amount / 100),
                "," + String(format: "%02d", amount % 100) + nbsp + "€")
    }

    /// Montant complet : 1990 → « 19,90 € ».
    public static func money(cents: Int) -> String {
        let parts = moneyParts(cents: cents)
        return parts.integer + parts.fraction
    }

    /// Masse : 2400 → « 2 400 mg ».
    public static func milligrams(_ mg: Int) -> String {
        grouped(mg) + nbsp + "mg"
    }

    /// Repère nutritionnel : 80 → « 80 % VNR ».
    public static func percentVNR(_ percent: Int) -> String {
        "\(percent)\(nbsp)%\(nbsp)VNR"
    }

    /// Note sur 5 à la française : 4.3 → « 4,3 ».
    public static func rating(_ value: Double) -> String {
        String(format: "%.1f", value).replacingOccurrences(of: ".", with: ",")
    }
    /// Masse déclarée, avec une décimale quand elle porte du sens :
    /// 2400 → « 2 400 mg » · 1,4 → « 1,4 mg ». Les étiquettes de micronutriments
    /// se lisent au dixième de milligramme ; arrondir à l’entier fausserait la
    /// composition affichée (cas de la vitamine B6 à 1,4 mg).
    public static func milligrams(_ mg: Double) -> String {
        let rounded = (mg * 10).rounded() / 10
        if rounded == rounded.rounded() {
            return milligrams(Int(rounded))
        }
        return String(format: "%.1f", rounded).replacingOccurrences(of: ".", with: ",")
            + nbsp + "mg"
    }

    /// Prix par gramme d’actif, depuis des centimes exacts : trois décimales
    /// sous dix centimes pour rester discriminant (« 0,040 €/g créatine »),
    /// deux au-delà (« 1,11 €/g Mg »).
    public static func pricePerGram(centsExact: Double, activeShort: String) -> String {
        let euros = centsExact / 100
        let digits = euros < 0.10 ? 3 : 2
        let formatted = String(format: "%.\(digits)f", euros)
            .replacingOccurrences(of: ".", with: ",")
        return formatted + nbsp + "€/g " + activeShort
    }

    /// Date courte : « 3 août ». Formateur unique du produit, pour que jour et
    /// mois ne soient jamais reformatés écran par écran.
    public static func dayMonth(_ date: Date) -> String {
        dayMonthFormatter.string(from: date)
    }

    /// Date abrégée avec année : « 12 juil. 2026 ». Employée par les mentions
    /// de provenance, où l’année importe pour juger de la fraîcheur.
    public static func shortDate(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }

    /// Jour de la semaine et date : « samedi 25 juillet ». Utilisé par
    /// l’en-tête d’Aujourd’hui, qui ne doit jamais coder un jour en dur.
    public static func weekdayDayMonth(_ date: Date) -> String {
        weekdayFormatter.string(from: date)
    }

    /// Première lettre en capitale, pour les sur-titres et débuts de phrase.
    public static func capitalizingFirstLetter(_ text: String) -> String {
        guard let first = text.first else { return text }
        return first.uppercased() + text.dropFirst()
    }

    private static let shortDateFormatter = frenchFormatter(template: "d MMM y")
    private static let dayMonthFormatter = frenchFormatter(template: "d MMMM")
    private static let weekdayFormatter = frenchFormatter(template: "EEEE d MMMM")

    private static func frenchFormatter(template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter
    }
}
