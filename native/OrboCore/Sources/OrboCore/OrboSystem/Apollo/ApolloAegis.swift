/// A placement on Apollo's instrument. Natal values are read from Hestia's
/// sealed Tapestry; sky values are read from one Horae cross-section.
public struct AstrolabePlacement: Hashable, Sendable {
    public let gene: AstroDNAGene
    public let longitude: CelestialLongitude
    public let motion: Motion
    public let house: House?
    public let condition: Mater.QualifiedTemper?
}

public struct AstrolabeHouse: Hashable, Sendable {
    public let sign: Sign
    public let house: House
}

public struct AstrolabeChart: Hashable, Sendable {
    public enum Kind: String, Hashable, Sendable { case sky, natal }
    public let subject: AstrolabeSubjectIdentity
    public let kind: Kind
    public let name: String
    public let julianDay: JulianDay
    public let place: Topos?
    public let sect: Sect?
    public let placements: [AstrolabePlacement]
    public let houses: [AstrolabeHouse]

    public func placement(_ gene: AstroDNAGene) -> AstrolabePlacement? {
        placements.first { $0.gene == gene }
    }
}

/// The two seats of the first native Aegis. The source cross-section is retained
/// unchanged, so the Big Three and wheel cannot quietly display different skies.
public struct ApolloAegis: Hashable, Sendable {
    public let source: HoraeOutput
    public let sky: AstrolabeChart
    public let natal: AstrolabeChart?
    /// Ring's directed Sun-to-Moon separation, used to draw the prototype's phase disc.
    public let lunarSeparation: RingSeparation
}

public enum ApolloAegisFailure: Error, Equatable {
    case incompleteSky
    case incompleteEngraving
    case missingPlacement(AstroDNAGene)
}

public extension Apollo {
    static func establishAegis(
        at julianDay: JulianDay, using horae: Horae,
        hestia: Hestia?, atPlace place: Topos?
    ) throws -> ApolloAegis {
        try establishAegis(from: askHorae(at: julianDay, using: horae), hestia: hestia, atPlace: place)
    }

    static func establishAegis(
        from output: HoraeOutput, hestia: Hestia?, atPlace place: Topos?
    ) throws -> ApolloAegis {
        try establishAegis(from: output, natal: hestia.flatMap { try nativeChart(from: $0) }, atPlace: place)
    }

    /// A new sky crosses the same kept Plate. Re-establish with Hestia only when
    /// the engraving changes; ordinary live updates do not unpack it again.
    static func advanceAegis(_ aegis: ApolloAegis, from output: HoraeOutput) throws -> ApolloAegis {
        try establishAegis(from: output, natal: aegis.natal, atPlace: aegis.sky.place)
    }

    private static func establishAegis(
        from output: HoraeOutput, natal: AstrolabeChart?, atPlace place: Topos?
    ) throws -> ApolloAegis {
        guard output.celestial.count == MundaneBody.canonicalOrder.count,
              Set(output.celestial.map(\.body)) == Set(MundaneBody.canonicalOrder),
              output.celestial.allSatisfy({ $0.julianDay == output.julianDay }),
              output.terra.julianDay == output.julianDay else {
            throw ApolloAegisFailure.incompleteSky
        }
        let coordinates = Dictionary(uniqueKeysWithValues: output.celestial.map { ($0.body, $0) })
        let longitudes = Dictionary(uniqueKeysWithValues: output.celestial.compactMap { coordinate -> (Planet, CelestialLongitude)? in
            guard let planet = coordinate.body.planet else { return nil }
            return (planet, CelestialLongitude(coordinate.directionalDegree.physicalDegrees)!)
        })
        let ascendant = try place.map { try Hecate.castAscendant(terra: output.terra, topos: $0) }
        let ascLongitude = ascendant.map { CelestialLongitude(Double($0.arcsecond) / 3600)! }
        let sect = try ascLongitude.map { try Hecate.castSect(ascendant: $0, sun: longitudes[.sun]!) }
        let condition = Rhea.bear(longitudes, sect: sect)
        let houses = ascLongitude.map { Themis.set($0.sign).houses }
        var placements: [AstrolabePlacement] = []
        for gene in AstroDNAGene.canonicalOrder {
            let longitude: CelestialLongitude
            let motion: Motion
            if gene == .ascendant {
                guard let ascLongitude else { continue }
                longitude = ascLongitude
                motion = .direct
            } else {
                let body = MundaneBody.canonicalOrder.first {
                    $0 == .trueNorthNode ? gene == .northNode : $0.displayName == gene.rawValue
                }!
                let coordinate = coordinates[body]!
                longitude = CelestialLongitude(coordinate.directionalDegree.physicalDegrees)!
                motion = coordinate.directionalDegree.motion
            }
            let planet = Planet(rawValue: gene.rawValue)
            placements.append(AstrolabePlacement(
                gene: gene, longitude: longitude, motion: motion,
                house: houses?.first { $0.sign == longitude.sign }?.house,
                condition: planet.map { condition.temper(for: $0) }
            ))
        }
        let sky = AstrolabeChart(subject: placeOnAstrolabe(identity: "sky"), kind: .sky,
            name: "The sky", julianDay: output.julianDay, place: place, sect: sect, placements: placements,
            houses: houses?.map { AstrolabeHouse(sign: $0.sign, house: $0.house) } ?? [])
        return ApolloAegis(source: output, sky: sky, natal: natal,
            lunarSeparation: Oceanus.separation(from: longitudes[.sun]!, to: longitudes[.moon]!))
    }

    private static func nativeChart(from hestia: Hestia) throws -> AstrolabeChart? {
        guard hestia.hearthLit else { return nil }
        guard let engraving = hestia.nativeEngraving(), let tempus = engraving.tempus,
              let package = hestia.canonicalTapestry(for: engraving.subjectID),
              let place = engraving.topos, let sect = engraving.sect else {
            throw ApolloAegisFailure.incompleteEngraving
        }
        let degrees = package.tapestry.degrees
        var placements: [AstrolabePlacement] = []
        for gene in AstroDNAGene.canonicalOrder {
            var found: AstrolabePlacement?
            for degree in degrees {
                for value in degree.placement.values {
                    guard case let .astroDNA(candidate, state) = value, candidate == gene else { continue }
                    found = AstrolabePlacement(gene: gene,
                        longitude: CelestialLongitude(Double(state.arcsecond) / 3600)!, motion: state.motion,
                        house: degree.tympan.house,
                        condition: degree.mater.conditions.first { $0.planet.rawValue == gene.rawValue })
                }
            }
            guard let found else { throw ApolloAegisFailure.missingPlacement(gene) }
            placements.append(found)
        }
        return AstrolabeChart(subject: placeOnAstrolabe(identity: engraving.subjectID.rawValue), kind: .natal,
            name: engraving.name, julianDay: tempus.absoluteInstant.julianDay,
            place: place, sect: sect, placements: placements,
            houses: Sign.canonicalOrder.compactMap { sign in
                degrees[sign.rawValue * 30].tympan.house.map { AstrolabeHouse(sign: sign, house: $0) }
            })
    }
}
