import Foundation

public enum OrboEngravingDeliveryFailure: Error, Sendable {
    case atlasUnresolved(EngravingAtlasResolution)
}

/// Application assembly of the existing, fixed Engraving itinerary.
/// This function keeps no state and performs no owner-domain work.
@discardableResult
public func deliverOrboEngraving(
    orbo: inout Orbo,
    horae: inout Horae,
    hermes: inout HermesCourier,
    hestia: inout Hestia,
    now: () -> AbsoluteInstant = { AbsoluteInstant(unixSecondsSince1970: Date().timeIntervalSince1970)! }
) throws -> HermesTicketID {
    let commissioned = try orbo.commissionEngraving(subjectID: hestia.nativeSubjectID)
    let ticket = try orbo.entrustEngraving(to: &hermes, occurredAt: now())
    _ = try orbo.beginAstrosphereIntroduction()
    guard try hermes.deliverNext(ticketID: ticket, occurredAt: now()) == OrboOnboarding.engravingItinerary[0] else {
        throw HermesCourier.Failure.addressMismatch
    }
    let resolution = Atlas().resolve(commissioned.contents)
    guard case let .found(engraving) = resolution else {
        throw OrboEngravingDeliveryFailure.atlasUnresolved(resolution)
    }
    let resolved = HermesPackage(
        packageID: commissioned.packageID, subjectID: commissioned.subjectID,
        sender: commissioned.sender, kind: commissioned.kind,
        addresses: commissioned.addresses, contents: engraving
    )!
    try hermes.recover(ticketID: ticket, package: resolved, occurredAt: now())
    guard try hermes.deliverNext(ticketID: ticket, occurredAt: now()) == OrboOnboarding.engravingItinerary[1] else {
        throw HermesCourier.Failure.addressMismatch
    }
    return try finishOrboEngraving(
        resolved, orbo: &orbo, horae: &horae, hermes: &hermes, hestia: &hestia, now: now
    )
}

/// Continues the same entrusted package from its delivered Moirai stop.
/// Shared by the app and the existing birth-to-Hearth acceptance boundary.
@discardableResult
public func finishOrboEngraving(
    _ atlasResolved: HermesPackage<Engraving>,
    orbo: inout Orbo,
    horae: inout Horae,
    hermes: inout HermesCourier,
    hestia: inout Hestia,
    now: () -> AbsoluteInstant = { AbsoluteInstant(unixSecondsSince1970: Date().timeIntervalSince1970)! }
) throws -> HermesTicketID {
    guard let ticket = orbo.engravingTicketID else { throw OrboHermesFailure.noEngravingCommission }
    let worked = try Moirai.process(atlasResolved, through: &horae)
    try hermes.recover(ticketID: ticket, package: worked, occurredAt: now())
    guard try hermes.deliverNext(ticketID: ticket, occurredAt: now()) == Hestia.address else {
        throw HermesCourier.Failure.addressMismatch
    }
    let lighting = try hestia.receiveAndAnnounce(
        worked, to: OrboOnboarding.orboAddress, via: &hermes, occurredAt: now()
    )
    try hermes.recordReceipt(
        ticketID: ticket, packageID: worked.packageID, recipient: Hestia.address, receivedAt: now()
    )
    guard try hermes.deliverNext(ticketID: lighting.ticketID, occurredAt: now()) == OrboOnboarding.orboAddress else {
        throw HermesCourier.Failure.addressMismatch
    }
    try orbo.receiveHearthLitNotice(lighting.package)
    try hermes.recordReceipt(
        ticketID: lighting.ticketID, packageID: lighting.package.packageID,
        recipient: OrboOnboarding.orboAddress, receivedAt: now()
    )
    return lighting.ticketID
}
