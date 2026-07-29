import NutristackDesignSystem
import NutristackDomain
import SwiftUI
import UIKit

/// Scanner (gabarit DS §9) : recouvrement plein écran, cadre carré de 240 pt
/// à dimensions fixes, ligne de balayage, torche, fiche de résultat glissée
/// depuis le bas. Le fond sombre est l’exception documentée du DS §3
/// (contexte caméra) ; il reste identique dans les deux modes.
struct ScannerView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.catalogRepository) private var repository
    @Environment(StackStore.self) private var stack
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Créé au premier affichage : la fabrique est isolée MainActor.
    @State private var engine: (any ScannerEngine)?
    @State private var isTorchOn = false
    @State private var scanPhase: CGFloat = 0
    @State private var foundProduct: Product?
    /// Dernier code refusé : la caméra ré-émet le même code à chaque image,
    /// et sans cette mémoire l’avertissement se répéterait en rafale.
    @State private var lastUnknownCode: String?

    var body: some View {
        ZStack {
            backdrop
            VStack(spacing: 0) {
                header
                Spacer()
                viewfinder
                hint
                torchButton
                Spacer()
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, DSSpacing.screenMargin)
        }
        .overlay(alignment: .bottom) { resultCard }
        .animation(DSMotion.sheet, value: foundProduct)
        .task { await startScanning() }
        .onDisappear { stopScanning() }
    }

    // MARK: Fond

    @ViewBuilder private var backdrop: some View {
        if let camera = engine as? CameraScannerEngine,
           camera.providesCameraPreview {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
            LinearGradient(colors: [DSColor.scannerBackdropTop.opacity(0.55),
                                    DSColor.scannerBackdropBottom.opacity(0.55)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        } else {
            LinearGradient(colors: [DSColor.scannerBackdropTop, DSColor.scannerBackdropBottom],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }

    private var header: some View {
        HStack {
            Text("Scanner un produit")
                .font(DSFont.scaled(17, .heavy))
                .foregroundStyle(.white)
            Spacer()
            Button {
                router.closeScanner()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Color.white.opacity(0.12)))
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(ScalePressStyle())
            .accessibilityLabel("Fermer le scanner")
        }
        .padding(.top, DSSpacing.s8)
    }

    // MARK: Cadre de visée (240 pt fixes, DS §7)

    private var viewfinder: some View {
        ZStack {
            ViewfinderCorners()
                .stroke(Color.white.opacity(0.85),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round))
            if foundProduct == nil {
                scanline
            }
        }
        .frame(width: DSSize.scanFrame, height: DSSize.scanFrame)
        .contentShape(Rectangle())
        .onTapGesture { engine?.simulateDetection() }
        .onAppear {
            guard !reduceMotion else {
                scanPhase = 0.5
                return
            }
            withAnimation(.easeInOut(duration: 0.95).repeatForever(autoreverses: true)) {
                scanPhase = 1
            }
        }
        .accessibilityLabel("Cadre de visée. Touchez pour une détection de démonstration.")
    }

    private var scanline: some View {
        Rectangle()
            .fill(LinearGradient(colors: [DSColor.scannerScanline.opacity(0),
                                          DSColor.scannerScanline,
                                          DSColor.scannerScanline.opacity(0)],
                                 startPoint: .leading, endPoint: .trailing))
            .frame(height: 2)
            .shadow(color: DSColor.scannerScanline.opacity(0.7), radius: 6)
            .offset(y: -DSSize.scanFrame / 2 + 18
                + (DSSize.scanFrame - 36) * scanPhase)
            .accessibilityHidden(true)
    }

    private var hint: some View {
        VStack(spacing: 5) {
            Text("Visez le code-barres · EAN-13 et EAN-8")
                .font(DSFont.scaled(14, .bold))
                .foregroundStyle(.white)
            Text("Produit introuvable ? Quatre photos suffisent pour l\u{2019}ajouter.")
                .font(DSFont.scaled(12.5, .regular))
                .foregroundStyle(Color.white.opacity(0.62))
        }
        .multilineTextAlignment(.center)
        .padding(.top, DSSpacing.s28)
    }

    private var torchButton: some View {
        Button {
            isTorchOn.toggle()
            engine?.setTorch(isTorchOn)
        } label: {
            Image(systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(isTorchOn ? DSColor.scannerBackdropBottom : .white)
                .frame(width: 46, height: 46)
                .background(Circle().fill(isTorchOn ? .white : Color.white.opacity(0.12)))
        }
        .buttonStyle(ScalePressStyle())
        .padding(.top, DSSpacing.s16)
        .accessibilityLabel(isTorchOn ? "Éteindre la torche" : "Allumer la torche")
    }

    // MARK: Résultat

    @ViewBuilder private var resultCard: some View {
        if let product = foundProduct {
            VStack(spacing: DSSpacing.s14) {
                HStack(spacing: DSSpacing.s14) {
                    Packshot(image: nil, size: .scanResult)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(product.name) · \(product.brand.shortName)")
                            .dsStyle(.rowTitle).foregroundStyle(DSColor.ink)
                        metricLine(product)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack(spacing: 10) {
                    Button(stack.contains(product) ? "Déjà suivi" : "Ajouter") {
                        add(product)
                    }
                    .buttonStyle(DSButtonStyle(
                        stack.contains(product) ? .done : .secondary, compact: true))
                    .disabled(stack.contains(product))
                    Button("Voir la fiche") {
                        router.closeScanner()
                        router.openProduct(product)
                    }
                    .buttonStyle(DSButtonStyle(.primary, compact: true))
                }
            }
            .padding(DSSpacing.s16)
            .background(DSColor.bg)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.scanResult, style: .continuous))
            .shadow(color: DSShadow.color, radius: DSShadow.radius, y: DSShadow.offsetY)
            .padding(.horizontal, DSSpacing.screenMargin)
            .padding(.bottom, DSSpacing.s16)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    /// Ligne de métrique du résultat : prix par gramme d’actif puis note.
    /// L’étoile est un symbole en couleur d’action, jamais un glyphe de texte
    /// (DS §7), ce qui la rend aussi lisible par VoiceOver.
    @ViewBuilder private func metricLine(_ product: Product) -> some View {
        HStack(spacing: 4) {
            if let exact = product.pricePerActiveGramCentsExact,
               let short = product.primaryIngredient?.active.shortName {
                Text(DSFormat.pricePerGram(centsExact: exact, activeShort: short)
                    + " élémentaire ·")
                    .dsStyle(.secondary).foregroundStyle(DSColor.ink2)
            }
            Image(systemName: "star.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DSColor.accent)
            Text(DSFormat.rating(product.ratings.effectAverage))
                .dsStyle(.secondary).foregroundStyle(DSColor.ink2)
        }
        .accessibilityElement(children: .combine)
    }

    /// Démarre la capture et consomme le flux de codes jusqu’à la fermeture.
    ///
    /// Le moteur est construit ici et non dans l’initialiseur de la vue : sa
    /// fabrique est isolée sur l’acteur principal, et une vue SwiftUI peut être
    /// instanciée hors de cet acteur. L’isolation explicite de la méthode rend
    /// le point de bascule visible plutôt qu’implicite.
    @MainActor private func startScanning() async {
        let engine = self.engine ?? ScannerEngineFactory.make()
        self.engine = engine
        engine.start()
        for await code in engine.codes {
            await handle(code)
        }
    }

    /// Éteint la torche et arrête la session à la disparition de l’écran.
    @MainActor private func stopScanning() {
        engine?.setTorch(false)
        engine?.stop()
    }

    /// Ajoute le produit scanné à la stack, puis referme le scanner.
    @MainActor private func add(_ product: Product) {
        guard stack.add(product) else { return }
        router.show("\(product.brand.shortName) ajouté à votre stack")
        router.closeScanner()
    }

    /// Traite un code détecté : recherche, retour haptique, fiche de résultat.
    @MainActor private func handle(_ code: String) async {
        guard foundProduct == nil, code != lastUnknownCode else { return }
        guard let product = await repository.product(ean: code) else {
            lastUnknownCode = code
            router.show("Produit introuvable dans le catalogue")
            return
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        foundProduct = product
    }
}

/// Quatre angles arrondis du cadre de visée (rayon 14, branches de 26).
struct ViewfinderCorners: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 14
        let arm: CGFloat = 26
        let minX = rect.minX, maxX = rect.maxX, minY = rect.minY, maxY = rect.maxY

        path.move(to: CGPoint(x: minX, y: minY + arm))
        path.addLine(to: CGPoint(x: minX, y: minY + radius))
        path.addArc(center: CGPoint(x: minX + radius, y: minY + radius), radius: radius,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: CGPoint(x: minX + arm, y: minY))

        path.move(to: CGPoint(x: maxX - arm, y: minY))
        path.addLine(to: CGPoint(x: maxX - radius, y: minY))
        path.addArc(center: CGPoint(x: maxX - radius, y: minY + radius), radius: radius,
                    startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: maxX, y: minY + arm))

        path.move(to: CGPoint(x: maxX, y: maxY - arm))
        path.addLine(to: CGPoint(x: maxX, y: maxY - radius))
        path.addArc(center: CGPoint(x: maxX - radius, y: maxY - radius), radius: radius,
                    startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: maxX - arm, y: maxY))

        path.move(to: CGPoint(x: minX + arm, y: maxY))
        path.addLine(to: CGPoint(x: minX + radius, y: maxY))
        path.addArc(center: CGPoint(x: minX + radius, y: maxY - radius), radius: radius,
                    startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: minX, y: maxY - arm))

        return path
    }
}

#Preview("Clair") {
    ScannerView().environment(AppRouter()).environment(StackStore())
}

#Preview("Sombre") {
    ScannerView().environment(AppRouter()).environment(StackStore())
        .preferredColorScheme(.dark)
}

#Preview("AX1") {
    ScannerView().environment(AppRouter()).environment(StackStore())
        .environment(\.dynamicTypeSize, .accessibility1)
}
