// swift-tools-version: 5.7
// Package umbrella para compatibilidade com Xcode 14 (dependências path locais).
import PackageDescription

let package = Package(
    name: "WIMBPackages",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "WIMBCore", targets: ["WIMBCore"]),
        .library(name: "NetworkClient", targets: ["NetworkClient"]),
        .library(name: "TransportEngine", targets: ["TransportEngine"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "MapFeature", targets: ["MapFeature"]),
        .library(name: "AppShell", targets: ["AppShell"])
    ],
    targets: [
        .target(
            name: "WIMBCore",
            path: "WIMBCore/Sources/WIMBCore"
        ),
        .testTarget(
            name: "WIMBCoreTests",
            dependencies: ["WIMBCore"],
            path: "WIMBCore/Tests/WIMBCoreTests"
        ),
        .target(
            name: "NetworkClient",
            dependencies: ["WIMBCore"],
            path: "NetworkClient/Sources/NetworkClient"
        ),
        .testTarget(
            name: "NetworkClientTests",
            dependencies: ["NetworkClient"],
            path: "NetworkClient/Tests/NetworkClientTests"
        ),
        .target(
            name: "TransportEngine",
            dependencies: ["WIMBCore", "NetworkClient"],
            path: "TransportEngine/Sources/TransportEngine"
        ),
        .testTarget(
            name: "TransportEngineTests",
            dependencies: ["TransportEngine"],
            path: "TransportEngine/Tests/TransportEngineTests"
        ),
        .target(
            name: "DesignSystem",
            dependencies: ["WIMBCore"],
            path: "DesignSystem/Sources/DesignSystem"
        ),
        .target(
            name: "MapFeature",
            dependencies: ["WIMBCore", "TransportEngine", "DesignSystem"],
            path: "MapFeature/Sources/MapFeature"
        ),
        .target(
            name: "AppShell",
            dependencies: ["DesignSystem"],
            path: "AppShell/Sources/AppShell"
        )
    ]
)
