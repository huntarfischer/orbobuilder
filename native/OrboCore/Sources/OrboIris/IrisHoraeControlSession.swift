import OrboCore

/// Iris presentation state for the first Horae-backed temporal controls.
///
/// Iris remembers only the currently displayed Horae frame and an optional
/// presentation focus. Every temporal or body-address change is expressed as a
/// HoraeControlIntent and resolved by Horae before Iris accepts the new frame.
/// Iris owns no clock, ephemeris, interpolation, or Locate access.
public struct IrisHoraeControlSession: Hashable, Sendable {
    public private(set) var frame: IrisHoraeFrame
    public private(set) var focusedBody: MundaneBody?
    public let domain: HoraeControlDomain

    public init(
        horae: Horae,
        initialJulianDay: JulianDay
    ) throws {
        self.domain = horae.controlDomain
        self.frame = IrisHoraeFrame(
            port: Horae.signalForIris(try horae.respond(to: .seekUT(to: initialJulianDay)))
        )
        self.focusedBody = nil
    }

    public var plane: IrisHoraePlane {
        IrisHoraePlane(frame: frame)
    }

    /// Absolute temporal address. Horae resolve the requested UT and return the
    /// complete celestial + Terra state before Iris changes what it displays.
    public mutating func seek(
        to julianDay: JulianDay,
        through horae: Horae
    ) throws {
        let output = try horae.respond(to: .seekUT(to: julianDay))
        frame = IrisHoraeFrame(port: Horae.signalForIris(output))
    }

    /// Relative temporal displacement from the exact Horae-resolved UT currently
    /// displayed by Iris. The offset remains presentation-neutral.
    public mutating func shift(
        by offset: HoraeUTOffset,
        through horae: Horae
    ) throws {
        let output = try horae.respond(
            to: .shiftUT(from: frame.julianDay, by: offset)
        )
        frame = IrisHoraeFrame(port: Horae.signalForIris(output))
    }

    /// Presentation focus on one body at the current Horae plane.
    ///
    /// The focus itself belongs to Iris, but selecting it still travels through
    /// Horae's body-control path so the focused address is lawful at the exact UT.
    public mutating func focus(
        on body: MundaneBody,
        through horae: Horae
    ) throws {
        let output = try horae.respond(
            to: .driveBody(to: body, at: frame.julianDay)
        )
        frame = IrisHoraeFrame(port: Horae.signalForIris(output))
        focusedBody = body
    }
}
