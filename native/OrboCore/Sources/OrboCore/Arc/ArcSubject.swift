/// A lawful coordinate-bearing subject presented to Arc.
///
/// `identity` and `provenance` are carried through unchanged so later Orbo
/// systems can tell what the coordinate belongs to and where it came from.
/// Arc does not interpret either value.
public struct ArcSubject: Hashable, Sendable, Codable {
    public let identity: String
    public let provenance: String
    public let coordinate: ArcCoordinate

    public init(identity: String, provenance: String, coordinate: ArcCoordinate) {
        self.identity = identity
        self.provenance = provenance
        self.coordinate = coordinate
    }
}

/// One subject together with the exact Arc field cast from its coordinate.
public struct ArcSubjectCast: Hashable, Sendable, Codable {
    public let subject: ArcSubject
    public let field: ArcField

    internal init(subject: ArcSubject, field: ArcField) {
        self.subject = subject
        self.field = field
    }
}

/// Two lawful subjects together with the exact composite state produced from
/// their coordinates. Subject identity and provenance remain attached to the
/// query but do not participate in Arc geometry.
public struct ArcSubjectComposition: Hashable, Sendable, Codable {
    public let first: ArcSubject
    public let second: ArcSubject
    public let composite: ArcComposite

    internal init(first: ArcSubject, second: ArcSubject, composite: ArcComposite) {
        self.first = first
        self.second = second
        self.composite = composite
    }
}

public extension Arc {
    /// Casts Arc from a coordinate-bearing subject while preserving its
    /// identity and provenance unchanged.
    static func cast(_ subject: ArcSubject) -> ArcSubjectCast {
        ArcSubjectCast(subject: subject, field: cast(subject.coordinate))
    }

    /// Casts many subjects. Coordinates shared by more than one subject reuse
    /// one calculated Arc field within this operation while each subject keeps
    /// its own identity and provenance.
    static func cast(_ subjects: [ArcSubject]) -> [ArcSubjectCast] {
        var fieldsByCoordinate: [ArcCoordinate: ArcField] = [:]

        return subjects.map { subject in
            let field: ArcField
            if let existing = fieldsByCoordinate[subject.coordinate] {
                field = existing
            } else {
                let created = cast(subject.coordinate)
                fieldsByCoordinate[subject.coordinate] = created
                field = created
            }

            return ArcSubjectCast(subject: subject, field: field)
        }
    }

    /// Composes two coordinate-bearing subjects by delegating only their exact
    /// coordinates to Arc's universal half-arc law.
    static func compose(_ first: ArcSubject, _ second: ArcSubject) -> ArcSubjectComposition {
        ArcSubjectComposition(
            first: first,
            second: second,
            composite: compose(first.coordinate, second.coordinate)
        )
    }
}
