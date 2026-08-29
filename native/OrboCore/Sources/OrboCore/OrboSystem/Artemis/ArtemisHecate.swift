/// Pass B direct seam from Artemis to Hecate.
///
/// Artemis asks Hecate what she knows about one exact admitted key. She does not
/// reach into Kleides or a catalogue, cast a spell, or manufacture an answer.
public extension Artemis {
    static func askHecate(
        _ kleisID: KleisID
    ) -> HecateKleisInquiry? {
        Hecate.inquire(kleisID)
    }
}
