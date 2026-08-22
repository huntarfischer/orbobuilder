import Foundation

/// One celestial tract instruction inside a Spine schematic.
public struct SpineSchematicBodyPlan: Hashable, Sendable {
    public let body: MundaneBody
    public let supportDegrees: Double
    public let scanStepDays: Double

    public init?(body: MundaneBody, supportDegrees: Double, scanStepDays: Double) {
        guard supportDegrees.isFinite,
              supportDegrees > 0,
              supportDegrees <= 360,
              scanStepDays.isFinite,
              scanStepDays > 0 else { return nil }
        self.body = body
        self.supportDegrees = supportDegrees
        self.scanStepDays = scanStepDays
    }
}

/// One exact astronomical fence the Forge must prove before manufacture begins.
public struct SpineSchematicBoundaryCheck: Hashable, Sendable {
    public let body: MundaneBody
    public let physicalDegrees: Double
    public let motion: Motion
    public let julianDay: JulianDay
    public let toleranceDegrees: Double

    public init?(
        body: MundaneBody,
        physicalDegrees: Double,
        motion: Motion,
        julianDay: JulianDay,
        toleranceDegrees: Double
    ) {
        guard physicalDegrees.isFinite,
              physicalDegrees >= 0,
              physicalDegrees < 360,
              toleranceDegrees.isFinite,
              toleranceDegrees > 0 else { return nil }
        self.body = body
        self.physicalDegrees = physicalDegrees
        self.motion = motion
        self.julianDay = julianDay
        self.toleranceDegrees = toleranceDegrees
    }
}

/// Hephaestus's recipient-native instructions for celestial Spine manufacture.
/// Hermes may carry this value later; the Forge only reads the instructions it owns here.
public struct SpineSchematic: Hashable, Sendable {
    public let identity: String
    public let version: UInt16
    public let bone: OrboSpineBoneSpan
    public let astronomicalAuthority: String
    public let astronomicalSourceVersion: String
    public let bodyPlans: [SpineSchematicBodyPlan]
    public let boundaryChecks: [SpineSchematicBoundaryCheck]

    public init?(
        identity: String,
        version: UInt16,
        bone: OrboSpineBoneSpan,
        astronomicalAuthority: String,
        astronomicalSourceVersion: String,
        bodyPlans: [SpineSchematicBodyPlan],
        boundaryChecks: [SpineSchematicBoundaryCheck] = []
    ) {
        let trimmedIdentity = identity.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAuthority = astronomicalAuthority.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedVersion = astronomicalSourceVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        let bodies = bodyPlans.map(\.body)

        guard !trimmedIdentity.isEmpty,
              version > 0,
              !trimmedAuthority.isEmpty,
              !trimmedVersion.isEmpty,
              !bodyPlans.isEmpty,
              Set(bodies).count == bodies.count,
              boundaryChecks.allSatisfy({
                  $0.julianDay.value >= bone.start.value - 1e-12
                      && $0.julianDay.value <= bone.end.value + 1e-12
              }) else { return nil }

        self.identity = trimmedIdentity
        self.version = version
        self.bone = bone
        self.astronomicalAuthority = trimmedAuthority
        self.astronomicalSourceVersion = trimmedVersion
        self.bodyPlans = bodyPlans
        self.boundaryChecks = boundaryChecks
    }

    public func bodyPlan(for body: MundaneBody) -> SpineSchematicBodyPlan? {
        bodyPlans.first { $0.body == body }
    }

    /// Durable manufacture may forge one tract at a time without changing the parent schematic.
    public func bodySchematic(for body: MundaneBody) -> SpineSchematic? {
        guard let bodyPlan = bodyPlan(for: body) else { return nil }
        return SpineSchematic(
            identity: identity,
            version: version,
            bone: bone,
            astronomicalAuthority: astronomicalAuthority,
            astronomicalSourceVersion: astronomicalSourceVersion,
            bodyPlans: [bodyPlan],
            boundaryChecks: boundaryChecks
        )
    }
}
