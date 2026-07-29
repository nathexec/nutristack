import AVFoundation
import SwiftUI

/// Moteur caméra : session AVFoundation limitée aux métadonnées EAN-13 et
/// EAN-8 (PRD §5.2), torche physique, aperçu vidéo.
///
/// Concurrence : `AVCaptureSession` et `AVCaptureDevice` ne sont pas
/// `Sendable` ; ils sont confinés par convention à `sessionQueue` (création
/// d’aperçu mise à part, tolérée par AVFoundation). Les propriétés sont
/// marquées `nonisolated(unsafe)` pour documenter cette garantie manuelle.
@MainActor
final class CameraScannerEngine: NSObject, ScannerEngine {
    let providesCameraPreview = true
    let codes: AsyncStream<String>

    nonisolated(unsafe) let session = AVCaptureSession()
    private nonisolated(unsafe) var device: AVCaptureDevice?
    private nonisolated let sessionQueue = DispatchQueue(label: "com.nutristack.scanner.session")
    private let continuation: AsyncStream<String>.Continuation
    private let fallbackDemoCode: String
    private var isConfigured = false

    static var isAuthorizedOrUndetermined: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status == .authorized || status == .notDetermined
    }

    init(fallbackDemoCode: String) {
        self.fallbackDemoCode = fallbackDemoCode
        // `makeStream` fournit le flux et sa continuation d’un seul tenant :
        // pas d’optionnel implicitement déballé le temps de les relier.
        (codes, continuation) = AsyncStream<String>.makeStream()
        super.init()
    }

    func start() {
        Task {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            guard granted else { return }
            configureIfNeeded()
            sessionQueue.async { [session] in
                if !session.isRunning { session.startRunning() }
            }
        }
    }

    func stop() {
        sessionQueue.async { [session] in
            if session.isRunning { session.stopRunning() }
        }
    }

    func setTorch(_ isOn: Bool) {
        sessionQueue.async { [device] in
            guard let device, device.hasTorch else { return }
            do {
                try device.lockForConfiguration()
                device.torchMode = isOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                // Torche indisponible : l’interface reste utilisable sans elle.
            }
        }
    }

    /// Sur la caméra, l’appui sur le cadre sert de secours de démonstration.
    func simulateDetection() {
        continuation.yield(fallbackDemoCode)
    }

    private func configureIfNeeded() {
        guard !isConfigured else { return }
        isConfigured = true
        sessionQueue.async { [session, self] in
            session.beginConfiguration()
            defer { session.commitConfiguration() }
            guard let camera = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: camera),
                  session.canAddInput(input) else { return }
            session.addInput(input)
            device = camera

            let output = AVCaptureMetadataOutput()
            guard session.canAddOutput(output) else { return }
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.ean13, .ean8]
        }
    }
}

extension CameraScannerEngine: AVCaptureMetadataOutputObjectsDelegate {
    /// Rappel AVFoundation, planifié sur la file principale à la configuration.
    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput,
                                    didOutput metadataObjects: [AVMetadataObject],
                                    from connection: AVCaptureConnection) {
        MainActor.assumeIsolated {
            guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let code = object.stringValue else { return }
            continuation.yield(code)
        }
    }
}

/// Aperçu vidéo de la session, plein cadre.
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    /// Vue dont le calque racine **est** le calque d’aperçu : redéfinir
    /// `layerClass` évite de gérer la géométrie d’un sous-calque à la main, et
    /// rend la conversion ci-dessous sûre par construction.
    final class PreviewView: UIView {
        // Un override de membre de classe ne peut pas devenir `static` :
        // la règle ne s’applique pas aux redéfinitions.
        // swiftlint:disable:next static_over_final_class
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer {
            // swiftlint:disable:next force_cast
            layer as! AVCaptureVideoPreviewLayer
        }
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}
