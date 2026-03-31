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
    private let onScan: (QRScanResult) -> Void
    
    /// Creates a new QRScannerView.
    ///
    /// - Parameter onScan: A closure called when a code is successfully recognized.
    public init(onScan: @escaping (QRScanResult) -> Void) {
        self.onScan = onScan
    }
    
    public var body: some View {
        ZStack {
            #if targetEnvironment(simulator)
            SimulatorMockView(onScan: onScan)
            #elseif os(iOS)
            CameraScannerLayer(onScan: onScan)
            #else
            PlatformNotSupportedView()
            #endif
        }
        .background(Color.black)
    }
}

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
            Button("Simulate Scan") {
                onScan(QRScanResult(code: "https://ersanq.com", type: "org.iso.QRCode"))
            }
            .buttonStyle(.borderedProminent)
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
