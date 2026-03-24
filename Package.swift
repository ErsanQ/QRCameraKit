// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "QRCameraKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "QRCameraKit",
            targets: ["QRCameraKit"]
        ),
    ],
    targets: [
        .target(
            name: "QRCameraKit",
            path: "Sources/QRCameraKit",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "QRCameraKitTests",
            dependencies: ["QRCameraKit"],
            path: "Tests/QRCameraKitTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
