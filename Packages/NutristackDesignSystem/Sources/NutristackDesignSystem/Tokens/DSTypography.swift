#if canImport(CoreText)
import CoreText
#endif
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Famille typographique unique du produit (référence : DS v2.0.1, §4).
/// Schibsted Grotesk, licence SIL OFL. Si les fichiers de police ne sont pas
/// présents, SwiftUI retombe silencieusement sur la police système ; le rendu
/// exact exige donc l’installation des polices (voir README).
public enum DSFontFamily {
    public static let name = "Schibsted Grotesk"
    /// Vrai si la famille est disponible à l’exécution.
    public static var isAvailable: Bool {
        #if canImport(UIKit)
        return UIFont(name: name, size: 12) != nil
        #else
        return false
        #endif
    }
}

/// Enregistre les polices déposées dans `Resources/Fonts` du package.
/// À appeler une fois au démarrage de l’application.
public enum DSFontRegistrar {
    @discardableResult
    public static func registerBundledFonts() -> Int {
        #if canImport(CoreText)
        let urls = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        var count = 0
        for url in urls where CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil) {
            count += 1
        }
        return count
        #else
        return 0
        #endif
    }
}

/// Styles de texte nommés. Toute la hiérarchie se construit par la graisse,
/// la taille et la casse ; jamais par changement de famille (DS §4).
public enum DSTextStyle {
    case screenTitle    // 32 · 800 · −0,022 em : titres d’écran
    case figure         // 29 · 800 : grands chiffres du résumé
    case productName    // 24 · 800 · −0,018 em : nom de produit, titre du comparateur
    case tileValue      // 25 · 800 : valeurs de tuiles
    case sheetTitle     // 20 · 800 : titres de feuilles
    case verdictTitle   // 17 · 800 : carte de verdict
    case rowTitle       // 16 · 700 : noms dans les listes
    case button         // 16 · 700 : libellés de boutons
    case backLink       // 16 · 600 : lien retour
    case body           // 15,5 · 450 : texte courant
    case subBody        // 14,5 · 450 : sous-textes, avis
    case secondary      // 13 · 450 : sous-lignes, tableaux
    case unit           // 12,5 · 500 : unités de tuiles, légendes de jauges
    case label          // 11 · 700 · capitales : sections, provenance
    case tileLabel      // 10,5 · 700 · capitales : étiquettes de tuiles, marques
    case micro          // 9,5 · 700 · capitales : filigranes

    var size: CGFloat {
        switch self {
        case .screenTitle: return 32
        case .figure: return 29
        case .tileValue: return 25
        case .productName: return 24
        case .sheetTitle: return 20
        case .verdictTitle: return 17
        case .rowTitle, .button, .backLink: return 16
        case .body: return 15.5
        case .subBody: return 14.5
        case .secondary: return 13
        case .unit: return 12.5
        case .label: return 11
        case .tileLabel: return 10.5
        case .micro: return 9.5
        }
    }
    var weight: Font.Weight {
        switch self {
        case .screenTitle, .figure, .productName, .tileValue, .sheetTitle, .verdictTitle: return .heavy
        case .rowTitle, .button, .label, .tileLabel, .micro: return .bold
        case .backLink: return .semibold
        case .unit: return .medium
        case .body, .subBody, .secondary: return .regular
        }
    }
    var relative: Font.TextStyle {
        switch self {
        case .screenTitle, .figure: .largeTitle
        case .productName, .tileValue: .title2
        case .sheetTitle: .title3
        case .verdictTitle, .rowTitle, .button, .backLink: .headline
        case .body: .body
        case .subBody, .secondary, .unit: .subheadline
        case .label, .tileLabel, .micro: .caption
        }
    }
    /// Interlettrage en points (em × corps), conforme au DS §4.
    var tracking: CGFloat {
        switch self {
        case .screenTitle: return -0.022 * 32
        case .productName: return -0.018 * 24
        case .sheetTitle: return -0.012 * 20
        case .verdictTitle: return -0.010 * 17
        case .rowTitle: return -0.008 * 16
        case .label: return 0.07 * 11
        case .tileLabel: return 0.07 * 10.5
        case .micro: return 0.10 * 9.5
        default: return 0
        }
    }
    var isUppercased: Bool {
        switch self {
        case .label, .tileLabel, .micro: return true
        default: return false
        }
    }
    /// Police du style, avec repli système silencieux et Dynamic Type.
    public var font: Font {
        Font.custom(DSFontFamily.name, size: size, relativeTo: relative).weight(weight)
    }
}

/// Fabrique de polices du Design System.
///
/// Point de passage obligatoire pour toute taille qui n’a pas encore de style
/// nommé dans `DSTextStyle` : elle garantit le `relativeTo:` sans lequel le
/// texte ne suivrait pas Dynamic Type (DS §11). Appeler `Font.custom(_:size:)`
/// directement est interdit : la taille serait figée.
public enum DSFont {
    public static func scaled(_ size: CGFloat,
                              _ weight: Font.Weight,
                              relativeTo textStyle: Font.TextStyle = .body) -> Font {
        Font.custom(DSFontFamily.name, size: size, relativeTo: textStyle).weight(weight)
    }
}

public extension Text {
    /// Applique un style de texte du Design System (police, interlettrage, casse).
    func dsStyle(_ style: DSTextStyle) -> some View {
        self.font(style.font)
            .tracking(style.tracking)
            .textCase(style.isUppercased ? .uppercase : nil)
    }
}
