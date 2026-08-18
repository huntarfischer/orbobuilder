import Foundation

/// One admitted construction artifact consumed by the native P22 assembly workflow.
/// SHA-256 is over the exact committed gzip bytes, not the decompressed CSV text.
public struct MundaneTimespineP22CanonicalInput: Hashable, Sendable {
    public enum Family: String, Hashable, Sendable {
        case body
        case stations
        case retrogradePassages
        case retrogradeCrossings
        case exactMajorRelationships
        case exactMinorRelationships
        case eclipses
    }

    public let family: Family
    public let relativePath: String
    public let compressedBytes: Int
    public let sha256: String
    public let expectedRows: Int?

    public init(
        family: Family,
        relativePath: String,
        compressedBytes: Int,
        sha256: String,
        expectedRows: Int? = nil
    ) {
        self.family = family
        self.relativePath = relativePath
        self.compressedBytes = compressedBytes
        self.sha256 = sha256
        self.expectedRows = expectedRows
    }
}

/// Frozen repo-input contract for assembling the first real P22 ORBOTS candidate.
///
/// This does not regenerate astronomy and is not a runtime resource manifest. It identifies
/// the already-admitted Pass 5 construction matter that the native Forge tool may present to
/// Hephaestus through the assembled-storage-image manufacture route.
public enum MundaneTimespineP22CanonicalInputs {
    public static let astronomicalSource = MundaneTimespineP22ForgeRecipe.astronomicalSource
    public static let astronomicalSourceVersion = MundaneTimespineP22ForgeRecipe.canonicalAstronomicalSourceVersion

    public static let bodyInputs: [MundaneTimespineP22CanonicalInput] = [
        body(.sun, bytes: 1_706_966, sha256: "e989440da15e442e17ef655736b625aa4a177e1bf0ae2c9963c2606e5dcde463"),
        body(.moon, bytes: 20_824_888, sha256: "c307ecf195bcf77144513a66d62bda0aa1c36559c4c3c087894859b461a4e48a"),
        body(.mercury, bytes: 2_425_009, sha256: "9e82e8f684a3a343ecd8c3145e7f0fcd06368830652600f0129721cb214f39c6"),
        body(.venus, bytes: 2_083_925, sha256: "0c4c5db23fba5a6bb8548941e8490d2006cccd584ad0023a092f22d3300006cd"),
        body(.mars, bytes: 1_091_321, sha256: "9943f59d47ddb4d04c7cb11308cbc3351befbdd3e46b82e0cad0f9fb8a52ed49"),
        body(.jupiter, bytes: 2_473_792, sha256: "dd84ef4ff818c1fe25b42c6a128b511068b9e797c2f6d86e4eba0c446ecba7e0"),
        body(.saturn, bytes: 1_376_100, sha256: "07690c3e60d2b552b2e1aedd95ed7002f26ad56f6b413d08277febda400ca3bf"),
        body(.uranus, bytes: 633_292, sha256: "94b10d36e304342aaa133e5ddd3dae601c44260566c923bd40281250b63ece36"),
        body(.neptune, bytes: 399_415, sha256: "ae0c6f8e07fe7908b7eefa00b82af2f98fae9330da1a70a315bfef793323d649"),
        body(.pluto, bytes: 310_337, sha256: "3a51987a93bcd392729641d52fcbc5cd19aa780bf2c5d96f489e9fb3b90d07f0"),
        body(.trueNorthNode, bytes: 1_269_836, sha256: "fc9aa99521d575ca369a55973873b4ccaad72275e21da1a79f48e4fe37aa00d1"),
    ]

    public static let sharedMotionInputs: [MundaneTimespineP22CanonicalInput] = [
        .init(
            family: .stations,
            relativePath: "station-table.csv.gz",
            compressedBytes: 417_580,
            sha256: "3585d65d4708f2fd64401396af1b3000f7f26261a60e82b74d3d000a4952939c",
            expectedRows: MundaneTimespineP22ForgeRecipe.canonicalStationCount
        ),
        .init(
            family: .retrogradePassages,
            relativePath: "retrograde-passages.csv.gz",
            compressedBytes: 392_954,
            sha256: "11ae455a68e94b05ff0c8406ae98dd7335f1a567cac204c5ec8f44d0655233d1",
            expectedRows: MundaneTimespineP22ForgeRecipe.canonicalRetrogradePassageCount
        ),
        .init(
            family: .retrogradeCrossings,
            relativePath: "retrograde-crossings.csv.gz",
            compressedBytes: 2_447_332,
            sha256: "a1d3a7466a4ebecf6b4c49d6b4c85c38f046a28e74d34068b9310765147736f3"
        ),
    ]

    public static let universalEventInputs: [MundaneTimespineP22CanonicalInput] = [
        .init(
            family: .exactMajorRelationships,
            relativePath: "exact-major-mundane-transits.csv.gz",
            compressedBytes: 8_959_884,
            sha256: "307178a19fc2b7d5ab7364cf73e00f57ca18a7c5693072b81d4cef56f5d3f057",
            expectedRows: 308_474
        ),
        .init(
            family: .exactMinorRelationships,
            relativePath: "exact-minor-mundane-transits.csv.gz",
            compressedBytes: 17_090_967,
            sha256: "3acbafa92a0a091f125337ab0898c32f1b02be0d88bf0d78415af79ef179ff46",
            expectedRows: 461_824
        ),
        .init(
            family: .eclipses,
            relativePath: "eclipse-table.csv.gz",
            compressedBytes: 62_156,
            sha256: "15e13795d8b460782606b3dd3302796633d1229f30f2d397cf228777319e72a8",
            expectedRows: 1_133
        ),
    ]

    public static var all: [MundaneTimespineP22CanonicalInput] {
        bodyInputs + sharedMotionInputs + universalEventInputs
    }

    public static var expectedRelationshipRows: Int {
        universalEventInputs
            .filter { $0.family == .exactMajorRelationships || $0.family == .exactMinorRelationships }
            .compactMap(\.expectedRows)
            .reduce(0, +)
    }

    public static var expectedEclipseRows: Int {
        universalEventInputs.first { $0.family == .eclipses }?.expectedRows ?? 0
    }

    private static func body(
        _ body: MundaneBody,
        bytes: Int,
        sha256: String
    ) -> MundaneTimespineP22CanonicalInput {
        .init(
            family: .body,
            relativePath: "body-tables/\(body.constructionBodyFileName)",
            compressedBytes: bytes,
            sha256: sha256,
            expectedRows: MundaneTimespineP22.profile(for: body).constructionRecordCount
        )
    }
}
