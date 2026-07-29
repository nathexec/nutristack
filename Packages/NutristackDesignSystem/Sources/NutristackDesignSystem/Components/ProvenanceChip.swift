import SwiftUI

/// Statuts de provenance d’une donnée (PRD §8.3, DS §7).
public enum ProvenanceStatus {
    /// Vérifiée par l’équipe avec preuve conservée (point accent).
    case verified
    /// Relevée sans recoupement (point tertiaire).
    case recorded
    /// Contribution en cours de vérification (point ambre).
    case pending

    var dotColor: Color {
        switch self {
        case .verified: return DSColor.accent
        case .recorded: return DSColor.ink3
        case .pending: return DSColor.amber
        }
    }
    /// Libellé d’accessibilité du statut (testé).
    var accessibilityName: String {
        switch self {
        case .verified: return "Donnée vérifiée"
        case .recorded: return "Donnée relevée"
        case .pending: return "Donnée en vérification"
        }
    }
}

/// Pastille de provenance (DS §7) : pilule `surface2`, capitales 11/700,
/// point coloré selon le statut. Un appui ouvre le détail par champ.
/// « Vérifiée » signifie contrôlée avec preuve, jamais une validation d’efficacité.
public struct ProvenanceChip: View {
    private let status: ProvenanceStatus
    private let text: String
    private let action: (() -> Void)?

    public init(status: ProvenanceStatus, text: String, action: (() -> Void)? = nil) {
        self.status = status
        self.text = text
        self.action = action
    }

    public var body: some View {
        Group {
            if let action {
                Button(action: action) { label }
            } else {
                label
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(status.accessibilityName). \(text)")
    }

    private var label: some View {
        HStack(spacing: 7) {
            Circle().fill(status.dotColor).frame(width: 6, height: 6)
            Text(text).dsStyle(.label).foregroundStyle(DSColor.ink2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(DSColor.surface2)
        .clipShape(Capsule())
    }
}

#Preview("Clair") {
    VStack(alignment: .leading, spacing: 10) {
        ProvenanceChip(status: .verified, text: "Étiquette · vérifiée le 12 juil. 2026") {}
        ProvenanceChip(status: .recorded, text: "Relevé équipe · 21 juil.")
        ProvenanceChip(status: .pending, text: "En vérification")
    }.padding().background(DSColor.bg)
}
#Preview("Sombre") {
    ProvenanceChip(status: .verified, text: "Étiquette · vérifiée le 12 juil. 2026")
        .padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    ProvenanceChip(status: .pending, text: "En vérification")
        .padding().environment(\.dynamicTypeSize, .accessibility1)
}
