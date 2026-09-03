import OrboCore

/// Commands travel outward separately from the read-only manifestation ports.
public struct IrisAstrolabeControls {
    public var playing = false
    public var horizonFrame = true
    public var aspects = ApolloAspectSettings()
    public var skyContacts: [ApolloContact] = []
    public var natalContacts: [ApolloContact] = []
    public var crossContacts: [ApolloCrossContact] = []
    public var heldBody: AstroDNAGene?
    public var focusedBody: AstroDNAGene?
    public var courses: [LunarCourse] = [.natal, .sky]
    public var selectAlmanacBody: (MundaneBody?) -> Void = { _ in }
    public var togglePlayback: () -> Void = {}
    public var toggleFrame: () -> Void = {}
    public var openTabula: () -> Void = {}
    public var keepHearth: () -> Void = {}
    public var selectCourse: (LunarCourse) -> Void = { _ in }
    public var seek: (JulianDay) -> Void = { _ in }
    public var beginScrub: (AstroDNAGene, Double, Double) -> Void = { _, _, _ in }
    public var moveScrub: (Double, Double) -> Void = { _, _ in }
    public var endScrub: () -> Void = {}
    public init() {}
}
