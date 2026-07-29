import NutristackDesignSystem
import NutristackDomain
import SwiftUI

/// Feuille de partage du comparateur : aperçu de la carte, puis partage de
/// l’image rendue en haute définition (ImageRenderer, échelle 3).
/// La carte reste factuelle et signée « comparaison vérifiable » (PRD §9.4).
struct CompareShareSheet: View {
    let left: Product
    let right: Product
    let result: ComparisonEngine.Result

    @State private var renderedImage: Image?

    var body: some View {
        VStack(spacing: DSSpacing.s16) {
            Text("Partager la comparaison")
                .dsStyle(.sheetTitle).foregroundStyle(DSColor.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            ShareCardView(left: left, right: right)
            if let renderedImage {
                ShareLink(item: renderedImage,
                          preview: SharePreview("Comparaison Nutristack",
                                                image: renderedImage)) {
                    Text("Partager en image")
                }
                .buttonStyle(DSButtonStyle(.primary))
            } else {
                Button("Partager en image") {}
                    .buttonStyle(DSButtonStyle(.done))
                    .disabled(true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DSSpacing.screenMargin)
        .padding(.top, DSSpacing.s16)
        .presentationDetents([.height(420)])
        .presentationCornerRadius(DSRadius.sheet)
        .presentationDragIndicator(.visible)
        .background(DSColor.bg)
        // `renderCard` est synchrone et sur le même acteur : un `await` ici
        // serait superflu, donc un avertissement, donc une erreur de build.
        .task { renderCard() }
    }

    /// Rend la carte en clair (une image partagée ne suit pas le mode sombre).
    @MainActor private func renderCard() {
        let renderer = ImageRenderer(content:
            ShareCardView(left: left, right: right)
                .frame(width: 340)
                .padding(16)
                .background(Color.white)
                .environment(\.colorScheme, .light))
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            renderedImage = Image(uiImage: uiImage)
        }
    }
}

/// Carte de partage : titre, deux lignes de prix par gramme (gagnant en
/// accent avec l’écart), effet perçu, filigrane produit.
struct ShareCardView: View {
    let left: Product
    let right: Product

    var body: some View {
        let percent = ComparisonEngine.savingsPercent(left, right)
        let leftWins = (left.pricePerActiveGramCentsExact ?? .infinity)
            <= (right.pricePerActiveGramCentsExact ?? .infinity)
        return VStack(alignment: .leading, spacing: 10) {
            Text("\(left.primaryIngredient?.active.name ?? "Actif") : "
                 + "le vrai prix par gramme")
                .font(DSFont.scaled(16, .heavy))
                .foregroundStyle(DSColor.ink)
            shareRow(for: left, isWinner: leftWins, percent: leftWins ? percent : nil)
            DSHairline()
            shareRow(for: right, isWinner: !leftWins, percent: leftWins ? nil : percent)
            DSHairline()
            HStack {
                Text("Effet perçu vérifié")
                    .font(DSFont.scaled(11.5, .regular))
                    .foregroundStyle(DSColor.ink2)
                Spacer()
                Text("\(DSFormat.rating(left.ratings.effectAverage))"
                     + " (\(left.ratings.effectVerifiedCount))"
                     + " · \(DSFormat.rating(right.ratings.effectAverage))"
                     + " (\(right.ratings.effectVerifiedCount))")
                    .font(DSFont.scaled(11.5, .bold))
                    .foregroundStyle(DSColor.ink)
            }
            Text("Nutristack · comparaison vérifiable")
                .dsStyle(.micro).foregroundStyle(DSColor.ink3)
                .padding(.top, 2)
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 14, trailing: 16))
        .background(DSColor.bg)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.packLarge, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: DSRadius.packLarge, style: .continuous)
            .stroke(DSColor.hairline, lineWidth: DSSize.hairline))
    }

    private func shareRow(for product: Product, isWinner: Bool, percent: Int?) -> some View {
        HStack {
            Text("\(product.brand.name) \(product.formLabel)")
                .font(DSFont.scaled(13.5, .bold))
                .foregroundStyle(DSColor.ink)
            Spacer()
            HStack(spacing: 5) {
                if let exact = product.pricePerActiveGramCentsExact,
                   let short = product.primaryIngredient?.active.shortName {
                    Text(DSFormat.pricePerGram(centsExact: exact, activeShort: short))
                        .font(DSFont.scaled(13.5, .heavy))
                }
                if let percent {
                    Text("−\(percent)\u{00A0}%")
                        .font(DSFont.scaled(11, .heavy))
                        .padding(.vertical, 2).padding(.horizontal, 6)
                        .background(Capsule().fill(DSColor.accentTint))
                }
            }
            .foregroundStyle(isWinner ? DSColor.accent : DSColor.ink)
        }
    }
}
