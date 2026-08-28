enum OrboLotCasting {
    static let fortuneID = KleisID(rawValue: "Fortune")!
    static let spiritID = KleisID(rawValue: "Spirit")!
    static let erosID = KleisID(rawValue: "Eros")!
    static let necessityID = KleisID(rawValue: "Necessity")!

    static func resources(_ names: [String]) -> [HecateResourceKey] {
        names.map { HecateResourceKey(rawValue: $0)! }
    }

    /// Casts one of Orbo's frozen sect-reversing Lot formulas.
    /// All operands are already-established canonical longitudes.
    static func cast(
        ascendant: CelestialLongitude,
        first: CelestialLongitude,
        second: CelestialLongitude,
        sect: Sect
    ) -> CelestialLongitude {
        let raw = sect == .day
            ? ascendant.degrees + first.degrees - second.degrees
            : ascendant.degrees + second.degrees - first.degrees

        return CelestialLongitude(raw)!
    }
}
