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
            name: "OrboSpineForgeTool",
            targets: ["OrboSpineForgeTool"]
        ),
        .executable(
            name: "OrboSpineTerraForgeTool",
            targets: ["OrboSpineTerraForgeTool"]
        ),
        .executable(
            name: "OrboSpineMotionForgeTool",
            targets: ["OrboSpineMotionForgeTool"]
        ),
        .executable(
            name: "OrboSpineCandidateManifestTool",
            targets: ["OrboSpineCandidateManifestTool"]
        ),
        .executable(
            name: "OrboSpineAssemblyProofTool",
            targets: ["OrboSpineAssemblyProofTool"]
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
            name: "OrboSpineForgeTool",
            dependencies: ["OrboCore"]
        ),
        .executableTarget(
            name: "OrboSpineTerraForgeTool",
            dependencies: ["OrboCore"]
        ),
        .executableTarget(
            name: "OrboSpineMotionForgeTool",
            dependencies: ["OrboCore"]
        ),
        .executableTarget(
            name: "OrboSpineCandidateManifestTool",
            dependencies: ["OrboCore"]
        ),
        .executableTarget(
            name: "OrboSpineAssemblyProofTool",
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
