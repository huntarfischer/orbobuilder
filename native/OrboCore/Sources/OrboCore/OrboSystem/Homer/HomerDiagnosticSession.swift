import Foundation

/// Stable diagnostic location identity owned by Homer.
///
/// Concrete entities supply their own location IDs; Homer does not maintain a
/// pantheon registry or infer what exists in the system.
public struct HomerLocationID: Hashable, Codable, Sendable, RawRepresentable {
    public let rawValue: String

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }
}

/// One entity-owned place Homer can occupy diagnostically.
public protocol HomerDiagnosticLocation {
    static var homerLocationID: HomerLocationID { get }
}

public struct HomerActionID: Hashable, Codable, Sendable, RawRepresentable {
    public let rawValue: String

    public init?(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        self.rawValue = trimmed
    }
}

public enum HomerJourneyEventKind: String, Hashable, Codable, Sendable {
    case entered
    case left
    case inspected
    case acted
}

/// Homer's own diagnostic journey history.
///
/// This records only what Homer himself did: where he stood, whether he
/// inspected that owner, and which owner-admitted action he performed. It does
/// not copy or merge the owner's interior state or history.
public struct HomerJourneyEvent: Hashable, Codable, Sendable {
    public let sequence: Int
    public let kind: HomerJourneyEventKind
    public let locationID: HomerLocationID
    public let actionID: HomerActionID?
    public let occurredAt: AbsoluteInstant

    public init(
        sequence: Int,
        kind: HomerJourneyEventKind,
        locationID: HomerLocationID,
        actionID: HomerActionID? = nil,
        occurredAt: AbsoluteInstant
    ) {
        self.sequence = sequence
        self.kind = kind
        self.locationID = locationID
        self.actionID = actionID
        self.occurredAt = occurredAt
    }
}

/// One live diagnostic Homer session.
///
/// Homer may occupy exactly one entity-owned location at a time. Location grants
/// no capabilities by itself: each owner separately defines the controls Homer
/// may use while seated there.
public struct HomerDiagnosticSession: Hashable, Sendable {
    public enum Failure: Error, Hashable, Sendable {
        case alreadyLocated
        case nowhere
        case wrongLocation
    }

    public private(set) var currentLocation: HomerLocationID?
    public private(set) var history: [HomerJourneyEvent]

    public init() {
        self.currentLocation = nil
        self.history = []
    }

    public mutating func enter<Location: HomerDiagnosticLocation>(
        _ location: Location.Type,
        occurredAt: AbsoluteInstant
    ) throws {
        guard currentLocation == nil else { throw Failure.alreadyLocated }

        currentLocation = location.homerLocationID
        append(
            kind: .entered,
            locationID: location.homerLocationID,
            occurredAt: occurredAt
        )
    }

    public mutating func leave(occurredAt: AbsoluteInstant) throws {
        guard let locationID = currentLocation else { throw Failure.nowhere }

        append(kind: .left, locationID: locationID, occurredAt: occurredAt)
        currentLocation = nil
    }

    func inspect<Location: HomerDiagnosticLocation, Result>(
        _ location: Location.Type,
        actionID: HomerActionID,
        occurredAt: AbsoluteInstant,
        operation: () throws -> Result
    ) throws -> Result {
        try require(location)
        let result = try operation()
        append(
            kind: .inspected,
            locationID: location.homerLocationID,
            actionID: actionID,
            occurredAt: occurredAt
        )
        return result
    }

    func act<Location: HomerDiagnosticLocation, Result>(
        _ location: Location.Type,
        actionID: HomerActionID,
        occurredAt: AbsoluteInstant,
        operation: () throws -> Result
    ) throws -> Result {
        try require(location)
        let result = try operation()
        append(
            kind: .acted,
            locationID: location.homerLocationID,
            actionID: actionID,
            occurredAt: occurredAt
        )
        return result
    }

    private func require<Location: HomerDiagnosticLocation>(
        _ location: Location.Type
    ) throws {
        guard currentLocation != nil else { throw Failure.nowhere }
        guard currentLocation == location.homerLocationID else {
            throw Failure.wrongLocation
        }
    }

    private mutating func append(
        kind: HomerJourneyEventKind,
        locationID: HomerLocationID,
        actionID: HomerActionID? = nil,
        occurredAt: AbsoluteInstant
    ) {
        history.append(
            HomerJourneyEvent(
                sequence: history.count + 1,
                kind: kind,
                locationID: locationID,
                actionID: actionID,
                occurredAt: occurredAt
            )
        )
    }
}
