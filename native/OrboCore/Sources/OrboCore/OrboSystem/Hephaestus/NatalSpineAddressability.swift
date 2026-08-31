public struct NatalSpineAddress: Hashable, Sendable {
    public let coordinate: OrboSpineCelestialCoordinate
    public let themisSourceRow: Int
    public let oceanusSourceRows: [Int]
    public let rheaSourceRows: [Int]

    public init?(
        coordinate: OrboSpineCelestialCoordinate,
        themisSourceRow: Int,
        oceanusSourceRows: [Int],
        rheaSourceRows: [Int]
    ) {
        guard themisSourceRow >= 0,
              oceanusSourceRows.allSatisfy({ $0 >= 0 }),
              rheaSourceRows.allSatisfy({ $0 >= 0 }) else {
            return nil
        }
        self.coordinate = coordinate
        self.themisSourceRow = themisSourceRow
        self.oceanusSourceRows = oceanusSourceRows
        self.rheaSourceRows = rheaSourceRows
    }
}

/// The first single, navigable Natal Spine body.
///
/// The forged Titan layers remain traceable, while OrboSpineLocate supplies the
/// one temporal engine for both UT -> celestial coordinate and celestial
/// coordinate -> every UT occurrence. No second chronology is introduced.
/// Candidate identity is its immutable forged matter; Locate is derived solely
/// from the substrate and therefore is not a second identity surface.
public struct NatalSpineCandidate: Hashable, Sendable {
    public let commission: NatalSpineForgeCommission
    public let substrate: NatalSpineCelestialSubstrate
    public let themis: [NatalSpineForgedThemisSpan]
    public let oceanus: [NatalSpineForgedOceanusRealization]
    public let rhea: [NatalSpineForgedRheaQualification]

    private let locate: OrboSpineLocate

    fileprivate init(
        layer: NatalSpineRheaForgeLayer,
        locate: OrboSpineLocate
    ) {
        self.commission = layer.commission
        self.substrate = layer.substrate
        self.themis = layer.themis
        self.oceanus = layer.oceanus
        self.rhea = layer.rhea
        self.locate = locate
    }

    public static func == (lhs: NatalSpineCandidate, rhs: NatalSpineCandidate) -> Bool {
        lhs.commission == rhs.commission
            && lhs.substrate == rhs.substrate
            && lhs.themis == rhs.themis
            && lhs.oceanus == rhs.oceanus
            && lhs.rhea == rhs.rhea
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(commission)
        hasher.combine(substrate)
        hasher.combine(themis)
        hasher.combine(oceanus)
        hasher.combine(rhea)
    }

    public var subjectID: HermesSubjectID { commission.subjectID }
    public var bounds: NatalSpineBounds { commission.schematics.bounds }

    /// UT -> one address in the already-forged child body.
    public func address(
        of body: MundaneBody,
        at julianDay: JulianDay
    ) throws -> NatalSpineAddress {
        let coordinate = try locate.coordinate(of: body, at: julianDay)
        return try address(for: coordinate)
    }

    /// Celestial time -> every occurrence on this native's finite Bone.
    public func addresses(
        of body: MundaneBody,
        at directionalDegree: OrboSpineDirectionalDegree
    ) throws -> [NatalSpineAddress] {
        try locate.occurrences(of: body, at: directionalDegree).map {
            try address(for: $0)
        }
    }

    private func address(
        for coordinate: OrboSpineCelestialCoordinate
    ) throws -> NatalSpineAddress {
        let epsilon = 1e-9
        let covering = themis.filter {
            $0.span.body == coordinate.body
                && coordinate.julianDay.value >= $0.span.start.value - epsilon
                && coordinate.julianDay.value < $0.span.end.value - epsilon
        }
        guard covering.count == 1, let house = covering.first else {
            throw NatalSpineAddressabilityFailure.themisCoverageMismatch(coordinate.body)
        }

        let oceanusRows = oceanus.compactMap { forged -> Int? in
            let event = forged.realization.occurrence
            guard event.body == coordinate.body,
                  abs(event.julianDay.value - coordinate.julianDay.value) <= epsilon,
                  event.directionalDegree.motion == coordinate.directionalDegree.motion,
                  abs(event.directionalDegree.physicalDegrees - coordinate.directionalDegree.physicalDegrees) <= 1e-7 else {
                return nil
            }
            return forged.sourceRow
        }.sorted()

        let rheaRows = rhea.compactMap { forged -> Int? in
            let source = forged.qualification.source
            guard source.body == coordinate.body,
                  abs(source.julianDay.value - coordinate.julianDay.value) <= epsilon else {
                return nil
            }
            return forged.sourceRow
        }.sorted()

        guard let address = NatalSpineAddress(
            coordinate: coordinate,
            themisSourceRow: house.sourceRow,
            oceanusSourceRows: oceanusRows,
            rheaSourceRows: rheaRows
        ) else {
            throw NatalSpineAddressabilityFailure.invalidAddress
        }
        return address
    }
}

public enum NatalSpineAddressabilityFailure: Error, Hashable, Sendable {
    case invalidLocate
    case themisCoverageMismatch(MundaneBody)
    case invalidAddress
}

public extension Hephaestus {
    /// ACT II Beat 6. Gives the complete forged candidate the same Locate law as
    /// the Mundane OrboSpine: one child chronology, addressable from UT or from
    /// directional celestial time.
    static func forgeNatalSpineAddressability(
        on layer: NatalSpineRheaForgeLayer
    ) throws -> NatalSpineCandidate {
        guard let locate = OrboSpineLocate(
            bone: layer.bounds.bone,
            celestialSupports: layer.substrate.supports,
            stations: layer.substrate.stations,
            boundaryAnchors: layer.substrate.boundaryAnchors
        ) else {
            throw NatalSpineAddressabilityFailure.invalidLocate
        }

        return NatalSpineCandidate(layer: layer, locate: locate)
    }
}
