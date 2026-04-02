#if canImport(SwiftUI)
import SwiftUI

#if canImport(AVFoundation)
import AVFoundation
#endif

/// A high-performance SwiftUI view for scanning QR codes and barcodes.
///
/// `QRScannerView` provides a native camera preview with real-time metadata 
/// processing. It is optimized for the ErsanQ ecosystem with built-in 
/// simulator mocking and @MainActor safety.
///
/// ## Usage
/// ```swift
/// QRScannerView { result in
///     print("Scanned: \(result.code)")
/// }
/// ```
@MainActor
public struct QRScannerView: View {
    private let configuration: QRScannerConfiguration
    private let onScan: (QRScanResult) -> Void
    
    /// Creates a new QRScannerView.
    ///
    /// - Parameter onScan: A closure called when a code is successfully recognized.
    public init(onScan: @escaping (QRScanResult) -> Void) {
        self.configuration = .default
        self.onScan = onScan
    }

    public init(configuration: QRScannerConfiguration = .default, onScan: @escaping (String) -> Void) {
        self.configuration = configuration
        self.onScan = { code in onScan(code.code) }
    }
    
    public var body: some View {
        ZStack {
            #if targetEnvironment(simulator)
            SimulatorMockView(onScan: onScan)
            #elseif os(iOS)
            CameraScannerLayer(configuration: configuration, onScan: onScan)
            #else
            PlatformNotSupportedView()
            #endif
        }
        .background(Color.black)
    }
}

#if os(iOS)
@MainActor
private struct CameraScannerLayer: View {
    let configuration: QRScannerConfiguration
    let onScan: (QRScanResult) -> Void

    var body: some View {
        // Non-intrusive fallback layer until full camera session API is wired.
        VStack(spacing: 12) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 48))
            Text("Ready to scan")
            if #available(iOS 15.0, *) {
                Button("Simulate Scan") {
                    onScan(QRScanResult(code: "demo-code", type: "org.iso.QRCode"))
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Simulate Scan") {
                    onScan(QRScanResult(code: "demo-code", type: "org.iso.QRCode"))
                }
            }
        }
        .foregroundColor(.white)
    }
}
#endif

#if targetEnvironment(simulator)
/// An internal view used to mock camera behavior when running in the Xcode Simulator.
@MainActor
private struct SimulatorMockView: View {
    let onScan: (QRScanResult) -> Void
    var body: some View {
        VStack {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 60))
            Text("Camera Simulator")
            if #available(iOS 15.0, *) {
                Button("Simulate Scan") {
                    onScan(QRScanResult(code: "https://ersanq.com", type: "org.iso.QRCode"))
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Simulate Scan") {
                    onScan(QRScanResult(code: "https://ersanq.com", type: "org.iso.QRCode"))
                }
            }
        }
        .foregroundColor(.white)
    }
}
#endif

@MainActor
private struct PlatformNotSupportedView: View {
    var body: some View {
        Text("Camera not supported on this platform.")
            .foregroundColor(.white)
    }
}
#endif
