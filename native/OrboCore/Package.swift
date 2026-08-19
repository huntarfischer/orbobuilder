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
        ),
        .executable(
            name: "OrboForgeTool",
            targets: ["OrboForgeTool"]
        ),
        .executable(
            name: "P22BoundaryForgeTool",
            targets: ["P22BoundaryForgeTool"]
        )
    ],
    targets: [
        .target(
            name: "OrboCore",
            resources: [
                .copy("Geoplacement/Resources/geoplacement-atlas-v1.js")
            ]
        ),
        .executableTarget(
            name: "OrboForgeTool",
            dependencies: ["OrboCore"]
        ),
        .executableTarget(
            name: "P22BoundaryForgeTool",
            dependencies: ["OrboCore"]
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
