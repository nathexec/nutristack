import Observation
import SwiftUI

/// Apparence choisie dans Profil (auto, clair, sombre), persistée.
@Observable
@MainActor
final class AppearanceStore {
    /// Apparence choisie par l’utilisateur. `auto` laisse le système décider,
    /// ce qui reste le défaut : la palette du Design System est définie pour
    /// les deux modes.
    enum Mode: String, CaseIterable {
        case auto, light, dark
        var label: String {
            switch self {
            case .auto: return "Auto"
            case .light: return "Clair"
            case .dark: return "Sombre"
            }
        }
    }

    var mode: Mode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: Self.key) }
    }

    /// `nil` laisse le système décider (mode auto).
    var colorScheme: ColorScheme? {
        switch mode {
        case .auto: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    private static let key = "appearance.mode"

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.key)
        mode = saved.flatMap(Mode.init(rawValue:)) ?? .auto
    }
}
