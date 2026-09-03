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
        .library(
            name: "OrboIris",
            targets: ["OrboIris"]
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
        ),
        .executable(
            name: "OrboSpineDioscuriCertificationTool",
            targets: ["OrboSpineDioscuriCertificationTool"]
        ),
        .executable(
            name: "OrboSpineHephaestusCompletionTool",
            targets: ["OrboSpineHephaestusCompletionTool"]
        )
    ],
    targets: [
        .target(
            name: "OrboCore",
            resources: [
                .copy("Geoplacement/Resources/geoplacement-atlas-v1.js")
            ],
            linkerSettings: [.linkedLibrary("z")]
        ),
        .target(
            name: "OrboIris",
            dependencies: ["OrboCore"]
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
        .executableTarget(
            name: "OrboSpineDioscuriCertificationTool",
            dependencies: ["OrboCore"]
        ),
        .executableTarget(
            name: "OrboSpineHephaestusCompletionTool",
            dependencies: ["OrboCore"]
        ),
        .testTarget(
            name: "OrboCoreTests",
            dependencies: ["OrboCore"],
            resources: [
                .copy("Fixtures")
            ]
        ),
        .testTarget(
            name: "OrboIrisTests",
            dependencies: ["OrboIris", "OrboCore"]
        )
    ]
)
