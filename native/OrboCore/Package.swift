// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "OrboCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "OrboCore",
            targets: ["OrboCore"]
        )
    ],
    targets: [
        .target(
            name: "OrboCore"
        ),
        .testTarget(
            name: "OrboCoreTests",
            dependencies: ["OrboCore"],
            resources: [
                .copy("Fixtures")
            ]
        )
    ]
)
