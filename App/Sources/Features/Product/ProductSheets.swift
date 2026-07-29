import NutristackDesignSystem
import NutristackDomain
import SwiftUI

/// Feuille de provenance des données (PRD §8.3, DS §7) : chaque champ,
/// son statut et sa date. La formulation exclut toute validation d’efficacité.
struct ProvenanceSheet: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Provenance des données")
                .dsStyle(.sheetTitle).foregroundStyle(DSColor.ink)
            Text("Chaque information affiche son origine et sa date. "
                 + "« Vérifiée » signifie contrôlée par l\u{2019}équipe avec preuve "
                 + "conservée, jamais une validation d\u{2019}efficacité.")
                .dsStyle(.secondary).foregroundStyle(DSColor.ink2)
                .lineSpacing(3)
                .padding(.top, 4).padding(.bottom, DSSpacing.s12)
            let lastID = product.provenance.last?.id
            ForEach(product.provenance) { field in
                HStack {
                    Text(field.field)
                        .font(DSFont.scaled(14, .regular))
                        .foregroundStyle(DSColor.ink)
                    Spacer(minLength: 10)
                    ProvenanceChip(status: chipStatus(field.status),
                                   text: detail(for: field))
                }
                .padding(.vertical, DSSpacing.s12)
                if field.id != lastID { DSHairline() }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DSSpacing.screenMargin)
        .padding(.top, DSSpacing.s16)
        .presentationDetents([.medium])
        .presentationCornerRadius(DSRadius.sheet)
        .presentationDragIndicator(.visible)
        .background(DSColor.bg)
    }

    /// Compose le libellé de provenance à partir de la source et de la date.
    /// Le domaine ne stocke plus de chaîne pré-formatée : c’est ici que la
    /// date devient du texte, une seule fois et dans un seul format.
    private func detail(for field: FieldProvenance) -> String {
        guard let date = field.date else { return field.source }
        return "\(field.source) · \(DSFormat.shortDate(date))"
    }

    private func chipStatus(_ status: FieldProvenance.Status) -> ProvenanceStatus {
        switch status {
        case .verified: return .verified
        case .recorded: return .recorded
        case .pending: return .pending
        }
    }
}

/// Feuille pédagogique de l’étiquette (PRD §6.5) : le composé, l’actif
/// élémentaire, et pourquoi la comparaison porte sur lui.
struct LabelExplainerSheet: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Comprendre cette étiquette")
                .dsStyle(.sheetTitle).foregroundStyle(DSColor.ink)
            if let ingredient = product.primaryIngredient {
                explainerText(ingredient)
                    .padding(.top, 4).padding(.bottom, DSSpacing.s12)
                ActiveGauge(fraction: ingredient.elementalFraction)
                    .padding(.bottom, 6)
                ActiveGaugeCaption(
                    leading: Text(DSFormat.milligrams(ingredient.elementalMgPerServing))
                        .bold() + Text(" d\u{2019}actif élémentaire"),
                    trailing: "sur "
                        + DSFormat.milligrams(ingredient.compoundMgPerServing)
                        + " de composé")
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DSSpacing.screenMargin)
        .padding(.top, DSSpacing.s16)
        .presentationDetents([.height(280)])
        .presentationCornerRadius(DSRadius.sheet)
        .presentationDragIndicator(.visible)
        .background(DSColor.bg)
    }

    private func explainerText(_ ingredient: IngredientDeclaration) -> some View {
        (Text(DSFormat.milligrams(ingredient.compoundMgPerServing) + " de ")
         + Text(ingredient.compoundName.lowercased()).bold()
         + Text(" apportent ")
         + Text(DSFormat.milligrams(ingredient.elementalMgPerServing)
                + " de \(ingredient.active.name.lowercased()) élémentaire").bold()
         + Text(", la quantité que votre corps peut réellement utiliser. "
                + "C\u{2019}est elle que nous comparons entre produits, "
                + "quelle que soit la forme."))
            .font(DSFont.scaled(13.5, .regular))
            .foregroundStyle(DSColor.ink2)
            .lineSpacing(3)
    }
}
