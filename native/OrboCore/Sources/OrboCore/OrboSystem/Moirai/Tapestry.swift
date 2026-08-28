/// The empty Placement subsection of one Tapestry degree.
///
/// Lachesis will later allot Clotho's coordinate-bearing pattern matter here.
public struct TapestryPlacement: Hashable, Sendable {
    public var isEmpty: Bool { true }

    internal init() {}
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
/// Lachesis can later allot independent source matter without merging domains.
public struct TapestryDegree: Hashable, Sendable {
    public let address: DegreeAddress
    public let placement: TapestryPlacement
    public let tympan: TapestryTympan
    public let mater: TapestryMater
    public let ring: TapestryRing
    public let arc: TapestryArc

    internal init(address: DegreeAddress) {
        self.address = address
        self.placement = TapestryPlacement()
        self.tympan = TapestryTympan()
        self.mater = TapestryMater()
        self.ring = TapestryRing()
        self.arc = TapestryArc()
    }
}

/// Lachesis's canonical empty allotment template.
///
/// A fresh Tapestry contains exactly 360 degree-addressed rows. It derives no
/// astrological truth. Lachesis alone will later populate its Placement,
/// Tympan, Mater, Ring, and Arc subsections from already-authoritative matter.
public struct Tapestry: Hashable, Sendable {
    public let degrees: [TapestryDegree]

    public init() {
        self.degrees = DegreeAddress.canonicalOrder.map(TapestryDegree.init)
    }
}
