/// Hermes's diagnostic seat for Homer.
///
/// Homer may operate these controls only while located with Hermes. The controls
/// delegate to HermesCourier's existing public operations; they do not recreate
/// courier logic, bypass validation, or inspect endpoint-owned truth.
public enum HermesHomerLocation: HomerDiagnosticLocation {
    public static let homerLocationID = HomerLocationID(rawValue: "Hermes")!
}

public enum HermesHomerControls {
    public static let inspectJourneyAction = HomerActionID(rawValue: "inspectJourney")!
    public static let acceptPackageAction = HomerActionID(rawValue: "acceptPackage")!
    public static let deliverNextAction = HomerActionID(rawValue: "deliverNext")!
    public static let recoverPackageAction = HomerActionID(rawValue: "recoverPackage")!
    public static let recordReceiptAction = HomerActionID(rawValue: "recordReceipt")!

    public static func inspectJourney(
        session: inout HomerDiagnosticSession,
        courier: HermesCourier,
        ticketID: HermesTicketID,
        occurredAt: AbsoluteInstant
    ) throws -> HomerPort<HermesJourneyPOV> {
        try session.inspect(
            HermesHomerLocation.self,
            actionID: inspectJourneyAction,
            occurredAt: occurredAt
        ) {
            guard let port = courier.signalForHomer(ticketID: ticketID) else {
                throw HermesCourier.Failure.unknownTicket
            }
            return port
        }
    }

    @discardableResult
    public static func accept<Contents: Hashable & Sendable>(
        session: inout HomerDiagnosticSession,
        courier: inout HermesCourier,
        package: HermesPackage<Contents>,
        occurredAt: AbsoluteInstant
    ) throws -> HermesTicketID {
        try session.act(
            HermesHomerLocation.self,
            actionID: acceptPackageAction,
            occurredAt: occurredAt
        ) {
            try courier.accept(package: package, occurredAt: occurredAt)
        }
    }

    @discardableResult
    public static func deliverNext(
        session: inout HomerDiagnosticSession,
        courier: inout HermesCourier,
        ticketID: HermesTicketID,
        occurredAt: AbsoluteInstant
    ) throws -> HermesAddress {
        try session.act(
            HermesHomerLocation.self,
            actionID: deliverNextAction,
            occurredAt: occurredAt
        ) {
            try courier.deliverNext(ticketID: ticketID, occurredAt: occurredAt)
        }
    }

    public static func recover<Contents: Hashable & Sendable>(
        session: inout HomerDiagnosticSession,
        courier: inout HermesCourier,
        ticketID: HermesTicketID,
        package: HermesPackage<Contents>,
        occurredAt: AbsoluteInstant
    ) throws {
        try session.act(
            HermesHomerLocation.self,
            actionID: recoverPackageAction,
            occurredAt: occurredAt
        ) {
            try courier.recover(
                ticketID: ticketID,
                package: package,
                occurredAt: occurredAt
            )
        }
    }

    public static func recordReceipt(
        session: inout HomerDiagnosticSession,
        courier: inout HermesCourier,
        ticketID: HermesTicketID,
        packageID: HermesPackageID,
        recipient: HermesAddress,
        receivedAt: AbsoluteInstant
    ) throws {
        try session.act(
            HermesHomerLocation.self,
            actionID: recordReceiptAction,
            occurredAt: receivedAt
        ) {
            try courier.recordReceipt(
                ticketID: ticketID,
                packageID: packageID,
                recipient: recipient,
                receivedAt: receivedAt
            )
        }
    }
}
