import Foundation

/// The result of a successful camera scan.
public struct QRScanResult: Identifiable, Sendable {
    /// A unique identifier for the scan event.
    public let id = UUID()
    /// The raw string content extracted from the QR code or barcode.
    public let code: String
    /// The type of code detected (e.g., "org.iso.QRCode").
    public let type: String
    /// The timestamp when the scan occurred.
    public let date: Date
    
    /// Creates a new QRScanResult.
    ///
    /// - Parameters:
    ///   - code: The string payload of the code.
    ///   - type: The metadata type of the code.
    ///   - date: The date of the scan. Defaults to now.
    public init(code: String, type: String, date: Date = Date()) {
        self.code = code
        self.type = type
        self.date = date
    }
}
