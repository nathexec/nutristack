import Foundation
import NutristackDomain

/// Source de codes-barres du scanner. Deux implémentations :
/// caméra réelle (AVFoundation) et simulateur (démonstration, prévisualisations,
/// permission refusée). L’écran ne dépend que de ce protocole.
@MainActor
protocol ScannerEngine: AnyObject {
    /// Vrai si l’implémentation fournit un aperçu caméra.
    var providesCameraPreview: Bool { get }
    /// Flux des codes EAN détectés.
    var codes: AsyncStream<String> { get }
    func start()
    func stop()
    /// Torche physique quand elle existe, sans effet sinon.
    func setTorch(_ isOn: Bool)
    /// Déclenche une détection de démonstration (appui sur le cadre).
    func simulateDetection()
}

/// Moteur simulé : émet le code de démonstration après un court délai,
/// ou immédiatement sur demande. Utilisé en simulateur et en prévisualisation.
@MainActor
final class SimulatedScannerEngine: ScannerEngine {
    let providesCameraPreview = false
    let codes: AsyncStream<String>

    private let continuation: AsyncStream<String>.Continuation
    private let demoCode: String
    private let delay: Duration
    private var autoTask: Task<Void, Never>?

    init(demoCode: String, delay: Duration = .seconds(1.5)) {
        self.demoCode = demoCode
        self.delay = delay
        // `makeStream` fournit le flux et sa continuation d’un seul tenant :
        // pas d’optionnel implicitement déballé le temps de les relier.
        (codes, continuation) = AsyncStream<String>.makeStream()
    }

    func start() {
        autoTask?.cancel()
        autoTask = Task { [delay, demoCode, continuation] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            continuation.yield(demoCode)
        }
    }

    func stop() {
        autoTask?.cancel()
    }

    func setTorch(_ isOn: Bool) {}

    func simulateDetection() {
        continuation.yield(demoCode)
    }
}

/// Choisit le moteur selon l’environnement : caméra sur appareil autorisé,
/// simulé en simulateur ou en cas de refus de permission.
@MainActor
enum ScannerEngineFactory {
    /// Code-barres de repli du mode simulé : celui du produit que la
    /// démonstration met en avant. Il vit ici plutôt que dans l’écran, qui
    /// n’a pas à connaître le catalogue de démonstration.
    static let demonstrationCode = DemoCatalog.albaMagnesium.ean

    static func make(demoCode: String = demonstrationCode) -> any ScannerEngine {
        #if targetEnvironment(simulator)
        return SimulatedScannerEngine(demoCode: demoCode)
        #else
        if CameraScannerEngine.isAuthorizedOrUndetermined {
            return CameraScannerEngine(fallbackDemoCode: demoCode)
        }
        return SimulatedScannerEngine(demoCode: demoCode)
        #endif
    }
}
