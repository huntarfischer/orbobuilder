/// Hecate's standard one-way socket to Homer.
///
/// The supplied inquiry is already Hecate-authored truth. This seam does not
/// choose a key, perform an inquiry, cast, interpret, or add presentation matter.
public extension Hecate {
    static func signalForHomer(
        _ inquiry: HecateKleisInquiry
    ) -> HomerPort<HecateKleisInquiry> {
        HomerPort(pointOfView: inquiry)
    }
}
