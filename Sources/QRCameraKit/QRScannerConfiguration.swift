import Foundation
#if canImport(AVFoundation)
import AVFoundation
#endif

public struct QRScannerConfiguration: Sendable {
    public enum OverlayColor: Sendable {
        case white, yellow, green, blue
        case custom(Double, Double, Double)
    }

    public enum CodeType: Sendable {
        case qr

        #if canImport(AVFoundation)
        var avType: AVMetadataObject.ObjectType { .qr }
        #endif
    }

    public let codeTypes: [CodeType]
    public let scanInterval: TimeInterval
    public let vibrateOnScan: Bool
    public let overlayColor: OverlayColor

    public init(
        codeTypes: [CodeType] = [.qr],
        scanInterval: TimeInterval = 0.8,
        vibrateOnScan: Bool = true,
        overlayColor: OverlayColor = .green
    ) {
        self.codeTypes = codeTypes
        self.scanInterval = scanInterval
        self.vibrateOnScan = vibrateOnScan
        self.overlayColor = overlayColor
    }

    public static let `default` = QRScannerConfiguration()
}
