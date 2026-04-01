#if os(iOS) && canImport(AVFoundation) && canImport(UIKit)
import Foundation
import AVFoundation
import UIKit

@MainActor
final class QRCameraSession: NSObject {
    let session = AVCaptureSession()
    private let onResult: (QRScanResult) -> Void

    init(configuration: QRScannerConfiguration, onResult: @escaping (QRScanResult) -> Void) {
        self.onResult = onResult
        super.init()
    }

    func requestPermissionAndConfigure() {}
    func start() {}
    func stop() {}
}
#endif
