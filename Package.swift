// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "JustPhotoPicker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "JustPhotoPicker",
            targets: ["JustPhotoPicker"]
        ),
    ],
    targets: [
        .target(
            name: "JustPhotoPicker",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "JustPhotoPickerTests",
            dependencies: ["JustPhotoPicker"]
        ),
    ]
)
