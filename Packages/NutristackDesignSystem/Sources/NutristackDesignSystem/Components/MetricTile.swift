import SwiftUI

/// Texte monétaire au format « prix étiquette » : entier à taille pleine,
/// décimales et symbole à 58 % en graisse 800 (DS §4). Montant en centimes.
public struct MoneyText: View {
    private let cents: Int
    private let size: CGFloat
    public init(cents: Int, size: CGFloat = 25) {
        self.cents = cents
        self.size = size
    }
    public var body: some View {
        let parts = DSFormat.moneyParts(cents: cents)
        return (
            Text(parts.integer)
                .font(DSFont.scaled(size, .heavy, relativeTo: .largeTitle))
            + Text(parts.fraction)
                .font(DSFont.scaled(size * 0.58, .heavy, relativeTo: .largeTitle))
        )
        .tracking(-0.02 * size)
        .accessibilityLabel(Text(DSFormat.money(cents: cents)))
    }
}

/// Tuile métrique (DS §7) : filet, rayon 13, valeur, unité, étiquette capitale.
/// La tuile « prix par actif » est la seule à valeur en accent (`isHero`).
public struct MetricTile<Value: View>: View {
    private let unit: String
    private let label: String
    private let isHero: Bool
    private let value: Value

    public init(unit: String, label: String, isHero: Bool = false,
                @ViewBuilder value: () -> Value) {
        self.unit = unit
        self.label = label
        self.isHero = isHero
        self.value = value()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            value.foregroundStyle(isHero ? DSColor.accent : DSColor.ink)
            Text(unit).dsStyle(.unit).foregroundStyle(DSColor.ink2)
            Text(label).dsStyle(.tileLabel).foregroundStyle(DSColor.ink3)
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 14, leading: 15, bottom: 12, trailing: 15))
        .background(DSColor.bg)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.standard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: DSRadius.standard, style: .continuous)
            .stroke(DSColor.hairline, lineWidth: DSSize.hairline))
    }
}

public extension MetricTile where Value == MoneyText {
    /// Tuile monétaire (montant en centimes).
    init(moneyCents: Int, unit: String, label: String, isHero: Bool = false) {
        self.init(unit: unit, label: label, isHero: isHero) {
            MoneyText(cents: moneyCents)
        }
    }
}

public extension MetricTile where Value == RatingTileValue {
    /// Tuile de note (étoile accent + valeur à la française). Toujours
    /// accompagnée de son décompte en unité (DS §10 : jamais de note sans n).
    init(rating: Double, unit: String, label: String) {
        self.init(unit: unit, label: label) { RatingTileValue(value: rating) }
    }
}

/// Valeur « étoile + note » d’une tuile.
public struct RatingTileValue: View {
    let value: Double
    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DSColor.accent)
            Text(DSFormat.rating(value))
                .font(DSFont.scaled(25, .bold))
        }
    }
}

#Preview("Clair") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
        MetricTile(moneyCents: 1990, unit: "0,33\u{00A0}€ par jour", label: "Prix · 60 jours")
        MetricTile(moneyCents: 111, unit: "/ g de Mg élémentaire", label: "Prix par actif", isHero: true)
        MetricTile(rating: 4.3, unit: "41 avis vérifiés", label: "Effet perçu")
        MetricTile(rating: 4.5, unit: "67 avis", label: "Expérience")
    }.padding().background(DSColor.bg)
}
#Preview("Sombre") {
    MetricTile(moneyCents: 111, unit: "/ g de Mg élémentaire", label: "Prix par actif", isHero: true)
        .padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    MetricTile(rating: 4.3, unit: "41 avis vérifiés", label: "Effet perçu")
        .padding().environment(\.dynamicTypeSize, .accessibility1)
}
