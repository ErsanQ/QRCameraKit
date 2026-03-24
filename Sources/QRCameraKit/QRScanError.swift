import Foundation

// MARK: - QRScanError

/// Describes errors that can occur during QR code scanning.
///
/// Handle these in the `.failure` case of ``QRScanResult``:
///
/// ```swift
/// QRScannerView { result in
///     switch result {
///     case .success(let code):
///         process(code)
///     case .failure(let error):
///         switch error {
///         case .cameraPermissionDenied:
///             showSettingsAlert()
///         default:
///             showGenericError(error.localizedDescription)
///         }
///     }
/// }
/// ```
public enum QRScanError: LocalizedError, Sendable {

    /// The user denied camera access, or it is restricted by the system.
    case cameraPermissionDenied

    /// The device has no available camera (e.g. simulator without camera access).
    case noCameraAvailable

    /// The `AVCaptureSession` failed to configure or start.
    case sessionSetupFailed(String)

    /// The scanned string could not be decoded as valid UTF-8.
    case invalidPayload

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .cameraPermissionDenied:
            return "Camera access is required to scan QR codes. Please enable it in Settings."
        case .noCameraAvailable:
            return "No camera is available on this device."
        case .sessionSetupFailed(let reason):
            return "Camera session failed to start: \(reason)"
        case .invalidPayload:
            return "The scanned code contains invalid data."
        }
    }

    /// Returns `true` when the error is recoverable by prompting the user to open Settings.
    public var requiresSettingsRedirect: Bool {
        if case .cameraPermissionDenied = self { return true }
        return false
    }
}
