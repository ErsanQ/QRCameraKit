#if canImport(SwiftUI)
#if canImport(UIKit)
import SwiftUI

// MARK: - View+QRScanner

public extension View {

    /// Presents a ``QRScannerView`` as a sheet when `isPresented` is `true`.
    ///
    /// The sheet dismisses automatically after a successful scan.
    ///
    /// ```swift
    /// @State private var isScanning = false
    /// @State private var scannedCode = ""
    ///
    /// Button("Scan QR Code") { isScanning = true }
    ///     .qrScanner(isPresented: $isScanning) { code in
    ///         scannedCode = code
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: Controls whether the scanner sheet is visible.
    ///   - configuration: Scanner appearance and behavior. Defaults to ``QRScannerConfiguration/default``.
    ///   - onScan: Called with the scanned string on success. The sheet dismisses automatically.
    func qrScanner(isPresented: Binding<Bool>, onScan: @escaping (String) -> Void) -> some View {
        sheet(isPresented: isPresented) {
            QRScannerSheet(
                isPresented: isPresented,
                onScan: onScan
            )
        }
    }

    /// Presents a ``QRScannerView`` as a sheet, with full `Result` error handling.
    ///
    /// ```swift
    /// Button("Scan") { isScanning = true }
    ///     .qrScannerResult(isPresented: $isScanning) { result in
    ///         switch result {
    ///         case .success(let code): handleCode(code)
    ///         case .failure(let error): showError(error)
    ///         }
    ///     }
    /// ```
    func qrScannerResult(
        isPresented: Binding<Bool>,
        onResult: @escaping (QRScanResult) -> Void
    ) -> some View {
        sheet(isPresented: isPresented) {
            QRScannerSheet(
                isPresented: isPresented,
                onScan: { code in onResult(QRScanResult(code: code, type: "org.iso.QRCode")) }
            )
        }
    }
}

// MARK: - QRScannerSheet

private struct QRScannerSheet: View {
    @Binding var isPresented: Bool
    let onScan: (String) -> Void

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                scannerContent
            }
        } else {
            NavigationView {
                scannerContent
            }
        }
    }

    @ViewBuilder
    private var scannerContent: some View {
        QRScannerView { result in
            let code = result.code
            onScan(code)
            isPresented = false
        }
        .navigationTitle("Scan QR Code")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { isPresented = false }
            }
        }
    }
}
#endif
#endif
