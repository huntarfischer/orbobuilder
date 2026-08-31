public extension Lachesis {
    /// Conducts the Natal Spine Titan pass against one native and one Clotho life domain.
    /// The three tables remain separate. Rhea receives the temporal facts already
    /// established by Themis and Oceanus rather than performing another time sweep.
    static func petitionNatalSpine<Port: NatalSpineTimespinePort>(
        native truth: NatalSpineNativeTruth,
        bounds: NatalSpineBounds,
        through port: Port
    ) throws -> (
        themis: NatalSpineThemisTable,
        oceanus: NatalSpineOceanusTable,
        rhea: NatalSpineRheaTable
    ) {
        let themis = try Themis.traceNatalSpine(
            native: truth,
            bounds: bounds,
            through: port
        )
        let oceanus = try Oceanus.traceNatalSpine(
            native: truth,
            bounds: bounds,
            through: port
        )
        let rhea = try Rhea.qualifyNatalSpine(
            native: truth,
            bounds: bounds,
            themis: themis,
            oceanus: oceanus,
            through: port
        )
        return (themis, oceanus, rhea)
    }
}
