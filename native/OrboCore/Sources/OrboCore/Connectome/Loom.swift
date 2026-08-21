import Foundation

public struct FieldAddress: RawRepresentable, Codable, Hashable, Sendable, Comparable {
    public static let count = 360

    public let rawValue: Int

    public init?(rawValue: Int) {
        guard (0..<Self.count).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }

    public static let canonicalOrder: [FieldAddress] =
        (0..<count).map { FieldAddress(rawValue: $0)! }

    public static func < (lhs: FieldAddress, rhs: FieldAddress) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        guard let address = Self(rawValue: value) else {
            throw DecodingError.dataCorruptedError(
                in: try decoder.singleValueContainer(),
                debugDescription: "FieldAddress must be in 0..<360."
            )
        }
        self = address
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct FieldCell: Codable, Hashable, Sendable {
    public let address: FieldAddress

    public init(address: FieldAddress) {
        self.address = address
    }
}

public enum LoomConstructionState: String, Codable, Hashable, Sendable {
    case construction
}

public enum LoomError: Error, Equatable, Sendable {
    case unsupportedCodec(Int)
    case invalidGrid
}

public struct Loom: Hashable, Sendable {
    public static let codec = 1

    public let constructionState: LoomConstructionState
    public let cells: [FieldCell]

    public init() {
        constructionState = .construction
        cells = FieldAddress.canonicalOrder.map(FieldCell.init)
    }

    private init(constructionState: LoomConstructionState, cells: [FieldCell]) throws {
        guard cells.map(\.address) == FieldAddress.canonicalOrder else {
            throw LoomError.invalidGrid
        }
        self.constructionState = constructionState
        self.cells = cells
    }

    public func encoded() throws -> Data {
        let payload = Payload(
            codec: Self.codec,
            constructionState: constructionState,
            cells: cells
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(payload)
    }

    public static func decode(_ data: Data) throws -> Loom {
        let payload = try JSONDecoder().decode(Payload.self, from: data)
        guard payload.codec == Self.codec else {
            throw LoomError.unsupportedCodec(payload.codec)
        }
        return try Loom(
            constructionState: payload.constructionState,
            cells: payload.cells
        )
    }

    private struct Payload: Codable {
        let codec: Int
        let constructionState: LoomConstructionState
        let cells: [FieldCell]
    }
}
