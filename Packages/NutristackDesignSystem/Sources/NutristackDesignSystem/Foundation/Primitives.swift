import SwiftUI

/// Filet horizontal 1 pt (DS §5 : élévation par filet, pas par ombre).
public struct DSHairline: View {
    public init() {}
    public var body: some View {
        Rectangle()
            .fill(DSColor.hairline)
            .frame(height: DSSize.hairline)
    }
}

/// Retour tactile des rangées de liste : échelle 0,992 (DS §7).
/// Public afin que les écrans réutilisent le token au lieu de le redéfinir.
public struct RowPressStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.992 : 1)
            .animation(DSMotion.tap, value: configuration.isPressed)
    }
}

/// Ligne « étoile + note » réutilisée par tuiles et rangées.
struct RatingMark: View {
    let value: Double
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DSColor.accent)
            Text(DSFormat.rating(value))
        }
    }
}
