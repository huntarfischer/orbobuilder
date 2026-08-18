import Foundation
import SwiftUI
import OrboCore

@main
struct OrboLabApp: App {
    var body: some Scene {
        WindowGroup {
            FoundationLabView()
        }
    }
}

private struct FoundationLabView: View {
    private let bodyLongitude = CelestialLongitude(70)!
    private let ascendantLongitude = CelestialLongitude(220)!
    private let civilDate = CivilDate(year: 1985, month: 4, day: 10)!
    private let civilClock = CivilClockTime(hour: 20, minute: 16)!
    private let labAstroDNA = AstroDNA(rawSequence: [
        40_123,
        997_654,
        1_008_000,
        1_584_123,
        244_444,
        1_987_200,
        432_000,
        1_407_111,
        1_200_000,
        1_297_000,
        3_599,
        2_096_000,
    ])!

    private var condition: EssentialCondition {
        Mater.essentialCondition(
            of: .mars,
            at: bodyLongitude,
            sect: .day
        )!
    }

    private var frame: Tympan.Frame {
        Tympan.frame(for: .scorpio)
    }

    private var ringRelation: RingMark? {
        let bodyState = Ring.state(of: bodyLongitude, motion: .direct)
        let ascendantState = Ring.state(of: ascendantLongitude, motion: .retrograde)
        return Ring.relation(between: bodyState, and: ascendantState)
    }

    private var labPlaceResolution: GeoplacementResolution {
        GeoplacementAtlas.resolve("Madison, WI, USA")
    }

    private var labCivilResolution: CivilTimeResolution? {
        guard case let .found(place) = labPlaceResolution else { return nil }
        return CivilTime.resolve(
            date: civilDate,
            time: civilClock,
            in: place.timezone
        )
    }

    private var eclipseContract: MundaneTimespineUniversalEventContract {
        MundaneTimespineP22.universalEventTable(for: .eclipse)
    }

    private var majorRelationshipContract: MundaneTimespineUniversalEventContract {
        MundaneTimespineP22.universalEventTable(for: .exactMajorRelationships)
    }

    private var minorRelationshipContract: MundaneTimespineUniversalEventContract {
        MundaneTimespineP22.universalEventTable(for: .exactMinorRelationships)
    }

