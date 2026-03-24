#if canImport(UIKit)
import AVFoundation
import UIKit

// MARK: - QRCameraSession

/// Manages the `AVCaptureSession` lifecycle and metadata output.
///
/// This is an internal class — consumers interact with ``QRScannerView`` directly.
final class QRCameraSession: NSObject {

    // MARK: - Properties

    let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    private let sessionQueue = DispatchQueue(label: "com.qrcamerakit.session", qos: .userInitiated)

    private let configuration: QRScannerConfiguration
    private let onResult: (QRScanResult) -> Void

    private var lastScanDate = Date.distantPast
    private var isConfigured = false

    // MARK: - Init

    init(configuration: QRScannerConfiguration, onResult: @escaping (QRScanResult) -> Void) {
        self.configuration = configuration
        self.onResult = onResult
        super.init()
    }

    // MARK: - Setup

    func requestPermissionAndConfigure() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            sessionQueue.async { self.configureSession() }

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                if granted {
                    self.sessionQueue.async { self.configureSession() }
                } else {
                    DispatchQueue.main.async {
                        self.onResult(.failure(.cameraPermissionDenied))
                    }
                }
            }

        case .denied, .restricted:
            DispatchQueue.main.async {
                self.onResult(.failure(.cameraPermissionDenied))
            }

        @unknown default:
            break
        }
    }

    private func configureSession() {
        guard !isConfigured else { return }

        session.beginConfiguration()
        session.sessionPreset = .high

        // Input
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            DispatchQueue.main.async {
                self.onResult(.failure(.noCameraAvailable))
            }
            return
        }
        session.addInput(input)

        // Output
        guard session.canAddOutput(metadataOutput) else {
            session.commitConfiguration()
            DispatchQueue.main.async {
                self.onResult(.failure(.sessionSetupFailed("Cannot add metadata output.")))
            }
            return
        }
        session.addOutput(metadataOutput)

        // Set supported types AFTER adding to session
        let supported = metadataOutput.availableMetadataObjectTypes
        let requested = configuration.codeTypes.map(\.avType).filter { supported.contains($0) }
        metadataOutput.metadataObjectTypes = requested
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)

        session.commitConfiguration()
        isConfigured = true
        session.startRunning()
    }

    // MARK: - Lifecycle

    func start() {
        sessionQueue.async {
            if self.isConfigured && !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QRCameraSession: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let stringValue = object.stringValue,
            !stringValue.isEmpty
        else { return }

        // Throttle by scanInterval
        let now = Date()
        guard now.timeIntervalSince(lastScanDate) >= configuration.scanInterval else { return }
        lastScanDate = now

        // Haptic feedback
        if configuration.vibrateOnScan {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        onResult(.success(stringValue))
    }
}
#endif
