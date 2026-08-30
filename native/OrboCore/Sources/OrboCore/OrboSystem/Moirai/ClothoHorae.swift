/// Production Door I seam from Clotho to Horae.
///
/// Clotho supplies one resolved Tempus. Horae asks Locate for that exact UT and
/// returns the canonical Timespine cross-section unchanged. No second time,
/// fallback sky, or wider OrboSpine runtime is introduced here.
extension Horae: ClothoPortI {
    public mutating func queryNatalSlice(at tempus: Tempus) throws -> HoraeOutput {
        try seek(to: tempus.absoluteInstant.julianDay)
    }
}
