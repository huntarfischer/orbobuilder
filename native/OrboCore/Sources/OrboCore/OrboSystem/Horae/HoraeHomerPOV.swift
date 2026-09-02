/// The page Horae gives Homer when Homer enters Horae as a point of view.
///
/// `output` remains the exact existing Horae signal so tests can prove the page
/// was authored from real Horae truth. The Iris port contains only Homer's two
/// Pass A outward forms: text and selections.
public struct HoraeHomerPOVPage: Hashable, Sendable {
    public let output: HoraeOutput
    public let irisPort: HomerIrisPort

    public init(output: HoraeOutput, irisPort: HomerIrisPort) {
        self.output = output
        self.irisPort = irisPort
    }
}

extension Horae {
    /// Horae's own Homer-facing menu.
    ///
    /// Horae resolve the real cross-section, describe it, and own the menu Homer
    /// is allowed to show while attached. HOMER is deliberately the final option.
    public func homerPOV(at julianDay: JulianDay) throws -> HoraeHomerPOVPage {
        let output = try seek(to: julianDay)
        let text = [
            "HORAE",
            "UT · JD \(output.julianDay.value)",
            "\(output.celestial.count) bodies · Terra present",
        ].joined(separator: "\n")

        return HoraeHomerPOVPage(
            output: output,
            irisPort: HomerIrisPort(
                text: text,
                selections: [.homer]
            )
        )
    }
}
