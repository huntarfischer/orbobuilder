/// Horae's standard one-way socket to Homer.
///
/// The supplied output is already Horae-resolved truth. This seam does not seek,
/// respond to controls, resolve chronology, or add presentation matter.
public extension Horae {
    static func signalForHomer(
        _ output: HoraeOutput
    ) -> HomerPort<HoraeOutput> {
        HomerPort(pointOfView: output)
    }
}
