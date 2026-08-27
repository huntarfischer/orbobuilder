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

        let supplied = Set(suppliedResources)
        let missing = kleis.requiredResources.filter { !supplied.contains($0) }
        guard missing.isEmpty else {
            throw HecateFailure.missingResources(missing)
        }

        return kleis
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
}
