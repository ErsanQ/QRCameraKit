#if canImport(UIKit)
import SwiftUI
import AVFoundation

// MARK: - QRScannerView

/// A full-screen SwiftUI camera view that scans QR codes and barcodes.
@MainActor
public struct QRScannerView: View {

    // MARK: - Properties

    private let configuration: QRScannerConfiguration
    private let onResult: (QRScanResult) -> Void

    @StateObject private var viewModel: QRScannerViewModel

    // MARK: - Init

    public init(
        configuration: QRScannerConfiguration = .default,
        onScan: @escaping (String) -> Void
    ) {
        let resultHandler: (QRScanResult) -> Void = { result in
            if case .success(let code) = result { onScan(code) }
        }
        self.configuration = configuration
        self.onResult = resultHandler
        self._viewModel = StateObject(
            wrappedValue: QRScannerViewModel(
                configuration: configuration,
                onResult: resultHandler
            )
        )
    }

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
            #if !targetEnvironment(simulator)
            QRCameraPreview(session: viewModel.session)
                .ignoresSafeArea()
            #else
            Color.black.ignoresSafeArea()
            Text("Camera Not Available in Simulator")
                .foregroundColor(.white)
            #endif

            if configuration.showOverlay {
                QRScannerOverlay(color: configuration.overlayColor)
            }

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

    #if canImport(AVFoundation)
    let session: AVCaptureSession
    private let cameraSession: QRCameraSession

    init(configuration: QRScannerConfiguration, onResult: @escaping (QRScanResult) -> Void) {
        let cam = QRCameraSession(configuration: configuration) { result in
            DispatchQueue.main.async {
                onResult(result)
            }
        }
        self.cameraSession = cam
        self.session = cam.session

        cam.requestPermissionAndConfigure()
    }

    func start() { cameraSession.start() }
    func stop()  { cameraSession.stop() }
    #else
    init(configuration: QRScannerConfiguration, onResult: @escaping (QRScanResult) -> Void) {}
    func start() {}
    func stop() {}
    #endif
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
                #if os(iOS)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                #endif
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.85))
    }
}
#endif
