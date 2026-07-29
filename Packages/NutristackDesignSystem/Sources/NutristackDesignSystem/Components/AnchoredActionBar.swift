import SwiftUI

/// Barre d’action ancrée (DS §7) : filet supérieur, fond translucide flouté,
/// actions en flex égal. À poser via `safeAreaInset(edge: .bottom)` sur le
/// `ScrollView` d’un écran poussé : le contenu défile dessous, la barre ne
/// flotte jamais dans la page et reste accessible sans défilement.
///
/// ```swift
/// ScrollView { contenu }
///     .safeAreaInset(edge: .bottom) {
///         AnchoredActionBar {
///             PrimaryButton("Ajouter à ma stack") { }
///             Button("Comparer") { }.buttonStyle(DSButtonStyle(.secondary))
///         }
///     }
/// ```
public struct AnchoredActionBar<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            DSHairline()
            HStack(spacing: 10) { content }
                .padding(EdgeInsets(top: 12, leading: DSSpacing.screenMargin,
                                    bottom: 14, trailing: DSSpacing.screenMargin))
        }
        .background(DSColor.bg.opacity(0.92))
        .background(.ultraThinMaterial)
    }
}

#Preview("Clair") {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(0..<12, id: \.self) { _ in
                RoundedRectangle(cornerRadius: DSRadius.standard)
                    .fill(DSColor.surface2).frame(height: 64)
            }
        }.padding(DSSpacing.screenMargin)
    }
    .background(DSColor.bg)
    .safeAreaInset(edge: .bottom) {
        AnchoredActionBar {
            PrimaryButton("Ajouter à ma stack") {}
            Button("Comparer") {}.buttonStyle(DSButtonStyle(.secondary))
        }
    }
}
#Preview("Sombre") {
    Color.clear.background(DSColor.bg)
        .safeAreaInset(edge: .bottom) {
            AnchoredActionBar { PrimaryButton("Partager en image") {} }
        }
        .preferredColorScheme(.dark)
}
#Preview("AX1") {
    Color.clear
        .safeAreaInset(edge: .bottom) {
            AnchoredActionBar { PrimaryButton("Ajouter à ma stack") {} }
        }
        .environment(\.dynamicTypeSize, .accessibility1)
}
