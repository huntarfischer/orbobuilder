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
    private let spinePorts = OrboSpinePorts()
    private let sampleDirectDegree = OrboSpineDirectionalDegree(19.372)!
    private let sampleRetrogradeDegree = OrboSpineDirectionalDegree(physicalDegrees: 19.372, motion: .retrograde)!
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

    private var imprint: Tympan.Imprint {
        Tympan.imprint(for: .scorpio)
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

    private var shellAddressLaw: String {
        OrboSpineShellFamily.allCases.map(\.rawValue).joined(separator: ".")
    }

    private var auxiliaryPackOneText: String {
        OrboSpineCelestialSmeldIntent.firstSmeld
            .map(auxiliaryFactorName)
            .joined(separator: " + ")
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 18) {
                Text("ORBO LAB")
                    .font(.title2.monospaced().weight(.semibold))

                Text("FOUNDATION CONTRACTS / COMPONENT EXAMPLES")
                    .font(.caption.monospaced())

                Divider()

                sectionTitle("ORBOSPINE")
                readout("identity", OrboSpineContract.identity)
                readout("class", "Mundane Timespine")
                readout("build state", "sealed source connected in Orbo")
                readout("native proof", "OrboCoreTests")
                readout("live runtime", "Orbo / Astrolabe and Inspect tabs")
                readout("celestial core", "\(OrboSpineContract.canonicalBodies.count) canonical tracts")
                readout("coordinate", "continuous directional degree [0,720)")
                readout("direct lane", "[0,360) increasing")
                readout("retro lane", "[360,720) decreasing")
                readout("navigation", "720 whole-degree cells")
                readout(
                    "direct sample",
                    String(format: "19.372 -> %.3f / cell %d", sampleDirectDegree.degrees, sampleDirectDegree.navigationCell)
                )
                readout(
                    "retro sample",
                    String(format: "19.372 -> %.3f / cell %d", sampleRetrogradeDegree.degrees, sampleRetrogradeDegree.navigationCell)
                )
                readout("South Node", "derived +180 degrees / not an independent tract")
                readout("native place", "absent")

                Divider()

                sectionTitle("CELESTIAL TRACTS")
                ForEach(OrboSpineContract.canonicalBodies, id: \.self) { body in
                    readout(
                        body.displayName,
                        "support \(supportDegreeText(OrboSpineContract.supportDegrees(for: body)))"
                    )
                }
                readout("source", "sealed files loaded by Orbo")

                Divider()

                sectionTitle("TERRA MARROW")
                readout("identity", "Earth reference-frame marrow")
                readout("coordinate", "turn + tilt + UT")
                readout("turn", "Greenwich sidereal orientation / ARMC")
                readout("tilt", "true ecliptic obliquity")
                readout("support", "\(TerraMarrowContract.supportIntervalSeconds / 3_600) hours")
                readout("refinement", TerraMarrowContract.refinementLaw.rawValue)
                readout(
                    "source seams",
                    TerraMarrowContract.sourceModelSeamYears.map(String.init).joined(separator: " / ")
                )
                readout("place", "none")
                readout("source", "sealed files loaded by Orbo")

                Divider()

                sectionTitle("TEMPORAL SHELLS")
                readout("Frame", "Saturn / F")
                readout("Revolt", "Uranus / R")
                readout("Wave", "Neptune / W")
                readout("Zeitgeist", "Pluto / Z")
                readout("address", shellAddressLaw)
                readout("ownership", "independent half-open intervals")
                readout("substrate", "A.5 imported / canonical tables present")
                readout("Chronos", "Library chronology + Horae occurrences")
                readout("OrboSpine image", "existing sealed Z21–Z23 files")

                Divider()

                sectionTitle("AUXILIARY SOCKET")
                readout("state", "empty")
                readout("core broadened", "no")
                readout("intended pack 1", auxiliaryPackOneText)
                readout("Ring membership", "separate policy / not automatic")
                readout("manufacture", "not part of Pass 5 C")

                Divider()

                sectionTitle("ORBOSPINE PORTS")
                readout("Door I", spinePorts.locate.rawValue + " → Horae")
                readout("Door II", spinePorts.library.rawValue + " → Chronos")
                readout("Door III", spinePorts.link.rawValue + " → Hecate")

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
                readout("rising", signName(imprint.risingSign))
                readout(
                    "Mars governs",
                    houseList(Tympan.housesRuled(by: .mars, rising: imprint.risingSign))
                )

                ForEach(imprint.houses, id: \.house) { record in
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
                readout("Timespine codec", "none / AstroDNA codec remains isolated")

                Divider()

                sectionTitle("SPINE LIFECYCLE")
                readout("forge", SpineSmeldContract.forgeAuthority)
                readout("certification", SpineSmeldContract.certificationAuthority)
                readout("seal", SpineSmeldContract.sealAuthority)
                readout("seal before mounting", SpineSmeldContract.requiresSealBeforeMount ? "required" : "not required")
                readout("replacement", SpineSmeldContract.replacementLaw)
                readout("lifecycle", OrboSpineLifecycleBoundary.allCases.map(\.rawValue).joined(separator: " → "))

                Divider()

                Text("Component examples from live OrboCore contracts. Use Orbo’s Sky and Inspect tabs for the mounted Spine and the Birth tab for a real birth-to-Hearth journey. Tests remain the proof authority.")
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

    private func supportDegreeText(_ degrees: Double) -> String {
        if degrees == degrees.rounded() {
            return String(format: "%.0f°", degrees)
        }
        return String(format: "%.1f°", degrees)
    }

    private func auxiliaryFactorName(_ factor: OrboSpineAuxiliaryFactorID) -> String {
        if factor == .trueBlackMoonLilith { return "True Black Moon Lilith" }
        if factor == .chiron { return "Chiron" }
        return factor.rawValue
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
