import XCTest
@testable import QRCameraKit

final class QRCameraKitTests: XCTestCase {

    // MARK: - QRScanError

    func test_error_cameraPermissionDenied_hasDescription() {
        let error = QRScanError.cameraPermissionDenied
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.requiresSettingsRedirect)
    }

    func test_error_noCameraAvailable_doesNotRequireSettings() {
        let error = QRScanError.noCameraAvailable
        XCTAssertFalse(error.requiresSettingsRedirect)
    }

    func test_error_sessionSetupFailed_includesReason() {
        let error = QRScanError.sessionSetupFailed("test reason")
        XCTAssertTrue(error.errorDescription?.contains("test reason") ?? false)
    }

    func test_error_invalidPayload_hasDescription() {
        XCTAssertNotNil(QRScanError.invalidPayload.errorDescription)
    }

    // MARK: - QRScannerConfiguration

    func test_defaultConfiguration_hasQRCodeType() {
        let config = QRScannerConfiguration.default
        XCTAssertEqual(config.codeTypes.count, 1)
        if case .qr = config.codeTypes[0] {} else {
            XCTFail("Expected .qr code type")
        }
    }

    func test_defaultConfiguration_scanInterval() {
        XCTAssertEqual(QRScannerConfiguration.default.scanInterval, 1.0)
    }

    func test_defaultConfiguration_vibrateOnScan() {
        XCTAssertTrue(QRScannerConfiguration.default.vibrateOnScan)
    }

    func test_defaultConfiguration_showsOverlay() {
        XCTAssertTrue(QRScannerConfiguration.default.showOverlay)
    }

    func test_customConfiguration_multipleCodeTypes() {
        let config = QRScannerConfiguration(codeTypes: [.qr, .ean13, .code128])
        XCTAssertEqual(config.codeTypes.count, 3)
    }

    func test_customConfiguration_customScanInterval() {
        let config = QRScannerConfiguration(scanInterval: 2.5)
        XCTAssertEqual(config.scanInterval, 2.5)
    }

    // MARK: - QRCodeType AVFoundation Mapping

    func test_qrCodeType_avType_qr() {
        XCTAssertEqual(QRCodeType.qr.avType, .qr)
    }

    func test_qrCodeType_avType_ean13() {
        XCTAssertEqual(QRCodeType.ean13.avType, .ean13)
    }

    func test_qrCodeType_avType_code128() {
        XCTAssertEqual(QRCodeType.code128.avType, .code128)
    }

    func test_qrCodeType_avType_pdf417() {
        XCTAssertEqual(QRCodeType.pdf417.avType, .pdf417)
    }

    // MARK: - QRScanResult (typealias of Result<String, QRScanError>)

    func test_scanResult_success_isSuccess() {
        let result: QRScanResult = .success("https://apple.com")
        XCTAssertNotNil(try? result.get())
        XCTAssertEqual(try? result.get(), "https://apple.com")
    }

    func test_scanResult_failure_isFailure() {
        let result: QRScanResult = .failure(.noCameraAvailable)
        XCTAssertThrowsError(try result.get())
    }

    // MARK: - Sendable Conformance

    func test_configuration_isSendable() {
        let _: any Sendable = QRScannerConfiguration.default
    }

    func test_error_isSendable() {
        let _: any Sendable = QRScanError.cameraPermissionDenied
    }

    func test_codeType_isSendable() {
        let _: any Sendable = QRCodeType.qr
    }
}
