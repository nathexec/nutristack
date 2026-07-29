import SwiftUI

/// Bloc de chargement (DS §7) : rectangle `surface2` à miroitement discret.
/// Jamais de disque tournant central. Le miroitement est désactivé quand
/// `Réduire les animations` est actif.
public struct SkeletonBlock: View {
    private let height: CGFloat
    private let cornerRadius: CGFloat
    @State private var phase: CGFloat = -1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(height: CGFloat, cornerRadius: CGFloat = DSRadius.standard) {
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(DSColor.surface2)
            .frame(height: height)
            .overlay {
                if !reduceMotion {
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.35), .clear],
                            startPoint: .leading, endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 0.6)
                        .offset(x: geo.size.width * phase)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            }
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
            .accessibilityLabel("Chargement")
    }
}

#Preview("Clair") {
    VStack(spacing: 12) {
        SkeletonBlock(height: 64)
        SkeletonBlock(height: 96)
        SkeletonBlock(height: 40, cornerRadius: DSRadius.pill)
    }.padding().background(DSColor.bg)
}
#Preview("Sombre") {
    SkeletonBlock(height: 64).padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    SkeletonBlock(height: 64).padding().environment(\.dynamicTypeSize, .accessibility1)
}
