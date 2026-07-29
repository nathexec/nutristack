import SwiftUI

/// Jauge d’actif, élément signature du produit (DS §1 et §7) : barre de 6 pt
/// dont la portion pleine représente la fraction d’actif élémentaire dans le
/// composé déclaré. Piste hachurée à 45°, remplissage accent, révélation
/// unique à l’apparition. Toujours accompagnée des deux valeurs en clair
/// (« soit 300 mg de Mg élémentaire » · « 80 % VNR »).
///
/// Accessibilité : la géométrie est masquée ; annoncez les valeurs via les
/// légendes (`ActiveGaugeCaption`), conformément au DS §11.
public struct ActiveGauge: View {
    private let fraction: Double
    private let animatesOnAppear: Bool
    @State private var revealed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(fraction: Double, animatesOnAppear: Bool = true) {
        self.fraction = DSFormat.clamp01(fraction)
        self.animatesOnAppear = animatesOnAppear
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                HatchShape()
                    .stroke(DSColor.hairline, lineWidth: 1)
                    .clipShape(Capsule())
                Capsule()
                    .fill(DSColor.accent)
                    .frame(width: geo.size.width * (revealed ? fraction : 0))
            }
        }
        .frame(height: DSSize.gaugeActive)
        .onAppear {
            if animatesOnAppear && !reduceMotion {
                withAnimation(DSMotion.reveal.delay(DSMotion.gaugeDelay)) { revealed = true }
            } else {
                revealed = true
            }
        }
        .accessibilityHidden(true)
    }
}

/// Légende de jauge : deux textes en vis-à-vis (DS §7).
public struct ActiveGaugeCaption: View {
    private let leading: Text
    private let trailing: String
    public init(leading: Text, trailing: String) {
        self.leading = leading
        self.trailing = trailing
    }
    public var body: some View {
        HStack {
            leading
            Spacer(minLength: 8)
            Text(trailing)
        }
        .font(DSTextStyle.unit.font)
        .foregroundStyle(DSColor.ink2)
    }
}

#Preview("Clair") {
    VStack(alignment: .leading, spacing: 6) {
        ActiveGauge(fraction: 0.125)
        ActiveGaugeCaption(
            leading: Text("soit ") + Text("300\u{00A0}mg").bold() + Text(" de Mg élémentaire"),
            trailing: DSFormat.percentVNR(80)
        )
    }.padding().background(DSColor.bg)
}
#Preview("Sombre") {
    ActiveGauge(fraction: 0.125)
        .padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    ActiveGauge(fraction: 0.125)
        .padding().environment(\.dynamicTypeSize, .accessibility1)
}
