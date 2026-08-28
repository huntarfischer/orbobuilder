/// One coordinate-bearing value allotted into the Placement subsection.
///
/// AstroDNA keeps its exact RingFineState, including motion. Hecate Lots keep
/// their exact CelestialLongitude. The degree address is only the containing
/// 0...359 Tapestry row; it does not replace the exact value.
public enum TapestryPlacementValue: Hashable, Sendable {
    case astroDNA(gene: AstroDNAGene, state: RingFineState)
    case fortune(CelestialLongitude)
    case spirit(CelestialLongitude)
    case eros(CelestialLongitude)
    case necessity(CelestialLongitude)

    public var degreeAddress: DegreeAddress {
        let degree: Int
        switch self {
        case let .astroDNA(_, state):
            degree = state.coarseState.degree
        case let .fortune(longitude):
            degree = Int(longitude.degrees.rounded(.down))
        case let .spirit(longitude):
            degree = Int(longitude.degrees.rounded(.down))
        case let .eros(longitude):
            degree = Int(longitude.degrees.rounded(.down))
        case let .necessity(longitude):
            degree = Int(longitude.degrees.rounded(.down))
        }
        return DegreeAddress(rawValue: degree)!
    }
}

/// The Placement subsection of one Tapestry degree.
public struct TapestryPlacement: Hashable, Sendable {
    public let values: [TapestryPlacementValue]

    public var isEmpty: Bool { values.isEmpty }

    internal init(values: [TapestryPlacementValue] = []) {
        self.values = values
    }
}

/// The empty Tympan subsection of one Tapestry degree.
///
/// Lachesis will later collapse Themis's testimony here.
public struct TapestryTympan: Hashable, Sendable {
    public var isEmpty: Bool { true }

    internal init() {}
}

/// The empty Mater subsection of one Tapestry degree.
///
/// Lachesis will later collapse Rhea's testimony here.
public struct TapestryMater: Hashable, Sendable {
    public var isEmpty: Bool { true }

    internal init() {}
}

/// The empty Ring subsection of one Tapestry degree.
///
/// Lachesis will later collapse Oceanus's testimony here.
public struct TapestryRing: Hashable, Sendable {
    public var isEmpty: Bool { true }

    internal init() {}
}

/// The empty Arc subsection of one Tapestry degree.
///
/// Lachesis will later collapse Asteria's testimony here.
public struct TapestryArc: Hashable, Sendable {
    public var isEmpty: Bool { true }

    internal init() {}
}

/// One canonical zodiacal degree of the Tapestry.
///
/// The degree is the shared address. Each subsection remains distinct so
/// Lachesis can allot independent source matter without merging domains.
public struct TapestryDegree: Hashable, Sendable {
    public let address: DegreeAddress
    public let placement: TapestryPlacement
    public let tympan: TapestryTympan
    public let mater: TapestryMater
    public let ring: TapestryRing
    public let arc: TapestryArc

    internal init(address: DegreeAddress) {
        self.init(
            address: address,
            placement: TapestryPlacement(),
            tympan: TapestryTympan(),
            mater: TapestryMater(),
            ring: TapestryRing(),
            arc: TapestryArc()
        )
    }

    internal init(
        address: DegreeAddress,
        placement: TapestryPlacement,
        tympan: TapestryTympan,
        mater: TapestryMater,
        ring: TapestryRing,
        arc: TapestryArc
    ) {
        self.address = address
        self.placement = placement
        self.tympan = tympan
        self.mater = mater
        self.ring = ring
        self.arc = arc
    }
}

/// Lachesis's canonical 360-degree allotment table.
public struct Tapestry: Hashable, Sendable {
    public let degrees: [TapestryDegree]

    public init() {
        self.degrees = DegreeAddress.canonicalOrder.map(TapestryDegree.init)
    }

    internal init(allottedDegrees degrees: [TapestryDegree]) {
        precondition(degrees.count == DegreeAddress.count)
        precondition(degrees.map(\.address) == DegreeAddress.canonicalOrder)
        self.degrees = degrees
    }
}

public extension Lachesis {
    /// Allots Clotho's coordinate-bearing PatternPacket matter into Placement.
    ///
    /// Pattern and Sect remain packet-wide truths and are not assigned to a
    /// zodiacal degree. No coordinate is recalculated or altered here.
    static func allot(
        _ packet: PatternPacket,
        into tapestry: Tapestry
    ) -> Tapestry {
        precondition(tapestry.degrees.count == DegreeAddress.count)
        precondition(tapestry.degrees.map(\.address) == DegreeAddress.canonicalOrder)
        precondition(tapestry.degrees.allSatisfy { $0.placement.isEmpty })

        var values = AstroDNAGene.canonicalOrder.map { gene in
            TapestryPlacementValue.astroDNA(
                gene: gene,
                state: packet.astroDNA[gene]
            )
        }
        values.append(.fortune(packet.fortune))
        values.append(.spirit(packet.spirit))
        values.append(.eros(packet.eros))
        values.append(.necessity(packet.necessity))

        let valuesByAddress = Dictionary(grouping: values, by: \.degreeAddress)

        let allottedDegrees = tapestry.degrees.map { degree in
            TapestryDegree(
                address: degree.address,
                placement: TapestryPlacement(
                    values: valuesByAddress[degree.address] ?? []
                ),
                tympan: degree.tympan,
                mater: degree.mater,
                ring: degree.ring,
                arc: degree.arc
            )
        }

        return Tapestry(allottedDegrees: allottedDegrees)
    }
}
