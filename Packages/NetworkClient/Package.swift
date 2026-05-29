// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "NetworkClient",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "NetworkClient",
            targets: ["NetworkClient"]
        )
    ],
    dependencies: [
        .package(path: "../WIMBCore")
    ],
    targets: [
        .target(
            name: "NetworkClient",
            dependencies: ["WIMBCore"]
        ),
        .testTarget(
            name: "NetworkClientTests",
            dependencies: ["NetworkClient"]
        )
    ]
)
