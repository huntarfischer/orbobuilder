public enum NatalSpineHoraeDeliveryFailure: Error, Hashable, Sendable {
    case wrongDestination
    case unexpectedEnvelope
    case subjectMismatch
    case packageMismatch
}

public extension Horae {
    /// ACT III Beat 1. Horae accept only the sealed Natal Spine type at their
    /// printed stop. The courier remains responsible for route progression;
    /// Horae validate the arriving envelope and return the exact finished object.
    static func receiveNatalSpine(
        _ package: HermesPackage<SealedNatalSpine>,
        deliveredTo address: HermesAddress
    ) throws -> SealedNatalSpine {
        guard address == NatalSpineCommission.horaeAddress else {
            throw NatalSpineHoraeDeliveryFailure.wrongDestination
        }
        guard package.sender == OrboOnboarding.orboAddress,
              package.kind == NatalSpineCommission.packageKind,
              package.addresses == NatalSpineCommission.itinerary else {
            throw NatalSpineHoraeDeliveryFailure.unexpectedEnvelope
        }
        guard package.subjectID == package.contents.subjectID else {
            throw NatalSpineHoraeDeliveryFailure.subjectMismatch
        }
        guard package.packageID == package.contents.packageID else {
            throw NatalSpineHoraeDeliveryFailure.packageMismatch
        }
        return package.contents
    }
}
