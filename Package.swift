// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "LyricsProvider",
    dependencies: [
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", majorVersion: 3),
        .Package(url: "https://github.com/devxoul/Then", majorVersion: 2),
        ]
)
