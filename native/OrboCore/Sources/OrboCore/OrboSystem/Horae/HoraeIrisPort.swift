/// Standard outward Iris port from Horae.
///
/// Horae remains owner of the resolved output. The port carries that exact
/// snapshot outward without interpretation, presentation, or control authority.
public extension Horae {
    static func signalForIris(
        _ output: HoraeOutput
    ) -> IrisPort<HoraeOutput> {
        IrisPort(signal: output)
    }
}
