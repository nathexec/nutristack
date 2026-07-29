import SwiftUI

/// Rangée de prise (DS §7) : packshot à gauche, contenu, coche 30 à droite.
/// État fait : disque accent, trait dessiné, contenu à 50 %, nom barré finement.
/// La bascule est réversible ; l’animation suit le token `state`.
public struct IntakeRow: View {
    private let image: Image?
    private let title: String
    private let subtitle: String
    private let isDone: Bool
    private let onToggle: () -> Void

    public init(image: Image?, title: String, subtitle: String,
                isDone: Bool, onToggle: @escaping () -> Void) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.isDone = isDone
        self.onToggle = onToggle
    }

    public var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DSSpacing.s14) {
                Packshot(image: image, size: .list)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .dsStyle(.rowTitle)
                        .foregroundStyle(DSColor.ink)
                        .strikethrough(isDone, color: DSColor.ink3)
                    Text(subtitle)
                        .dsStyle(.secondary)
                        .foregroundStyle(DSColor.ink2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(isDone ? 0.5 : 1)
                checkCircle
            }
            .padding(.vertical, DSSpacing.s14)
            .contentShape(Rectangle())
        }
        .buttonStyle(RowPressStyle())
        .animation(DSMotion.state, value: isDone)
        .accessibilityLabel("\(title), \(subtitle)")
        .accessibilityValue(isDone ? "prise faite" : "à prendre")
        .accessibilityHint("Touchez pour \(isDone ? "annuler" : "cocher") la prise")
    }

    private var checkCircle: some View {
        ZStack {
            Circle()
                .fill(isDone ? DSColor.accent : Color.clear)
            Circle()
                .stroke(isDone ? DSColor.accent : DSColor.ring, lineWidth: 1.7)
            CheckmarkShape()
                .trim(from: 0, to: isDone ? 1 : 0)
                .stroke(DSColor.onAccent,
                        style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
        }
        .frame(width: DSSize.check, height: DSSize.check)
    }
}

#Preview("Clair") {
    VStack(spacing: 0) {
        IntakeRow(image: nil, title: "Oméga-3 TG",
                  subtitle: "Boreal · 2 capsules · 0,42\u{00A0}€",
                  isDone: false, onToggle: {})
        DSHairline()
        IntakeRow(image: nil, title: "Magnésium bisglycinate",
                  subtitle: "Alba Nutrition · 2 gélules · 0,33\u{00A0}€",
                  isDone: true, onToggle: {})
    }.padding(.horizontal, DSSpacing.screenMargin).background(DSColor.bg)
}
#Preview("Sombre") {
    IntakeRow(image: nil, title: "Créatine monohydrate",
              subtitle: "Halterra · 5\u{00A0}g · 0,20\u{00A0}€",
              isDone: true, onToggle: {})
        .padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    IntakeRow(image: nil, title: "Oméga-3 TG",
              subtitle: "Boreal · 2 capsules",
              isDone: false, onToggle: {})
        .padding().environment(\.dynamicTypeSize, .accessibility1)
}
