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

    private var shellAddressLaw: String {
        OrboSpineShellFamily.allCases.map(\.rawValue).joined(separator: ".")
    }

    private var auxiliaryPackOneText: String {
        OrboSpineAuxiliaryIntent.firstPack
            .map(auxiliaryFactorName)
            .joined(separator: " + ")
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 18) {
                Text("ORBO LAB")
                    .font(.title2.monospaced().weight(.semibold))

                Text("MUNDANE TIMESPINE / PASS B NATIVE PROVEN")
                    .font(.caption.monospaced())

                Divider()

                sectionTitle("ORBOSPINE")
                readout("identity", OrboSpineContract.identity)
                readout("class", "Mundane Timespine")
                readout("build state", "A + A.5 + B complete")
                readout("native proof", "10 / 10 OrboSpine contract tests")
                readout("next", "Pass C / canonical manufacture")
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
                readout("manufacture", "pending Pass C")

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
                readout("manufacture", "pending Pass C")

                Divider()

                sectionTitle("TEMPORAL SHELLS")
                readout("Frame", "Saturn / F")
                readout("Revolt", "Uranus / R")
                readout("Wave", "Neptune / W")
                readout("Zeitgeist", "Pluto / Z")
                readout("address", shellAddressLaw)
                readout("ownership", "independent half-open intervals")
                readout("substrate", "A.5 imported / canonical tables present")
                readout("Chronos", "future navigator / not truth owner")
                readout("OrboSpine image", "not manufactured yet")

                Divider()

                sectionTitle("AUXILIARY SOCKET")
                readout("state", "empty")
                readout("core broadened", "no")
                readout("intended pack 1", auxiliaryPackOneText)
                readout("Ring membership", "separate policy / not automatic")
                readout("manufacture", "not part of Pass 5 C")

                Divider()

                sectionTitle("ORBOSPINE PORTS")
                readout("ChronosPort", "\(String(describing: type(of: spinePorts.chronos))) / neutral")
                readout("HoraePort", "\(String(describing: type(of: spinePorts.horae))) / neutral")
                readout("ClothoPort", "\(String(describing: type(of: spinePorts.clotho))) / neutral")
                readout("behavior", "none defined in Pass 5")

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

                sectionTitle("FORGE / APPARATUS")
                readout("role", "generic astronomical apparatus")
                readout("owner", "MundaneTimespineForge")
                readout("language", "native Swift")
                readout("deep source", "Ephemeris -> Forge only")
                readout("Z22 recipe", "canonical Z22 construction recipe")
                readout("law", "celestial occurrence <-> civic UT")
                readout("runtime oracle", "no")

                Divider()

                sectionTitle("HEPHAESTUS / SPINE FORGE")
                readout("role", "Spine forge + final fabrication seal")
                readout("owner", "OrboCore / Hephaestus")
                readout("apparatus", "Forge")
                readout(
                    "lifecycle",
                    OrboSpineLifecycleBoundary.allCases.map(\.rawValue).joined(separator: " -> ")
                )
                readout("candidate", "Hephaestus manufactures")
                readout("certification", "Dioscuri independently resonate")
                readout("final seal", "Hephaestus after certification")
                readout("maintenance", "Dioscuri resonance after seal")
                readout("runtime query", "none")
                readout("make", Hephaestus.fabricationRole)
                readout("identity", Hephaestus.candidateIdentityAlgorithm)
                readout("rehydration", Hephaestus.candidateRehydrationLaw)
                readout("overrule", Hephaestus.overruleRole)
                readout("seal", "deterministic sidecar / \(HephaestusSeal.identityAlgorithm)")
                readout("seal mutation", Hephaestus.sealMutationRole)
                readout("quarantine", Hephaestus.quarantineLaw)
                readout("interpretive", Hephaestus.interpretationRole)
                readout("OrboSpine C", "not begun")
                readout("OrboSpine seal", "not available before Pass G")

                Divider()

                sectionTitle("POLLUX / DIOSCURI I")
                readout("current scope", "existing Z22 machinery")
                readout("OrboSpine stage", "Pass E / not begun")
                readout("role", Pollux.role)
                readout("nature", Pollux.nature)
                readout("order", Pollux.order)
                readout("input", "Hephaestus candidate")
                readout("axis", Pollux.axis)
                readout("identity", Pollux.identityLaw)
                readout("ordering", Pollux.orderingLaw)
                readout("Reader", Pollux.readerRole)
                readout("ephemeris", Pollux.ephemerisRole)
                readout("civic time", Pollux.civicTimeRole)
                readout("ambiguity", Pollux.ambiguityPolicy)
                readout("Castor", "built")
                readout("Dioscuri", "built")

                Divider()

                sectionTitle("CASTOR / DIOSCURI II")
                readout("current scope", "existing Z22 machinery")
                readout("OrboSpine stage", "Pass E / not begun")
                readout("role", Castor.role)
                readout("nature", Castor.nature)
                readout("order", Castor.order)
                readout("input", Castor.inputLaw)
                readout("axis", Castor.axis)
                readout("candidate", "independently verified")
                readout("Reader", Castor.readerRole)
                readout("Forge", Castor.forgeRole)
                readout("ephemeris", Castor.ephemerisRole)
                readout("expectations", Castor.expectationRole)
                readout("answer", Castor.answerLaw)
                readout("comparison", Castor.comparisonRole)
                readout("Pollux", "built")
                readout("Dioscuri", "built")

                Divider()

                sectionTitle("DIOSCURI / RESONANCE")
                readout("current scope", "existing Z22 implementation")
                readout("OrboSpine role", "certification + maintenance resonance")
                readout("OrboSpine stage", "Pass E / not begun")
                readout("role", Dioscuri.authorityRole)
                readout("dialect", Dioscuri.currentDialect)
                readout("contract", "v\(Dioscuri.contractVersion)")
                readout("implementation", "v\(Dioscuri.certificationImplementationVersion)")
                readout("twins", "Pollux + Castor")
                readout("order", Dioscuri.order)
                readout("origin", Dioscuri.origin)
                readout("oracle", Dioscuri.oracleRole)
                readout("Forge", Dioscuri.forgeRole)
                readout("correction", Dioscuri.correctionRole)
                readout("averaging", Dioscuri.averagingRole)
                readout("body", "implemented")
                readout("markers", "implemented")
                readout("motion", "implemented")
                readout("relationships", "implemented")
                readout("eclipses", "implemented")
                readout("execution", Dioscuri.exhaustiveExecutionLaw)
                readout("checkpoint", Dioscuri.checkpointLaw)
                readout("checkpoint validation", Dioscuri.checkpointValidationLaw)
                readout("quantization", Dioscuri.quantizationPolicy)
                readout("second strike", Dioscuri.secondStrikePolicy)
                readout("divergence", Dioscuri.divergencePolicy)
                readout("verdict target", Dioscuri.verdictTarget)
                readout("seal authority", Dioscuri.sealAuthority)
                readout("Z22 certification", "candidate preserved / verdict pending")

                Divider()

                sectionTitle("Z22 CONSTRUCTION SUBSTRATE")
                readout("role", "historical construction specimen / audit evidence")
                readout("status", "preserved / not the final OrboSpine support law")
                readout("span", "Z22 Pluto Zeitgeist")
                readout("start", MundaneTimespineP22.startUTC)
                readout("end exclusive", MundaneTimespineP22.endUTC)
                readout("bodies", "\(MundaneTimespineP22.profiles.count)")
                readout("body records", "\(MundaneTimespineP22.totalConstructionRecords)")
                readout("stations", "\(MundaneTimespineP22ForgeRecipe.canonicalStationCount)")
                readout("retro passages", "\(MundaneTimespineP22ForgeRecipe.canonicalRetrogradePassageCount)")
                readout("relationships", "\(MundaneTimespineP22CanonicalInputs.expectedRelationshipRows)")
                readout("eclipses", "\(MundaneTimespineP22CanonicalInputs.expectedEclipseRows)")
                readout("civic offset", "\(MundaneTimespineP22.civicOffsetBitsRequired) bits from Z22 start")
                readout("civic authority", "integer seconds / \(MundaneTimespineP22CivicSerialization.auditLaw)")
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

                sectionTitle("Z22 UNIVERSAL CELESTIAL EVENTS")
                readout("law", MundaneTimespineP22.universalEventsAreCelestialTimeFirst ? "celestial-time-first" : "INVALID")
                readout("eclipses", "\(eclipseContract.constructionRecordCount)")
                readout("exact major", "\(majorRelationshipContract.constructionRecordCount)")
                readout("exact minor", "\(minorRelationshipContract.constructionRecordCount)")
                readout("relationships total", "\(majorRelationshipContract.constructionRecordCount + minorRelationshipContract.constructionRecordCount)")
                readout("all events", "\(MundaneTimespineP22.totalUniversalEventRecords)")
                readout("Ring coverage", "\(admittedRingMarkCount) / \(RingMark.allCases.count) marks")
                readout("orb stored", "none / exact relationships only")
                readout("relationship UT", "canonical integer second / lexical JD quantization cell")
                readout("major gzip", byteCount(majorRelationshipContract.compressedBytes))
                readout("minor gzip", byteCount(minorRelationshipContract.compressedBytes))
                readout("eclipse gzip", byteCount(eclipseContract.compressedBytes))

                Divider()

                sectionTitle("Z22 STORAGE / READER")
                readout("scope", "Z22 storage architecture / not final Pass D image")
                readout("artifact family", MundaneTimespineStorageFormat.identifier)
                readout("storage version", "\(MundaneTimespineStorageFormat.version)")
                readout("legacy readable", "ORBOTS01 / v\(MundaneTimespineStorageFormat.legacyVersion)")
                readout("storage law", MundaneTimespineStorageFormat.celestialTimeFirst ? "celestial-time-first" : "INVALID")
                readout("exact degrees", "integer microdegrees")
                readout("runtime reader", "native / ephemeris-free")
                readout("UT -> celestial", "implemented")
                readout("celestial -> UT", "implemented")
                readout("relationships", "implemented / read-time filters")
                readout("eclipses", "implemented / read-time filters")
                readout("event union", "implemented")
                readout("shipping Z22", "not installed")
                readout("OrboSpine runtime", "Pass D / not begun")
                readout("proof authority", "OrboCoreTests")

                Divider()

                Text("Diagnostic readout of live OrboCore. Manufactured OrboSpine matter remains absent until Pass C. Tests remain the proof authority.")
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
