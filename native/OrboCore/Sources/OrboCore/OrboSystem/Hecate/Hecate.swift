/// Stage 0 failures at Hecate's cast gate.
public enum HecateFailure: Error, Hashable, Sendable {
    case unknownKleis(KleisID)
    case missingResources([HecateResourceKey])
}

/// Hecate casts only from resources placed in her hands.
/// Stage 0 proves the gate but performs no spell calculation yet.
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
}
