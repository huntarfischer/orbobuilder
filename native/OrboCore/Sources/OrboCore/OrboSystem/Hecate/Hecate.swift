/// Failures at Hecate's cast gate.
public enum HecateFailure: Error, Hashable, Sendable {
    case unknownKleis(KleisID)
    case missingResources([HecateResourceKey])
    case invalidCast(KleisID)
}

/// Hecate casts only from resources placed in her hands.
public enum Hecate {
    public static func prepareCast(
        _ kleisID: KleisID,
        using suppliedResources: [HecateResourceKey],
        from kleides: Kleides
    ) throws -> Kleis {
        guard let kleis = kleides.kleis(kleisID) else {
            throw HecateFailure.unknownKleis(kleisID)
        }
        guard let formula = kleis.operationalFormula else {
            throw HecateFailure.invalidCast(kleisID)
        }

        let supplied = Set(suppliedResources)
        let missing = formula.requiredResources.filter { !supplied.contains($0) }
        guard missing.isEmpty else {
            throw HecateFailure.missingResources(missing)
        }

        return kleis
    }

    /// Casts the local Ascendant from the supplied universal Terra state and Topos.
    public static func castAscendant(
        terra: TerraMarrowSample,
        topos: Topos
    ) throws -> RingFineState {
        _ = try prepareCast(
            AscendantKleis.id,
            using: [AscendantKleis.terraResource, AscendantKleis.toposResource],
            from: .canonical
        )

        guard let ascendant = AscendantKleis.cast(terra: terra, topos: topos) else {
            throw HecateFailure.invalidCast(AscendantKleis.id)
        }

        return ascendant
    }

    /// Casts Sect through the frozen Orbo Sect law from supplied Ascendant and Sun.
    public static func castSect(
        ascendant: CelestialLongitude,
        sun: CelestialLongitude
    ) throws -> Sect {
        _ = try prepareCast(
            SectKleis.id,
            using: [SectKleis.ascendantResource, SectKleis.sunResource],
            from: .canonical
        )

        return SectKleis.cast(ascendant: ascendant, sun: sun)
    }

    /// Casts canonical AstroDNA from the twelve AstroDNAGene values supplied to Hecate.
    /// Hecate never seeks a missing gene and delegates AstroDNA validity to AstroDNA itself.
    public static func castAstroDNA(
        using suppliedGenes: [AstroDNAGene: RingFineState]
    ) throws -> AstroDNA {
        let suppliedResources = suppliedGenes.keys.map(AstroDNAKleis.resourceKey(for:))

        _ = try prepareCast(
            AstroDNAKleis.id,
            using: suppliedResources,
            from: .canonical
        )

        guard let astroDNA = AstroDNAKleis.cast(using: suppliedGenes) else {
            throw HecateFailure.invalidCast(AstroDNAKleis.id)
        }

        return astroDNA
    }

    public static func castFortune(
        ascendant: CelestialLongitude,
        moon: CelestialLongitude,
        sun: CelestialLongitude,
        sect: Sect
    ) throws -> CelestialLongitude {
        try castReversingLot(
            OrboLotCasting.fortuneID,
            using: OrboLotCasting.resources(["Asc", "Mo", "Su", "Sect"]),
            ascendant: ascendant,
            first: moon,
            second: sun,
            sect: sect
        )
    }

    public static func castSpirit(
        ascendant: CelestialLongitude,
        sun: CelestialLongitude,
        moon: CelestialLongitude,
        sect: Sect
    ) throws -> CelestialLongitude {
        try castReversingLot(
            OrboLotCasting.spiritID,
            using: OrboLotCasting.resources(["Asc", "Su", "Mo", "Sect"]),
            ascendant: ascendant,
            first: sun,
            second: moon,
            sect: sect
        )
    }

    public static func castEros(
        ascendant: CelestialLongitude,
        venus: CelestialLongitude,
        spirit: CelestialLongitude,
        sect: Sect
    ) throws -> CelestialLongitude {
        try castReversingLot(
            OrboLotCasting.erosID,
            using: OrboLotCasting.resources(["Asc", "Ve", "Sp", "Sect"]),
            ascendant: ascendant,
            first: venus,
            second: spirit,
            sect: sect
        )
    }

    public static func castNecessity(
        ascendant: CelestialLongitude,
        fortune: CelestialLongitude,
        mercury: CelestialLongitude,
        sect: Sect
    ) throws -> CelestialLongitude {
        try castReversingLot(
            OrboLotCasting.necessityID,
            using: OrboLotCasting.resources(["Asc", "F", "Me", "Sect"]),
            ascendant: ascendant,
            first: fortune,
            second: mercury,
            sect: sect
        )
    }

    private static func castReversingLot(
        _ kleisID: KleisID,
        using suppliedResources: [HecateResourceKey],
        ascendant: CelestialLongitude,
        first: CelestialLongitude,
        second: CelestialLongitude,
        sect: Sect
    ) throws -> CelestialLongitude {
        _ = try prepareCast(
            kleisID,
            using: suppliedResources,
            from: .canonical
        )

        return OrboLotCasting.cast(
            ascendant: ascendant,
            first: first,
            second: second,
            sect: sect
        )
    }
}
