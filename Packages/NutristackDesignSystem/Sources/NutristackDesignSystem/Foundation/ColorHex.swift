import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Analyse de couleurs hexadécimales, isolée pour être testable.
enum HexColor {
    /// Composantes d’une couleur sur 0...255. Une structure nommée plutôt
    /// qu’un tuple à trois membres : mêmes accès (`.red`), type citable.
    struct RGB {
        let red: Int
        let green: Int
        let blue: Int
    }

    /// « 175947 » → composantes rouge, vert, bleu.
    static func parse(_ hex: String) -> RGB {
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        return RGB(red: Int((value >> 16) & 0xFF),
                   green: Int((value >> 8) & 0xFF),
                   blue: Int(value & 0xFF))
    }
}

public extension Color {
    /// Couleur dynamique clair/sombre du Design System, avec alpha optionnel.
    /// Implémentée par fournisseur de trait pour suivre le mode d’apparence en direct.
    ///
    /// Réservée à la définition des tokens de `DSColor`. Les écrans consomment
    /// les tokens nommés, jamais des valeurs hexadécimales (DS §3).
    init(light: String, dark: String, lightAlpha: CGFloat = 1, darkAlpha: CGFloat = 1) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { trait in
            let hex = trait.userInterfaceStyle == .dark ? dark : light
            let alpha = trait.userInterfaceStyle == .dark ? darkAlpha : lightAlpha
            let rgb = HexColor.parse(hex)
            return UIColor(red: CGFloat(rgb.red) / 255,
                           green: CGFloat(rgb.green) / 255,
                           blue: CGFloat(rgb.blue) / 255,
                           alpha: alpha)
        })
        #else
        let rgb = HexColor.parse(light)
        self.init(red: Double(rgb.red) / 255, green: Double(rgb.green) / 255,
                  blue: Double(rgb.blue) / 255, opacity: lightAlpha)
        #endif
    }
}
