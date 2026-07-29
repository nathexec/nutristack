import SwiftUI

/// Tailles normalisées de la pastille packshot (DS §2).
public enum PackshotSize {
    case compare      // 46, rayon 10 (en-têtes du comparateur)
    case list         // 58, rayon 13 (rangées de liste)
    case scanResult   // 64, rayon 13 (fiche de résultat du scanner)
    case productPage  // 130 × 154, rayon 16 (en-tête de fiche)

    var dimensions: CGSize {
        switch self {
        case .compare: return CGSize(width: 46, height: 46)
        case .list: return CGSize(width: 58, height: 58)
        case .scanResult: return CGSize(width: 64, height: 64)
        case .productPage: return CGSize(width: 130, height: 154)
        }
    }
    var radius: CGFloat {
        switch self {
        case .compare: return DSRadius.small
        case .list, .scanResult: return DSRadius.standard
        case .productPage: return DSRadius.packLarge
        }
    }
}

/// Pastille packshot : fond blanc constant, produit détouré, toujours à gauche
/// de l’information (DS §2). En mode sombre, la pastille reste blanche avec un
/// liseré à 9 % ; un packshot ne s’inverse jamais. Sans image conforme,
/// affiche le contenant générique neutre.
public struct Packshot: View {
    private let image: Image?
    private let size: PackshotSize
    private let accessibilityLabel: String?
    @Environment(\.colorScheme) private var scheme

    public init(image: Image?, size: PackshotSize, accessibilityLabel: String? = nil) {
        self.image = image
        self.size = size
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        let dims = size.dimensions
        let pad = min(dims.width, dims.height) * 0.08
        ZStack {
            DSColor.pack
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .padding(pad)
            } else {
                GenericContainerShape()
                    .stroke(DSColor.ink3, lineWidth: 1.5)
                    .padding(pad * 2)
            }
        }
        .frame(width: dims.width, height: dims.height)
        .clipShape(RoundedRectangle(cornerRadius: size.radius, style: .continuous))
        .overlay {
            if scheme == .dark {
                RoundedRectangle(cornerRadius: size.radius, style: .continuous)
                    .stroke(Color.white.opacity(0.09), lineWidth: 1)
            }
        }
        .accessibilityLabel(accessibilityLabel ?? "")
        .accessibilityHidden(accessibilityLabel == nil)
    }
}

#Preview("Clair") {
    HStack(spacing: 16) {
        Packshot(image: nil, size: .compare)
        Packshot(image: nil, size: .list)
        Packshot(image: nil, size: .productPage)
    }.padding().background(DSColor.bg)
}
#Preview("Sombre") {
    HStack(spacing: 16) {
        Packshot(image: nil, size: .list)
        Packshot(image: nil, size: .productPage)
    }.padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    Packshot(image: nil, size: .list)
        .padding().environment(\.dynamicTypeSize, .accessibility1)
}