    private var admittedRingMarkCount: Int {
        Set(
            MundaneTimespineP22.majorRelationshipMarks
            + MundaneTimespineP22.minorRelationshipMarks
        ).count
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 18) {
                Text("ORBO LAB")
                    .font(.title2.monospaced().weight(.semibold))

                Text("PHASE 1b / OVUM CONSTRUCTION")
                    .font(.caption.monospaced())

                Divider()

                sectionTitle("RING")
                readout("states", "\(Ring.states)")
                readout("fine states", "\(Ring.fineStates)")
                readout("marks", "\(Ring.marks.count)")
                readout("sample", "70 -> 220")
                readout("relation", ringRelation.map(ringMarkName) ?? "none")

                Divider()

                sectionTitle("MATER")
                readout("planet", condition.planet.rawValue)
                readout("longitude", "\(condition.longitude.degrees)")
                readout("sign", signName(condition.longitude.sign))
                readout("element", Mater.element(of: condition.longitude.sign).rawValue)
                readout("modality", Mater.modality(of: condition.longitude.sign).rawValue)
                readout("domicile ruler", Mater.domicileRuler(of: condition.longitude.sign).rawValue)
                readout("dignities", dignityText)
                readout("debilities", debilityText)
                readout("bound ruler", condition.bound.ruler.rawValue)
                readout("face ruler", condition.face.ruler.rawValue)
                readout("peregrine", condition.isPeregrine ? "yes" : "no")

                Divider()

                sectionTitle("TYMPAN")
                readout("rising", signName(frame.risingSign))
                readout(
                    "Mars governs",
                    houseList(Tympan.housesRuled(by: .mars, rising: frame.risingSign))
                )

                ForEach(frame.houses, id: \.house) { record in
                    let coRuler = record.coRuler.map { " / co-ruler \($0.rawValue)" } ?? ""
                    readout(
                        "house \(record.house.rawValue)",
                        "\(signName(record.sign)) / \(record.ruler.rawValue)\(coRuler)"
                    )
                }

                Divider()

                sectionTitle("GEOPLACEMENT")
                readout("atlas version", GeoplacementAtlas.version)
                readout("records", "\(GeoplacementAtlas.count)")
                readout("query", "Madison, WI, USA")

                switch labPlaceResolution {
                case let .found(place):
                    readout("resolution", "found")
                    readout("place", place.canonicalName)
                    readout("latitude", "\(place.latitude.degrees)")
                    readout("longitude", "\(place.longitude.degrees)")
                    readout("timezone", place.timezone.rawValue)
                case let .ambiguous(places):
                    readout("resolution", "ambiguous / \(places.count) matches")
                case .notFound:
                    readout("resolution", "not found")
                }

                Divider()

                sectionTitle("CIVIL TIME")
                readout("local date", "1985-04-10")
                readout("local clock", "20:16:00")
                readout("tzdb version", CivilTime.timeZoneDataVersion)
                readout("year range", "\(CivilTime.supportedYearRange.lowerBound)-\(CivilTime.supportedYearRange.upperBound)")

                if let labCivilResolution {
                    switch labCivilResolution {
                    case let .resolved(match):
                        readout("resolution", "resolved")
                        readout("timezone", match.timezone?.rawValue ?? "none")
                        readout("UTC offset", match.offset.clockDescription)
                        readout("source", match.source.rawValue)
                        readout("Julian Day", String(format: "%.8f", match.instant.julianDay.value))
                    case let .ambiguous(first, second):
                        readout("resolution", "ambiguous")
                        readout("first offset", first.offset.clockDescription)
                        readout("second offset", second.offset.clockDescription)
                    case .nonexistent:
                        readout("resolution", "nonexistent")
                    case let .unknownTimeZone(zone):
                        readout("resolution", "unknown timezone")
                        readout("timezone", zone.rawValue)
                    case let .unsupportedYear(year):
                        readout("resolution", "unsupported year \(year)")
                    case let .unsupportedCalendar(calendar):
                        readout("resolution", "unsupported calendar \(calendar.rawValue)")
                    }
                } else {
                    readout("resolution", "place unresolved")
                }

                Divider()

                sectionTitle("ASTRODNA CONTRACT")
                readout("codec", "\(AstroDNA.codec)")
                readout("genes", "\(AstroDNA.geneCount)")
                readout("identity", "12 x RingFineState")
                readout(
                    "gene order",
                    AstroDNAGene.canonicalOrder.map(\.displayName).joined(separator: " · ")
                )
                readout("Asc fine state", "\(labAstroDNA[.ascendant].rawValue)")
                readout("Asc longitude", String(format: "%.6f", labAstroDNA.longitude(of: .ascendant).degrees))
                readout("Node source", "true / osculating north node")
                readout("Node motion", labAstroDNA.motion(of: .northNode).rawValue)
                readout("South Node", String(format: "%.6f", labAstroDNA.southNodeLongitude.degrees))
                readout("degree projection", labAstroDNA.degreeSequenceString)

                Divider()

                sectionTitle("FORGE")
                readout("role", "generic apparatus")
                readout("owner", "MundaneTimespineForge")
                readout("language", "native Swift")
                readout("deep source", "Ephemeris -> Forge only")
                readout("P22 recipe", "MundaneTimespineP22ForgeRecipe")
                readout("P22 boundary", "direct Pluto 0 Aries -> direct Pluto 0 Aries")
                readout("law", "celestial occurrence <-> civic UT")
                readout("runtime oracle", "no")

                Divider()

                sectionTitle("HEPHAESTUS")
                readout("role", "Timespine manufacturer")
                readout("owner", "OrboCore / Hephaestus")
                readout("Forge", "generic apparatus")
                readout("recipe contract", "native Swift")
                readout("candidate", "immutable ORBOTS artifact")
                readout("identity", Hephaestus.candidateIdentityAlgorithm)
                readout("artifact family", MundaneTimespineStorageFormat.identifier)
                readout("storage version", "\(MundaneTimespineStorageFormat.version)")
                readout("law", Hephaestus.celestialTimeFirst ? "celestial-time-first" : "INVALID")
                readout("mutation", "new bytes -> new identity")
                readout("runtime role", Hephaestus.runtimeRole)
                readout("P22 recipe", MundaneTimespineP22ForgeRecipe.recipeIdentifier)
                readout("P22 recipe ver", "\(MundaneTimespineP22ForgeRecipe.recipeVersion)")
                readout("P22 candidate", "awaiting full assembly")
                readout("Dioscuri", "not built yet")

                Divider()

                sectionTitle("MUNDANE TIMESPINE / P22")
                readout("status", "Pass 5 native assembly")
                readout("span", MundaneTimespineP22.spanName)
                readout("start", MundaneTimespineP22.startUTC)
                readout("end exclusive", MundaneTimespineP22.endUTC)
                readout("bodies", "\(MundaneTimespineP22.profiles.count)")
                readout("body records", "\(MundaneTimespineP22.totalConstructionRecords)")
                readout("civic offset", "\(MundaneTimespineP22.civicOffsetBitsRequired) bits from P22 start")
                readout("motion tables", "stations · retrograde passages · retrograde crossings")
                readout("Node", "True North Node / direct-retrograde user terminology")

                ForEach(MundaneTimespineP22.profiles, id: \.body) { profile in
                    let resolution = profile.celestialResolutionDegrees == 1
                        ? "1°"
                        : String(format: "%.1f°", profile.celestialResolutionDegrees)
                    let markers = profile.markerBodies.map(\.displayName).joined(separator: " + ")
                    readout(
                        profile.body.displayName,
                        "\(resolution) · \(profile.constructionRecordCount) · markers \(markers)"
                    )
                }

                Divider()

                sectionTitle("UNIVERSAL CELESTIAL EVENTS / P22")
                readout("law", MundaneTimespineP22.universalEventsAreCelestialTimeFirst ? "celestial-time-first" : "INVALID")
                readout("eclipses", "\(eclipseContract.constructionRecordCount)")
                readout("exact major", "\(majorRelationshipContract.constructionRecordCount)")
                readout("exact minor", "\(minorRelationshipContract.constructionRecordCount)")
                readout("all events", "\(MundaneTimespineP22.totalUniversalEventRecords)")
                readout("Ring coverage", "\(admittedRingMarkCount) / \(RingMark.allCases.count) marks")
                readout("orb stored", "none / exact relationships only")
                readout("major gzip", byteCount(majorRelationshipContract.compressedBytes))
                readout("minor gzip", byteCount(minorRelationshipContract.compressedBytes))
                readout("eclipse gzip", byteCount(eclipseContract.compressedBytes))

                Divider()

                sectionTitle("TIMESPINE STORAGE / READER")
                readout("artifact family", MundaneTimespineStorageFormat.identifier)
                readout("storage version", "\(MundaneTimespineStorageFormat.version)")
                readout("storage law", MundaneTimespineStorageFormat.celestialTimeFirst ? "celestial-time-first" : "INVALID")
                readout("exact degrees", "integer microdegrees")
                readout("runtime reader", "native / ephemeris-free")
                readout("UT -> celestial", "implemented")
                readout("celestial -> UT", "implemented")
                readout("relationships", "implemented / read-time filters")
                readout("eclipses", "implemented / read-time filters")
                readout("event union", "implemented")
                readout("shipping P22", "not installed yet")
                readout("Dioscuri", "not built yet")
                readout("proof authority", "OrboCoreTests")

                Divider()

                Text("Diagnostic readout of live OrboCore. Tests remain the proof authority.")
                    .font(.caption.monospaced())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .scrollIndicators(.visible)
        .scrollBounceBehavior(.always)
    }

