// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "AppShell",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "AppShell", targets: ["AppShell"])
    ],
    dependencies: [
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "AppShell",
            dependencies: ["DesignSystem"]
        )
    ]
)
