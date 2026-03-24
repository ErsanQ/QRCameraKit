import AVFoundation

// MARK: - QRScanResult

/// The outcome of a QR code scan.
public typealias QRScanResult = Result<String, QRScanError>

// MARK: - QRCodeType

/// The barcode symbologies that ``QRScannerView`` can detect.
///
/// Default is ``QRCodeType/qr`` only. Pass multiple types to scan
/// different formats simultaneously:
///
/// ```swift
/// QRScannerView(codeTypes: [.qr, .ean13, .pdf417]) { result in
///     handleResult(result)
/// }
/// ```
public enum QRCodeType: Sendable {
    case qr
    case ean8
    case ean13
    case code128
    case code39
    case pdf417
    case aztec
    case dataMatrix

    var avType: AVMetadataObject.ObjectType {
        switch self {
        case .qr:         return .qr
        case .ean8:       return .ean8
        case .ean13:      return .ean13
        case .code128:    return .code128
        case .code39:     return .code39
        case .pdf417:     return .pdf417
        case .aztec:      return .aztec
        case .dataMatrix: return .dataMatrix
        }
    }
}

// MARK: - QRScannerConfiguration

/// Controls the behavior of ``QRScannerView``.
///
/// ```swift
/// let config = QRScannerConfiguration(
///     codeTypes: [.qr, .ean13],
///     scanInterval: 1.5,
///     vibrateOnScan: true
/// )
///
/// QRScannerView(configuration: config) { result in ... }
/// ```
public struct QRScannerConfiguration: Sendable {

    /// The symbologies to detect. Defaults to `[.qr]`.
    public var codeTypes: [QRCodeType]

    /// Minimum seconds between successive scan callbacks.
    ///
    /// Prevents flooding the callback when the camera stays on a code.
    /// Defaults to `1.0`.
    public var scanInterval: TimeInterval

    /// Whether to vibrate (haptic) on a successful scan. Defaults to `true`.
    public var vibrateOnScan: Bool

    /// Whether to show the default corner-marker overlay. Defaults to `true`.
    public var showOverlay: Bool

    /// Tint color for the overlay corners. Defaults to `.white`.
    public var overlayColor: OverlayColor

    public enum OverlayColor: Sendable {
        case white, yellow, green, blue, custom(red: Double, green: Double, blue: Double)
    }

    public init(
        codeTypes: [QRCodeType] = [.qr],
        scanInterval: TimeInterval = 1.0,
        vibrateOnScan: Bool = true,
        showOverlay: Bool = true,
        overlayColor: OverlayColor = .white
    ) {
        self.codeTypes = codeTypes
        self.scanInterval = scanInterval
        self.vibrateOnScan = vibrateOnScan
        self.showOverlay = showOverlay
        self.overlayColor = overlayColor
    }

    /// The default configuration.
    public static var `default`: QRScannerConfiguration { QRScannerConfiguration() }
}
