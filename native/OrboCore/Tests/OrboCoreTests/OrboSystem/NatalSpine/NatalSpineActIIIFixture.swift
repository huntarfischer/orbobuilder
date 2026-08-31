import Foundation
@testable import OrboCore

enum NatalSpineActIIIFixture {
    struct CourierState {
        var courier: HermesCourier
        let ticketID: HermesTicketID
        let package: HermesPackage<SealedNatalSpine>
    }

    static func sealedSpine() throws -> SealedNatalSpine {
        let candidate = try NatalSpineActIIFixture.addressableCandidate()
        let approval = try Dioscuri.inspectNatalSpine(
            candidate,
            against: candidate.commission.schematics,
            parentProvenance: candidate.substrate.parentProvenance
        ).get()
        return Hephaestus.sealNatalSpine(approval)
    }

    static func inHermesCustodyAfterHephaestus() throws -> CourierState {
        let sealed = try sealedSpine()
        let commission = sealed.candidate.commission
        let request = NatalSpineCommission.package(
            subjectID: commission.subjectID,
            packageID: commission.packageID
        )
        let certified = HermesPackage(
            packageID: request.packageID,
            subjectID: request.subjectID,
            sender: request.sender,
            kind: request.kind,
            addresses: request.addresses,
            contents: commission.schematics
        )!
        let package = Hephaestus.releaseNatalSpine(sealed)

        var courier = HermesCourier()
        let ticketID = try courier.accept(package: request, occurredAt: instant(1_920_000_000))
        _ = try courier.deliverNext(ticketID: ticketID, occurredAt: instant(1_920_000_060))
        try courier.recover(ticketID: ticketID, package: certified, occurredAt: instant(1_920_000_120))
        _ = try courier.deliverNext(ticketID: ticketID, occurredAt: instant(1_920_000_180))
        try courier.recover(ticketID: ticketID, package: package, occurredAt: instant(1_920_000_240))

        return CourierState(courier: courier, ticketID: ticketID, package: package)
    }

    static func instant(_ seconds: Double) -> AbsoluteInstant {
        AbsoluteInstant(unixSecondsSince1970: seconds)!
    }
}
