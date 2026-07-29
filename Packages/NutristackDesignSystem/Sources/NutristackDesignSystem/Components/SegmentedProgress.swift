import SwiftUI

/// Progression segmentée de la routine (DS §7) : un segment de 4 pt par prise
/// planifiée, rempli par la gauche en ressort. La structure encode l’information.
public struct SegmentedProgress: View {
    private let total: Int
    private let completed: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(total: Int, completed: Int) {
        self.total = max(1, total)
        self.completed = Self.clamp(completed, total: total)
    }

    /// Borne le nombre accompli dans [0 ; total] (testé).
    static func clamp(_ completed: Int, total: Int) -> Int {
        min(max(0, completed), max(1, total))
    }

    public var body: some View {
        // `Array` plutôt qu’une plage : `ForEach` sur `Range<Int>` suppose une
        // borne constante, or le nombre de prises change avec la stack.
        HStack(spacing: 5) {
            ForEach(Array(0..<total), id: \.self) { index in
                Capsule()
                    .fill(DSColor.surface2)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(DSColor.accent)
                            .scaleEffect(x: index < completed ? 1 : 0.0001,
                                         y: 1, anchor: .leading)
                    }
                    .clipShape(Capsule())
            }
        }
        .frame(height: DSSize.gaugeThin)
        .animation(reduceMotion ? nil : DSMotion.state, value: completed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(completed) prises sur \(total)")
    }
}

#Preview("Clair") {
    VStack(spacing: 14) {
        SegmentedProgress(total: 4, completed: 0)
        SegmentedProgress(total: 4, completed: 2)
        SegmentedProgress(total: 4, completed: 4)
    }.padding().background(DSColor.bg)
}
#Preview("Sombre") {
    SegmentedProgress(total: 4, completed: 3)
        .padding().background(DSColor.bg).preferredColorScheme(.dark)
}
#Preview("AX1") {
    SegmentedProgress(total: 4, completed: 2)
        .padding().environment(\.dynamicTypeSize, .accessibility1)
}
