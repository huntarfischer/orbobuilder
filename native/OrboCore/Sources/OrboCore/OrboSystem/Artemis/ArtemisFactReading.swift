/// The first transcribed Lunar Pane course: FACT. Its chart comes through the
/// Apollo/Artemis handoff; the renderer receives no independent subject or house frame.
public struct ArtemisFactReading: Hashable, Sendable {
    public let chart: AstrolabeChart
    public let selectedGene: AstroDNAGene?

    internal init(chart: AstrolabeChart, selectedGene: AstroDNAGene?) {
        self.chart = chart
        self.selectedGene = selectedGene
    }

    public var rows: [AstrolabePlacement] {
        if let selectedGene { return chart.placements.filter { $0.gene == selectedGene } }
        let order: [AstroDNAGene] = [.sun, .moon, .mercury, .venus, .mars, .jupiter,
            .saturn, .uranus, .neptune, .pluto, .northNode, .ascendant]
        return order.compactMap { chart.placement($0) }
    }

    public var subject: AstrolabeSubjectIdentity { chart.subject }
}
