#if canImport(UIKit)
import SwiftUI
import AVFoundation

// MARK: - QRScannerView

/// A full-screen SwiftUI camera view that scans QR codes and barcodes.
///
/// ## Basic usage
/// ```swift
/// QRScannerView { code in
///     print("Scanned:", code)
/// }
/// ```
///
/// ## With error handling
/// ```swift
/// QRScannerView { result in
///     switch result {
///     case .success(let code):
///         handleCode(code)
///     case .failure(let error):
///         if error.requiresSettingsRedirect {
///             openSettings()
///         }
///     }
/// }
/// ```
///
/// ## Custom configuration
/// ```swift
/// QRScannerView(
///     configuration: QRScannerConfiguration(
///         codeTypes: [.qr, .ean13],
///         overlayColor: .yellow
///     )
/// ) { result in
///     handleResult(result)
/// }
/// ```
public struct QRScannerView: View {

    // MARK: - Properties

    private let configuration: QRScannerConfiguration
    private let onResult: (QRScanResult) -> Void

    @StateObject private var viewModel: QRScannerViewModel

    // MARK: - Init

    /// Creates a scanner with a simple string callback (success only).
    ///
    /// Errors are silently ignored. Use the `Result`-based init if you need error handling.
    public init(
        configuration: QRScannerConfiguration = .default,
        onScan: @escaping (String) -> Void
    ) {
        self.configuration = configuration
        self.onResult = { result in
            if case .success(let code) = result { onScan(code) }
        }
        self._viewModel = StateObject(
            wrappedValue: QRScannerViewModel(
                configuration: configuration,
                onResult: { result in
                    if case .success(let code) = result { onScan(code) }
                }
            )
        )
    }

    /// Creates a scanner with a full `Result` callback.
    public init(
        configuration: QRScannerConfiguration = .default,
        onResult: @escaping (QRScanResult) -> Void
    ) {
        self.configuration = configuration
        self.onResult = onResult
        self._viewModel = StateObject(
            wrappedValue: QRScannerViewModel(
                configuration: configuration,
                onResult: onResult
            )
        )
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Camera feed
            QRCameraPreview(session: viewModel.session)
                .ignoresSafeArea()

            // Default overlay
            if configuration.showOverlay {
                QRScannerOverlay(color: configuration.overlayColor)
            }

            // Permission denied state
            if viewModel.permissionDenied {
                QRPermissionDeniedView()
            }
        }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }
}

// MARK: - QRScannerViewModel

@MainActor
final class QRScannerViewModel: ObservableObject {

    @Published var permissionDenied = false

    let session: AVCaptureSession
    private let cameraSession: QRCameraSession

    init(configuration: QRScannerConfiguration, onResult: @escaping (QRScanResult) -> Void) {
        let cam = QRCameraSession(configuration: configuration) { result in
            DispatchQueue.main.async {
                if case .failure(let error) = result,
                   case .cameraPermissionDenied = error {
                    // Will be handled by permissionDenied flag below
                }
                onResult(result)
            }
        }
        self.cameraSession = cam
        self.session = cam.session

        cam.requestPermissionAndConfigure()
    }

    func start() { cameraSession.start() }
    func stop()  { cameraSession.stop() }
}

// MARK: - QRPermissionDeniedView

private struct QRPermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white)

            Text("Camera Access Required")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Please enable camera access in Settings to scan QR codes.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.85))
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    QRScannerView { code in
        print("Scanned:", code)
    }
}
#endif
#endif
