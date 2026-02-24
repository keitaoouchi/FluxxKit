// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FluxxKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "FluxxKit", targets: ["FluxxKit"])
    ],
    targets: [
        .target(name: "FluxxKit"),
        .testTarget(name: "FluxxKitTests", dependencies: ["FluxxKit"])
    ]
)
