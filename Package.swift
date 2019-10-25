// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "LyricsKit",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
    ],
    products: [
        .library(
            name: "LyricsKit",
            targets: ["LyricsCore", "LyricsService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cx-org/CombineX", .branch("master")),
        .package(url: "https://github.com/ddddxxx/Regex", from: "0.1.0"),
        .package(url: "https://github.com/1024jp/GzipSwift", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "LyricsCore",
            dependencies: ["Regex"]),
        .target(
            name: "LyricsService",
            dependencies: ["LyricsCore", "CXShim", "Regex", "Gzip"]),
        .testTarget(
            name: "LyricsKitTests",
            dependencies: ["LyricsCore", "LyricsService"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
