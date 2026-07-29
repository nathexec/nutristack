import SwiftUI

/// Rangée produit des listes (DS §7) : packshot 58, marque en capitales,
/// nom, ligne de métrique (prix par actif en accent, note avec décompte),
/// chevron. La note affiche toujours son décompte (DS §10).
public struct ProductRow: View {
    private let image: Image?
    private let brand: String
    private let name: String
    private let tag: String?
    private let rating: Double?
    private let ratingCount: String?
    private let action: () -> Void

    public init(image: Image?, brand: String, name: String,
                tag: String? = nil, rating: Double? = nil, ratingCount: String? = nil,
                action: @escaping () -> Void) {
        self.image = image
        self.brand = brand
        self.name = name
        self.tag = tag
        self.rating = rating
        self.ratingCount = ratingCount
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.s14) {
                Packshot(image: image, size: .list)
                VStack(alignment: .leading, spacing: 3) {
                    Text(brand).dsStyle(.tileLabel).foregroundStyle(DSColor.ink3)
                    Text(name).dsStyle(.rowTitle).foregroundStyle(DSColor.ink)
                    metricLine
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DSColor.ink3)
            }
            .padding(.vertical, DSSpacing.s14)
            .contentShape(Rectangle())
        }
        .buttonStyle(RowPressStyle())
    }

    @ViewBuilder private var metricLine: some View {
        HStack(spacing: 5) {
            if let tag {
                Text(tag)
                    .font(DSFont.scaled(13, .bold))
                    .foregroundStyle(DSColor.accent)
            }
            if let rating {
                if tag != nil { Text("·").foregroundStyle(DSColor.ink2) }
                RatingMark(value: rating)
                    .font(DSFont.scaled(13, .semibold))
                    .foregroundStyle(DSColor.ink)
                if let ratingCount {
                    Text("· \(ratingCount)")
                        .dsStyle(.secondary)
                        .foregroundStyle(DSColor.ink2)
                }
            }
        }
    }
}

#Preview("Clair") {
    VStack(spacing: 0) {
        ProductRow(image: nil, brand: "Alba Nutrition", name: "Magnésium bisglycinate",
                   tag: "1,11\u{00A0}€/g Mg", rating: 4.3, ratingCount: "41 avis", action: {})
        DSHairline()
        ProductRow(image: nil, brand: "Halterra", name: "Créatine monohydrate Creapure",
                   tag: "0,040\u{00A0}€/g créatine", rating: 4.6, ratingCount: "112 avis", action: {})
    }.padding(.horizontal, DSSpacing.screenMargin).background(DSColor.bg)
}
#Preview("Sombre") {
    ProductRow(image: nil, brand: "Nordika", name: "Magnésium citrate",
               tag: "0,66\u{00A0}€/g Mg", rating: 4.0, ratingCount: "28 avis", action: {})
        .padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    ProductRow(image: nil, brand: "Boreal", name: "Oméga-3 forme triglycérides",
               tag: "0,058\u{00A0}€/g EPA+DHA", rating: 4.4, ratingCount: "63 avis", action: {})
        .padding().environment(\.dynamicTypeSize, .accessibility1)
}