    private var dignityText: String {
        let values = DignityRung.allCases
            .filter { condition.dignities.contains($0) }
            .map(\.rawValue)
        return values.isEmpty ? "none" : values.joined(separator: ", ")
    }

    private var debilityText: String {
        let values = EssentialDebility.allCases
            .filter { condition.debilities.contains($0) }
            .map(\.rawValue)
        return values.isEmpty ? "none" : values.joined(separator: ", ")
    }

    private func houseList(_ houses: [House]) -> String {
        houses.map { String($0.rawValue) }.joined(separator: ", ")
    }

    private func byteCount(_ bytes: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }

    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline.monospaced())
    }

    @ViewBuilder
    private func readout(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)

            Text(value)
                .font(.body.monospaced())
        }
    }

    private func ringMarkName(_ mark: RingMark) -> String {
        switch mark {
        case .conjunction: return "conjunction"
        case .semisextile: return "semisextile"
        case .semisquare: return "semisquare"
        case .sextile: return "sextile"
        case .quintile: return "quintile"
        case .square: return "square"
        case .trine: return "trine"
        case .sesquiquadrate: return "sesquiquadrate"
        case .biquintile: return "biquintile"
        case .quincunx: return "quincunx"
        case .opposition: return "opposition"
        }
    }

    private func signName(_ sign: Sign) -> String {
        switch sign {
        case .aries: return "Aries"
        case .taurus: return "Taurus"
        case .gemini: return "Gemini"
        case .cancer: return "Cancer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Scorpio"
        case .sagittarius: return "Sagittarius"
        case .capricorn: return "Capricorn"
        case .aquarius: return "Aquarius"
        case .pisces: return "Pisces"
        }
    }
}
