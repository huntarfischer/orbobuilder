/// Castor is the civic resonator. He receives only body + UT and independently reads
/// the assembled OrboSpine runtime. He never receives Pollux's expected celestial answer.
public enum CastorResonator {
    public static func answer(
        body: MundaneBody,
        at julianDay: JulianDay,
        from candidate: OrboSpineRuntime
    ) throws -> OrboSpineCelestialCoordinate {
        try candidate.locate.coordinate(of: body, at: julianDay)
    }
}
