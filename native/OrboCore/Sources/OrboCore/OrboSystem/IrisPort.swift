/// Orbo's universal one-way socket to Iris.
///
/// The cable carries a snapshot, not a leash. The source entity owns the
/// signal, Iris owns its manifestation, and the port performs no domain or
/// presentation work.
public struct IrisPort<Signal: Hashable & Sendable>: Hashable, Sendable {
    public let signal: Signal

    public init(signal: Signal) {
        self.signal = signal
    }
}
