public struct CelestialLongitude: Hashable, Codable, Sendable {
    public let degrees: Double

    /// Creates a canonical celestial longitude in the half-open interval [0, 360).
    /// Non-finite input is rejected rather than normalized into an invalid state.
    public init?(_ degrees: Double) {
        guard degrees.isFinite else { return nil }

        var normalized = degrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 {
            normalized += 360
        }

        // Collapse negative zero and exact full-circle multiples to canonical zero.
        if normalized == 0 {
            normalized = 0
        }

        self.degrees = normalized
    }

    public var sign: Sign {
        Sign(rawValue: Int(degrees / 30))!
    }

    public var degreeInSign: DegreeInSign {
        DegreeInSign(unchecked: degrees.truncatingRemainder(dividingBy: 30))
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(Double.self)
        guard let value = Self(raw) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "CelestialLongitude requires a finite numeric value."
            )
        }
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(degrees)
    }
}

public struct DegreeInSign: Hashable, Codable, Sendable {
    public let value: Double

    /// A positional degree within one sign. Valid values are [0, 30).
    public init?(_ value: Double) {
        guard value.isFinite, value >= 0, value < 30 else { return nil }
        self.value = value
    }

    internal init(unchecked value: Double) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(Double.self)
        guard let value = Self(raw) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "DegreeInSign requires 0 <= value < 30."
            )
        }
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

/// A boundary on a sign interval. Unlike DegreeInSign, 30 is legal because
/// the final Egyptian bound and a full-sign interval end at 30 exactly.
public struct DegreeBoundaryInSign: Hashable, Codable, Sendable {
    public let value: Double

    public init?(_ value: Double) {
        guard value.isFinite, value >= 0, value <= 30 else { return nil }
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(Double.self)
        guard let value = Self(raw) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "DegreeBoundaryInSign requires 0 <= value <= 30."
            )
        }
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
