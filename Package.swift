// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QRCameraKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "QRCameraKit",
            targets: ["QRCameraKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "QRCameraKit",
            dependencies: [],
            path: "Sources/QRCameraKit"),
        .testTarget(
            name: "QRCameraKitTests",
            dependencies: ["QRCameraKit"],
            path: "Tests/QRCameraKitTests"),
    ]
)
