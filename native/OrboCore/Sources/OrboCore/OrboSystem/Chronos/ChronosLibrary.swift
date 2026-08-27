/// Stage 3 Chronos seam to prepared OrboSpine Library chronology.
///
/// Chronos supplies query grammar over factual Library matter. The Library owns
/// the prepared rows; Chronos receives only the Port II read surface, never the
/// full OrboSpineRuntime.
public extension Chronos {
    static func resolveStations(
        body: MundaneBody,
        using library: OrboSpineLibraryCatalog
    ) -> ChronosResolution {
        let fact = ChronosFactIdentity.station(body: body)
        let source = ChronosSourceReference(rawValue: "library:stations")!

        return .resolved(
            ChronosAnswer(
                hits: library.stations(for: body).map { station in
                    ChronosHit(
                        address: .moment(station.julianDay),
                        fact: fact,
                        source: source
                    )
                }
            )
        )
    }

    static func resolveShell(
        _ id: OrboSpineShellID,
        using library: OrboSpineLibraryCatalog
    ) -> ChronosResolution {
        let fact = ChronosFactIdentity.shell(id)
        guard let interval = library.shell(id) else {
            return .resolved(ChronosAnswer(hits: []))
        }

        let source = ChronosSourceReference(
            rawValue: "library:\(shelf(for: id.family).rawValue)"
        )!
        let address = ChronosInterval(
            start: interval.start,
            endExclusive: interval.end
        )!

        return .resolved(
            ChronosAnswer(
                hits: [
                    ChronosHit(
                        address: .interval(address),
                        fact: fact,
                        source: source
                    )
                ]
            )
        )
    }

    private static func shelf(
        for family: OrboSpineShellFamily
    ) -> OrboSpineLibraryShelf {
        switch family {
        case .frame:
            return .frame
        case .revolt:
            return .revolt
        case .wave:
            return .wave
        case .zeitgeist:
            return .zeitgeist
        }
    }
}
